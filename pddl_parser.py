from typing import Dict, List
import yaml


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
    act_param_precond = f"(:action {act}\n\t:parameters()\n\t:precondition{act_config['precondition']}"
    # assume we always have a labeled-oneof
    effects = "\n\t:effect"
    for eff, eff_config in act_config["effects"].items():
        effects += f"\n\t\t(labeled-oneof {eff}"
        for eff_type in eff_config:
            for out, out_config in eff_config[eff_type].items():
                effects += f"\n\t\t\t(outcome {out}\n\t{out_config}\n\t\t\t)"
        effects += "\n\t\t)"
    return act_param_precond + effects

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

def parse_actions(actions: Dict):
    parsed_actions = {}
    for act, act_config in actions.items():
        parsed_actions[act] = {"precondition": {}, "effects": {}}
        # do for now until you move out preprocessing
        if act != "check-order-availability":
            continue
        for cond, cond_config in act_config["condition"].items():
            parsed_actions[act]["precondition"] = []
            for cond_config_key, cond_config_val in cond_config.items():
                if cond_config_key == "known":
                    parsed_actions[act]["precondition"].extend(return_certainty_predicates(cond, cond_config_val))
        parsed_actions[act]["precondition"] = fluents_to_pddl_and(parsed_actions[act]["precondition"], 3)
        for eff, eff_config in act_config["effects"].items():
            parsed_actions[act]["effects"][eff] = {}
            for eff_type in eff_config:
                parsed_actions[act]["effects"][eff][eff_type] = {}
                for out, out_config in eff_config[eff_type]["outcomes"].items():
                    parsed_actions[act]["effects"][eff][eff_type][out] = []
                    if "updates" in out_config:
                        for update_var, update_config in out_config["updates"].items():
                            if "known" in update_config:
                                parsed_actions[act]["effects"][eff][eff_type][out].extend(return_certainty_predicates(update_var, update_config["known"]))
                    parsed_actions[act]["effects"][eff][eff_type][out] = fluents_to_pddl_and(parsed_actions[act]["effects"][eff][eff_type][out], 5)        
    return parsed_actions

def parse_to_pddl(filename: str):
    # load in the yaml
    loaded_yaml = yaml.load(open(filename, "r"), Loader=yaml.FullLoader)
    predicates = parse_predicates(loaded_yaml["context-variables"], loaded_yaml["actions"].keys())
    predicates = predicates_to_pddl(predicates)
    print(predicates)
    parsed_actions = parse_actions(loaded_yaml["actions"])
    actions_to_pddl(parsed_actions)
    print()
    

if __name__ == "__main__":
    parse_to_pddl("yaml_samples/order_pizza.yaml")
