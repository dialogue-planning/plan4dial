from lib2to3.pytree import convert
import yaml
import json


def parse_to_json_config(filename: str):
    loaded_yaml = yaml.load(open(filename, "r"), Loader=yaml.FullLoader)
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
                if yaml_act["condition"][cond]["known"]:
                    json_config_cond.append([cond, "Known"])
                elif not yaml_act["condition"][cond]["known"]:
                    json_config_cond.append([cond, "Unknown"])
                else:
                    json_config_cond.append([cond, "Uncertain"])
            # how to handle or/not clauses?
            else:
                pass
            json_config["actions"][act]["condition"] = json_config_cond
        # convert effects
        for effect in yaml_act["effects"]:
            converted_eff = {}
            # create from template effects
            if effect == "validate-response":
                converted_eff["global-outcome-name"] = "validate-response"
                converted_eff["type"] = "oneof"
                valid = {
                    "name": "valid",
                    "updates": {
                        yaml_act["effects"][effect]["entity"]: {
                            "variable": yaml_act["effects"][effect]["entity"],
                            "value": f"${yaml_act['effects'][effect]['entity']}",
                            "certainty": "Known",
                        }
                    },
                    "intent": yaml_act["effects"][effect]["valid-intent"],
                }
                valid["follow_up"] = (
                    yaml_act["effects"][effect]["valid-follow-up"]
                    if "valid-follow-up" in yaml_act["effects"][effect]
                    else None
                )

                unclear = {
                    "name": "unclear",
                    "updates": {
                        yaml_act["effects"][effect]["entity"]: {
                            "variable": yaml_act["effects"][effect]["entity"],
                            "value": f"${yaml_act['effects'][effect]['entity']}",
                            "certainty": "Uncertain",
                        }
                    },
                }
                unclear["intent"] = (
                    yaml_act["effects"][effect]["unclear-intent"]
                    if "unclear-intent" in effect
                    else None
                )
                unclear["follow_up"] = f"clarify__{act}"
                converted_eff["outcomes"] = [valid, unclear]
            elif effect == "yes-no":
                converted_eff["global-outcome-name"] = "yes-no"
                converted_eff["type"] = "oneof"
                confirm = {
                    "name": "confirm",
                    "updates": {
                        yaml_act["effects"][effect]["entity"]: {
                            "variable": yaml_act["effects"][effect]["entity"],
                            "value": f"${yaml_act['effects'][effect]['entity']}",
                            "certainty": "Known",
                        }
                    },
                    "intent": "confirm",
                }
                deny = {
                    "name": "deny",
                    "updates": {
                        yaml_act["effects"][effect]["entity"]: {
                            "variable": yaml_act["effects"][effect]["entity"],
                            "value": None,
                            "certainty": "Unknown",
                        }
                    },
                    "intent": "deny",
                }
                converted_eff["outcomes"] = [confirm, deny]
            else:
                for option in yaml_act["effects"][effect]:
                    converted_eff["global-outcome-name"] = effect
                    converted_eff["type"] = option
                    outcomes = yaml_act["effects"][effect][option]["outcomes"]
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
                                    if status:
                                        status = "Known"
                                    elif not status:
                                        status = "Unknown"
                                    elif status == "maybe":
                                        status = "Uncertain"
                                    collect_updates[update]["certainty"] = status
                            next_outcome["updates"] = collect_updates
                        next_outcome["intent"] = (
                            out_config["intent"] if "intent" in out_config else None
                        )
                        next_outcome["follow_up"] = (
                            out_config["follow_up"]
                            if "follow_up" in out_config
                            else None
                        )
                        if "status" in out_config:
                            next_outcome["status"] = out_config["status"]
                        if "response" in out_config:
                            next_outcome["response"] = out_config["response"]
                        if "call" in out_config:
                            next_outcome["call"] = out_config["call"]
                        outcomes_list.append(next_outcome)
                    converted_eff["outcomes"] = outcomes_list
            json_config["actions"][act]["effect"] = converted_eff
        if "clarify" in yaml_act:
            clarify_act = {}
            entity = yaml_act["clarify"]["entity"]
            clarify_act["name"] = f"clarify__{act}"
            clarify_act["type"] = yaml_act["type"]
            clarify_act["subtype"] = yaml_act["subtype"]
            clarify_act["message_variants"] = yaml_act["clarify"]["message_variants"]
            clarify_act["condition"] = [[entity, "Uncertain"]]
            clarify_act["effect"] = {
                "type": "oneof",
                "global-outcome-name": "yes-no",
                "outcomes": [
                    {
                        "name": "confirm",
                        "updates": {
                            entity: {
                                "variable": entity,
                                "value": f"${entity}",
                                "certainty": True,
                            }
                        },
                        "intent": "confirm",
                    },
                    {
                        "name": "deny",
                        "updates": {entity: {"value": None, "certainty": False}},
                        "intent": "deny",
                    },
                ],
            }
        json_config["actions"][f"clarify__{act}"] = clarify_act
    return json_config


if __name__ == "__main__":
    print(json.dumps(parse_to_json_config("yaml_samples/order_pizza.yaml"), indent=4))
