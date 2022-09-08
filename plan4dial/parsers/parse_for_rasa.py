from pathlib import Path
import yaml
from itertools import product


def create_intent_example(extracted_value: str, entity: str, true_value=None):
    if not true_value:
        true_value = extracted_value
    return f'[{extracted_value}]{{"entity": "{entity}", "value": "{true_value}"}}'


def make_nlu_file(filename: str):
    loaded_yaml = yaml.load(open(filename, "r"), Loader=yaml.FullLoader)
    intents = loaded_yaml["intents"]
    nlu = {"nlu": []}
    for intent, intent_cfg in intents.items():
        examples = []
        variations = {}
        if "variables" in intent_cfg:
            variables = intent_cfg["variables"]
            for variable in variables:
                ctx_var = loaded_yaml["context_variables"][variable]
                variations[variable] = []
                if "examples" in ctx_var:
                    for ex in ctx_var["examples"]:
                        variations[variable].append(create_intent_example(ex, variable))
                if "options" in ctx_var:
                    variations[variable] = [
                        create_intent_example(option, variable)
                        for option in ctx_var["options"]
                    ]
                    if type(ctx_var["options"]) == dict:
                        for option, option_var in ctx_var["options"].items():
                            variations[variable].extend(
                                create_intent_example(v, variable, true_value=option)
                                for v in option_var["variations"]
                            )
                elif "extraction" in ctx_var:
                    if ctx_var["extraction"] == "regex":
                        nlu["nlu"].append(
                            {"regex": variable, "examples": "- " + ctx_var["pattern"]}
                        )
            variations = [tup for tup in product(*variations.values())]
            for variation in variations:
                for utterance in intent_cfg["utterances"]:
                    for i in range(len(variables)):
                        utterance = utterance.replace(
                            f"${variables[i]}", str(variation[i])
                        )
                    examples.append(utterance)
            nlu["nlu"].append(
                {"intent": intent, "examples": "- " + "\n- ".join(examples)}
            )
        else:
            nlu["nlu"].append(
                {
                    "intent": intent,
                    "examples": "- " + "\n- ".join(intent_cfg["utterances"]),
                }
            )
    return nlu


if __name__ == "__main__":
    base = Path(__file__).parent.parent
    loaded_yaml = yaml.load(
        open(
            str((base / "yaml_samples/advanced_custom_actions_test_v3.yaml").resolve())
        ),
        Loader=yaml.FullLoader,
    )
    f = open(str((base / "parsing/nlu.yml").resolve()), "w")
    f = yaml.dump(make_nlu_file(loaded_yaml), f)
