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
    for act in json_config["actions"]:
        yaml_act = loaded_yaml["actions"][act]
        # load in type, subtype, and message variants
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
                converted_eff["type"] = "oneof"
                valid = {
                    "name": "valid",
                    "updates": {
                        yaml_act["effects"][effect]["entity"]: {
                            "variable": yaml_act['effects'][effect]['entity'],
                            "value": f"${yaml_act['effects'][effect]['entity']}",
                            "certainty": "Known",
                        }
                    },
                    "intent": yaml_act["effects"][effect]["valid-intent"],
                }
                if "valid-follow-up" in yaml_act["effects"][effect]:
                    valid["follow_up"] = yaml_act["effects"][effect]["valid-follow-up"]
                unclear = {
                    "name": "unclear",
                    "updates": {
                        yaml_act["effects"][effect]['entity']: {
                            "variable": yaml_act['effects'][effect]['entity'],
                            "value": f"${yaml_act['effects'][effect]['entity']}",
                            "certainty": "Uncertain",
                            "follow_up": f"clarify__{act}",
                        }
                    }
                }
                if "unclear-intent" in effect:
                    unclear["unclear-intent"] = yaml_act["effects"][effect]["unclear-intent"]
                converted_eff["outcomes"] = [valid, unclear]
            json_config["actions"][act]["effect"] = {"validate-response": converted_eff}
    return json_config


if __name__ == "__main__":
    print(json.dumps(parse_to_json_config("yaml_samples/order_pizza.yaml"), indent=4))
