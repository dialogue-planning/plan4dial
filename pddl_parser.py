from typing import Dict, List
import yaml

TAB = " " * 4


def return_certainty_predicates(pred_name: str, known: bool):
    if known == True:
        return [f"(have_{pred_name})", f"(not (maybe-have_{pred_name}))"]
    elif known == False:
        return [f"(not (have_{pred_name}))", f"(not (maybe-have_{pred_name}))"]
    elif known == "maybe":
        return [f"(not (have_{pred_name}))", f"(not (maybe-have_{pred_name}))"]

def fluents_to_pddl(fluents: List[str], tabs: int):
    return (('\n' + '\t' * tabs) + "{0}".format(('\n' + '\t' * tabs).join(fluents))) if len(fluents) > 0 else ""

def fluents_to_pddl_and(fluents: List[str], tabs: int):
    return '\n' + ('\t' * (tabs - 1)) + f"(and{fluents_to_pddl(fluents, tabs)}\n" + ("\n" + '\t' * (tabs - 1) + ")") if len(fluents) > 0 else ""

def predicates_to_pddl(predicates: List[str]):
    return f"(:predicates{fluents_to_pddl_and(predicates, 2)}\n)"

def action_to_pddl(act: str, act_config: Dict):
    act_param = f"(:action {act}\n\t:parameters()"
    for cond, cond_config in act_config["condition"].items():
        precond = []
        for cond_config_key, cond_config_val in cond_config.items():
            if cond_config_key == "known":
                precond.extend(return_certainty_predicates(cond, cond_config_val))
    precond = f"\n\t:precondition{fluents_to_pddl_and(precond, 3)}"
    effects = "\n\t:effect"
    for eff, eff_config in act_config["effects"].items():
        effects += f"\n{(TAB * 2)}(labeled-oneof {eff}"
        for eff_type in eff_config:
            for out, out_config in eff_config[eff_type]["outcomes"].items():
                outcomes = []
                if "updates" in out_config:
                    for update_var, update_config in out_config["updates"].items():
                        if "known" in update_config:
                            outcomes.extend(return_certainty_predicates(update_var, update_config["known"]))
                effects += f"\n{(TAB * 3)}(outcome {out}{fluents_to_pddl_and(outcomes, 3)}\n{(TAB * 3)})"
        effects += F"\n{(TAB * 2)})"
    return act_param + precond + effects + "\n)"

def actions_to_pddl(actions: Dict):
    for act, act_config in actions.items():
        # do for now until you move out preprocessing
        if act != "check-order-availability":
            continue
        print(action_to_pddl(act, act_config))

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
        predicates.append(f"(can-do_{act})")
    return predicates

def parse_to_pddl(filename: str):
    # load in the yaml
    loaded_yaml = yaml.load(open(filename, "r"), Loader=yaml.FullLoader)
    predicates = parse_predicates(loaded_yaml["context-variables"], loaded_yaml["actions"].keys())
    predicates = predicates_to_pddl(predicates)
    print(predicates)
    # parsed_actions = parse_actions(loaded_yaml["actions"])
    actions_to_pddl(loaded_yaml["actions"])
    print()
    

if __name__ == "__main__":
    parse_to_pddl("yaml_samples/order_pizza.yaml")
