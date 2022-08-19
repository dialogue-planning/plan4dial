from typing import List, Dict
from copy import deepcopy


def map_update(entity: str, certainty: str):
    return {
        "found": {entity: {"value": f"${entity}", "known": True}},
        "maybe-found": {entity: {"value": f"${entity}", "known": "maybe"}},
        "didnt-find": {entity: {"value": None, "known": False}},
    }[certainty]


def clarify_act(entity: str, message_variants: List[str], single_slot: bool):
    deny_updates = map_update(entity, "didnt-find")
    if single_slot:
        deny_updates[f"allow_single_slot_{entity}"] = {"value": True}
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
                        "updates": deny_updates,
                        "intent": "deny",
                    },
                },
            }
        }
    }
    return {f"clarify__{entity}": clarify}


def single_slot(entity: str, clarify_cfg: Dict, additional_updates: Dict = None):
    fill_slot_updates = map_update(entity, "found")
    slot_unclear_updates = map_update(entity, "maybe-found")
    fill_slot_updates[f"allow_single_slot_{entity}"] = {"value": False}
    if additional_updates:
        key = frozenset({entity: "found"}.items())
        if key in additional_updates:
            fill_slot_updates.update(additional_updates[key])
        key = frozenset({entity: "maybe-found"}.items())
        if key in additional_updates:
            slot_unclear_updates.update(additional_updates[key])
    message_variants = (
        clarify_cfg["single_slot_message_variants"]
        if "single_slot_message_variants" in clarify_cfg
        else [f"Please enter a valid value for {entity.replace('_', ' ')}."]
    )
    single_slot = {}
    single_slot["type"], single_slot["subtype"] = "dialogue", "dialogue disambiguation"
    single_slot["message_variants"] = message_variants
    single_slot["condition"] = {
        entity: {"known": False},
        f"allow_single_slot_{entity}": {"value": True},
    }
    single_slot["effect"] = {
        "validate-slot-fill": {
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
    if "response_variants" in clarify_cfg:
        single_slot["effect"]["validate-slot-fill"]["oneof"]["outcomes"]["fill-slot"][
            "response_variants"
        ] = clarify_cfg["response_variants"]
    if "fallback_message_variants" in clarify_cfg:
        single_slot["fallback_message_variants"] = clarify_cfg[
            "fallback_message_variants"
        ]

    return {f"single_slot__{entity}": single_slot}


def create_clarifications_single_slots(
    original_act_name: str,
    original_act_config: Dict,
    entities: List[str],
    clarify: Dict,
    additional_updates: Dict = None,
):
    new_actions = {}
    new_ctx_vars = {}

    if len(entities) > 1:
        # only resort to single slot actions if we were not able to extract all entities in one go
        for eff, eff_config in original_act_config["effect"].items():
            for option in eff_config:
                outcomes = eff_config[option]["outcomes"]
                for out, out_config in outcomes.items():
                    for entity in entities:
                        if entity not in out_config["updates"]:
                            new_ctx_vars[f"allow_single_slot_{entity}"] = {
                                "type": "flag",
                                "init": False,
                            }
                            original_act_config["effect"][eff][option]["outcomes"][out][
                                "updates"
                            ][f"allow_single_slot_{entity}"] = {"value": True}
                            new_actions.update(
                                single_slot(entity, clarify[entity], additional_updates)
                            )
        new_actions[original_act_name] = original_act_config
        for entity in entities:
            new_actions.update(
                clarify_act(
                    entity,
                    clarify[entity]["message_variants"],
                    f"allow_single_slot_{entity}" in new_ctx_vars,
                )
            )
    return new_actions, new_ctx_vars


def update_config_clarification(
    loaded_yaml: Dict,
    original_act_name: str,
    entities: List[str],
    clarify: Dict,
    additional_updates: Dict = None,
):
    new_actions, new_ctx_vars = create_clarifications_single_slots(
        original_act_name,
        loaded_yaml["actions"][original_act_name],
        entities,
        clarify,
        additional_updates,
    )
    loaded_yaml["actions"].update(new_actions)
    loaded_yaml["context-variables"].update(new_ctx_vars)
