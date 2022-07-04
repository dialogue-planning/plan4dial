from pathlib import Path
import yaml
from typing import Dict
from itertools import product
import re


def create_intent_example(
    intent_cfg: Dict, extracted_value: str, entity: str, true_value=None
):
    if not true_value:
        true_value = extracted_value
    base = {}
    if type(intent_cfg["variables"]) == dict:
        if (
            "roles" in intent_cfg["variables"][entity]
            and "groups" not in intent_cfg["variables"][entity]
        ):
            for role in intent_cfg["variables"][entity]["roles"]:
                base[
                    f"{entity}(role={role})"
                ] = f'[{extracted_value}]{{"entity": "{entity}", "role": "{role}", "value": "{true_value}"}}'
        elif (
            "groups" in intent_cfg["variables"][entity]
            and "roles" not in intent_cfg["variables"][entity]
        ):
            for group in intent_cfg["variables"][entity]["groups"]:
                base[
                    f"{entity}(group={group})"
                ] = f'[{extracted_value}]{{"entity": "{entity}", "group": "{group}", "value": "{true_value}"}}'
        elif (
            "roles" in intent_cfg["variables"][entity]
            and "groups" in intent_cfg["variables"][entity]
        ):
            prod = product(
                intent_cfg["variables"][entity]["roles"],
                intent_cfg["variables"][entity]["groups"],
            )
            for p in prod:
                role, group = p[0], p[1]
                base[
                    f"{entity}(role={role}, group={group})"
                ] = f'[{extracted_value}]{{"entity": "{entity}", "role": "{role}", "group": "{group}", "value": "{true_value}"}}'
    else:
        base[
            entity
        ] = f'[{extracted_value}]{{"entity": "{entity}", "value": "{true_value}"}}'
    return base


def make_nlu_file(loaded_yaml: Dict):
    intents = loaded_yaml["intents"]
    nlu = {"nlu": []}
    for intent, intent_cfg in intents.items():
        entities = {}
        if "variables" in intent_cfg:
            variables = (
                list(intent_cfg["variables"].keys())
                if type(intent_cfg["variables"]) == dict
                else intent_cfg["variables"]
            )
            for variable in variables:
                ctx_var = loaded_yaml["context-variables"][variable]
                if "examples" in ctx_var:
                    for ex in ctx_var["examples"]:
                        for key, val in create_intent_example(
                            intent_cfg, extracted_value=ex, entity=variable
                        ).items():
                            if key not in entities:
                                entities[key] = [val]
                            else:
                                entities[key].append(val)
                if "options" in ctx_var:
                    for option in ctx_var["options"]:
                        for key, val in create_intent_example(
                            intent_cfg, extracted_value=option, entity=variable
                        ).items():
                            if key not in entities:
                                entities[key] = [val]
                            else:
                                entities[key].append(val)
                    for option, option_var in ctx_var["options"].items():
                        for v in option_var["variations"]:
                            for key, val in create_intent_example(
                                intent_cfg,
                                extracted_value=v,
                                entity=variable,
                                true_value=option,
                            ).items():
                                if key not in entities:
                                    entities[key] = [val]
                                else:
                                    entities[key].append(val)
                elif "extraction" in ctx_var:
                    if ctx_var["extraction"] == "regex":
                        nlu["nlu"].append(
                            {"regex": variable, "examples": "- " + ctx_var["pattern"]}
                        )

            new_utterances = []
            for utterance in intent_cfg["utterances"]:
                utterance_variations = []
                entity_occurrences = re.findall(rf"\$({variable}.*?)\$", utterance)
                for occ in entity_occurrences:
                    if not utterance_variations:
                        utterance_variations.extend(
                            utterance.replace(f"${occ}$", variation)
                            for variation in entities[occ]
                        )
                    else:
                        utterance_variations = [
                            u.replace(f"${occ}$", variation)
                            for u in utterance_variations
                            for variation in entities[occ]
                        ]
                new_utterances.extend(u for u in utterance_variations)
            nlu["nlu"].append(
                {"intent": intent, "examples": "- " + "\n- ".join(new_utterances)}
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
        open(str((base / "yaml_samples/order_pizza.yaml").resolve())),
        Loader=yaml.FullLoader,
    )
    f = open(str((base / "parsing/nlu.yml").resolve()), "w")
    f = yaml.dump(make_nlu_file(loaded_yaml), f)
