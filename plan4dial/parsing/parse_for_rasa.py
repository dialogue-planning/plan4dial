from pathlib import Path
import yaml
from yaml.representer import SafeRepresenter
from json_config_parser import parse_to_json_config
from preprocessing import preprocess_yaml
from typing import Dict
from itertools import product

class literal_str(str): pass

def change_style(style, representer):
    def new_representer(dumper, data):
        scalar = representer(dumper, data)
        scalar.style = style
        return scalar
    return new_representer

def make_nlu_file(loaded_yaml: Dict):
    represent_literal_str = change_style('|', SafeRepresenter.represent_str)
    yaml.add_representer(literal_str, represent_literal_str)
    intents = loaded_yaml["intents"]
    nlu = {"nlu": []}
    for intent, intent_cfg in intents.items():
        examples = []
        variations = {}
        if "variables" in intent_cfg:
            variables = intent_cfg["variables"]
            for variable in variables:
                ctx_var = loaded_yaml["context-variables"][variable]
                variations[variable] = ctx_var["examples"] if "examples" in ctx_var else []
                if "options" in ctx_var:
                    variations[variable].extend(ctx_var["options"].keys())
                    variations[variable].extend(v for option in ctx_var["options"].values() for v in option["variations"])
                elif "extraction" in ctx_var:
                    if ctx_var["extraction"] == "regex":
                        nlu["nlu"].append({"regex": variable, "examples": "- " + ctx_var["pattern"]})
            variations = [tup for tup in product(*variations.values())]
            for v in variations:
                print(v)
            for variation in variations:
                for utterance in intent_cfg["utterances"]:
                    for i in range(len(variables)):
                        utterance = utterance.replace(f"${variables[i]}", f"[{variation[i]}]({variables[i]})")
                    examples.append(utterance)
            nlu["nlu"].append({"intent": intent, "examples": "- " + "\n- ".join(examples)})
        else:
            nlu["nlu"].append({"intent": intent, "examples": "- " + "\n- ".join(intent_cfg["utterances"])})
    return nlu


if __name__ == "__main__":
    base = Path(__file__).parent.parent
    loaded_yaml = yaml.load(open(str((base / "yaml_samples/order_pizza.yaml").resolve())), Loader=yaml.FullLoader)
    f = open(str((base / "parsing/nlu.yml").resolve()), "w")
    f = yaml.dump(make_nlu_file(loaded_yaml), f)
