"""Util functions that are useful in custom actions.

Authors:
- Rebecca De Venezia
"""
from typing import Dict

def map_assignment_update(entity: str, assignment: str) -> Dict:
    """Given an entity and its assignment, returns the corresponding 
    update.

    Args:
    - entity (str): The entity in the update.
    - assignment (str): The assignment that describes if/how the entity
    was found.

    Returns:
    - (Dict): The update that corresponds to the entity and assignment
    provided.
    """
    return {
        "found": {entity: {"value": f"${entity}", "known": True}},
        "maybe-found": {entity: {"value": f"${entity}", "known": "maybe"}},
        "didnt-find": {entity: {"value": None, "known": False}},
    }[assignment]
