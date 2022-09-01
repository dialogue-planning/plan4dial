import yaml
from copy import deepcopy
from inspect import getmembers, isfunction
from plan4dial.custom_actions.utils import *
import plan4dial.custom_actions.custom as custom
from nnf import Or, And, Var, config


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
        ("found" if known else "didnt-find") if type(known) == bool else "maybe-found"
    )


def configure_certainty(known):
    return ("Known" if known else "Unknown") if type(known) == bool else "Uncertain"


@config(auto_simplify=True)
def convert_to_formula(condition: Dict):
    formula_terms = []
    if type(condition) == list:
        formula_terms.extend(
            [
                formula
                for nesting in condition
                for formula in convert_to_formula(nesting)
            ]
        )
    else:
        for connective, config in condition.items():
            if connective not in ["and", "or"]:
                formula_terms.extend(
                    Var(f"({connective}-{base_key}-{base_value})")
                    for base_key, base_value in config.items()
                )
            else:
                formula_terms.append(
                    And(convert_to_formula(config))
                    if connective == "and"
                    else Or(convert_to_formula(config))
                )
    return formula_terms


@config(auto_simplify=True)
def convert_to_DNF(condition: Dict):
    # mappings that will simplify formula creation
    return (And(convert_to_formula(condition)).negate()).to_CNF().negate()


def configure_value_setter(loaded_yaml, ctx_var):
    processed = deepcopy(loaded_yaml["actions"])
    ctx_var_cfg = loaded_yaml["context-variables"][ctx_var]
    var_options = (
        list(ctx_var_cfg["options"].keys())
        if type(ctx_var_cfg["options"]) == dict
        else ctx_var_cfg["options"]
    )

    for v in var_options:
        option_value_name = f"{ctx_var}-value-{v.replace(' ', '_')}"
        loaded_yaml["context-variables"][option_value_name] = {
            "type": "flag",
            "init": False,
        }
    # TODO: whenever we lose knowledge of the context variable, reset all values
    for act in loaded_yaml["actions"]:
        for eff, eff_config in loaded_yaml["actions"][act]["effect"].items():
            for option in eff_config:
                for out, out_config in eff_config[option]["outcomes"].items():
                    if "updates" in out_config:
                        for update_var, update_cfg in out_config["updates"].items():
                            if ctx_var == update_var and "known" in out_config:
                                if out_config["known"] == False:
                                    for v in var_options:
                                        option_value_name = f"{ctx_var}-value-{v.replace(' ', '_')}"
                                        processed[act][eff][option][out]["updates"][option_value_name] = {"value": False}

        # loaded_yaml["actions"][f"reset-{option_value_name}"] = {
        #     "type": "system",
        #     "condition": {
        #         ctx_var: {"known": False},
        #         option_value_name: {"value": True}
        #     },
        #     "effect": {
        #         "reset": {
        #             "oneof": {
        #                 "outcomes": {
        #                     f"reset-{option.replace(' ', '_')}": {
        #                         "updates": {
        #                             option_value_name: {"value": False, "interpretation": "json"}
        #                         }
        #                     }
        #                 }
        #             }
        #         }
        #     }
        # }
    processed[f"set-{ctx_var}"] = {
        "type": "system",
        "subtype": "Context dependent determination",
        "condition": {
            **{ctx_var: {"known": True}},
            **{f"{ctx_var}-value-{v.replace(' ', '_')}": {"value": False} for v in var_options},
        },
        "effect": {
            "set-valid-value": {
                "oneof": {
                    "outcomes": {
                        v.replace(' ', '_'): {
                            "updates": {
                                f"{ctx_var}-value-{v.replace(' ', '_')}": {"value": True},
                            },
                            "context": {ctx_var: v},
                        }
                        for v in var_options
                    }
                }
            }
        },
    }
    loaded_yaml["actions"] = processed


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


def instantiate_effects_add_fallbacks(loaded_yaml):
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
                if fallback:
                    for option in eff_config:
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


def duplicate_for_or_condition(loaded_yaml):
    processed = deepcopy(loaded_yaml["actions"])
    for act, act_cfg in loaded_yaml["actions"].items():
        for cond, cond_cfg in act_cfg["condition"].items():
            # currently only handles "or"s and "or"s of "ands" (when multiple conditions are listed under one bullet)
            if cond == "or":
                idx = 1
                for or_cond in cond_cfg:
                    new_cond = deepcopy(act_cfg["condition"])
                    del new_cond["or"]
                    for k, v in or_cond.items():
                        new_cond[k] = v
                    next_act_name = f"{act}-or-{idx}"
                    processed[next_act_name] = deepcopy(processed[act])
                    processed[next_act_name]["condition"] = new_cond
                    idx += 1
                del processed[act]
    loaded_yaml["actions"] = processed

def duplicate_for_or_when_condition(loaded_yaml):
    processed = deepcopy(loaded_yaml["actions"])
    for act, act_cfg in loaded_yaml["actions"].items():
        for eff, eff_config in loaded_yaml["actions"][act]["effect"].items():
            for option in eff_config:
                for out, out_config in eff_config[option]["outcomes"].items():
                    if "updates" in out_config:
                        for update_var, update_cfg in out_config["updates"].items():
                            # for now, assume we only use "and" explicitly to stack "when" expressions
                            if update_var == "and":
                                for when_expr in update_cfg:
                                    for when_cond, when_cond_cfg in when_expr["when"]["condition"].items():
                                        if when_cond == "or":
                                            for or_cond in when_cond_cfg:
                                                new_when = deepcopy(when_expr)
                                                del new_when["when"]["condition"]["or"]
                                                for k, v in or_cond.items():
                                                    new_when["when"]["condition"][k] = v
                                                processed[act]["effect"][eff][option]["outcomes"][out]["updates"][update_var].append(new_when)
                                    processed[act]["effect"][eff][option]["outcomes"][out]["updates"][update_var].remove(when_expr)
    loaded_yaml["actions"] = processed


def add_value_setters(loaded_yaml):
    processed = deepcopy(loaded_yaml)
    use_value_setters = set()
    # stores actions that need a separate action where their values are encoded in PDDL.
    # necessary whenever an action is contingent on a variable being a certain value.
    for act, act_cfg in loaded_yaml["actions"].items():
        for cond, cond_cfg in act_cfg["condition"].items():
            if "value" in cond_cfg:
                option = cond_cfg["value"]
                if type(option) == str:
                    if option not in loaded_yaml["context-variables"][cond]["options"]:
                        raise AssertionError(
                            f'Cannot specify the value "{option}" for the context variable "{cond}".'
                        )
                    # if not done already, create new "value-setting" actions, conditions, etc.
                    if f"{cond}-value-{option.replace(' ', '_')}" not in processed["context-variables"]:
                        configure_value_setter(processed, cond)
                        use_value_setters.add(cond)
                    # reset old condition to the refactored condition so we can specify value
                    # only delete the value portion (may still have "known")
                    del processed["actions"][act]["condition"][cond]["value"]
                    # delete whole condition if empty
                    if processed["actions"][act]["condition"][cond] == {}:
                        del processed["actions"][act]["condition"][cond]
                    # replace
                    processed["actions"][act]["condition"][f"{cond}-value-{option.replace(' ', '_')}"] = {
                        "value": True
                    }
    # NEED TO FIX ISSUE WHERE ASSIGNING A VARIABLE TO NULL DOES NOT RE-ASSIGN THE VALUES
    # OF THE "VALUE" CONTEXT VARIABLES. I.E. CUISINE == NULL DOES NOT CHANGE THAT
    # CUISINE-VALUE-MEXICAN IS STILL TRUE. EASY SOLUTION: AUTO-CREATE A SYSTEM ACTION SUCH THAT
    # IF WE DO NOT KNOW THE CONTEXT VARIABLE AND ONE OF THE VALUES IS TRUE (OR), RESET ALL VALUES.
    loaded_yaml["actions"], loaded_yaml["context-variables"] = (
        processed["actions"],
        processed["context-variables"],
    )


def convert_actions(loaded_yaml):
    processed = deepcopy(loaded_yaml["actions"])
    for act in loaded_yaml["actions"]:
        # convert preconditions
        json_config_cond = []
        condition = loaded_yaml["actions"][act]["condition"]
        for cond, cond_cfg in condition.items():
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
                            next_outcome["updates"][update_var]["variable"] = update_var
                            if "known" in update_cfg:
                                next_outcome["assignments"][
                                    f"${update_var}"
                                ] = configure_assignments(update_cfg["known"])
                                next_outcome["updates"][update_var][
                                    "certainty"
                                ] = configure_certainty(update_cfg["known"])
                                del next_outcome["updates"][update_var]["known"]
                            if "value" not in update_cfg:
                                 next_outcome["updates"][update_var]["value"] = None
                            next_outcome["updates"][update_var][
                                "interpretation"
                            ] = "json"
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
    instantiate_effects_add_fallbacks(loaded_yaml)
    add_follow_ups(loaded_yaml)
    duplicate_for_or_condition(loaded_yaml)
    duplicate_for_or_when_condition(loaded_yaml)
    add_value_setters(loaded_yaml)
    convert_ctx_var(loaded_yaml)
    convert_intents(loaded_yaml)
    convert_actions(loaded_yaml)
    if "template-effects" in loaded_yaml:
        del loaded_yaml["template-effects"]
    return loaded_yaml
