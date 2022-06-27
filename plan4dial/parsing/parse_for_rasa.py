from pathlib import Path
import yaml
from typing import Dict
from itertools import product


def create_intent_example(intent_cfg: Dict, extracted_value: str, entity: str, true_value=None):
    if not true_value:
        true_value = extracted_value
    next_var = []
    var_base = f'[{extracted_value}]{{"entity": "{entity}", '
    if type(intent_cfg["variables"]) == dict:
        if "groups" in intent_cfg["variables"][entity]:
            groups = [f'"group": "{group}", ' for group in intent_cfg["variables"][entity]["groups"]] 
            for group in groups:
                next_var.append(var_base + group)
        if "roles" in intent_cfg["variables"][entity]:
            roles = [f'"role": "{role}", ' for role in intent_cfg["variables"][entity]["roles"]]
            next_var_w_groups = []
            if next_var:
                for var in next_var:
                    for role in roles:
                        next_var_w_groups.append(var + role)
                next_var = next_var_w_groups
            else:                     
                for role in roles:
                    next_var.append(var_base + role)
    else:
        next_var = [var_base]
    return [var + f'"value": "{true_value}"}}' for var in next_var]

def make_nlu_file(loaded_yaml: Dict):
    intents = loaded_yaml["intents"]
    nlu = {"nlu": []}
    for intent, intent_cfg in intents.items():
        examples = []
        variations = {}
        if "variables" in intent_cfg:
            variables = list(intent_cfg["variables"].keys()) if type(intent_cfg["variables"]) == dict else intent_cfg["variables"]
            for variable in variables:
                ctx_var = loaded_yaml["context-variables"][variable]
                variations[variable] = []
                if "examples" in ctx_var:
                    for ex in ctx_var['examples']:
                        variations[variable].extend(ex for ex in create_intent_example(intent_cfg, ex, variable)) 
                if "options" in ctx_var:
                    variations[variable].extend(ex for option in ctx_var["options"] for ex in create_intent_example(intent_cfg, option, variable))
                    for option, option_var in ctx_var["options"].items():    
                        variations[variable].extend(ex for v in option_var["variations"] for ex in create_intent_example(intent_cfg, v, variable, true_value=option))
                elif "extraction" in ctx_var:
                    if ctx_var["extraction"] == "regex":
                        nlu["nlu"].append({"regex": variable, "examples": "- " + ctx_var["pattern"]})
            variations = [tup for tup in product(*variations.values())]
            for v in variations:
                print(v)
            for variation in variations:
                for utterance in intent_cfg["utterances"]:
                    for i in range(len(variables)):
                        utterance = utterance.replace(f"${variables[i]}", str(variation[i]))
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
