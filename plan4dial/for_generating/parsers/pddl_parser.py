"""This module contains all the files necessary to convert from the HOVOR configuration
to PDDL. This PDDL is later used to generate the controller/tree that determines how
the conversation is navigated.

Authors:
* Rebecca De Venezia
"""

from typing import Dict, List, Set, Union, Tuple


# define a tab
TAB = " " * 4


def _get_is_fflag(context_variables: Dict, v_name: str) -> bool:
    """Determines if the provided variable has a "known" setting of type fflag.

    Args:
        context_variables (Dict): The configuration of all context variables.
        v_name (str): The name of the variable.

    Returns:
        (bool): Indicates if the provided variable has a "known" setting of type fflag.
    """
    return (
        (context_variables[v_name]["known"]["type"] == "fflag")
        if "known" in context_variables[v_name]
        else False
    )


def _return_flag_value_fluent(
    v_name: str, is_fflag: bool, value: Union[bool, str]
) -> str:
    """Returns the fluent version of a flag or fflag context variable depending on the
    setting supplied.

    Args:
        v_name (str): The name of the variable.
        is_fflag (bool): Describes if the variable is of type fflag, in which case the
            "maybe" option can be considered.
        value (bool or str): The value setting of this context variable.

    Returns:
        (str): The fluent version of a flag or fflag context variable depending on the
            setting supplied.
    """
    if type(value) == bool:
        return f"({v_name})" if value else f"(not ({v_name}))"
    elif is_fflag:
        return f"(maybe__{v_name})"


def _return_certainty_fluents(v_name: str, is_fflag: bool, certainty: str) -> List[str]:
    """Returns the fluent version of the certainty setting of a context variable
    depending on the setting supplied.

    Args:
        v_name (str): The name of the variable.
        is_fflag (bool): Describes if the variable's "known" type is fflag, in which
            case the "Uncertain" option can be considered.
        certainty (str): The certainty setting of this context variable.

    Returns:
        (List[str]): The list of fluents that reflect the certainty setting for the
            context variable supplied.
    """
    # convert to a simpler representation
    if certainty == "Known":
        known = True
    elif certainty == "Unknown":
        known = False
    elif certainty == "Uncertain":
        known = "maybe"

    if type(known) == bool:
        # only include "maybe"s if the known type is fflag
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
        # "maybe"/"Uncertain" option chosen
        return [f"(not (know__{v_name}))", f"(maybe-know__{v_name})"]


def _fluents_to_pddl(
    fluents: List[str],
    tabs: int,
    name_wrap: str = None,
    and_wrap: bool = False,
    outer_brackets: bool = True,
) -> str:
    """Converts a list of fluents to PDDL. Adds tabs, outer brackets, names and "and"
    wraps as appropriate.

    Args:
        fluents (List[str]): A list of the string versions of the fluents.
        tabs (int): The "base" indentation of the fluents.
        outer_brackets (bool. optional): Setting to wrap the final statement with outer
            brackets, i.e. (outcome ...) Defaults to True.
        name_wrap (str, optional): Setting to wrap fluents with a name, i.e.
            ":predicates". Defaults to None.
        and_wrap (bool, optional): Setting to wrap fluents with an "and", i.e.
            :precondition\n(and\n\t(...\n\t)). Defaults to False.

    Returns:
        (str): The converted PDDL fluents.
    """
    # set up the base tabbing before each fluent
    fluent_tabs = TAB * (tabs + 1)
    # set up the base fluent before the and wrap
    and_wrap_tabs = TAB * tabs
    # if we are also including a name wrap with an and wrap, then everything needs to
    # be indented one more tab to make room for that
    if name_wrap and and_wrap:
        and_wrap_tabs += TAB
        fluent_tabs += TAB

    # join the fluents together
    fluents = (
        (("\n" + fluent_tabs) + "{0}".format(("\n" + fluent_tabs).join(fluents)))
        if len(fluents) > 0
        else ("")
    )
    # wrap with the and if necessary
    if and_wrap:
        fluents = f"\n{and_wrap_tabs}(and{fluents}\n{and_wrap_tabs})"
    # wrap with the name wrap and outer brackets if necessary
    if name_wrap:
        fluents = f"{name_wrap}{fluents}"
        fluents = (
            f"\n{TAB * tabs}({fluents}\n{TAB * tabs})"
            if outer_brackets
            else f"\n{TAB * tabs}{fluents}"
        )
    return fluents


def get_precond_fluents(
    context_variables: Dict, conditions: List[Union[str, bool]]
) -> Set[str]:
    """Convert an action precondition to PDDL fluents.

    Args:
        context_variables (Dict): The configuration of all context variables.
        conditions (List[Union[str, bool]]): The conditions to be converted.

    Returns:
        Set[str]: The set of converted fluents.
    """
    precond = set()
    # iterate through all the conditions
    for cond in conditions:
        cond_key = cond[0]
        cond_val = cond[1]
        cond_key_fflag = _get_is_fflag(context_variables, cond_key)
        # update precond depending on the type of condition value
        if cond_val is not None:
            if type(cond_val) == bool:
                precond.add(
                    _return_flag_value_fluent(cond_key, cond_key_fflag, cond_val)
                )
            elif cond_val in ["Known", "Unknown", "Uncertain"]:
                precond.update(
                    _return_certainty_fluents(cond_key, cond_key_fflag, cond_val)
                )
    return precond


def get_update_fluents(context_variables: Dict, updates: Dict) -> Set[str]:
    """Converts the update configuration of an action outcome to PDDL fluents.

    Args:
        context_variables (Dict): The configuration of all context variables.
        updates (Dict): The update configuration.

    Returns:
        outcomes (Set[str]): The set of fluents that were added by the outcome update.
    """
    outcomes = set()
    # iterate through all the update configurations
    for update_var, update_config in updates.items():
        # if the context variable has a "known" configuration, check if that is of type
        # fflag
        update_var_fflag = _get_is_fflag(context_variables, update_var)
        # add fluents based on the certainty if those were updated
        if "certainty" in update_config:
            outcomes.update(
                _return_certainty_fluents(
                    update_var, update_var_fflag, update_config["certainty"]
                )
            )
        # add fluents based on the value if we're dealing with a flag/fflag type
        if "value" in update_config:
            if update_config["value"] is not None:
                if context_variables[update_var]["type"] in ["flag", "fflag"]:
                    outcomes.add(
                        _return_flag_value_fluent(
                            update_var, update_var_fflag, update_config["value"]
                        )
                    )
    return outcomes


def _action_to_pddl(context_variables: Dict, act: str, act_config: Dict) -> str:
    """Converts an action from the YAML configuration to PDDL.

    Args:
        context_variables (Dict): The configuration of all context variables.
        act (str): The action name.
        act_config (Dict): The action configuration.

    Returns:
        (str): The converted action.
    """
    act_param = f"{TAB}(:action {act}\n{TAB * 2}:parameters()"

    # convert the preconditions
    precond = _fluents_to_pddl(
        fluents=get_precond_fluents(context_variables, act_config["condition"]),
        tabs=2,
        name_wrap=":precondition",
        and_wrap=True,
        outer_brackets=False,
    )
    # convert the effects
    effects = f"\n{TAB * 2}:effect\n{TAB * 3}(labeled-oneof \
        {act_config['effect']['global-outcome-name']}"
    # iterate through all the outcomes
    for out_config in act_config["effect"]["outcomes"]:
        if "updates" in out_config:
            # for each outcome, get the update fluents
            update_fluents = get_update_fluents(
                context_variables, out_config["updates"]
            )
            # add the outcome to the effect string
            effects += _fluents_to_pddl(
                fluents=update_fluents,
                tabs=4,
                # only take raw name
                name_wrap=f"outcome {out_config['name'].split('-EQ-')[1]}",
                and_wrap=True,
            )
    effects += f"\n{TAB * 3})"
    return act_param + precond + effects + f"\n{TAB})"


def _actions_to_pddl(loaded_yaml: Dict) -> str:
    """Converts actions from the YAML to PDDL format.

    Args:
        loaded_yaml (Dict): The loaded YAML configuration.

    Returns:
        (str): The converted actions.
    """
    return "\n".join(
        [
            _action_to_pddl(loaded_yaml["context_variables"], act, act_config)
            for act, act_config in loaded_yaml["actions"].items()
        ]
    )


def get_init_fluents(context_variables: Dict) -> Tuple[Set[str], Set[str]]:
    """Convert the initial state of context variables to a PDDL initial state.

    Args:
        context_variables (Dict): The configuration of all context variables.

    Returns:
        init_true (Set[str]): The partial initial state, which indicates all fluents
            that are initially true. Used in the PDDL.
        init_complete (Set[str]): The complete initial state, which indicates the state
            of all fluents in the initial state. Used by the rollout configuration.
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
        context_variables (Dict): The configuration of all context variables.

    Returns:
        predicates (List[str]): The collection of converted predicates.
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


def parse_to_pddl(loaded_yaml: Dict) -> Tuple[str, str]:
    """Converts the loaded YAML file to a PDDL specification.

    Args:
        loaded_yaml (Dict): The loaded YAML configuration.

    Returns:
        domain (str): The generated PDDL domain.
        problem (str): The generated PDDL problem.
    """
    predicates = _fluents_to_pddl(
        fluents=_parse_predicates(loaded_yaml["context_variables"]),
        tabs=1,
        name_wrap=":predicates",
    )
    actions = _actions_to_pddl(loaded_yaml)
    domain = f"(define\n{TAB}(domain {loaded_yaml['name']})\n{TAB}(:requirements \
        :strips :typing)\n{TAB}(:types )\n{TAB}(:constants ){predicates}\n{actions}\n)"
    problem_def = f"(define\n{TAB}(problem {loaded_yaml['name']}-problem)\n{TAB} \
        (:domain {loaded_yaml['name']})\n{TAB}(:objects )"
    init = _fluents_to_pddl(
        fluents=get_init_fluents(loaded_yaml["context_variables"])[0],
        tabs=1,
        name_wrap=":init",
    )
    goal = _fluents_to_pddl(
        fluents=["(goal)"],
        tabs=1,
        name_wrap=":goal",
        and_wrap=True,
    )
    problem = problem_def + init + goal + "\n)"
    return domain, problem
