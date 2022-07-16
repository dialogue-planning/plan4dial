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
        "effect": {
            "reset": {
                "oneof": {
                    "outcomes": {
                        "lock": {
                            "updates": {
                                "have-message": {
                                    "value": False,
                                },
                                "force-statement": {
                                    "value": False,
                                },
                            },
                            "intent": "fallback",
                        }
                    }
                }
            }
        },
        "message_variants": [],
    }

def fallback_setup(loaded_yaml):
    # set up the action, intent, and fluents needed for default fallback
    loaded_yaml["intents"]["fallback"] = {"utterances": [], "variables": []}
    loaded_yaml["actions"]["dialogue_statement"] = configure_dialogue_statement()
    loaded_yaml["context-variables"]["have-message"] = {
        "type": "flag",
        "initially": False,
    }
    loaded_yaml["context-variables"]["force-statement"] = {
        "type": "flag",
        "initially": False,
    }

def instantiate_clarification_actions(loaded_yaml):
    processed_actions = deepcopy(loaded_yaml["actions"])
    # instantiate clarification actions  
    for act, act_config in loaded_yaml["actions"].items():
        if "clarify" in act_config:
            clarify = {}
            entities = act_config["clarify"]["entities"]
            # if only 1 entity is provided
            if type(entities) != list:
                entities = [entities]
            clarify["type"], clarify["subtype"] = (
                act_config["type"],
                act_config["subtype"],
            )
            clarify["message_variants"] = act_config["clarify"]["message_variants"]
            clarify["condition"] = {entity: {"known": "maybe"} for entity in entities}
            clarify["effect"] = {
                "validate-clarification": {
                    "oneof": {
                        "outcomes": {
                            "confirm": {
                                "updates": {
                                    entity: {
                                        "value": f"${entity}",
                                        "known": True,
                                    }
                                    for entity in entities
                                },
                                "intent": "confirm",
                            },
                            "deny": {
                                "updates": {
                                    entity: {
                                        "value": None,
                                        "known": False,
                                    }
                                    for entity in entities
                                },
                                "intent": "deny",
                            },
                        }
                    }
                }
            }
            processed_actions[f"clarify__{act}"] = clarify
            del processed_actions[act]["clarify"]
    loaded_yaml["actions"] = processed_actions

def instantiate_effects(loaded_yaml):
    processed = deepcopy(loaded_yaml["actions"])
    # for all actions, instantiate template effect and add fallbacks if necessary
    for act, act_config in loaded_yaml["actions"].items():
        fallback = False
        if act != "dialogue_statement":
            processed[act]["condition"]["force-statement"] = {"value": False}
            fallback = (
                act_config["disable-fallback"] if "disable-fallback" in act_config else True
            )
            if fallback:
                if "fallback_message_variants" not in act_config:
                    processed[act]["fallback_message_variants"] = [
                        "Sorry, I couldn't understand that input.",
                        "I couldn't quite get that.",
                    ]
        for eff, eff_config in loaded_yaml["actions"][act]["effect"].items():
            if eff in loaded_yaml["template-effects"]:
                # for ease in parsing
                eff_config = {f"({key})": val for key, val in eff_config.items()}
                template_eff = deepcopy(loaded_yaml["template-effects"][eff])
                del template_eff["parameters"]
                for option in template_eff:
                    outcomes = template_eff[option]["outcomes"]
                    instantiated_outcomes = {}
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
                                            check_val, f"${eff_config[check_val]}"
                                        )
                            instantiated_outcomes[out] = {
                                "updates": new_updates
                            }
                        if "(valid-intent)" in eff_config:
                            instantiated_outcomes[out][
                                "intent"
                            ] = eff_config["(valid-intent)"]
                        if "(follow_up)" in eff_config:
                            instantiated_outcomes[out][
                                "follow_up"
                            ] = eff_config["(follow_up)"]
                    if fallback:
                        instantiated_outcomes["fallback"] = configure_fallback()   
                    processed[act]["effect"][eff] = {option: {"outcomes": instantiated_outcomes}}    
            else:
                for option in eff_config:
                    if fallback:
                        processed[act]["effect"][eff][option]["outcomes"]["fallback"] = configure_fallback()
    loaded_yaml["actions"] = processed

def convert_ctx_var(loaded_yaml):
    processed = deepcopy(loaded_yaml["context-variables"])
    # convert context variables
    processed = {
        var: {} for var in loaded_yaml["context-variables"]
    }
    for ctx_var, cfg in loaded_yaml["context-variables"].items():
        json_ctx_var = {}
        json_ctx_var["type"] = cfg["type"]
        if cfg["type"] == "enum":
            json_ctx_var["config"] = list(cfg["options"].keys())
        elif cfg["type"] == "flag" or cfg["type"] == "fflag":
            json_ctx_var["config"] = cfg["initially"]
        else:
            if "extraction" in cfg:
                json_ctx_var["config"] = {"extraction": cfg["extraction"]}
                if "method" in cfg:
                    json_ctx_var["config"]["method"] = cfg["method"]
                elif "pattern" in cfg:
                    json_ctx_var["config"]["pattern"] = cfg["pattern"]
            else:
                json_ctx_var["config"] = "null"
        if "known" in cfg:
            json_ctx_var["known"] = cfg["known"]
        processed[ctx_var] = json_ctx_var
    loaded_yaml["context-variables"] = processed

def convert_intents(loaded_yaml):
    processed = deepcopy(loaded_yaml["intents"])
    # convert intents
    for intent, intent_cfg in loaded_yaml["intents"].items():
        cur_intent = {}
        cur_intent["variables"] = []
        if "variables" in intent_cfg:
            cur_intent["variables"].extend(
                [f"${var}" for var in intent_cfg["variables"]]
            )
        cur_intent["utterances"] = intent_cfg["utterances"]
        processed[intent] = cur_intent
    loaded_yaml["intents"] = processed

def convert_actions(loaded_yaml):
    processed = deepcopy(loaded_yaml["actions"])
    for act in loaded_yaml["actions"]:
        # convert preconditions
        json_config_cond = []
        for cond, cond_cfg in loaded_yaml["actions"][act]["condition"].items():
            for cond_config_key, cond_config_val in cond_cfg.items():
                if cond_config_key == "known":
                    json_config_cond.append(
                        ([cond, "Known"] if cond_config_val else [cond, "Unknown"])
                        if type(cond_config_val) == bool
                        else [cond, "Uncertain"]
                    )
                elif cond_config_key == "value":
                    json_config_cond.append([cond, cond_config_val])
        processed[act]["condition"] = json_config_cond
        for eff, eff_config in loaded_yaml["actions"][act]["effect"].items():
            converted_eff = deepcopy(eff_config)
            converted_eff["global-outcome-name"] = eff
            intents = []
            for option in eff_config:
                converted_eff["type"] = option
                outcomes = eff_config[option]["outcomes"]
                outcomes_list = []
                for out, out_config in outcomes.items():
                    next_outcome = deepcopy(out_config)
                    next_outcome["name"] = f"{act}_DETDUP_{eff}-EQ-{out}"
                    if "intent" in out_config:
                        intents.append(out_config["intent"])
                    next_outcome[
                        "assignments"
                    ] = {}
                    if "updates" in out_config:
                        for update_var, update_cfg in out_config["updates"].items():
                            if "known" in update_cfg:
                                known = update_cfg["known"]
                                next_outcome["assignments"][f"${update_var}"] = (
                                    ("found" if known else "didnt-find")
                                    if type(known) == bool
                                    else "maybe-found"
                                )
                                next_outcome["updates"][update_var]["certainty"] = (("Known" if known else "Unknown")
                                    if type(known) == bool
                                    else "Uncertain")
                            if "can-do" in update_cfg:
                                next_outcome["updates"][f"can-do_{update_var}"] = {
                                    "value": update_cfg["can-do"],
                                    "interpretation": "json",
                                }
                                del next_outcome["updates"][update_var]
                            else:
                                next_outcome["updates"][update_var]["interpretation"] = (
                                    "json"
                                    if update_cfg["value"] in [True, False, None]
                                    else "spel"
                                )
                    outcomes_list.append(next_outcome)
                converted_eff["outcomes"] = outcomes_list
                del converted_eff[option]
                processed[act]["effect"] = converted_eff
        if intents:
            processed[act]["intents"] = {
                intent: loaded_yaml["intents"][intent] for intent in intents
            }
    loaded_yaml["actions"] = processed

def convert_yaml(filename: str):
    loaded_yaml = yaml.load(open(filename, "r"), Loader=yaml.FullLoader)
    fallback_setup(loaded_yaml)
    instantiate_clarification_actions(loaded_yaml)
    instantiate_effects(loaded_yaml)
    convert_ctx_var(loaded_yaml)
    convert_intents(loaded_yaml)
    convert_actions(loaded_yaml)
    del loaded_yaml["template-effects"]
    return loaded_yaml


if __name__ == "__main__":
    base = Path(__file__).parent.parent
    f = str((base / "yaml_samples/test.yaml").resolve())
    json_file = open("pizza.json", "w")
    json_file.write(json.dumps(convert_yaml(f), indent=4))
