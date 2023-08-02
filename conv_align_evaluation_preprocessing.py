import json
import random


def del_from_rollout(num_delete: int, path: str):
    with open(path, "r") as f:
        rollout_config = json.load(f)
        actions = rollout_config["actions"]
    partial = {act: set() for act in actions}
    idx = 0
    skip_acts = set()
    while idx < num_delete:
        # first randomly select an action that we haven't yet determined is empty
        act = random.choice(list(set(actions.keys()).difference(skip_acts)))
        # filter by outcomes that have at least one fluent
        filtered_outs = [
            out for out, out_cfg in actions[act]["effect"].items() if len(out_cfg) > 0
        ]
        if not filtered_outs:
            skip_acts.add(act)
            continue
        outcome = random.choice(filtered_outs)
        partial[act].add(outcome)
        actions[act]["effect"][outcome].remove(
            random.choice(actions[act]["effect"][outcome])
        )
        idx += 1
    rollout_config["actions"] = actions
    rollout_config["partial"] = {act: list(out) for act, out in partial.items()}
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


if __name__ == "__main__":
    del_percent_from_rollout(
        0.3,
        "/home/rebecca/plan4dial/plan4dial/local_data/gold_standard_bot/\
            output_files/rollout_config.json",
    )
