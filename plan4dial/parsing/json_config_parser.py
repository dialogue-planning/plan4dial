import yaml
import json
from pathlib import Path
from copy import deepcopy

from inspect import getmembers, isfunction
from plan4dial.custom_actions.utils import *
import plan4dial.custom_actions.custom as custom


def configure_fallback_true():
    return {
        "have-message": {"value": True},
        "force-statement": {"value": True},
    }


def configure_fallback():
    return {"updates": configure_fallback_true(), "intent": "fallback"}


def configure_dialogue_statement():
    return {
        "type": "dialogue",
        "condition": configure_fallback_true(),
        "effect": {
            "reset": {
                "oneof": {
                    "outcomes": {
                        "lock": {
                            "updates": {
                                "have-message": {
                                    "value": False,
                                },
                                "force-statement": {
                                    "value": False,
                                },
                            },
                            "intent": "fallback",
                        }
                    }
                }
            }
        },
        "message_variants": [],
    }

def configure_assignments(known):
    return (
                ("found" if known else "didnt-find")
                if type(known) == bool
                else "maybe-found"
            )

def configure_certainty(known):
    return (
            ("Known" if known else "Unknown")
            if type(known) == bool
            else "Uncertain"
        )

def configure_interpretation(value):
    return (
            "json"
            if value in [True, False, None] 
            else "spel"
        )

def reset_force_in_outcomes(clarify, prior_outcomes, forced_name):
    # every outcome in the forced action other than the fallback/unclear will undo the force
    new_outcomes = {}
    reset_force = False
    for out, out_config in prior_outcomes.items():
        if "intent" in out_config:
            intent = out_config["intent"]
            if intent != "fallback":
                if clarify:
                    if intent != "deny":
                        reset_force = True
                else:
                    if type(intent) == str:
                        if "maybe" not in intent:
                            reset_force = True
                    else:
                        if "maybe" not in intent.values():
                            reset_force = True
        else:
            reset_force = True
        if reset_force:
            out_config["updates"][forced_name] = {"value": False}
        new_outcomes[out] = out_config
    return new_outcomes


def base_setup(loaded_yaml):
    # set up the action, intent, and fluents needed for default fallback/unclear user input
    loaded_yaml["intents"]["fallback"] = {"utterances": [], "variables": []}
    loaded_yaml["actions"]["dialogue_statement"] = configure_dialogue_statement()
    loaded_yaml["context-variables"]["have-message"] = {
        "type": "flag",
        "init": False,
    }
    loaded_yaml["context-variables"]["force-statement"] = {
        "type": "flag",
        "init": False,
    }


def instantiate_clarification_actions(loaded_yaml):
    processed = deepcopy(loaded_yaml)
    for act, act_config in loaded_yaml["actions"].items():
        if "clarify" in act_config:
            update_config_clarification(
                processed,
                act,
                list(act_config["clarify"].keys()),
                act_config["clarify"],
            )
    for key in processed:
        loaded_yaml[key] = processed[key]


def instantiate_effects(loaded_yaml):
    processed = deepcopy(loaded_yaml["actions"])
    # for all actions, instantiate template effect and add fallbacks if necessary
    for act, act_config in loaded_yaml["actions"].items():
        fallback = False
        if act != "dialogue_statement":
            processed[act]["condition"]["force-statement"] = {"value": False}
            fallback = (
                not act_config["disable-fallback"]
                if "disable-fallback" in act_config
                else act_config["type"] != "system"
            )
            if fallback:
                if "fallback_message_variants" not in act_config:
                    processed[act]["fallback_message_variants"] = [
                        "Sorry, I couldn't understand that input.",
                        "I couldn't quite get that.",
                    ]
        for eff, eff_config in loaded_yaml["actions"][act]["effect"].items():
            if "template-effects" in loaded_yaml:
                if eff in loaded_yaml["template-effects"]:
                    # for ease in parsing
                    eff_config = {f"({key})": val for key, val in eff_config.items()}
                    template_eff = deepcopy(loaded_yaml["template-effects"][eff])
                    parameters = {f"({p})" for p in template_eff["parameters"]}
                    del template_eff["parameters"]
                    for option in template_eff:
                        outcomes = template_eff[option]["outcomes"]
                        instantiated_outcomes = {}
                        for out, out_config in outcomes.items():
                            updates = (
                                out_config["updates"]
                                if "updates" in out_config
                                else None
                            )
                            if updates:
                                new_updates = {}
                                for update, update_config in updates.items():
                                    if update in eff_config:
                                        new_updates[eff_config[update]] = template_eff[
                                            option
                                        ]["outcomes"][out]["updates"][update]
                                        update = eff_config[update]
                                    for key, val in update_config.items():
                                        check_val = (
                                            val[1:]
                                            if type(val) == str and val[0] == "$"
                                            else val
                                        )
                                        if check_val in eff_config:
                                            new_updates[update][
                                                key
                                            ] = check_val.replace(
                                                check_val,
                                                eff_config[check_val]
                                                if check_val == val
                                                else f"${eff_config[check_val]}",
                                            )
                                instantiated_outcomes[out] = {"updates": new_updates}
                            if "intent" in out_config:
                                if out_config["intent"] not in parameters:
                                    instantiated_outcomes[out]["intent"] = out_config[
                                        "intent"
                                    ]
                                elif out_config["intent"] in eff_config:
                                    instantiated_outcomes[out]["intent"] = eff_config[
                                        out_config["intent"]
                                    ]
                                else:
                                    instantiated_outcomes[out]["intent"] = "fallback"
                            else:
                                instantiated_outcomes[out]["intent"] = "fallback"
                            if "follow_up" in out_config:
                                if out_config["follow_up"] in eff_config:
                                    instantiated_outcomes[out][
                                        "follow_up"
                                    ] = eff_config[out_config["follow_up"]]
                        if fallback:
                            instantiated_outcomes["fallback"] = configure_fallback()
                        processed[act]["effect"][eff] = {
                            option: {"outcomes": instantiated_outcomes}
                        }
            else:
                for option in eff_config:
                    if fallback:
                        processed[act]["effect"][eff][option]["outcomes"][
                            "fallback"
                        ] = configure_fallback()
    loaded_yaml["actions"] = processed


def instantiate_advanced_custom_actions(loaded_yaml):
    processed = deepcopy(loaded_yaml)
    for act, act_config in loaded_yaml["actions"].items():
        if "advanced-custom" in act_config:
            for custom_act in getmembers(custom, isfunction):
                act_name, act_function = custom_act[0], custom_act[1]
                if act_name == act_config["advanced-custom"]["custom-type"]:
                    act_function(
                        processed, **act_config["advanced-custom"]["parameters"]
                    )
                    break
            del processed["actions"][act]
    for key in processed:
        loaded_yaml[key] = processed[key]


def convert_ctx_var(loaded_yaml):
    processed = deepcopy(loaded_yaml["context-variables"])
    # convert context variables
    processed = {var: {} for var in loaded_yaml["context-variables"]}
    for ctx_var, cfg in loaded_yaml["context-variables"].items():
        json_ctx_var = {}
        json_ctx_var["type"] = cfg["type"]
        if cfg["type"] == "enum":
            if type(cfg["options"]) == dict:
                json_ctx_var["config"] = list(cfg["options"].keys())
            else:
                json_ctx_var["config"] = cfg["options"]
        elif cfg["type"] == "flag" or cfg["type"] == "fflag":
            json_ctx_var["config"] = cfg["init"]
        else:
            if "extraction" in cfg:
                json_ctx_var["config"] = {"extraction": cfg["extraction"]}
                if "method" in cfg:
                    json_ctx_var["config"]["method"] = cfg["method"]
                elif "pattern" in cfg:
                    json_ctx_var["config"]["pattern"] = cfg["pattern"]
            else:
                json_ctx_var["config"] = "null"
        if "known" in cfg:
            json_ctx_var["known"] = cfg["known"]
        processed[ctx_var] = json_ctx_var
    loaded_yaml["context-variables"] = processed


def convert_intents(loaded_yaml):
    processed = deepcopy(loaded_yaml["intents"])
    # convert intents
    for intent, intent_cfg in loaded_yaml["intents"].items():
        cur_intent = {}
        cur_intent["variables"] = []
        if "variables" in intent_cfg:
            cur_intent["variables"].extend(
                [f"${var}" for var in intent_cfg["variables"]]
            )
        cur_intent["utterances"] = intent_cfg["utterances"]
        processed[intent] = cur_intent
    loaded_yaml["intents"] = processed


def add_follow_ups(loaded_yaml):
    processed = deepcopy(loaded_yaml["actions"])
    forced_acts = []
    for act in loaded_yaml["actions"]:
        for eff, eff_config in loaded_yaml["actions"][act]["effect"].items():
            for option in eff_config:
                outcomes = eff_config[option]["outcomes"]
                for out, out_config in outcomes.items():
                    next_outcome = deepcopy(out_config)
                    if "follow_up" in next_outcome:
                        forced = next_outcome["follow_up"]
                        next_outcome["updates"][f"forcing__{forced}"] = {"value": True}
                        forced_acts.append(forced)
                    if "response_variants" in next_outcome:
                        next_outcome["updates"].update(configure_fallback_true())
                    processed[act]["effect"][eff][option]["outcomes"][
                        out
                    ] = next_outcome
    with_forced = deepcopy(processed)
    for forced in forced_acts:
        name = f"forcing__{forced}"
        clarify_name = f"clarify__{forced}"
        for act in processed:
            # don't lock fallback/unclear so we can loop on a forced action if needed
            if act != forced and act != clarify_name and act != "dialogue_statement":
                with_forced[act]["condition"][name] = {"value": False}
        for eff, eff_config in loaded_yaml["actions"][forced]["effect"].items():
            for option in eff_config:
                with_forced[forced]["effect"][eff][option][
                    "outcomes"
                ] = reset_force_in_outcomes(
                    False, processed[forced]["effect"][eff][option]["outcomes"], name
                )
        if clarify_name in processed:
            for eff, eff_config in loaded_yaml["actions"][clarify_name][
                "effect"
            ].items():
                for option in eff_config:
                    with_forced[clarify_name]["effect"][eff][option][
                        "outcomes"
                    ] = reset_force_in_outcomes(
                        True,
                        processed[clarify_name]["effect"][eff][option]["outcomes"],
                        name,
                    )
        loaded_yaml["context-variables"][name] = {"type": "flag", "init": False}
    loaded_yaml["actions"] = with_forced


def convert_actions(loaded_yaml):
    processed = deepcopy(loaded_yaml["actions"])
    for act in loaded_yaml["actions"]:
        # convert preconditions
        json_config_cond = []
        condition = loaded_yaml["actions"][act]["condition"]
        for cond, cond_cfg in condition.items():
            if type(cond_cfg) == dict:
                for cond_config_key, cond_config_val in cond_cfg.items():
                    if cond_config_key == "known":
                        json_config_cond.append(
                            ([cond, "Known"] if cond_config_val else [cond, "Unknown"])
                            if type(cond_config_val) == bool
                            else [cond, "Uncertain"]
                        )
                    elif cond_config_key == "value":
                        json_config_cond.append([cond, cond_config_val])
        processed[act]["condition"] = json_config_cond
        for eff, eff_config in loaded_yaml["actions"][act]["effect"].items():
            converted_eff = deepcopy(eff_config)
            converted_eff["global-outcome-name"] = eff
            intents = []
            for option in eff_config:
                converted_eff["type"] = option
                outcomes = eff_config[option]["outcomes"]
                outcomes_list = []
                for out, out_config in outcomes.items():
                    next_outcome = deepcopy(out_config)
                    next_outcome["name"] = f"{act}_DETDUP_{eff}-EQ-{out}"
                    if "intent" not in out_config:
                        next_outcome["intent"] = None
                    else:
                        intents.append(out_config["intent"])
                    next_outcome["assignments"] = {}
                    if "updates" in out_config:
                        for update_var, update_cfg in out_config["updates"].items():
                            if update_var in ["and", "or"]:
                                #for expr in update_cfg:
                                    pass
                            else:
                                if "known" in update_cfg:
                                    next_outcome["assignments"][f"${update_var}"] = configure_assignments(update_cfg["known"])
                                    next_outcome["updates"][update_var]["certainty"] = configure_certainty(update_cfg["known"])
                                if "value" in update_cfg:
                                    next_outcome["updates"][update_var]["interpretation"] = configure_interpretation(update_cfg["value"])
                    outcomes_list.append(next_outcome)
                converted_eff["outcomes"] = outcomes_list
                del converted_eff[option]
                processed[act]["effect"] = converted_eff
        if intents:
            processed[act]["intents"] = {}
            for intent in intents:
                if type(intent) == str:
                    if intent in loaded_yaml["intents"]:
                        processed[act]["intents"][intent] = loaded_yaml["intents"][
                            intent
                        ]
    loaded_yaml["actions"] = processed


def convert_yaml(filename: str):
    loaded_yaml = yaml.load(open(filename, "r"), Loader=yaml.FullLoader)
    base_setup(loaded_yaml)
    instantiate_clarification_actions(loaded_yaml)
    instantiate_advanced_custom_actions(loaded_yaml)
    instantiate_effects(loaded_yaml)
    add_follow_ups(loaded_yaml)
    convert_ctx_var(loaded_yaml)
    convert_intents(loaded_yaml)
    convert_actions(loaded_yaml)
    if "template-effects" in loaded_yaml:
        del loaded_yaml["template-effects"]
    return loaded_yaml


if __name__ == "__main__":
    base = Path(__file__).parent.parent
    f = str((base / "yaml_samples/advanced_custom_actions_test_v3.yaml").resolve())
    json_file = open("pizza.json", "w")
    json_file.write(json.dumps(convert_yaml(f), indent=4))
