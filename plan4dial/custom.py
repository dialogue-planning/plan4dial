from typing import List, Dict
import itertools
import json

def map_update(entity: str, certainty: str):
    return {
        "Certain": {
            entity: {
                "value": f"${entity}",
                "known": True
            }
        },
        "Uncertain": {
            entity: {
                "value": f"${entity}",
                "known": "maybe"
            }
        },
        "Unknown": {
            entity: {
                "value": None,
                "known": False
            }
        }
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
                        "intent": "deny"
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
                        "intent": "deny"
                    },         
                },
            }
        }
    }
    return {f"single_slot__{entity}": single_slot}  

def slot_fill(action_name: str, message_variants: List[str], entities: List[str], clarify_messages: Dict, valid_intent: str, valid_follow_up: str=None, additional_updates: Dict=None):
    entity_combos = []
    # create the cross-product of certain, uncertain, and unknown with the entities given
    for entity in entities:
        entity_combos.append([p for p in itertools.product([entity], ["Certain", "Uncertain", "Unknown"])])
    entity_combos = itertools.product(*entity_combos)
    actions = {}
    actions["type"], actions["subtype"] = "dialogue", "dialogue disambiguation"
    actions["message_variants"] = message_variants
    actions["condition"] = {}
    for entity in entities:
        actions["condition"].update(map_update(entity, "Unknown"))
    actions["effect"] = {
        "validate-slot-fill": {
            "oneof": {
                "outcomes": {}
            }
        }
    }
    for combo in entity_combos:
        next_out = {"updates": {}}
        certainties = [info[1] for info in combo]
        if "Unknown" not in certainties and "Uncertain" not in certainties:
            next_out["intent"] = valid_intent
            if valid_follow_up:
                next_out["follow_up"] = valid_follow_up
        else:
            next_out["intent"] = {entity: certainty for entity, certainty in combo}
        outcome_name = "".join(f"{entity}_{certainty}-" for entity, certainty in combo)[:-1]
        for entity, certainty in combo:
            if certainty != "Unknown":
                next_out["updates"].update(map_update(entity, certainty))
        if next_out["updates"]:
            actions["effect"]["validate-slot-fill"]["oneof"]["outcomes"][outcome_name] = next_out
    actions = {action_name: actions}

    for clarify_action in [clarify_act(entity, clarify_messages[entity]) for entity in entities]:
        actions.update(clarify_action)
    if len(entities) > 1:
        for single_slot_action in [single_slot(entity) for entity in entities]:
            actions.update(single_slot_action)
    print(json.dumps(actions, indent=4))
    return actions

slot_fill("slot-fill-locations", ["please give your locations"], ["loc1", "loc2", "loc3"], {"loc1": "clarify loc1", "loc2": "clarify loc2", "loc3": "clarify loc3"}, "share_locs")