from typing import List, Dict
import itertools


def map_update(entity: str, certainty: str):
    return {
        "Certain": {entity: {"value": f"${entity}", "known": True}},
        "Uncertain": {entity: {"value": f"${entity}", "known": "maybe"}},
        "Unknown": {entity: {"value": None, "known": False}},
    }[certainty]


def clarify_act(entity: str, message_variants: List[str]):
    clarify = {}
    clarify["type"], clarify["subtype"] = "dialogue", "dialogue disambiguation"
    clarify["message_variants"] = message_variants
    clarify["condition"] = {entity: {"known": "maybe"}}
    clarify["effect"] = {
        "validate-clarification": {
            "oneof": {
                "outcomes": {
                    "confirm": {
                        "updates": map_update(entity, "Certain"),
                        "intent": "confirm",
                    },
                    "deny": {
                        "updates": map_update(entity, "Unknown"),
                        "intent": "deny",
                    },
                },
            }
        }
    }
    return {f"clarify__{entity}": clarify}


def single_slot(entity: str):
    single_slot = {}
    single_slot["type"], single_slot["subtype"] = "dialogue", "dialogue disambiguation"
    single_slot["message_variants"] = [f"Please enter a valid value for {entity}."]
    single_slot["condition"] = {entity: {"known": "maybe"}}
    single_slot["effect"] = {
        "validate-clarification": {
            "oneof": {
                "outcomes": {
                    "confirm": {
                        "updates": map_update(entity, "Certain"),
                        "intent": "confirm",
                    },
                    "deny": {
                        "updates": map_update(entity, "Unknown"),
                        "intent": "deny",
                    },
                },
            }
        }
    }
    return {f"single_slot__{entity}": single_slot}


def slot_fill(
    action_name: str,
    message_variants: List[str],
    entities: List[str],
    clarify_messages: Dict,
    fallback_message_variants: List,
    valid_intent: str,
    valid_follow_up: str = None,
    additional_valid_updates: Dict = None,
):
    entity_combos = []
    # create the cross-product of certain, uncertain, and unknown with the entities given
    for entity in entities:
        entity_combos.append(
            [
                p
                for p in itertools.product(
                    [entity], ["Certain", "Uncertain", "Unknown"]
                )
            ]
        )
    entity_combos = itertools.product(*entity_combos)
    action = {}
    action["type"], action["subtype"] = "dialogue", "dialogue disambiguation"
    action["message_variants"] = message_variants
    action["fallback_message_variants"] = fallback_message_variants
    action["condition"] = {}
    for entity in entities:
        action["condition"].update(map_update(entity, "Unknown"))
    action["effect"] = {"validate-slot-fill": {"oneof": {"outcomes": {}}}}
    for combo in entity_combos:
        next_out = {"updates": {}}
        certainties = [info[1] for info in combo]
        if "Unknown" not in certainties and "Uncertain" not in certainties:
            next_out["intent"] = valid_intent
            if valid_follow_up:
                next_out["follow_up"] = valid_follow_up
            if additional_valid_updates:
                next_out["updates"].update(additional_valid_updates)
        else:
            next_out["intent"] = {entity: certainty for entity, certainty in combo}
        outcome_name = "".join(f"{entity}_{certainty}-" for entity, certainty in combo)[
            :-1
        ]
        for entity, certainty in combo:
            if certainty != "Unknown":
                next_out["updates"].update(map_update(entity, certainty))
        if next_out["updates"]:
            action["effect"]["validate-slot-fill"]["oneof"]["outcomes"][
                outcome_name
            ] = next_out
    actions = {action_name: action}

    for clarify_action in [
        clarify_act(entity, clarify_messages[entity]) for entity in entities
    ]:
        actions.update(clarify_action)
    if len(entities) > 1:
        for single_slot_action in [single_slot(entity) for entity in entities]:
            actions.update(single_slot_action)
    return actions
