"""This module contains all the files necessary to convert from the HOVOR
configuration to PDDL. This PDDL is later used to generate the controller/tree
that determines how the conversation is navigated.

Authors:
- Rebecca De Venezia
"""

from plan4dial.parsers.pddl_parser import (
    get_precond_fluents,
    get_update_fluents,
    parse_init,
)
from typing import List


def convert_to_hovor_fluents(fluents: List[str]):
    not_str = "(not "
    for i in range(len(fluents)):
        if not_str in fluents[i]:
            fluents[i] = f"NegatedAtom {fluents[i].split(not_str)[1][1:-2]}()"
        else:
            fluents[i] = f"Atom {fluents[i][1:-1]}()"
    return fluents


def rollout_config(configuration):
    actions = {
        act: {
            "condition": convert_to_hovor_fluents(
                list(
                    get_precond_fluents(
                        configuration["context_variables"], act_cfg["condition"]
                    )
                )
            ),
            "effect": {},
        }
        for act, act_cfg in configuration["actions"].items()
    }
    for act, act_cfg in configuration["actions"].items():
        for out in act_cfg["effect"]["outcomes"]:
            if "updates" in out:
                actions[act]["effect"][out["name"]] = convert_to_hovor_fluents(
                    list(
                        get_update_fluents(
                            configuration["context_variables"], out["updates"]
                        )
                    )
                )
    return {
        "actions": actions,
        "initial_state": convert_to_hovor_fluents(
            list(parse_init(configuration["context_variables"])[1])
        ),
    }
