from pickletools import string1
from textwrap import fill
from typing import List, Dict
import itertools


def map_update(entity: str, certainty: str):
    return {
        "found": {entity: {"value": f"${entity}", "known": True}},
        "maybe-found": {entity: {"value": f"${entity}", "known": "maybe"}},
        "didnt-find": {entity: {"value": None, "known": False}},
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
                        "updates": map_update(entity, "found"),
                        "intent": "confirm",
                    },
                    "deny": {
                        "updates": map_update(entity, "didnt-find"),
                        "intent": "deny",
                    },
                },
            }
        }
    }
    return {f"clarify__{entity}": clarify}


def single_slot(entity: str, additional_updates: Dict):#, intent:str, message_variants: List[str]):
    fill_slot_updates = map_update(entity, "found")
    slot_unclear_updates = map_update(entity, "maybe-found")
    key = frozenset({entity: "found"}.items())
    if key in additional_updates:
        fill_slot_updates.update(additional_updates[key])
    key = frozenset({entity: "maybe-found"}.items())
    if key in additional_updates:
        slot_unclear_updates.update(additional_updates[key])
    single_slot = {}
    single_slot["type"], single_slot["subtype"] = "dialogue", "dialogue disambiguation"
    single_slot["message_variants"] = [f"Please enter a valid value for {entity}."]
    single_slot["condition"] = {entity: {"known": False}}
    single_slot["effect"] = {
        "validate-clarification": {
            "oneof": {
                "outcomes": {
                    "fill-slot": {
                        "updates": fill_slot_updates,
                        "intent": {entity: "found"},
                    },
                    "slot-unclear": {
                        "updates": slot_unclear_updates,
                        "intent": {entity: "maybe-found"},
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
    fallback_message_variants: List[str],
    # single_slot_fallback: List[str],
    valid_intent: str,
    valid_follow_up: str = None,
    additional_updates: Dict = None,
):
    if additional_updates:
        for i in range(len(additional_updates)):
            for update in additional_updates[i]["outcome"]:
                additional_updates[i]["outcome"][update] = (
                                        ("found" if additional_updates[i]["outcome"][update]["known"] else "didnt-find")
                                        if type(additional_updates[i]["outcome"][update]["known"]) == bool
                                        else "maybe-found"
                                    )
        additional_updates = {frozenset({entity: certainty for entity, certainty in setting["outcome"].items() if certainty != "didnt-find"}.items()): setting["also_update"] for setting in additional_updates}
    entity_combos = []
    # create the cross-product of found, maybe-found, and didnt-find with the entities given
    for entity in entities:
        entity_combos.append(
            [
                p
                for p in itertools.product(
                    [entity], ["found", "maybe-found", "didnt-find"]
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
        action["condition"].update(map_update(entity, "didnt-find"))
    action["effect"] = {"validate-slot-fill": {"oneof": {"outcomes": {}}}}
    for combo in entity_combos:
        next_out = {"updates": {}}
        certainties = [info[1] for info in combo]
        if "didnt-find" not in certainties and "maybe-found" not in certainties:
            next_out["intent"] = valid_intent
            if valid_follow_up:
                next_out["follow_up"] = valid_follow_up
        else:
            next_out["intent"] = {entity: certainty for entity, certainty in combo if certainty != "didnt-find"}
        outcome_name = "".join(f"{entity}_{certainty}-" for entity, certainty in combo if certainty != "didnt-find")[
            :-1
        ]
        for entity, certainty in combo:
            if certainty != "didnt-find":
                next_out["updates"].update(map_update(entity, certainty))
        if additional_updates:
            key = frozenset({entity: certainty for entity, certainty in combo if certainty != "didnt-find"}.items())
            if key in additional_updates:
                next_out["updates"].update(additional_updates[key])
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
        for single_slot_action in [single_slot(entity, additional_updates) for entity in entities]:
            actions.update(single_slot_action)
    return actions
