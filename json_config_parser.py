import yaml
import json

def parse_to_json_config(filename: str):
    loaded_yaml = yaml.load(open(filename, "r"), Loader=yaml.FullLoader)

    json_config = {}
    json_config["name"] = loaded_yaml["name"]
    # convert context variables
    json_config["context-variables"] = {var: {} for var in loaded_yaml["context-variables"]}
    for ctx_var, cfg in  loaded_yaml["context-variables"].items():
        json_config["context-variables"][ctx_var]["type"] = cfg["type"]
        # do variations need to be given to hovor?
        if cfg["type"] == "enum":
            json_config["context-variables"][ctx_var]["config"] = list(cfg["options"].keys())
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
            for utterance in intent["examples"]:
                split = utterance.split("$")
                json_config["intents"][intent_name]["utterances"].append(f"{split[0]}${split[1]}{split[2]}")
        else:
            json_config["intents"][intent_name]["utterances"] = intent["examples"]
    return json_config


if __name__ == "__main__":
    print(json.dumps(parse_to_json_config("yaml_samples/order_pizza.yaml"), indent=4))
