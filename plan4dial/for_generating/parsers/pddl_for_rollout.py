"""This module contains all the functions necessary to store the PDDL fluent
configuration in an easy-to-access way so that given an action, we can easily retrieve
what fluents are in its preconditions and which fluents are in each of its outcomes.
This is only used for the rollout implementation for beam search, as it needs to be
able to traverse the conversation based on ALL applicable actions and not just the
solution generated by the PRP planner.

Authors:
- Rebecca De Venezia
"""

from .pddl_parser import (
    get_precond_fluents,
    get_update_fluents,
    get_init_fluents,
)
from typing import Dict


def rollout_config(configuration_data: Dict) -> Dict:
    """Given the configuration data, generates a PDDL configuration in dict form for
    ease in calculating applicable actions in conversation rollouts.

    Args:
        configuration_data (Dict): The configuration data for the domain.

    Returns:
        Dict: The PDDL configuration in a dict form.
    """

    # initialize the actions with conditions
    actions = {
        act: {
            "condition": list(
                get_precond_fluents(
                    configuration_data["context_variables"], act_cfg["condition"]
                )
            ),
            "effect": {},
        }
        for act, act_cfg in configuration_data["actions"].items()
    }
    # instantiate the outcomes with update fluents
    for act, act_cfg in configuration_data["actions"].items():
        for out in act_cfg["effect"]["outcomes"]:
            if "updates" in out:
                actions[act]["effect"][out["name"]] = list(
                    get_update_fluents(
                        configuration_data["context_variables"], out["updates"]
                    ).difference(set(actions[act]["condition"]))
                )
    # return the actions, and initial state, and all fluents
    return {
        "actions": actions,
        "initial_state": list(
            get_init_fluents(configuration_data["context_variables"])[1]
        ),
        "partial": {act: [] for act in actions},
    }
