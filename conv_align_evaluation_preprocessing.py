import json
import random
from typing import Dict


def write_to_file(actions: Dict, partial: Dict, rollout_config: Dict, path: str):
    rollout_config["actions"] = actions
    rollout_config["partial"] = {act: list(out) for act, out in partial.items()}
    with open(path, "w") as f:
        f.write(json.dumps(rollout_config, indent=4))


def del_fluent_from_rollout(fluent_name: str, path: str):
    with open(path, "r") as f:
        rollout_config = json.load(f)
        actions = rollout_config["actions"]
        partial = {act: set() for act in actions}
    for act, act_cfg in actions.items():
        if fluent_name in act_cfg["condition"]:
            # note that we don't include conditions in `partial` because deleting
            # a condition makes the action applicable in MORE states
            act_cfg["condition"].remove(fluent_name)
        for out in act_cfg["effect"]:
            if fluent_name in act_cfg["effect"][out]:
                act_cfg["effect"][out].remove(fluent_name)
                partial[act].add(out)
    write_to_file(actions, partial, rollout_config, path)


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
    write_to_file(actions, partial, rollout_config, path)


def del_percent_from_rollout(percent: float, path: str):
    with open(path, "r") as f:
        rollout_config = json.load(f)
        actions = rollout_config["actions"]
    num_fluents = 0
    for _, act_cfg in actions.items():
        for _, out in act_cfg["effect"].items():
            num_fluents += len(out)
    del_from_rollout(int(percent * num_fluents), path)


if __name__ == "__main__":
    del_fluent_from_rollout(
        "(have-message)",
        "/home/rebecca/plan4dial/plan4dial/local_data/gold_standard_bot/\
output_files/rollout_config.json",
    )
