"""Util functions that are useful in custom actions.

Authors:
- Rebecca De Venezia
"""
from typing import Dict


def map_assignment_update(entity: str, assignment: str) -> Dict:
    """Given an entity and its assignment, returns the corresponding update.

    Args:
        entity (str): The entity in the update.
        assignment (str): The assignment that describes if/how the entity was found.

    Returns:
        Dict: The update that corresponds to the entity and assignment provided.
    """
    return {
        "found": {entity: {"value": f"${entity}", "known": True}},
        "maybe-found": {entity: {"value": f"${entity}", "known": "maybe"}},
        "didnt-find": {entity: {"value": None, "known": False}},
    }[assignment]

def make_additional_updates(org_out: Dict, add_upd: Dict) -> None:
    """Update an outcome by the additional updates provided by the suer.

    Args:
        org_out (Dict): The original outcome.
        add_upd (Dict): The additional updates to be added to the outcome.
    """
    if "updates" in add_upd:
        org_out["updates"].update(add_upd["updates"])
    if "response_variants" in add_upd:
        org_out["response_variants"] = add_upd["response_variants"]
    if "follow_up" in add_upd:
        org_out["follow_up"] = add_upd["follow_up"]
