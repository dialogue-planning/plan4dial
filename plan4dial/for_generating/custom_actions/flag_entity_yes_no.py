from .utils import make_additional_updates
from typing import List, Dict


def flag_entity_yes_no(
    loaded_yaml: Dict,
    action_name: str,
    message_variants: List[str],
    entity: str,
    confirm_intent: str = "confirm",
    deny_intent: str = "deny",
    additional_conditions: Dict = None,
    additional_updates: Dict = None,
):
    """Custom dialoigue action that updates the value of a flag/bool entity based on
    the user's response to a yes/no question.

    Args:
        loaded_yaml (Dict): The loaded YAML configuration.
        action_name (str): The name of this instance of the custom action.
        message_variants (List[str]): Possible messages the bot will utter upon
            execution of this action.
        entity (str): The flag entity to be set.
        confirm_intent (str, optional): The intent that indicates the user is saying
            "yes". Defaults to "confirm".
        deny_intent (str, optional): The intent that indicates the user is saying
            "no". Defaults to "deny".
        additional_conditions (Dict, optional): Additional conditions necessary before
            executing the :py:func:`flag_entity_yes_no
            <plan4dial.for_generating.custom_actions.flag_entity_yes_no.
            flag_entity_yes_no>` action. Defaults to None.
        additional_updates (Dict, optional): Additional updates to occur at either
            outcome. Specify "confirm_outcome" as the key when you want to add
            additional updates when the user confirms and "deny_outcome" for the
            opposite. Defaults to None.
    """
    # instantiate the action
    action = {}
    action["type"] = "dialogue"
    action["message_variants"] = message_variants
    action["condition"] = {entity: {"known": False}}
    if additional_conditions:
        action["condition"].update(additional_conditions)
    confirm_outcome_upd = {
                            "updates": {entity: {"known": True, "value": True}},
                            "intent": confirm_intent,
                          }
    deny_outcome_upd = {
                        "updates": {entity: {"known": True, "value": False}},
                        "intent": deny_intent,
                       }

    if additional_updates:
        if "confirm_outcome" in additional_updates:
            make_additional_updates(confirm_outcome_upd,
                                    additional_updates["confirm_outcome"])
        if "deny_outcome" in additional_updates:
            make_additional_updates(deny_outcome_upd,
                                    additional_updates["deny_outcome"])
    action["effect"] = {
        "get-response": {
            "oneof": {
                "outcomes": {
                    "confirm_outcome": confirm_outcome_upd,
                    "deny_outcome": deny_outcome_upd
                }
            }
        }
    }
    loaded_yaml["actions"].update({f"slot-fill__{action_name}": action})
