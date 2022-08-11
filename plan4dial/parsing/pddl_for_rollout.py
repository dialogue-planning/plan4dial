from plan4dial.parsing.pddl_parser import get_precond_fluents, get_update_fluents, parse_init

def rollout_config(configuration):
    actions = {act: {"condition": list(get_precond_fluents(act_cfg["condition"])), "effect": {}} for act, act_cfg in configuration["actions"].items()}
    for act, act_cfg in configuration["actions"].items():
        for out in act_cfg["effect"]["outcomes"]:
            if "updates" in out:
                actions[act]["effect"][out["name"].split(f"{act}_DETDUP_{act_cfg['effect']['global-outcome-name']}-EQ-")[1]] = list(get_update_fluents(out["updates"]))
    return {"actions": actions, "initial_state": list(parse_init(configuration["context-variables"])[1])} 