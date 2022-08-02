from typing import List, Dict
import itertools
from utils import *


def slot_fill(
    loaded_yaml: Dict,
    action_name: str,
    message_variants: List[str],
    entities: List[str],
    clarify: Dict,
    fallback_message_variants: List[str],
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
    new_actions, new_ctx_vars = create_clarifications_single_slots(action_name, action, entities, clarify, additional_updates)
    actions.update(new_actions)
    loaded_yaml["actions"].update(actions)
    loaded_yaml["context-variables"].update(new_ctx_vars)
