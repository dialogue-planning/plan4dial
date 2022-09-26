"""This module contains all the base functions required to convert a YAML 
configuration to the JSON configuration required by Hovor.

Authors:
- Rebecca De Venezia
"""

from typing import Union, Dict
import yaml
from copy import deepcopy
from inspect import getmembers, isfunction
from nnf import Or, And, Var, config
from importlib import import_module


def _configure_force_message_true() -> Dict:
    """
    Returns:
    - (Dict): Configuration where `have-message` and `force-statement` are set to True.
    """
    return {
        "have-message": {"value": True},
        "force-statement": {"value": True},
    }


def _configure_fallback() -> Dict:
    """
    Returns:
    - (Dict): Update configuration for a fallback outcome.
    """
    return {"updates": _configure_force_message_true(), "intent": "fallback"}


def _configure_dialogue_statement() -> Dict:
    """Returns the base `dialogue_statement` action.

    Most often, the `dialogue_statement` action is triggered when a fallback
    occurs; in this case, `dialogue_statement` updates its
    `message_variants` to the appropriate `fallback_message_variants`.
    Dialogue statements are also used for responses, in which case
    `dialogue_statement` updates its `message_variants` to the appropriate
    `response_variants`.

    Note that the intent `utter_dialogue_statement` is a blank intent because
    `message` actions (`dialogue` type actions with a single outcome) do not
    take user input into account and simply execute the single outcome.

    Returns:
    - (Dict): The full configuration for the `dialogue_statement` action.
    """
    return {
        "type": "dialogue",
        "condition": _configure_force_message_true(),
        "effect": {
            "reset": {
                "oneof": {
                    "outcomes": {
                        "lock": {
                            "updates": {
                                "have-message": {
                                    "value": False,
                                },
                                "force-statement": {
                                    "value": False,
                                },
                            },
                            "intent": "utter_dialogue_statement",
                        }
                    }
                }
            }
        },
        "message_variants": [],
    }


def _configure_assignments(known: Union[bool, str]) -> str:
    """Converts the parameter `known` (which is either True, False, or "maybe")
    to the equivalent Hovor assignment ("found", "didnt-find", and
    "maybe-found" respectively). Used for outcomes.

    Args:
    - known (bool or str): The "known" status of a context variable in the YAML.

    Returns:
    - (str): The Hovor assignment equivalent to the "known" parameter provided.
    """
    return (
        ("found" if known else "didnt-find") if type(known) == bool else "maybe-found"
    )


def _configure_certainty(known: Union[bool, str]) -> str:
    """Converts the parameter `known` (which is either True, False, or "maybe")
    to the equivalent Hovor certainty ("Known", "Unknown", and
    "Uncertain" respectively). Used for preconditions.

    Args:
    - known (bool or str): The "known" status of a context variable in the YAML.

    Returns:
    - (str): The Hovor certainty equivalent to the "known" parameter provided.
    """
    return ("Known" if known else "Unknown") if type(known) == bool else "Uncertain"


@config(auto_simplify=True)
def _convert_to_formula(condition: Dict) -> Union[And, Or]:
    """Converts an action condition from the YAML to a list of terms for an
    NNF formula.

    Args:
    - condition (Dict): An action condition from the YAML.

    Returns:
    - formula_terms (Union[nnf.And, nnf.Or]): An NNF formula.

    TODO: Test extensively once arbitrary conversion to DNF becomes viable.
    """
    formula_terms = []
    # if we get passed a list, update formula_terms by the conversion of each
    # element in the list
    if type(condition) == list:
        formula_terms.extend(
            [
                formula
                for nesting in condition
                for formula in _convert_to_formula(nesting)
            ]
        )
    else:
        # otherwise, inspect the parameter further
        for connective, config in condition.items():
            # if the key is not "and" or "or", then we know we're dealing with
            # a context variable and value setting. represent these with Vars.
            # NOTE: we may want to store the Var to dict mappings so we can
            # reference them later when constructing new actions from the
            # formula terms.
            if connective not in ["and", "or"]:
                formula_terms.extend(
                    Var(f"({connective}-{base_key}-{base_value})")
                    for base_key, base_value in config.items()
                )
            else:
                # if we are dealing with an "and" or "or", nest the terms in
                # the respective connective.
                formula_terms.append(
                    And(_convert_to_formula(config))
                    if connective == "and"
                    else Or(_convert_to_formula(config))
                )
    return formula_terms


@config(auto_simplify=True)
def _convert_to_DNF(condition: Dict) -> And:
    """Converts an action condition from the YAML to an NNF formula in
    Disjunctive Normal Form. Eventually, this would be used for auto-
    generating equivalent actions based on arbritrary logical formulas.

    NOTE: Will not be in use until issue #4 is resolved.

    Args:
    - condition (Dict): An action condition from the YAML.

    Returns:
    - (nnf.And): The DNF formula that the action condition was converted to.
    """
    return (And(_convert_to_formula(condition)).negate()).to_CNF().negate()


def _configure_value_setter(loaded_yaml: Dict, ctx_var: str) -> None:
    """Configures the actions in loaded_yaml to allow for value setting. This
    allows values to be used in preconditions, i.e. cuisine: {value: "Mexican"}.

    This is done by creating flag context variables that represent the value
    of the context variable; i.e. "cuisine-value-Mexican". We need to create
    flag representations so that value knowledge is reflected in the PDDL and
    ultimately the generated tree/controller. This flag is what would be used
    as a precondition to check the value of the context variable.

    Obviously, the flag values can be set when the context variable becomes
    known, and reset when the context variable becomes unknown.

    Args:
    - loaded_yaml (Dict): The loaded YAML configuration.
    - ctx_var (str): The context variable referenced in value-dependent
        preconditions.
    """
    processed = deepcopy(loaded_yaml["actions"])
    ctx_var_cfg = loaded_yaml["context_variables"][ctx_var]
    # possible values the context variable can be set to
    var_options = (
        list(ctx_var_cfg["options"].keys())
        if type(ctx_var_cfg["options"]) == dict
        else ctx_var_cfg["options"]
    )
    # create flag context variables that represent the given ctx_var being set
    # to all possible values; initialize all as False
    for v in var_options:
        option_value_name = f"{ctx_var}-value-{v.replace(' ', '_')}"
        loaded_yaml["context_variables"][option_value_name] = {
            "type": "flag",
            "init": False,
        }
    # create a function that sets the relevant "value flag" context variables
    # to true if the given context variable is known using context dependent
    # determination
    processed[f"set-{ctx_var}"] = {
        "type": "system",
        "subtype": "Context dependent determination",
        "condition": {
            **{ctx_var: {"known": True}},
            **{
                f"{ctx_var}-value-{v.replace(' ', '_')}": {"value": False}
                for v in var_options
            },
        },
        "effect": {
            "set-valid-value": {
                "oneof": {
                    "outcomes": {
                        v.replace(" ", "_"): {
                            "updates": {
                                f"{ctx_var}-value-{v.replace(' ', '_')}": {
                                    "value": True
                                },
                            },
                            "context": {ctx_var: {"value": v}},
                        }
                        for v in var_options
                    }
                }
            }
        },
    }
    # whenever we lose knowledge of the context variable, reset all values
    for act in loaded_yaml["actions"]:
        for eff, eff_config in loaded_yaml["actions"][act]["effect"].items():
            for option in eff_config:
                for out, out_config in eff_config[option]["outcomes"].items():
                    if "updates" in out_config:
                        for update_var, update_cfg in out_config["updates"].items():
                            if ctx_var == update_var and "known" in update_cfg:
                                if update_cfg["known"] == False:
                                    for v in var_options:
                                        processed[act]["effect"][eff][option][
                                            "outcomes"
                                        ][out]["updates"][
                                            f"{ctx_var}-value-{v.replace(' ', '_')}"
                                        ] = {
                                            "value": False
                                        }
    loaded_yaml["actions"] = processed


def _base_fallback_setup(loaded_yaml: Dict) -> None:
    """Sets up the default intents, action, and context variables needed to
    handle fallbacks. 

    Args:
    - loaded_yaml (Dict): The loaded YAML configuration.
    """
    # set up the action, intent, and fluents needed for default fallback/unclear user input
    loaded_yaml["intents"]["fallback"] = {"utterances": [], "variables": []}
    loaded_yaml["intents"]["utter_dialogue_statement"] = {
        "utterances": [],
        "variables": [],
    }
    loaded_yaml["actions"]["dialogue_statement"] = _configure_dialogue_statement()
    loaded_yaml["context_variables"]["have-message"] = {
        "type": "flag",
        "init": False,
    }
    loaded_yaml["context_variables"]["force-statement"] = {
        "type": "flag",
        "init": False,
    }


def _instantiate_custom_actions(loaded_yaml: Dict) -> None:
    """Instantiate custom actions.

    NOTE: All custom action functions must be placed in a file in
    plan4dial/generate_files/custom_actions.py. The name of the file should
    be the same name as the function that configures the custom action.

    NOTE: The custom actions are responsible for adding the actions to the
    configuration. This is because some custom actions add multiple actions,
    make changes to the context variables, etc. As a rule, the `loaded_yaml`
    should always be the first parameter.

    Args:
    - loaded_yaml (Dict): The loaded YAML configuration.
    """
    processed = deepcopy(loaded_yaml)
    # iterate through all actions
    for act, act_config in loaded_yaml["actions"].items():
        # if we're dealing with a custom action
        if act_config["type"] == "custom":
            # find the appropriate file in the custom_actions folder
            custom_act_name = act_config["subtype"]
            for custom_act in getmembers(import_module(f"generate_files.custom_actions.{custom_act_name}"), isfunction):
                act_name, act_function = custom_act[0], custom_act[1]
                if act_name == custom_act_name:
                    act_function(
                        processed, **act_config["custom"]["parameters"]
                    )
                    break
            # delete the custom action instantiation outline
            del processed["actions"][act]
    for key in processed:
        loaded_yaml[key] = processed[key]


def _add_fallbacks(loaded_yaml: Dict) -> None:
    """Ensure that non-fallback options can only run if a fallback did not just
    occur. Add fallback outcomes to actions as necessary.

    Args:
    - loaded_yaml (Dict): The loaded YAML configuration.
    """
    processed = deepcopy(loaded_yaml["actions"])
    for act, act_config in loaded_yaml["actions"].items():
        fallback = False
        # for all non-fallback actions, make sure we can only execute that
        # action if a fallback is not occurring
        if act != "dialogue_statement":
            processed[act]["condition"]["force-statement"] = {"value": False}
            # check if either fallbacks are disabled or we have a system action
            # (fallbacks are only needed for dialogue actions)
            fallback = (
                not act_config["disable-fallback"]
                if "disable-fallback" in act_config
                else act_config["type"] != "system"
            )
            # if this action has fallbacks enabled, and we haven't specified
            # custom fallback message variants, add these as default
            if fallback:
                if "fallback_message_variants" not in act_config:
                    processed[act]["fallback_message_variants"] = [
                        "Sorry, I couldn't understand that input.",
                        "Sorry, I didn't quite get that.",
                    ]
        # if this action has fallbacks enabled, add fallback outcomes 
        # as necessary
        for eff, eff_config in loaded_yaml["actions"][act]["effect"].items():
            if fallback:
                for option in eff_config:
                    processed[act]["effect"][eff][option]["outcomes"][
                        "fallback"
                    ] = _configure_fallback()
    loaded_yaml["actions"] = processed


def _add_follow_ups_and_responses(loaded_yaml: Dict) -> None:
    """Configures follow up actions and responses where they were specified
    in the YAML.

    Follow ups are actions that are forced to take place after an outcome.
    Responses are messages that the agent must utter after an outcome.

    NOTE: As it stands, follow ups only force the action that you specify and 
    disable all others. This means that for actions that, for example, lead into
    clarifications, those clarifications will not be forced too. A more complex
    configuration for robust follow_up functionality (as well as more
    description of the issue) is detailed in #5, but this bare-bones
    specification can be safely used in the meantime.

    Args:
    - loaded_yaml (Dict): The loaded YAML configuration.
    """
    processed = deepcopy(loaded_yaml["actions"])
    forced_acts = []
    for act in loaded_yaml["actions"]:
        for eff, eff_config in loaded_yaml["actions"][act]["effect"].items():
            for option in eff_config:
                for out, out_config in eff_config[option]["outcomes"].items():
                    next_outcome = deepcopy(out_config)
                    # if a follow up was specified, set the forcing__{action}
                    # flag to True and keep track of which action was forced
                    if "follow_up" in next_outcome:
                        forced = next_outcome["follow_up"]
                        forcing_name = f"forcing__{forced}"
                        if "updates" in next_outcome:
                            next_outcome["updates"][forcing_name] = {"value": True}
                        else:
                            next_outcome["updates"] = {forcing_name: {"value": True}}
                        forced_acts.append(forced)
                    # force a message if a response was indicated
                    if "response_variants" in next_outcome:
                        if "updates" in next_outcome:
                            next_outcome["updates"].update(_configure_force_message_true())
                        else:
                            next_outcome["updates"] = _configure_force_message_true()
                    processed[act]["effect"][eff][option]["outcomes"][
                        out
                    ] = next_outcome
    with_forced = deepcopy(processed)
    # iterate through all the actions that are going to be forced at some point
    for forced in forced_acts:
        forcing_name = f"forcing__{forced}"
        # iterate through all actions
        for act in processed:
            # don't lock the fallback so we can fallback on a forced action if needed
            # don't lock the forced action itself, obviously
            if act != forced and act != "dialogue_statement":
                with_forced[act]["condition"][forcing_name] = {"value": False}
        # for all actions that are being forced, any outcome that IS NOT a fallback 
        # will end the force
        for eff, eff_config in loaded_yaml["actions"][forced]["effect"].items():
            for option in eff_config:
                for out, out_config in with_forced[forced]["effect"][eff][option]["outcomes"].items():
                    if "intent" in out_config:
                        if out_config["intent"] != "fallback":
                            reset_force = True
                    else:
                        reset_force = True
                    if reset_force:
                        if "updates" in out_config:
                            out_config["updates"][forcing_name] = {"value": False}
                        else:
                            out_config["updates"] = {forcing_name: {"value": False}}
        loaded_yaml["context_variables"][forcing_name] = {"type": "flag", "init": False}
    loaded_yaml["actions"] = with_forced


def _duplicate_for_or_condition(loaded_yaml: Dict) -> None:
    """Creates equivalent actions to those with an "or" precondition by splitting
    them up into separate actions. 

    NOTE: ARBITRARY FORMULAS ARE NOT YET HANDLED (see #4).  
    Should not be deployed yet.

    Args:
    - loaded_yaml (Dict): The loaded YAML configuration.
    """
    processed = deepcopy(loaded_yaml["actions"])
    for act, act_cfg in loaded_yaml["actions"].items():
        for cond, cond_cfg in act_cfg["condition"].items():
            # currently only handles "or"s and "or"s of "ands" (when multiple conditions are listed under one bullet)
            if cond == "or":
                idx = 1
                # for each or condition, create a new action with that 
                # condition and none of the other ones in the or clause
                for or_cond in cond_cfg:
                    new_cond = deepcopy(act_cfg["condition"])
                    del new_cond["or"]
                    for k, v in or_cond.items():
                        new_cond[k] = v
                    next_act_name = f"{act}-or-{idx}"
                    processed[next_act_name] = deepcopy(processed[act])
                    processed[next_act_name]["condition"] = new_cond
                    idx += 1
                del processed[act]
    loaded_yaml["actions"] = processed


def _duplicate_for_or_when_condition(loaded_yaml: Dict) -> None:
    """Creates equivalent "when" expressions to those with an "or" condition by splitting
    them up into separate conditions. 

    NOTE: ARBITRARY FORMULAS ARE NOT YET HANDLED (see #3 and #4).  
    Should not be deployed yet.

    Args:
    - loaded_yaml (Dict): The loaded YAML configuration.
    """
    processed = deepcopy(loaded_yaml["actions"])
    for act in loaded_yaml["actions"]:
        for eff, eff_config in loaded_yaml["actions"][act]["effect"].items():
            for option in eff_config:
                for out, out_config in eff_config[option]["outcomes"].items():
                    if "updates" in out_config:
                        for update_var, update_cfg in out_config["updates"].items():
                            # for now, assume we only use "and" explicitly to stack "when" expressions
                            if update_var == "and":
                                for when_expr in update_cfg:
                                    for when_cond, when_cond_cfg in when_expr["when"][
                                        "condition"
                                    ].items():
                                        if when_cond == "or":
                                            # iterate through each "or" condition
                                            for or_cond in when_cond_cfg:
                                                new_when = deepcopy(when_expr)
                                                del new_when["when"]["condition"]["or"]
                                                # create new expressions for each condition
                                                for k, v in or_cond.items():
                                                    new_when["when"]["condition"][k] = v
                                                processed[act]["effect"][eff][option][
                                                    "outcomes"
                                                ][out]["updates"][update_var].append(
                                                    new_when
                                                )
                                    processed[act]["effect"][eff][option]["outcomes"][
                                        out
                                    ]["updates"][update_var].remove(when_expr)
    loaded_yaml["actions"] = processed


def _add_value_setters(loaded_yaml: Dict) -> None:
    """Configures value setters when an action is contingent on the string value of a 
    context variable. Resets the precondition of these actions to rely on the flag values
    that represent the true value of the context variable.

    Args:
    - loaded_yaml (Dict): The loaded YAML configuration.

    Raises:
    - AssertionError: Raised if the user tried to specify an invalid value for a context
    variable in a precondition.
    """
    processed = deepcopy(loaded_yaml)
    for act, act_cfg in loaded_yaml["actions"].items():
        for cond, cond_cfg in act_cfg["condition"].items():
            if "value" in cond_cfg:
                option = cond_cfg["value"]
                if type(option) == str:
                    if option not in loaded_yaml["context_variables"][cond]["options"]:
                        raise AssertionError(
                            f'Cannot specify the value "{option}" for the context variable "{cond}".'
                        )
                    # if not done already, create new "value-setting" actions, conditions, etc.
                    if (
                        f"{cond}-value-{option.replace(' ', '_')}"
                        not in processed["context_variables"]
                    ):
                        _configure_value_setter(processed, cond)
                    # reset old condition to the refactored condition so we can specify value
                    # only delete the value portion (may still have "known")
                    del processed["actions"][act]["condition"][cond]["value"]
                    # delete whole condition if empty
                    if processed["actions"][act]["condition"][cond] == {}:
                        del processed["actions"][act]["condition"][cond]
                    # replace
                    processed["actions"][act]["condition"][
                        f"{cond}-value-{option.replace(' ', '_')}"
                    ] = {"value": True}
    loaded_yaml["actions"], loaded_yaml["context_variables"] = (
        processed["actions"],
        processed["context_variables"],
    )

def _convert_ctx_var(loaded_yaml: Dict) -> None:
    """Converts the context variables from how they were formatted in the YAML
    to the JSON configuration that Hovor requires.

    Args:
    - loaded_yaml (Dict): The loaded YAML configuration.
    """
    processed = deepcopy(loaded_yaml["context_variables"])
    # convert context variables
    processed = {var: {} for var in loaded_yaml["context_variables"]}
    for ctx_var, cfg in loaded_yaml["context_variables"].items():
        json_ctx_var = {}
        json_ctx_var["type"] = cfg["type"]
        if cfg["type"] == "enum":
            # don't include variations in the config
            if type(cfg["options"]) == dict:
                json_ctx_var["config"] = list(cfg["options"].keys())
            else:
                json_ctx_var["config"] = cfg["options"]
        # for flags/fflags, the config is the initial setting
        elif cfg["type"] == "flag" or cfg["type"] == "fflag":
            json_ctx_var["config"] = cfg["init"]
        else:
            # add other information to the config as necessary
            if "extraction" in cfg:
                json_ctx_var["config"] = {"extraction": cfg["extraction"]}
                if "method" in cfg:
                    json_ctx_var["config"]["method"] = cfg["method"]
                elif "pattern" in cfg:
                    json_ctx_var["config"]["pattern"] = cfg["pattern"]
            else:
                json_ctx_var["config"] = "null"
        if "known" in cfg:
            json_ctx_var["known"] = cfg["known"]
        processed[ctx_var] = json_ctx_var
    loaded_yaml["context_variables"] = processed


def _convert_intents(loaded_yaml: Dict) -> None:
    """Converts the intents from how they were formatted in the YAML to the
    JSON configuration that Hovor requires.

    Args:
    - loaded_yaml (Dict): The loaded YAML configuration.
    """
    processed = deepcopy(loaded_yaml["intents"])
    for intent, intent_cfg in loaded_yaml["intents"].items():
        cur_intent = {}
        cur_intent["variables"] = []
        # add the $ identifier to all variables
        if "variables" in intent_cfg:
            cur_intent["variables"].extend(
                [f"${var}" for var in intent_cfg["variables"]]
            )
        cur_intent["utterances"] = intent_cfg["utterances"]
        processed[intent] = cur_intent
    loaded_yaml["intents"] = processed


def _convert_actions(loaded_yaml: Dict) -> None:
    """Converts the actions from how they were formatted in the YAML to the
    JSON configuration that Hovor requires.

    Args:
    - loaded_yaml (Dict): The loaded YAML configuration.
    """
    processed = deepcopy(loaded_yaml["actions"])
    for act in loaded_yaml["actions"]:
        # convert preconditions
        json_config_cond = []
        condition = loaded_yaml["actions"][act]["condition"]
        for cond, cond_cfg in condition.items():
            for cond_config_key, cond_config_val in cond_cfg.items():
                if cond_config_key == "known":
                    json_config_cond.append(
                        ([cond, "Known"] if cond_config_val else [cond, "Unknown"])
                        if type(cond_config_val) == bool
                        else [cond, "Uncertain"]
                    )
                elif cond_config_key == "value":
                    json_config_cond.append([cond, cond_config_val])
        processed[act]["condition"] = json_config_cond
        # convert effects
        for eff, eff_config in loaded_yaml["actions"][act]["effect"].items():
            converted_eff = deepcopy(eff_config)
            converted_eff["global-outcome-name"] = eff
            intents = []
            for option in eff_config:
                converted_eff["type"] = option
                outcomes_list = []
                for out, out_config in eff_config[option]["outcomes"].items():
                    next_outcome = deepcopy(out_config)
                    # reformat name
                    next_outcome["name"] = f"{act}_DETDUP_{eff}-EQ-{out}"
                    # use blank intent if no intent was specified
                    if "intent" not in out_config:
                        next_outcome["intent"] = None
                    else:
                        intents.append(out_config["intent"])
                    next_outcome["assignments"] = {}
                    if "updates" in out_config:
                        for update_var, update_cfg in out_config["updates"].items():
                            next_outcome["updates"][update_var]["variable"] = update_var
                            # set the assignments and certainty based on the "known" settings
                            # that were updated
                            if "known" in update_cfg:
                                next_outcome["assignments"][
                                    f"${update_var}"
                                ] = _configure_assignments(update_cfg["known"])
                                next_outcome["updates"][update_var][
                                    "certainty"
                                ] = _configure_certainty(update_cfg["known"])
                                del next_outcome["updates"][update_var]["known"]
                            # set value to None if not specified (i.e. if just setting 
                            # known: False)
                            if "value" not in update_cfg:
                                next_outcome["updates"][update_var]["value"] = None
                            # JSON interpretations are handled in the most straightforward
                            # way by Hovor (as opposed to spel, which requires a specific format)
                            next_outcome["updates"][update_var][
                                "interpretation"
                            ] = "json"
                    outcomes_list.append(next_outcome)
                converted_eff["outcomes"] = outcomes_list
                del converted_eff[option]
                processed[act]["effect"] = converted_eff
        # add the intents in a separate section
        if intents:
            processed[act]["intents"] = {}
            for intent in intents:
                # don't consider null or frozenset intents
                if type(intent) == str:
                    if intent in loaded_yaml["intents"]:
                        processed[act]["intents"][intent] = loaded_yaml["intents"][
                            intent
                        ]
    loaded_yaml["actions"] = processed


def _convert_yaml(filename: str) -> Dict:
    """Generates the JSON configuration required by Hovor from the provided
    YAML file. First preprocesses the YAML, adding clarification actions,
    follow-up actions, etc, then finally converts everything into Hovor
    format.

    Args:
    - filename (str): the YAML file.

    Returns:
    - (Dict): The JSON configuration required by Hovor.
    """
    loaded_yaml = yaml.load(open(filename, "r"), Loader=yaml.FullLoader)
    _base_fallback_setup(loaded_yaml)
    _instantiate_custom_actions(loaded_yaml)
    _add_fallbacks(loaded_yaml)
    _add_follow_ups_and_responses(loaded_yaml)
    _duplicate_for_or_condition(loaded_yaml)
    _duplicate_for_or_when_condition(loaded_yaml)
    _add_value_setters(loaded_yaml)
    _convert_ctx_var(loaded_yaml)
    _convert_intents(loaded_yaml)
    _convert_actions(loaded_yaml)
    return loaded_yaml
