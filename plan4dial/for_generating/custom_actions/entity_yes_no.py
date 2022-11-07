from typing import List, Dict


def entity_yes_no(
    loaded_yaml: Dict,
    action_name: str,
    message_variants: List[str],
    entity: str,
    additional_conditions: Dict = None,
    confirm_intent: str = "confirm",
    deny_intent: str = "deny",
):
    # instantiate the action
    action = {}
    action["type"] = "dialogue"
    action["message_variants"] = message_variants
    action["condition"] = {entity: {"known": False}}
    if additional_conditions:
        action["condition"].update(additional_conditions)
    action["effect"] = {
        "get-response": {
            "oneof": {
                "outcomes": {
                    "confirm_outcome": {
                        "updates": {entity: {"known": True, "value": True}},
                        "intent": confirm_intent,
                    },
                    "deny_outcome": {
                        "updates": {entity: {"known": True, "value": False}},
                        "intent": deny_intent,
                    },
                }
            }
        }
    }
    loaded_yaml["actions"].update({f"slot-fill__{action_name}": action})
