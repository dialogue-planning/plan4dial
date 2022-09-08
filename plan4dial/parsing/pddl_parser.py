from typing import Dict, List
from pathlib import Path
from plan4dial.parsing.json_config_parser import convert_yaml


TAB = " " * 4


def return_flag_value_fluent(f_name: str, is_fflag: bool, value):
    if type(value) == bool:
        return f"({f_name})" if value else f"(not ({f_name}))"
    elif is_fflag and value == "maybe":
        return f"(maybe-{f_name})"

def return_known_fluents(f_name: str, is_fflag: bool, known):
    if type(known) == bool:
        return (
            [f"(know__{f_name})", f"(not (maybe-know__{f_name}))"]
            if known
            else [f"(not (know__{f_name}))", f"(not (maybe-know__{f_name}))"]
        ) if is_fflag else (
            [f"(know__{f_name})"]
            if known
            else [f"(not (know__{f_name}))"]
        )
    else:
        return [f"(not (know__{f_name}))", f"(maybe-know__{f_name})"]

def return_certainty_fluents(f_name: str, is_fflag: bool, certainty):
    if certainty == "Known":
        return return_known_fluents(f_name, is_fflag, True)
    elif certainty == "Unknown":
        return return_known_fluents(f_name, is_fflag, False)
    elif certainty == "Uncertain":
        return return_known_fluents(f_name, is_fflag, "maybe")

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
        cond_key_fflag = (context_variables[cond_key]["known"]["type"] == "fflag") if "known" in context_variables[cond_key] else False
        if cond_val != None:
            if type(cond_val) == bool:
                precond.add(return_flag_value_fluent(cond_key, cond_key_fflag, cond_val))
            elif cond_val in ["Known", "Unknown", "Uncertain"]:
                precond.update(return_certainty_fluents(cond_key, cond_key_fflag, cond_val))
            else:
                precond.add(f"({cond_val})")
    return precond

def get_update_fluents(context_variables: Dict, updates):
    outcomes = set()
    for update_var, update_config in updates.items():
        update_var_fflag = (context_variables[update_var]["known"]["type"] == "fflag") if "known" in context_variables[update_var] else False
        if "certainty" in update_config:
            outcomes.update(
                return_certainty_fluents(update_var, update_var_fflag, update_config["certainty"])
            )
        if "value" in update_config:
            if update_config["value"] != None:
                if context_variables[update_var]["type"] in ["flag", "fflag"]:
                    outcomes.add(
                        return_flag_value_fluent(update_var, update_var_fflag, update_config["value"])
                    )
    return outcomes

def action_to_pddl(context_variables: Dict, act: str, act_config: Dict):
    act_param = f"{TAB}(:action {act}\n{TAB * 2}:parameters()"


    precond = fluents_to_pddl(
        fluents=get_precond_fluents(context_variables, act_config["condition"]), tabs=2, name_wrap=":precondition", and_wrap=True
    )
    effects = f"\n{TAB * 2}:effect\n{TAB * 3}(labeled-oneof {act_config['effect']['global-outcome-name']}"
    for out_config in act_config["effect"]["outcomes"]:
        if "updates" in out_config:
            update_fluents = get_update_fluents(context_variables, out_config["updates"])
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

def actions_to_pddl(loaded_yaml: Dict):
    return "\n".join(
        [
            action_to_pddl(loaded_yaml["context_variables"], act, act_config)
            for act, act_config in loaded_yaml["actions"].items()
        ]
    )

def parse_init(context_variables: Dict):
    init_true = set()
    init_true_complete = set()
    for var, var_config in context_variables.items():
        if "known" in var_config:
            known_status = var_config["known"]["init"]
            if type(known_status) == bool:
                if known_status:
                    init_true.add(f"(know__{var})")
                else:
                    init_true_complete.add(f"(not (know__{var}))")
                    if var_config["known"]["type"] == "fflag":
                        init_true_complete.add(f"(not (maybe-know__{var}))")
            else:
                if known_status == "maybe":
                    init_true.add(f"(maybe-know__{var})")
        if var_config["type"] in ["flag", "fflag"]:
            status = var_config["config"]
            if type(status) == bool:
                if status:
                    init_true.add(f"({var})")
                else:
                    init_true_complete.add(f"(not ({var}))")
                    if var_config["type"] == "fflag":
                        init_true_complete.add(f"(not (maybe-{var}))")
            else:
                if status == "maybe":
                    init_true.add(f"(maybe-{var})")
    init_true_complete.update(init_true)
    return init_true, init_true_complete

def parse_predicates(context_variables: Dict):
    predicates = []
    init_true = []
    for var, var_config in context_variables.items():
        if "known" in var_config:
            predicates.append(f"(know__{var})")
            if var_config["known"]["type"] == "fflag":
                predicates.append(f"(maybe-know__{var})")
            known_status = var_config["known"]["init"]
            if type(known_status) == bool:
                if known_status:
                    init_true.append(f"(know__{var})")
            else:
                if known_status == "maybe":
                    init_true.append(f"(maybe-know__{var})")
        if var_config["type"] in ["flag", "fflag"]:
            predicates.append(f"({var})")
            if var_config["type"] == "fflag":
                predicates.append(f"(maybe-{var})")
            status = var_config["config"]
            if type(status) == bool:
                if status:
                    init_true.append(f"({var})")
            else:
                if status == "maybe":
                    init_true.append(f"(maybe-{var})")
    return predicates


def parse_to_pddl(loaded_yaml: Dict):
    predicates = fluents_to_pddl(
        fluents=parse_predicates(
            loaded_yaml["context_variables"]),
        tabs=1,
        outer_brackets=True,
        name_wrap=":predicates",
    )
    actions = actions_to_pddl(loaded_yaml)
    domain = f"(define\n{TAB}(domain {loaded_yaml['name']})\n{TAB}(:requirements :strips :typing)\n{TAB}(:types )\n{TAB}(:constants ){predicates}\n{actions}\n)"
    problem_def = f"(define\n{TAB}(problem {loaded_yaml['name']}-problem)\n{TAB}(:domain {loaded_yaml['name']})\n{TAB}(:objects )"
    init = fluents_to_pddl(
        fluents=parse_init(loaded_yaml["context_variables"])[0],
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


if __name__ == "__main__":
    base = Path(__file__).parent.parent
    f = str((base / "yaml_samples/advanced_custom_actions_test_v3.yaml").resolve())
    parse_to_pddl(convert_yaml(f))
