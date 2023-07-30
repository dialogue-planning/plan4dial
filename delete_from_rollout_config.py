import json
import random


def del_from_rollout(num_delete: int, path: str):
    with open(path, "r") as f:
        rollout_config = json.load(f)
        actions = rollout_config["actions"]
    idx = 0
    skip_acts = set()
    while idx < num_delete:
        # first randomly select an action that we haven't yet determined is empty
        act = random.choice(list(set(actions.keys()).difference(skip_acts)))
        # check if the action has conditions/effects available
        filter_cond_effs = []
        # conditions must have at least one fluent
        if len(actions[act]["condition"]) > 0:
            filter_cond_effs.append("condition")
        # filter by outcomes that have at least one fluent
        filtered_outs = [
            out for out, out_cfg in actions[act]["effect"].items() if len(out_cfg) > 0
        ]
        if len(filtered_outs) > 0:
            filter_cond_effs.append("effect")

        if not filter_cond_effs:
            skip_acts.add(act)
            continue

        # randomly select condition or effect
        cond_or_effect = random.choice(filter_cond_effs)
        if cond_or_effect == "effect":
            outcome = random.choice(filtered_outs)
            # want to ensure we are deleting from something that still has fluents left
            if len(actions[act]["effect"][outcome]) == 0:
                continue
            actions[act]["effect"][outcome].remove(
                random.choice(actions[act]["effect"][outcome])
            )
        else:
            if len(actions[act]["condition"]) == 0:
                continue
            actions[act]["condition"].remove(random.choice(actions[act]["condition"]))
        idx += 1

    rollout_config["actions"] = actions
    with open(path, "w") as f:
        f.write(json.dumps(rollout_config, indent=4))


def del_percent_from_rollout(percent: float, path: str):
    with open(path, "r") as f:
        rollout_config = json.load(f)
        actions = rollout_config["actions"]
    num_fluents = 0
    for _, act_cfg in actions.items():
        num_fluents += len(act_cfg["condition"])
        for _, out in act_cfg["effect"].items():
            num_fluents += len(out)
    del_from_rollout(int(percent * num_fluents), path)


del_from_rollout(1, "rollout_config copy.json")
