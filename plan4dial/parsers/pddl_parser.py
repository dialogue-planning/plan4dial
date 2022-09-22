"""This module contains all the files necessary to convert from the HOVOR
configuration to PDDL. This PDDL is later used to generate the controller/tree
that determines how the conversation is navigated.

Authors:
- Rebecca De Venezia
"""

from typing import Dict, List, Set, Union, Tuple


# define a tab
TAB = " " * 4


def return_flag_value_fluent(v_name: str, is_fflag: bool, value: Union[bool, str]) -> str:
    """Returns the fluent version of a flag or fflag context variable depending
    on the setting supplied.

    Args:
    - v_name (str): The name of the variable.
    - is_fflag (bool): Describes if the variable is of type fflag, in which 
    case the "maybe" option can be considered.
    - value (bool or str): The value setting of this context variable.

    Returns:
    - (str): The fluent version of a flag or fflag context variable depending
    on the setting supplied.
    """
    if type(value) == bool:
        return f"({v_name})" if value else f"(not ({v_name}))"
    elif is_fflag:
        return f"(maybe__{v_name})"


def return_known_fluents(v_name: str, is_fflag: bool, known: Union[bool, str]) -> List[str]:
    """Helper function for `return_certainty_fluents`. Returns the fluent 
    version of the "known" setting of a context variable depending on the
    setting supplied. In this case, the "known" setting is what we would see 
    in the YAML; the only options are True, False, and "maybe".

    Args:
    - v_name (str): The name of the variable.
    - is_fflag (bool): Describes if the variable is of type fflag, in which 
    case the "maybe" option can be considered.
    - known (bool or str): The "known" setting of this context variable.

    Returns:
    - (str): The fluent version of the "known" setting of a context variable
    depending on the setting supplied.
    """
    if type(known) == bool:
        return (
            (
                [f"(know__{v_name})", f"(not (maybe-know__{v_name}))"]
                if known
                else [f"(not (know__{v_name}))", f"(not (maybe-know__{v_name}))"]
            )
            if is_fflag
            else ([f"(know__{v_name})"] if known else [f"(not (know__{v_name}))"])
        )
    else:
        return [f"(not (know__{v_name}))", f"(maybe-know__{v_name})"]


def return_certainty_fluents(v_name: str, is_fflag: bool, certainty: str) -> List[str]:
    """Returns the fluent version of the certainty setting of a context variable
    depending on the setting supplied.

    Args:
    - v_name (str): The name of the variable.
    - is_fflag (bool): Describes if the variable is of type fflag, in which 
    case the "Uncertain" option can be considered.
    - certainty (str): The certainty setting of this context variable.

    Returns:
    - (str): The fluent version of the certainty setting of a context variable
    depending on the setting supplied.
    """
    if certainty == "Known":
        return return_known_fluents(v_name, is_fflag, True)
    elif certainty == "Unknown":
        return return_known_fluents(v_name, is_fflag, False)
    elif certainty == "Uncertain":
        return return_known_fluents(v_name, is_fflag, "maybe")


def fluents_to_pddl(
    fluents: List[str],
    tabs: int,
    outer_brackets: bool = False,
    name_wrap: str = None,
    and_wrap: bool = False,
):
    fluent_tabs = TAB * (tabs + 1)
    and_wrap_tabs = TAB * tabs
    if name_wrap and and_wrap:
        and_wrap_tabs += TAB
        fluent_tabs += TAB

    fluents = (
        (("\n" + fluent_tabs) + "{0}".format(("\n" + fluent_tabs).join(fluents)))
        if len(fluents) > 0
        else ("")
    )
    if and_wrap:
        fluents = f"\n{and_wrap_tabs}(and{fluents}\n{and_wrap_tabs})"
    if name_wrap:
        fluents = f"{name_wrap}{fluents}"
        fluents = (
            f"\n{TAB * tabs}({fluents}\n{TAB * tabs})"
            if outer_brackets
            else f"\n{TAB * tabs}{fluents}"
        )
    return fluents


def get_precond_fluents(context_variables: Dict, conditions):
    precond = set()
    for cond in conditions:
        cond_key = cond[0]
        cond_val = cond[1]
        cond_key_fflag = (
            (context_variables[cond_key]["known"]["type"] == "fflag")
            if "known" in context_variables[cond_key]
            else False
        )
        if cond_val != None:
            if type(cond_val) == bool:
                precond.add(
                    return_flag_value_fluent(cond_key, cond_key_fflag, cond_val)
                )
            elif cond_val in ["Known", "Unknown", "Uncertain"]:
                precond.update(
                    return_certainty_fluents(cond_key, cond_key_fflag, cond_val)
                )
            else:
                precond.add(f"({cond_val})")
    return precond


def get_update_fluents(context_variables: Dict, updates: Dict) -> Set[str]:
    """Converts the update configuration of an action outcome to PDDL fluents.

    Args:
    - context_variables (Dict): The configuration of all context variables.
    - updates (Dict): The update configuration.

    Returns:
    - outcomes (Set[str]): The set of fluents that were added by the outcome update.
    """
    outcomes = set()
    for update_var, update_config in updates.items():
        update_var_fflag = (
            (context_variables[update_var]["known"]["type"] == "fflag")
            if "known" in context_variables[update_var]
            else False
        )
        if "certainty" in update_config:
            outcomes.update(
                return_certainty_fluents(
                    update_var, update_var_fflag, update_config["certainty"]
                )
            )
        if "value" in update_config:
            if update_config["value"] != None:
                if context_variables[update_var]["type"] in ["flag", "fflag"]:
                    outcomes.add(
                        return_flag_value_fluent(
                            update_var, update_var_fflag, update_config["value"]
                        )
                    )
    return outcomes


def _action_to_pddl(context_variables: Dict, act: str, act_config: Dict) -> str:
    """Converts an action from the YAML configuration to PDDL.

    Args:
    - context_variables (Dict): The configuration of all context variables.
    - act (str): The action name.
    - act_config (Dict): The action configuration.

    Returns:
    - (str): The converted action.
    """
    act_param = f"{TAB}(:action {act}\n{TAB * 2}:parameters()"

    # convert the preconditions
    precond = fluents_to_pddl(
        fluents=get_precond_fluents(context_variables, act_config["condition"]),
        tabs=2,
        name_wrap=":precondition",
        and_wrap=True,
    )
    # convert the effects
    effects = f"\n{TAB * 2}:effect\n{TAB * 3}(labeled-oneof {act_config['effect']['global-outcome-name']}"
    # iterate through all the outcomes
    for out_config in act_config["effect"]["outcomes"]:
        if "updates" in out_config:
            # for each outcome, get the update fluents
            update_fluents = get_update_fluents(
                context_variables, out_config["updates"]
            )
            # add the outcome to the effect string
            effects += fluents_to_pddl(
                fluents=update_fluents,
                tabs=4,
                outer_brackets=True,
                # only take raw name
                name_wrap=f"outcome {out_config['name'].split('-EQ-')[1]}",
                and_wrap=True,
            )
    effects += f"\n{TAB * 3})"
    return act_param + precond + effects + f"\n{TAB})"


def _actions_to_pddl(loaded_yaml: Dict) -> str:
    """Converts actions from the YAML to PDDL format.

    Args:
    - loaded_yaml (Dict): The loaded YAML configuration.

    Returns:
    (str): The converted actions.
    """
    return "\n".join(
        [
            _action_to_pddl(loaded_yaml["context_variables"], act, act_config)
            for act, act_config in loaded_yaml["actions"].items()
        ]
    )


def _parse_init(context_variables: Dict) -> Tuple[Set[str], Set[str]]:
    """Convert the initial state of context variables to a PDDL initial state.

    Args:
    - context_variables (Dict): The configuration of all context variables.

    Returns:
    - init_true (Set[str]): The partial initial state, which indicates all fluents that
    are initially true. Used in the PDDL.
    - init_complete (Set[str]): The complete initial state, which indicates the state of
    all fluents in the initial state. Used by the rollout configuration.
    """
    init_true = set()
    init_complete = set()
    # iterate through all context variables
    for var, var_config in context_variables.items():
        # if this variable has a known setting
        if "known" in var_config:
            known_status = var_config["known"]["init"]
            if type(known_status) == bool:
                # if known is True, add this to the partial satate
                if known_status:
                    init_true.add(f"(know__{var})")
                # otherwise, add the appropriate False known settings to the
                # complete state
                else:
                    init_complete.add(f"(not (know__{var}))")
                    if var_config["known"]["type"] == "fflag":
                        init_complete.add(f"(not (maybe-know__{var}))")
            else:
                init_true.add(f"(maybe-know__{var})")
        # similarly add the context variables that are flag/fflag types
        if var_config["type"] in ["flag", "fflag"]:
            status = var_config["config"]
            if type(status) == bool:
                if status:
                    init_true.add(f"({var})")
                else:
                    init_complete.add(f"(not ({var}))")
                    if var_config["type"] == "fflag":
                        init_complete.add(f"(not (maybe__{var}))")
            else:
                init_true.add(f"(maybe__{var})")
    init_complete.update(init_true)
    return init_true, init_complete


def _parse_predicates(context_variables: Dict) -> List[str]:
    """Converts the context variables to PDDL predicates.

    Args:
    - context_variables (Dict): The configuration of all context variables.

    Returns:
    - predicates (List[str]): The collection of converted predicates.
    """
    predicates = []
    # iterate through all context variables
    for var, var_config in context_variables.items():
        # add all "known" settings as predicates
        if "known" in var_config:
            predicates.append(f"(know__{var})")
            if var_config["known"]["type"] == "fflag":
                predicates.append(f"(maybe-know__{var})")
        # add all flag/fflag type context variables as predicates
        if var_config["type"] in ["flag", "fflag"]:
            predicates.append(f"({var})")
            if var_config["type"] == "fflag":
                predicates.append(f"(maybe__{var})")
    return predicates


def _parse_to_pddl(loaded_yaml: Dict) -> Tuple[str, str]:
    """Converts the loaded YAML file to a PDDL specification.

    Args:
    - loaded_yaml (Dict): The loaded YAML configuration.

    Returns:
    - domain (str): The generated PDDL domain.
    - problem (str): The generated PDDL problem.
    """
    predicates = fluents_to_pddl(
        fluents=_parse_predicates(loaded_yaml["context_variables"]),
        tabs=1,
        outer_brackets=True,
        name_wrap=":predicates",
    )
    actions = _actions_to_pddl(loaded_yaml)
    domain = f"(define\n{TAB}(domain {loaded_yaml['name']})\n{TAB}(:requirements :strips :typing)\n{TAB}(:types )\n{TAB}(:constants ){predicates}\n{actions}\n)"
    problem_def = f"(define\n{TAB}(problem {loaded_yaml['name']}-problem)\n{TAB}(:domain {loaded_yaml['name']})\n{TAB}(:objects )"
    init = fluents_to_pddl(
        fluents=_parse_init(loaded_yaml["context_variables"])[0],
        tabs=1,
        outer_brackets=True,
        name_wrap=":init",
    )
    goal = fluents_to_pddl(
        fluents=["(goal)"],
        tabs=1,
        outer_brackets=True,
        name_wrap=":goal",
        and_wrap=True,
    )
    problem = problem_def + init + goal + "\n)"
    return domain, problem
