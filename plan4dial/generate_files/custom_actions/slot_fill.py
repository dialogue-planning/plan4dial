"""Contains all the functions for the `slot_fill` custom action that is
provided to bot designers by default.

Authors:
- Rebecca De Venezia
"""

from typing import List, Dict
import itertools
from .utils import _map_assignment_update


def slot_fill(
    loaded_yaml: Dict,
    action_name: str,
    message_variants: List[str],
    entities: List[str],
    config_entities: Dict,
    fallback_message_variants: List[str],
    additional_updates: Dict = None,
) -> None:
    """Custom action provided by default that allows bot designers to specify
    entity slot fills with ease.

    Handles actions that can be clarified, as well as those that can't, or a
    mix of both. This depends on what the `known`'s `type` setting is for each
    entity in the YAML.

    Also handles "partial" extraction, where the bot asks for multiple entities
    but is only able to extract some. In that case, the bot will follow up with
    `clarify` actions in which it tries to extract uncertain entities, or
    `slot_fill` actions in which it tries to extract unknown entities
    individually in order to make up for the missing information (only used
    when there are > 1 entities specified).

    Additional outcomes can also be specified for certain outcomes, i.e. when
    entity `pizza` is extracted, respond with the given `response_variants`.

    Args:
    - loaded_yaml (Dict): The loaded YAML configuration.
    - action_name (str): The name of this instance of the custom action.
    - message_variants (List[str]): Possible messages the bot will utter upon
    execution of this action.
    - entities (List[str]): The entities to be extracted or have their "slots
    filled."
    - config_entities (Dict): Holds configurations that specify what the bot
    should do in certain situations regarding each entity. The keys are each
    entity and the values are the configuration for each entity.

    The 3 configuration options are:
        - clarify_message_variants (List[str]): The message variants that will
        be used for the clarify action for this entity. Only necessary if the
        `known` `type` of this entity is of type `fflag`.
        - single_slot_message_variants (List[str]): Custom message variants to
        utter for `single_slot` extractions of the given entity. Only necessary
        to specify if there are > 1 entities.
        - fallback_message_variants (List[str]): Custom fallback messages to
        utter if the bot tries to extract this entity by itself with a
        `single_slot` action and fails. Differs from the outer 
        `fallback_message_variants` parameter, which applies to the initial
        `slot_fill` action only. The default fallback messages will replace 
        this parameter if not specified.

    - fallback_message_variants (List[str]): Custom fallback messages to utter
    if the bot fails to extract any entities.
    - additional_updates (Dict, optional): Additional updates to specify when
    a given extraction happens AT ANY POINT. Indicate the extraction that 
    happens in the outcome by specifying the `known` status of the entities you
    desire. You can not only use this to add arbitrary context variable
    updates under `also_update`, but also other outcome-specific attributes
    such as `response_variants`. NOTE: Will only match to outcomes that match
    the given specification exactly. For example, if you specify an additional
    update for when `test1` is known, updates would only be added to actions
    where ONLY `test1` is extracted, and not when `test1`, `test2` and `test3`
    are extracted, for example. This is done to reduce ambiguity. 
    Defaults to None.

    See the tutorial in `README.md` for an example of a `slot_fill` action.
    """
    if additional_updates:
        for i in range(len(additional_updates)):
            for update in additional_updates[i]["outcome"]:
                additional_updates[i]["outcome"][update] = (
                    (
                        "found"
                        if additional_updates[i]["outcome"][update]["known"]
                        else "didnt-find"
                    )
                    if type(additional_updates[i]["outcome"][update]["known"]) == bool
                    else "maybe-found"
                )
        cfg_updates = {}
        for setting in additional_updates:
            key = frozenset(
                {
                    entity: certainty
                    for entity, certainty in setting["outcome"].items()
                    if certainty != "didnt-find"
                }.items()
            )
            cfg_updates[key] = {}
            if "also_update" in setting:
                cfg_updates[key]["updates"] = setting["also_update"]
            if "response_variants" in setting:
                cfg_updates[key]["response_variants"] = setting["response_variants"]
    entity_combos = []
    # create the cross-product of found, maybe-found, and didnt-find with the entities given
    for entity in entities:
        entity_combos.append(
            [
                p
                for p in itertools.product(
                    [entity],
                    (
                        ["found", "maybe-found", "didnt-find"]
                        if loaded_yaml["context_variables"][entity]["known"]["type"]
                        == "fflag"
                        else ["found", "didnt-find"]
                    ),
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
        action["condition"].update(_map_assignment_update(entity, "didnt-find"))
    action["effect"] = {"validate-slot-fill": {"oneof": {"outcomes": {}}}}
    for combo in entity_combos:
        next_out = {"updates": {}}
        next_out["intent"] = {
            entity: certainty
            for entity, certainty in combo
            if certainty != "didnt-find"
        }
        outcome_name = "".join(
            f"{entity}_{certainty}-"
            for entity, certainty in combo
            if certainty != "didnt-find"
        )[:-1]
        for entity, certainty in combo:
            if certainty != "didnt-find":
                next_out["updates"].update(_map_assignment_update(entity, certainty))

        if additional_updates:
            key = frozenset(
                {
                    entity: certainty
                    for entity, certainty in combo
                    if certainty != "didnt-find"
                }.items()
            )
            if key in cfg_updates:
                if "updates" in cfg_updates[key]:
                    next_out["updates"].update(cfg_updates[key]["updates"])
                if "response_variants" in cfg_updates[key]:
                    next_out["response_variants"] = cfg_updates[key][
                        "response_variants"
                    ]
        if next_out["updates"]:
            action["effect"]["validate-slot-fill"]["oneof"]["outcomes"][
                outcome_name
            ] = next_out
    actions = {f"slot-fill__{action_name}": action}
    new_actions, new_ctx_vars = _create_clarifications_single_slots(
        action_name, action, entities, config_entities, additional_updates
    )
    actions.update(new_actions)
    loaded_yaml["actions"].update(actions)
    loaded_yaml["context_variables"].update(new_ctx_vars)

def _clarify_act(entity: str, message_variants: List[str], single_slot: bool, additional_updates: Dict = None):
    deny_updates = _map_assignment_update(entity, "didnt-find")
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
                        "updates": _map_assignment_update(entity, "found"),
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


def _single_slot(entity: str, clarify_cfg: Dict, additional_updates: Dict = None):
    fill_slot_updates = _map_assignment_update(entity, "found")
    slot_unclear_updates = _map_assignment_update(entity, "maybe-found")
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
    if "fallback_message_variants" in clarify_cfg:
        single_slot["fallback_message_variants"] = clarify_cfg[
            "fallback_message_variants"
        ]

    return {f"single_slot__{entity}": single_slot}


def _create_clarifications_single_slots(
    original_act_name: str,
    original_act_config: Dict,
    entities: List[str],
    config_entities: Dict,
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
                    if "updates" in out_config:
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
                                    _single_slot(
                                        entity, config_entities[entity], additional_updates
                                    )
                                )
        new_actions[original_act_name] = original_act_config
    for entity in entities:
        # only create clarify actions if clarify messages were specified
        if "clarify_message_variants" in config_entities[entity]:
            new_actions.update(
                _clarify_act(
                    entity,
                    config_entities[entity]["clarify_message_variants"],
                    f"allow_single_slot_{entity}" in new_ctx_vars,
                )
            )
    return new_actions, new_ctx_vars
