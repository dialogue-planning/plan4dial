from typing import List, Dict


def flag_entity_yes_no(
    loaded_yaml: Dict,
    action_name: str,
    message_variants: List[str],
    entity: str,
    confirm_intent: str = "confirm",
    deny_intent: str = "deny",
    additional_conditions: Dict = None,
    additional_updates: Dict = None
):
    # instantiate the action
    action = {}
    action["type"] = "dialogue"
    action["message_variants"] = message_variants
    action["condition"] = {entity: {"known": False}}
    if additional_conditions:
        action["condition"].update(additional_conditions)
    confirm_outcome_upd = {entity: {"known": True, "value": True}}
    deny_outcome_upd = {entity: {"known": True, "value": False}}
    if additional_updates:
        if "confirm_outcome" in additional_updates:
            confirm_outcome_upd.update(additional_updates["confirm_outcome"])
        if "deny_outcome" in additional_updates:
            deny_outcome_upd.update(additional_updates["deny_outcome"])
    action["effect"] = {
        "get-response": {
            "oneof": {
                "outcomes": {
                    "confirm_outcome": {
                        "updates": confirm_outcome_upd,
                        "intent": confirm_intent,
                    },
                    "deny_outcome": {
                        "updates": deny_outcome_upd,
                        "intent": deny_intent,
                    }
                }
            }
        }
    }
    loaded_yaml["actions"].update({f"slot-fill__{action_name}": action})
