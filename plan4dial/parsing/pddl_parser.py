from typing import Dict, List
import yaml
import json
from pathlib import Path
from preprocessing import preprocess_yaml

TAB = " " * 4


def return_certainty_predicates(pred_name: str, known: bool):
    if known == True:
        return [f"(have_{pred_name})", f"(not (maybe-have_{pred_name}))"]
    elif known == False:
        return [f"(not (have_{pred_name}))", f"(not (maybe-have_{pred_name}))"]
    elif known == "maybe":
        return [f"(not (have_{pred_name}))", f"(not (maybe-have_{pred_name}))"]


def fluents_to_pddl(fluents: List[str], tabs: int):
    return (
        (("\n" + TAB * tabs) + "{0}".format(("\n" + TAB * tabs).join(fluents)))
        if len(fluents) > 0
        else ""
    )


def fluents_to_pddl_and(fluents: List[str], tabs: int):
    return (
        "\n"
        + (TAB * tabs)
        + f"(and{fluents_to_pddl(fluents, tabs + 1)}\n"
        + ("\n" + TAB * tabs + ")")
        if len(fluents) > 0
        else ""
    )


def predicates_to_pddl(predicates: List[str]):
    return f"{TAB}(:predicates{fluents_to_pddl_and(predicates, 2)}\n{TAB})"


def action_to_pddl(act: str, act_config: Dict):
    act_param = f"{TAB}(:action {act}\n{TAB * 2}:parameters()"
    for cond, cond_config in act_config["condition"].items():
        precond = []
        for cond_config_key, cond_config_val in cond_config.items():
            if cond_config_key == "known":
                precond.extend(return_certainty_predicates(cond, cond_config_val))
            precond.append(f"(can-do__{act})")

    precond = f"\n{TAB * 2}:precondition{fluents_to_pddl_and(precond, 2)}"
    effects = f"\n{TAB * 2}:effect"
    for eff, eff_config in act_config["effects"].items():
        effects += f"\n{TAB * 3}(labeled-oneof {eff}"
        for eff_type in eff_config:
            for out, out_config in eff_config[eff_type]["outcomes"].items():
                outcomes = []
                if "updates" in out_config:
                    for update_var, update_config in out_config["updates"].items():
                        if "known" in update_config:
                            outcomes.extend(
                                return_certainty_predicates(
                                    update_var, update_config["known"]
                                )
                            )
                        if "can-do" in update_config:
                            outcomes.append(f"(can-do__{update_var})" if update_config["can-do"] else f"(not (can-do__{update_var}))")
                effects += f"\n{TAB * 4}(outcome {out}{fluents_to_pddl_and(outcomes, 5)}\n{TAB * 4})"
        effects += f"\n{TAB * 3})"
    return act_param + precond + effects + f"\n{TAB})"

def actions_to_pddl(actions: Dict):
    return "\n".join([action_to_pddl(act, act_config) for act, act_config in actions.items()])

def parse_predicates(context_variables: Dict, actions: List[str]):
    predicates = []
    for var, var_config in context_variables.items():
        if "known" in var_config:
            predicates.append(f"(have_{var})")
            if var_config["known"]["type"] == "fflag":
                predicates.append(f"(maybe-have_{var})")
        else:
            predicates.append(f"({var})")
    for act in actions:
        predicates.append(f"(can-do__{act})")
    return predicates


def parse_to_pddl(loaded_yaml: Dict):
    predicates = parse_predicates(
        loaded_yaml["context-variables"], loaded_yaml["actions"].keys()
    )
    predicates = predicates_to_pddl(predicates)
    actions = actions_to_pddl(loaded_yaml["actions"])
    return f"(define\n{TAB}(domain {loaded_yaml['name']}\n{TAB}(:requirements :strips :typing)\n{TAB}(:types )\n{TAB}(:constants )\n{predicates}\n{actions}\n)"

if __name__ == "__main__":
    base = Path(__file__).parent.parent
    f = str((base / "yaml_samples/order_pizza.yaml").resolve())
    # print(json.dumps(parse_to_pddl(preprocess_yaml(f)), indent=4))
    print(parse_to_pddl(preprocess_yaml(f)))