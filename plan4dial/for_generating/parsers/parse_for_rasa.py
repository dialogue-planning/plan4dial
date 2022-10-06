"""This module contains all the functions necessary to generate a NLU file that Rasa
can use to extract intents and entities.

NOTE: We use a bare-bones specification so we rely on Rasa as little as possible (no
roles, groups, stories, or anything too "Rasa-specific").

Authors:
* Rebecca De Venezia
"""

from itertools import product
from typing import Union, Dict


def _create_intent_example(
    extracted_value: str, entity: str, true_value: Union[str, None] = None
) -> str:
    """Create an intent example according to the Rasa NLU format. Also accounts for
    synonyms/variations if specified, while mapping back to the "true" value that we
    want to set to.

    Args:
        extracted_value (str): The value that was extracted.
        entity (str): The entity we are trying to extract.
        true_value (str or None): If we extracted a variation, this is the "true" value
            that we want to set the extraction to. Defaults to None, in which case we
            know that the true value was what was extracted.

    Returns:
        (str): The intent example.
    """
    if not true_value:
        true_value = extracted_value
    return f'[{extracted_value}]{{"entity": "{entity}", "value": "{true_value}"}}'


def make_nlu_file(loaded_yaml: Dict) -> Dict:
    """Generates the NLU configuration that Rasa requires to extract intents and
    entities.

    Args:
        loaded_yaml (Dict): The loaded YAML configuration.

    Returns:
        Dict: The NLU configuration for Rasa.
    """
    intents = loaded_yaml["intents"]
    nlu = {"nlu": []}
    # iterate through all intents
    for intent, intent_cfg in intents.items():
        examples = []
        variations = {}
        # if this intent has variables, iterate through them
        if "variables" in intent_cfg:
            variables = intent_cfg["variables"]
            # for each variable, access the context variable
            for variable in variables:
                ctx_var = loaded_yaml["context_variables"][variable]
                variations[variable] = []
                # create intent examples based on provided examples
                if "examples" in ctx_var:
                    for ex in ctx_var["examples"]:
                        variations[variable].append(
                            _create_intent_example(ex, variable)
                        )
                # create intent examples based on the options
                if "options" in ctx_var:
                    variations[variable] = [
                        _create_intent_example(option, variable)
                        for option in ctx_var["options"]
                    ]
                    # if the options have variations, make intent examples of the
                    # variations, using the original option as the true val
                    if type(ctx_var["options"]) == dict:
                        for option, option_var in ctx_var["options"].items():
                            variations[variable].extend(
                                _create_intent_example(v, variable, true_value=option)
                                for v in option_var["variations"]
                            )
                # add extraction pattern if necessary
                elif "extraction" in ctx_var:
                    if ctx_var["extraction"] == "regex":
                        nlu["nlu"].append(
                            {"regex": variable, "examples": "- " + ctx_var["pattern"]}
                        )
            # get the product of all the variations in this intent. this is so we can
            # generate examples of this intent with every combination of variations for
            # each entity.
            variations = [tup for tup in product(*variations.values())]
            for variation in variations:
                # for each utterance, iterate through all variables in the utterance.
                # replace each variable with the current variation on the intent
                # example.
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
