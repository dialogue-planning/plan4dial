import yaml
import json
from typing import Dict
from pathlib import Path
from preprocessing import preprocess_yaml


def parse_to_json_config(loaded_yaml: Dict):
    json_config = {}
    json_config["name"] = loaded_yaml["name"]
    # convert context variables
    json_config["context-variables"] = {
        var: {} for var in loaded_yaml["context-variables"]
    }
    for ctx_var, cfg in loaded_yaml["context-variables"].items():
        json_config["context-variables"][ctx_var]["type"] = cfg["type"]
        # do variations need to be given to hovor?
        if cfg["type"] == "enum":
            json_config["context-variables"][ctx_var]["config"] = list(
                cfg["options"].keys()
            )
        elif cfg["type"] == "flag" or cfg["type"] == "fflag":
            json_config["context-variables"][ctx_var]["config"] = cfg["initially"]
        else:
            json_config["context-variables"][ctx_var]["config"] = "null"
        # do confirm/confirmation_utterance need to be given to hovor?
    json_config["intents"] = {var["intent"]: {} for var in loaded_yaml["nlu"]}
    # convert intents
    for intent in loaded_yaml["nlu"]:
        intent_name = intent["intent"]
        json_config["intents"][intent_name] = {}
        json_config["intents"][intent_name]["utterances"] = []
        json_config["intents"][intent_name]["variables"] = []
        if "variables" in intent:
            # assume for now that we only have one entity in a sentence
            var = intent["variables"][0]
            json_config["intents"][intent_name]["variables"].append("$" + var)
        json_config["intents"][intent_name]["utterances"] = intent["examples"]
    # convert actions
    json_config["actions"] = {act: {} for act in loaded_yaml["actions"]}
    for act in loaded_yaml["actions"]:
        yaml_act = loaded_yaml["actions"][act]
        # load in name, type, subtype, and message variants
        json_config["actions"][act]["name"] = act
        json_config["actions"][act]["type"] = yaml_act["type"]
        if "subtype" in yaml_act:
            json_config["actions"][act]["subtype"] = yaml_act["subtype"]
        if "message_variants" in yaml_act:
            json_config["actions"][act]["message_variants"] = yaml_act[
                "message_variants"
            ]
        # convert preconditions
        json_config_cond = []
        for cond in yaml_act["condition"]:
            if cond not in ["or", "not"]:
                if "known" in cond:
                    json_config_cond.append(([cond, "Known"] if yaml_act["condition"][cond]["known"] else [cond, "Unknown"]) if type(yaml_act["condition"][cond]["known"]) == bool else [cond, "Uncertain"])
            # how to handle or/not clauses?
            else:
                pass
            json_config["actions"][act]["condition"] = json_config_cond
        # convert effects
        for eff, eff_config in yaml_act["effects"].items():
            converted_eff = {}
            for option in eff_config:
                converted_eff["global-outcome-name"] = eff
                converted_eff["type"] = option
                outcomes = eff_config[option]["outcomes"]
                outcomes_list = []
                for out, out_config in outcomes.items():
                    next_outcome = {}
                    next_outcome["name"] = out
                    updates = (
                        out_config["updates"] if "updates" in out_config else None
                    )
                    if updates:
                        collect_updates = {}
                        for update, update_config in updates.items():
                            collect_updates[update] = {
                                "variable": update,
                                # if the value isn't supplied then the user is likely just setting "known" to False
                                "value": update_config["value"]
                                if "value" in update_config
                                else None,
                            }
                            if (
                                update_config["known"]
                                if "known" in update_config
                                else None != None
                            ):
                                known = update_config["known"]
                                status = ("Known" if known else "Unknown") if type(known) == bool else "Uncertain"
                                collect_updates[update]["certainty"] = status
                        next_outcome["updates"] = collect_updates
                    if "intent" in out_config:
                        next_outcome["intent"] = out_config["intent"]
                    if "follow_up" in out_config:
                        next_outcome["follow_up"] = out_config["follow_up"]
                    if "status" in out_config:
                        next_outcome["status"] = out_config["status"]
                    if "response" in out_config:
                        next_outcome["response"] = out_config["response"]
                    if "call" in out_config:
                        next_outcome["call"] = out_config["call"]
                    outcomes_list.append(next_outcome)
                converted_eff["outcomes"] = outcomes_list
            json_config["actions"][act]["effect"] = converted_eff
    return json_config


if __name__ == "__main__":
    base = Path(__file__).parent.parent
    f = str((base / "yaml_samples/order_pizza.yaml").resolve())
    json_file = open("pizza.json", "w")
    json_file.write(json.dumps(parse_to_json_config(preprocess_yaml(f)), indent=4))
