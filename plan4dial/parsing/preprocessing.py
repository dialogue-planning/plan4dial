import yaml
import json
from pathlib import Path
from copy import deepcopy


def preprocess_yaml(filename: str):
    loaded_yaml = yaml.load(open(filename, "r"), Loader=yaml.FullLoader)
    processed = deepcopy(loaded_yaml)
    for act, act_config in loaded_yaml["actions"].items():
        # convert effects
        for eff, eff_config in loaded_yaml["actions"][act]["effects"].items():
            # create from template effects
            if eff == "validate-response":
                new_eff = {
                    "valid": {
                        "updates": {
                            eff_config["entity"]: {
                                "value": f"${eff_config['entity']}",
                                "known": True,
                                "interpretation": "spel"
                            }
                        },
                        "assignments": {
                            f"${eff_config['entity']}": "found"
                        },
                        "intent": eff_config["valid-intent"],
                    },
                    "unclear": {
                        "updates": {
                            eff_config["entity"]: {
                                "value": f"${eff_config['entity']}",
                                "known": "maybe",
                                "interpretation": "spel"
                            }
                        },
                        "assignments": {
                            f"${eff_config['entity']}": "maybe-found"
                        },
                        "follow_up": {"clarify": f"clarify__{act}"},
                    },
                }
                act_intents = [eff_config["valid-intent"]]
                if "valid-follow-up" in eff_config:
                    new_eff["valid"]["follow_up"] = eff_config["valid-follow-up"]
                if "unclear-intent" in eff_config:
                    unclear = eff_config["unclear-intent"]
                    new_eff["unclear"]["intent"] = unclear
                    act_intents.append(unclear)
                new_eff = {"validate-response": {"oneof": {"outcomes": new_eff}}}
                processed["actions"][act]["effects"] = new_eff
                processed["actions"][act]["intents"] = {act_intent: processed["intents"][act_intent] for act_intent in act_intents}
            elif eff == "yes-no":
                new_eff = {
                    "confirm": {
                        "updates": {
                            eff_config["entity"]: {
                                "value": f"${eff_config['entity']}",
                                "known": True,
                                "interpretation": "spel"
                            }
                        },
                        "assignments": {
                            f"${eff_config['entity']}": "found"
                        },
                        "intent": "confirm",
                    },
                    "deny": {
                        "updates": {
                            eff_config["entity"]: {
                                "value": None,
                                "known": False,
                                "interpretation": "json"
                            }
                        },
                        "assignments": {
                            f"${eff_config['entity']}": "didnt-find"
                        },
                        "intent": "deny",
                    },
                }
                if "valid-follow-up" in eff_config:
                    new_eff["valid"]["follow_up"] = eff_config["valid-follow-up"]
                if "unclear-intent" in eff_config:
                    new_eff["unclear"]["intent"] = eff_config["unclear-intent"]
                new_eff = {"yes-no": {"oneof": {"outcomes": new_eff}}}
                processed["actions"][act]["effects"] = new_eff
                processed["actions"][act]["intents"] = {act_intent: processed["intents"][act_intent] for act_intent in ["confirm", "deny"]}
            # general preprocessing needed for all other actions
            else:
                intents = []
                for option in eff_config:
                    outcomes = eff_config[option]["outcomes"]
                    for out, out_config in outcomes.items():
                        if "intent" in out_config:
                            intents.append(out_config["intent"])
                        processed["actions"][act]["effects"][eff][option]["outcomes"][out]["assignments"] = {}
                        if "updates" in out_config:
                            for update_var, update_cfg in out_config["updates"].items():
                                if "known" in update_cfg:
                                    known = update_cfg["known"]
                                    processed["actions"][act]["effects"][eff][option]["outcomes"][out]["assignments"][f"${update_var}"] = ("found" if known else "didnt-find") if type(known) == bool else "maybe-found"
                                if "can-do" in update_cfg:
                                    processed["actions"][act]["effects"][eff][option]["outcomes"][out]["updates"][f"can-do_{update_var}"] = {
                                        "value": update_cfg["can-do"],
                                        "interpretation": "json"
                                    }
                                    del processed["actions"][act]["effects"][eff][option]["outcomes"][out]["updates"][update_var]
                                else:
                                    processed["actions"][act]["effects"][eff][option]["outcomes"][out]["updates"][update_var]["interpretation"] = "json" if update_cfg["value"] in [True, False, None] else "spel"
                if intents:
                    processed["actions"][act]["intents"] = {intent: processed["context-variables"][intent] for intent in intents}
        if "clarify" in act_config:
            clarify_act = {}
            entity = act_config["clarify"]["entity"]
            clarify_act["type"] = act_config["type"]
            clarify_act["subtype"] = act_config["subtype"]
            clarify_act["message_variants"] = act_config["clarify"]["message_variants"]
            clarify_act["condition"] = {entity: {"known": "maybe"}}
            clarify_act["effects"] = {
                "yes-no": {
                    "oneof": {
                        "outcomes": {
                            "confirm": {
                                "updates": {
                                    entity: {"value": f"${entity}", "known": True, "interpretation": "spel"}
                                },
                                "assignments": {
                                    f"${eff_config['entity']}": "found"
                                },
                                "intent": "confirm",
                            },
                            "deny": {
                                "updates": {entity: {"value": None, "known": False, "interpretation": "json"}},
                                "assignments": {
                                    f"${eff_config['entity']}": "didnt-find"
                                },
                                "intent": "deny",
                            },
                        }
                    }
                }
            }
            clarify_act["intents"] = {act_intent: processed["intents"][act_intent] for act_intent in ["confirm", "deny"]}
            del processed["actions"][act]["clarify"]
            processed["actions"][f"clarify__{act}"] = clarify_act
    return processed


if __name__ == "__main__":
    base = Path(__file__).parent.parent
    f = str((base / "yaml_samples/order_pizza.yaml").resolve())
    print(json.dumps(preprocess_yaml(f), indent=4))
