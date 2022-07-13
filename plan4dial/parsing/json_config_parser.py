import json
from typing import Dict
from pathlib import Path
from preprocessing import preprocess_yaml


def parse_to_json_config(loaded_yaml: Dict):
    json_config = {}
    json_config["name"] = loaded_yaml["name"]
    if "responses" in loaded_yaml:
        json_config["responses"] = loaded_yaml["responses"]
    # convert context variables
    json_config["context-variables"] = {
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
        json_config["context-variables"][ctx_var] = json_ctx_var
        # do confirm/confirmation_utterance need to be given to hovor?
    json_config["intents"] = {var: {} for var in loaded_yaml["intents"]}
    # convert intents
    for intent, intent_cfg in loaded_yaml["intents"].items():
        cur_intent = {}
        cur_intent["variables"] = []
        if "variables" in intent_cfg:
            cur_intent["variables"].extend(
                [f"${var}" for var in intent_cfg["variables"]]
            )
        cur_intent["utterances"] = intent_cfg["utterances"]
        json_config["intents"][intent] = cur_intent
    # convert actions
    json_config["actions"] = {act: {} for act in loaded_yaml["actions"]}
    for act in loaded_yaml["actions"]:
        yaml_act = loaded_yaml["actions"][act]
        cur_json_act = {}
        # load in name, type, subtype, and message variants
        cur_json_act["name"] = act
        cur_json_act["type"] = yaml_act["type"]
        if "subtype" in yaml_act:
            cur_json_act["subtype"] = yaml_act["subtype"]
        if "message_variants" in yaml_act:
            cur_json_act["message_variants"] = yaml_act["message_variants"]
        # convert preconditions
        json_config_cond = []
        for cond, cond_cfg in yaml_act["condition"].items():
            for cond_config_key, cond_config_val in cond_cfg.items():
                if cond_config_key == "known":
                    json_config_cond.append(
                        ([cond, "Known"] if cond_config_val else [cond, "Unknown"])
                        if type(cond_config_val) == bool
                        else [cond, "Uncertain"]
                    )
                elif cond_config_key == "value":
                    json_config_cond.append([cond, cond_config_val])
        cur_json_act["condition"] = json_config_cond

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
                    next_outcome["name"] = f"{act}_DETDUP_{eff}-EQ-{out}"
                    updates = out_config["updates"] if "updates" in out_config else None
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
                            if "known" in update_config:
                                known = update_config["known"]
                                status = (
                                    ("Known" if known else "Unknown")
                                    if type(known) == bool
                                    else "Uncertain"
                                )
                                collect_updates[update]["certainty"] = status
                            collect_updates[update]["interpretation"] = update_config[
                                "interpretation"
                            ]
                        next_outcome["updates"] = collect_updates
                    next_outcome["assignments"] = out_config["assignments"]
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
            cur_json_act["effect"] = converted_eff
        if "intents" in yaml_act:
            cur_json_act["intents"] = yaml_act["intents"]
        if "call" in yaml_act:
            cur_json_act["call"] = yaml_act["call"]
        json_config["actions"][act] = cur_json_act
    return json_config


if __name__ == "__main__":
    base = Path(__file__).parent.parent
    f = str((base / "yaml_samples/test.yaml").resolve())
    json_file = open("pizza.json", "w")
    json_file.write(json.dumps(parse_to_json_config(preprocess_yaml(f)), indent=4))
