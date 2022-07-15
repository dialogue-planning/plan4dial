import yaml
import json
from pathlib import Path
from copy import deepcopy


def configure_fallback():
    return {
        "updates": {
            "have-message": {"value": True},
            "force-statement": {"value": True},
        },
        "intent": "fallback",
    }

def configure_dialogue_statement():
    return {
        "type": "dialogue",
        "condition": {
            "have-message": {"value": True},
            "force-statement": {"value": True},
        },
        "effects": {
            "reset": {
                "oneof": {
                    "outcomes": {
                        "lock": {
                            "updates": {
                                "have-message": {
                                    "value": False,
                                    "interpretation": "json",
                                },
                                "force-statement": {
                                    "value": False,
                                    "interpretation": "json",
                                },
                            },
                            "assignments": {},
                            "intent": "fallback",
                        }
                    }
                }
            }
        },
        "message_variants": [],
        "intents": {"fallback": {"utterances": [], "variables": []}},
    }

def instantiate_template_effect():
    pass

def preprocess_yaml(filename: str):
    loaded_yaml = yaml.load(open(filename, "r"), Loader=yaml.FullLoader)
    processed = deepcopy(loaded_yaml)
    # set up the action, intent, and fluents needed for default fallback
    processed["intents"]["fallback"] = {"utterances": [], "variables": []}
    processed["actions"]["dialogue_statement"] = configure_dialogue_statement()
    processed["context-variables"]["have-message"] = {
        "type": "flag",
        "initially": False,
    }
    processed["context-variables"]["force-statement"] = {
        "type": "flag",
        "initially": False,
    }

    for act, act_config in loaded_yaml["actions"].items():
        processed["actions"][act]["condition"]["force-statement"] = {"value": False}
        fallback = (
            act_config["disable-fallback"] if "disable-fallback" in act_config else True
        )
        if fallback:
            if "fallback_message_variants" not in act_config:
                processed["actions"][act]["fallback_message_variants"] = [
                    "Sorry, I couldn't understand that input.",
                    "I couldn't quite get that.",
                ]
        # preprocess effects
        for eff, eff_config in loaded_yaml["actions"][act]["effects"].items():
            # instantiate template effects if necessary
            if eff in loaded_yaml["effects"]:
                # for ease in parsing
                eff_config = {f"({key})": val for key, val in eff_config.items()}
                template_eff = loaded_yaml["effects"][eff]
                del template_eff["parameters"]
                instantiated_eff = {eff: {}}
                for option in template_eff:
                    instantiated_eff[eff][option] = {"outcomes": {}}
                    outcomes = template_eff[option]["outcomes"]
                    for out, out_config in outcomes.items():
                        updates = (
                            out_config["updates"] if "updates" in out_config else None
                        )
                        if updates:
                            new_updates = {}
                            for update, update_config in updates.items():
                                if update in eff_config:
                                    new_updates[eff_config[update]] = template_eff[
                                        option
                                    ]["outcomes"][out]["updates"][update]
                                    update = eff_config[update]
                                for key, val in update_config.items():
                                    check_val = (
                                        val[1:]
                                        if type(val) == str and val[0] == "$"
                                        else val
                                    )
                                    if check_val in eff_config:
                                        new_updates[update][key] = check_val.replace(
                                            check_val, eff_config[check_val]
                                        )
                            instantiated_eff[eff][option]["outcomes"][out] = {
                                "updates": new_updates
                            }
                        if "intent" in out_config:
                            instantiated_eff[eff][option]["outcomes"][out][
                                "intent"
                            ] = eff_config[out_config["intent"]]
                        if "follow_up" in out_config:
                            instantiated_eff[eff][option]["outcomes"][out][
                                "follow_up"
                            ] = eff_config[out_config["follow_up"]]
                    processed["actions"][act]["effects"][eff][option] = instantiated_eff
                    if fallback:
                        processed["actions"][act]["effects"][eff][option]["fallback"] = configure_fallback()
        # instantiate clarification actions
        if "clarify" in act_config:
            entities = act_config["clarify"]["entities"]
            clarify = {}
            clarify["type"], clarify["subtype"] = (
                act_config["type"],
                act_config["subtype"],
            )
            clarify["message_variants"] = act_config["clarify"]["message_variants"]
            clarify["condition"] = {entity: {"known": "maybe"} for entity in entities}
            clarify["effects"] = {
                "yes-no": {
                    "oneof": {
                        "outcomes": {
                            "confirm": {
                                "updates": {
                                    entity: {
                                        "value": f"${entity}",
                                        "known": True,
                                        "interpretation": "spel",
                                    }
                                    for entity in entities
                                },
                                "assignments": {
                                    f"${entity}": "found" for entity in entities
                                },
                                "intent": "confirm",
                            },
                            "deny": {
                                "updates": {
                                    entity: {
                                        "value": None,
                                        "known": False,
                                        "interpretation": "json",
                                    }
                                    for entity in entities
                                },
                                "assignments": {
                                    f"${entity}": "didnt-find" for entity in entities
                                },
                                "intent": "deny",
                            },
                            "fallback": {
                                "updates": {
                                    "have-message": {
                                        "value": True,
                                        "interpretation": "json",
                                    },
                                    "force-statement": {
                                        "value": True,
                                        "interpretation": "json",
                                    },
                                },
                                "assignments": {},
                                "intent": "fallback",
                            },
                        }
                    }
                }
            }
            clarify["intents"] = {
                act_intent: processed["intents"][act_intent]
                for act_intent in ["confirm", "deny"]
            }
            processed["actions"][f"clarify__{act}"] = clarify
            del processed["actions"][act]["clarify"]

            # general preprocessing needed for all actions
            intents = []
            for option in eff_config:
                outcomes = eff_config[option]["outcomes"]
                for out, out_config in outcomes.items():
                    if "intent" in out_config:
                        intents.append(out_config["intent"])
                    processed["actions"][act]["effects"][eff][option]["outcomes"][out][
                        "assignments"
                    ] = {}
                    if "updates" in out_config:
                        for update_var, update_cfg in out_config["updates"].items():
                            if "known" in update_cfg:
                                known = update_cfg["known"]
                                processed["actions"][act]["effects"][eff][option][
                                    "outcomes"
                                ][out]["assignments"][f"${update_var}"] = (
                                    ("found" if known else "didnt-find")
                                    if type(known) == bool
                                    else "maybe-found"
                                )
                            if "can-do" in update_cfg:
                                processed["actions"][act]["effects"][eff][option][
                                    "outcomes"
                                ][out]["updates"][f"can-do_{update_var}"] = {
                                    "value": update_cfg["can-do"],
                                    "interpretation": "json",
                                }
                                del processed["actions"][act]["effects"][eff][option][
                                    "outcomes"
                                ][out]["updates"][update_var]
                            else:
                                processed["actions"][act]["effects"][eff][option][
                                    "outcomes"
                                ][out]["updates"][update_var]["interpretation"] = (
                                    "json"
                                    if update_cfg["value"] in [True, False, None]
                                    else "spel"
                                )
            if intents:
                processed["actions"][act]["intents"] = {
                    intent: processed["intents"][intent] for intent in intents
                }

    return processed


if __name__ == "__main__":
    base = Path(__file__).parent.parent
    f = str((base / "yaml_samples/order_pizza.yaml").resolve())
    print(json.dumps(preprocess_yaml(f), indent=4))
