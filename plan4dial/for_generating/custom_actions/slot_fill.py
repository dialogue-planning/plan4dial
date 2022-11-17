"""Contains all the functions for the
:py:func:`slot_fill <plan4dial.for_generating.custom_actions.slot_fill.slot_fill>`
custom action that is provided to bot designers by default.

Authors:
- Rebecca De Venezia
"""

from typing import List, Dict, Tuple
import itertools
from .utils import map_assignment_update
from ..parsers.json_config_parser import configure_assignments


def slot_fill(
    loaded_yaml: Dict,
    action_name: str,
    message_variants: List[str],
    entities: List[str],
    config_entities: Dict = None,
    fallback_message_variants: List[str] = None,
    additional_updates: Dict = None,
) -> None:
    """Custom action provided by default that allows bot designers to specify entity
    slot fills with ease.

    Handles actions that can be clarified, as well as those that can't, or a mix of
    both. This depends on what the `known`'s `type` setting is for each entity in the
    YAML.

    Also handles "partial" extraction, where the bot asks for multiple entities but is
    only able to extract some. In that case, the bot will follow up with `clarify`
    actions in which it tries to extract uncertain entities, or
    :py:func:`single_slot
    <plan4dial.for_generating.custom_actions.slot_fill._single_slot>` actions in which
    it tries to extract unknown entities individually in order to make up for the
    missing information (only used when there are > 1 entities specified).

    Additional outcomes can also be specified for certain outcomes, i.e. when entity
    *pizza* is extracted, respond with the given `response_variants`.

    Args:
        loaded_yaml (Dict): The loaded YAML configuration.
        action_name (str): The name of this instance of the custom action.
        message_variants (List[str]): Possible messages the bot will utter
            upon execution of this action.
        entities (List[str]): The entities to be extracted or have their "slots
            filled."
        config_entities (Dict): Holds configurations that specify what the bot should
            do in certain situations regarding each entity. The keys are each entity
            and the values are the configuration for each entity. Defaults to None as
            this is not always necessary. The 3 configuration options are:

                | **clarify_message_variants** *(List[str])*: The message variants that
                    will be used for the clarify action for this entity. Only necessary
                    if the `known` `type` of this entity is of type `fflag`.
                | **single_slot_message_variants** *(List[str])*: Custom message
                    variants to utter for :py:func:`single_slot
                    <plan4dial.for_generating.custom_actions.slot_fill._single_slot>`
                    extractions of the given entity. Only necessary to specify if there
                    are > 1 entities.
                | **fallback_message_variants** *(List[str])*: Custom fallback messages
                    to utter if the bot tries to extract this entity by itself with a
                    :py:func:`single_slot
                    <plan4dial.for_generating.custom_actions.slot_fill._single_slot>`
                    action and fails. Differs from the outer
                    `fallback_message_variants` parameter, which applies to the initial
                    :py:func:`slot_fill
                    <plan4dial.for_generating.custom_actions.slot_fill.slot_fill>`
                    action only. The default fallback messages will replace this
                    parameter if not specified.

        fallback_message_variants (List[str]): Custom fallback messages to utter if the
            bot fails to extract any entities. Defaults to None.
        additional_updates (Dict, optional): Additional updates to specify when a given
            extraction happens AT ANY POINT. Indicate the extraction that happens in
            the outcome by specifying the `known` status of the entities you desire.
            You can not only use this to add arbitrary context variable updates under
            `also_update` but also other outcome-specific attributes such as
            `response_variants`.

                | **NOTE**: Will only match to outcomes that match the given
                    specification exactly. For example, if you specify an additional
                    update for when *test1* is known, updates would only be added to
                    actions where ONLY *test1* is extracted, and not when *test1*,
                    *test2* and *test3* are extracted, for example. This is done to
                    reduce ambiguity. Defaults to None.

    See the tutorial for an example of a
    :py:func:`slot_fill <plan4dial.for_generating.custom_actions.slot_fill.slot_fill>`
    action.
    """
    if additional_updates:
        # iterate through all additional updates
        for i in range(len(additional_updates)):
            # iterate through each context variable detailed in the outcome
            for var in additional_updates[i]["outcome"]:
                # convert to an assignment setting so we can more easily identify what
                # outcome we're referring to
                additional_updates[i]["outcome"][var] = configure_assignments(
                    additional_updates[i]["outcome"][var]["known"]
                )
        cfg_updates = {}
        for setting in additional_updates:
            # we don't want to consider when entities are NOT found because 1) it's a
            # lot more ambiguous and 2) when extracting entities, we only have
            # knowledge of what we DID extract and not what we DIDN'T. (yes, we could
            # figure it out by looking at the available outcome groups, but it's just
            # more overhead for what seems like an edge case - specifying additional
            # updates when updates ARE extracted is just a lot more intuitive).

            # frozenset is an easy way to see at a glance the assignment setting of
            # each (known/maybe known) context variable
            key = frozenset(
                {
                    entity: certainty
                    for entity, certainty in setting["outcome"].items()
                    if certainty != "didnt-find"
                }.items()
            )
            # add the appropriate updates
            cfg_updates[key] = {}
            if "also_update" in setting:
                cfg_updates[key]["updates"] = setting["also_update"]
            if "response_variants" in setting:
                cfg_updates[key]["response_variants"] = setting["response_variants"]
            if "follow_up" in setting:
                cfg_updates[key]["follow_up"] = setting["follow_up"]
    entity_combos = []
    # create the cross-product of found, maybe-found, and didnt-find with the entities
    # given
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
    # instantiate the action
    action = {}
    action["type"] = "dialogue"
    action["message_variants"] = message_variants
    if fallback_message_variants:
        action["fallback_message_variants"] = fallback_message_variants
    # condition: none of the entities can be found
    action["condition"] = {}
    for entity in entities:
        action["condition"].update(map_assignment_update(entity, "didnt-find"))
    action["effect"] = {"validate-slot-fill": {"oneof": {"outcomes": {}}}}
    # iterate through all the possible entity combinations
    for combo in entity_combos:
        # refine combo by exluding "didnt-find" which we don't need for updates
        refined_combo = {
            entity: certainty
            for entity, certainty in combo
            if certainty != "didnt-find"
        }
        # only consider outcomes in which we find at elast something
        if refined_combo:
            next_out = {"updates": {}}
            # store the intent based on the refined combo
            next_out["intent"] = refined_combo
            outcome_name = "".join(
                f"{entity}_{certainty}-" for entity, certainty in refined_combo.items()
            )[:-1]
            # add the updates based on what's in this refined combo (again, ignoring
            # what we didn't find)
            for entity, certainty in refined_combo.items():
                next_out["updates"].update(map_assignment_update(entity, certainty))

            if additional_updates:
                # convert the current outcome into a frozenset to be compared
                key = frozenset(
                    {
                        entity: certainty for entity, certainty in refined_combo.items()
                    }.items()
                )
                # check if this frozenset is included in the dict of outcomes with
                # additional updates; if so, add the appropriate updates
                if key in cfg_updates:
                    new_upd_cfg = cfg_updates[key]
                    if "updates" in new_upd_cfg:
                        next_out["updates"].update(new_upd_cfg["updates"])
                    if "response_variants" in new_upd_cfg:
                        next_out["response_variants"] = new_upd_cfg["response_variants"]
                    if "follow_up" in new_upd_cfg:
                        next_out["follow_up"] = new_upd_cfg["follow_up"]
            action["effect"]["validate-slot-fill"]["oneof"]["outcomes"][
                outcome_name
            ] = next_out
    actions = {f"slot-fill__{action_name}": action}
    # create clarifications and single slot actions as necessary
    new_actions, new_ctx_vars = _create_clarifications_single_slots(
        action_name,
        action,
        entities,
        config_entities,
        loaded_yaml["context_variables"],
        additional_updates,
    )
    # update the loaded YAML with the new actions
    actions.update(new_actions)
    loaded_yaml["actions"].update(actions)
    loaded_yaml["context_variables"].update(new_ctx_vars)


def _clarify_act(
    entity: str,
    message_variants: List[str],
    single_slot: bool,
    additional_updates: Dict = None,
) -> Dict:
    """Generates a `clarify` action for an entity.

    Args:
        entity (str): The entity to generate the action for.
        message_variants (List[str]): The message variants for the clarification
            action.
        single_slot (bool): Determines if this entity also has a
            :py:func:`single_slot
            <plan4dial.for_generating.custom_actions.slot_fill._single_slot>` action.
            This is necessary because of the situation where we "maybe" found the
            entity in the original action, try to clarify it and fail, and we were
            trying to extract > 1 entities originally. In that case, we need to
            activate the appropriate :py:func:`single_slot
            <plan4dial.for_generating.custom_actions.slot_fill._single_slot>`.
        additional_updates (Dict, optional): Any additional updates. In reality, it
            will only consider those where just this entity is extracted. Defaults to
            None.

    Returns:
        Dict: The `clarify` action configuration.
    """
    confirm_updates = map_assignment_update(entity, "found")
    # consider additional updates if the entity is extracted
    if additional_updates:
        key = frozenset({entity: "found"}.items())
        if key in additional_updates:
            confirm_updates.update(additional_updates[key])
    deny_updates = map_assignment_update(entity, "didnt-find")
    # if we were originally trying to extract multiple entities and we weren't able to
    # clarify one of them, we will have to move on to extracting the entity with a
    # `single_slot` action. the single_slot action has to be disabled by default so
    # that it doesn't run before the initial action (that tries to extract all
    # entities).
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
                        "updates": confirm_updates,
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


def _single_slot(
    entity: str,
    config_entity: Dict,
    known_is_fflag: bool,
    additional_updates: Dict = None,
) -> None:
    """Generates a 'single slot' action for the entity provided. These are only
    necessary when multiple entities were specified, to handle the case where the bot
    is able to only extract some on its first go and `clarify` actions as well as
    actions that extract an entity on its own (:py:func:`single_slot
    <plan4dial.for_generating.custom_actions.slot_fill._single_slot>`) need to take
    care of the rest.

    Args:
        entity (str): The entity to generate the action for.
        config_entity (Dict): The `config_entities` configuration for this entity.
            Necessary so that we can access the `single_slot_message_variants` and
            `fallback_message_variants` if they exist.
        known_is_fflag (bool): Indicates if the `known` setting for the entity in
            question is of type `fflag`.
        additional_updates (Dict, optional): Any additional updates. In reality, it
            will only consider those where just this entity is extracted, or maybe
            extracted. Defaults to None.

    Returns:
        Dict: The :py:func:`single_slot
        <plan4dial.for_generating.custom_actions.slot_fill._single_slot>` action
        configuration.
    """
    fill_slot_updates = map_assignment_update(entity, "found")

    # if we successfully extract the entity, we should reset this flag. while it might
    # not seem important, if all the entities are reset to null at some point, then we
    # need to ensure that the original action runs first to re-extract all the entities
    # and not any of the `single_slot` actions.
    fill_slot_updates[f"allow_single_slot_{entity}"] = {"value": False}
    # add additional updates if they exist
    if additional_updates:
        key = frozenset({entity: "found"}.items())
        if key in additional_updates:
            fill_slot_updates.update(additional_updates[key])
    # add message variants if they exist
    message_variants = (
        config_entity["single_slot_message_variants"]
        if "single_slot_message_variants" in config_entity
        else [f"Please enter a valid value for {entity.replace('_', ' ')}."]
    )
    single_slot = {}
    single_slot["type"], single_slot["subtype"] = "dialogue", "dialogue disambiguation"
    single_slot["message_variants"] = message_variants
    # condition: we can't know the entity and we have to have tried to extract it with
    # the original slot_fill action along with the other entities already
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
                    }
                },
            }
        }
    }
    if known_is_fflag:
        slot_unclear_updates = map_assignment_update(entity, "maybe-found")
        # add additional updates if they exist
        if additional_updates:
            key = frozenset({entity: "maybe-found"}.items())
            if key in additional_updates:
                slot_unclear_updates.update(additional_updates[key])
        single_slot["effect"]["validate-slot-fill"]["oneof"]["outcomes"][
            "slot-unclear"
        ] = {
            "updates": slot_unclear_updates,
            "intent": {entity: "maybe-found"},
        }
    if "fallback_message_variants" in config_entity:
        single_slot["fallback_message_variants"] = config_entity[
            "fallback_message_variants"
        ]
    return {f"single_slot__{entity}": single_slot}


def _create_clarifications_single_slots(
    original_act_name: str,
    original_act_config: Dict,
    entities: List[str],
    config_entities: Dict,
    context_variables: Dict,
    additional_updates: Dict = None,
) -> Tuple[Dict, Dict]:
    """Used by the :py:func:`slot_fill
    <plan4dial.for_generating.custom_actions.slot_fill.slot_fill>` action to generate
    `clarify` and :py:func:`single_slot
    <plan4dial.for_generating.custom_actions.slot_fill._single_slot>` actions where
    necessary.

    Args:
        original_act_name (str): The action name given to the original
            :py:func:`slot_fill
            <plan4dial.for_generating.custom_actions.slot_fill.slot_fill>` action.
        original_act_config (Dict): The configuration of the original
            :py:func:`slot_fill
            <plan4dial.for_generating.custom_actions.slot_fill.slot_fill>` action.
        entities (List[str]): The total list of entities to extract.
        config_entities (Dict): Configurations for these entities that hold more
            information.
        context_variables (Dict): The context variable configuration from
            *loaded_yaml*.
        additional_updates (Dict, optional): Any additional updates. Defaults to None.

    Returns:
        Tuple[Dict, Dict]: The new actions and context variables to be added.
    """
    new_actions = {}
    new_ctx_vars = {}

    if len(entities) > 1:
        # only resort to single slot actions if we were not able to extract all
        # entities in one go
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
                                original_act_config["effect"][eff][option]["outcomes"][
                                    out
                                ]["updates"][f"allow_single_slot_{entity}"] = {
                                    "value": True
                                }
                                new_actions.update(
                                    _single_slot(
                                        entity,
                                        config_entities[entity],
                                        context_variables[entity]["known"]["type"]
                                        == "fflag",
                                        additional_updates,
                                    )
                                )
        new_actions[original_act_name] = original_act_config
    for entity in entities:
        # only create clarify actions if clarify messages were specified
        if (
            context_variables[entity]["known"]["type"] == "fflag"
            and "clarify_message_variants" in config_entities[entity]
        ):
            new_actions.update(
                _clarify_act(
                    entity,
                    config_entities[entity]["clarify_message_variants"],
                    f"allow_single_slot_{entity}" in new_ctx_vars,
                    additional_updates,
                )
            )
    return new_actions, new_ctx_vars
