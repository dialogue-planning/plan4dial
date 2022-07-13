import yaml
import json
from pathlib import Path
from copy import deepcopy


def preprocess_yaml(filename: str):
    loaded_yaml = yaml.load(open(filename, "r"), Loader=yaml.FullLoader)
    for response, msg_vars in loaded_yaml["responses"].items():
        loaded_yaml["actions"][response] = {
            "type": "dialogue",
            "condition": {},
            "effects": {
                "reset":
                {
                    "oneof":
                    {
                        "outcomes":
                        {
                            "lock":
                            {
                                "updates": {
                                    response: {
                                        "can-do": False
                                    }
                                },
                            }

                        }
           
                    }

                }

            },
            "message_variants": msg_vars,
        }
    processed = deepcopy(loaded_yaml)
    for act, act_config in loaded_yaml["actions"].items():
        if act not in loaded_yaml["responses"]:
            processed["actions"][act]["condition"]["can-do_agent_fallback"] = {"value": False}
        # processed["actions"][act]["condition"][f"can-do_{act}"] = {"value": True}
        # convert effects
        for eff, eff_config in loaded_yaml["actions"][act]["effects"].items():
            # create from template effects
            if eff == "validate-response":
                new_eff = {
                    "valid": {
                        "updates": {
                            eff_config["entity"]: {
                                "value": f"${eff_config['entity']}",
                                "known": True,
                                "interpretation": "spel",
                            }
                        },
                        "assignments": {f"${eff_config['entity']}": "found"},
                        "intent": eff_config["valid-intent"],
                    },
                    "unclear": {
                        "updates": {
                            eff_config["entity"]: {
                                "value": f"${eff_config['entity']}",
                                "known": "maybe",
                                "interpretation": "spel",
                            }
                        },
                        "assignments": {f"${eff_config['entity']}": "maybe-found"},
                    },
                    "fallback": {
                                "updates": {
                                    "can-do_agent_fallback": {"value": True, "interpretation": "json",},
                                },
                                "assignments": {},
                                "intent": "fallback",
                            }
                }
                act_intents = [eff_config["valid-intent"]]
                if "valid-follow-up" in eff_config:
                    new_eff["valid"]["follow_up"] = eff_config["valid-follow-up"]
                if "unclear-intent" in eff_config:
                    unclear = eff_config["unclear-intent"]
                    new_eff["unclear"]["intent"] = unclear
                    act_intents.append(unclear)
                else:
                    unclear = f"{eff_config['entity']}-unclear"
                    new_eff["unclear"]["intent"] = unclear
                    processed["intents"][unclear] = {"variables": [], "utterances": []}
                    act_intents.append(unclear)
                new_eff = {"validate-response": {"oneof": {"outcomes": new_eff}}}
                processed["actions"][act]["effects"] = new_eff
                processed["actions"][act]["intents"] = {
                    act_intent: processed["intents"][act_intent]
                    for act_intent in act_intents
                }
            elif eff == "yes-no":
                new_eff = {
                    "confirm": {
                        "updates": {
                            eff_config["entity"]: {
                                "value": f"${eff_config['entity']}",
                                "known": True,
                                "interpretation": "spel",
                            }
                        },
                        "assignments": {f"${eff_config['entity']}": "found"},
                        "intent": "confirm",
                    },
                    "deny": {
                        "updates": {
                            eff_config["entity"]: {
                                "value": None,
                                "known": False,
                                "interpretation": "json",
                            }
                        },
                        "assignments": {f"${eff_config['entity']}": "didnt-find"},
                        "intent": "deny",
                    },
                    "fallback": {
                                "updates": {
                                    "can-do_agent_fallback": {"value": True, "interpretation": "json"},
                                },
                                "assignments": {},
                                "intent": "fallback",
                            }
                }
                if "valid-follow-up" in eff_config:
                    new_eff["valid"]["follow_up"] = eff_config["valid-follow-up"]
                if "unclear-intent" in eff_config:
                    new_eff["unclear"]["intent"] = eff_config["unclear-intent"]
                new_eff = {"yes-no": {"oneof": {"outcomes": new_eff}}}
                processed["actions"][act]["effects"] = new_eff
                processed["actions"][act]["intents"] = {
                    act_intent: processed["intents"][act_intent]
                    for act_intent in ["confirm", "deny"]
                }
            # general preprocessing needed for all other actions
            else:
                intents = []

                for option in eff_config:
                    if act not in loaded_yaml["responses"]:
                        processed["actions"][act]["effects"][eff][option]["outcomes"]["fallback"] = {
                                "updates": {
                                    "can-do_agent_fallback": {"value": True, "interpretation": "json"},
                                },
                                "assignments": {},
                                "intent": "fallback",
                            }
                    outcomes = eff_config[option]["outcomes"]
                    for out, out_config in outcomes.items():
                        if "intent" in out_config:
                            intents.append(out_config["intent"])
                        processed["actions"][act]["effects"][eff][option]["outcomes"][
                            out
                        ]["assignments"] = {}
                        if "updates" in out_config:
                            for update_var, update_cfg in out_config["updates"].items():
                                if "known" in update_cfg:
                                    known = update_cfg["known"]
                                    processed["actions"][act]["effects"][eff][option][
                                        "outcomes"
                                    ][out]["assignments"][f"${update_var}"] = (
                                        ("found" if known else "didnt-find")
                                        if type(known) == bool
                                        else "maybe-found"
                                    )
                                if "can-do" in update_cfg:
                                    processed["actions"][act]["effects"][eff][option][
                                        "outcomes"
                                    ][out]["updates"][f"can-do_{update_var}"] = {
                                        "value": update_cfg["can-do"],
                                        "interpretation": "json",
                                    }
                                    del processed["actions"][act]["effects"][eff][
                                        option
                                    ]["outcomes"][out]["updates"][update_var]
                                else:
                                    processed["actions"][act]["effects"][eff][option][
                                        "outcomes"
                                    ][out]["updates"][update_var]["interpretation"] = (
                                        "json"
                                        if update_cfg["value"] in [True, False, None]
                                        else "spel"
                                    )
                if intents:
                    processed["actions"][act]["intents"] = {
                        intent: processed["intents"][intent]
                        for intent in intents
                    }
            # add fallback outcomes for each action
            # entities = {entity for outcome in eff_config["oneof"]["outcomes"] for entity in eff_config["oneof"]["outcomes"][outcome]["updates"]}
            # processed["actions"][act]["effects"][eff]["oneof"]["outcomes"]["fallback"] = {"updates":  {}, "assignments": {f"${entity}": "didnt-find" for entity in entities}, "intent": "fallback" }
        if "clarify" in act_config:
            entities = act_config["clarify"]["entities"]
            clarify = {}
            clarify["type"] = act_config["type"]
            clarify["subtype"] = act_config["subtype"]
            clarify["message_variants"] = act_config["clarify"]["message_variants"]
            clarify["condition"] = {entity: {"known": "maybe"} for entity in entities}
            clarify["effects"] = {
                "yes-no": {
                    "oneof": {
                        "outcomes": {
                            "confirm": {
                                "updates": {
                                    entity: {
                                        "value": f"${entity}",
                                        "known": True,
                                        "interpretation": "spel",
                                    } for entity in entities
                                },
                                "assignments": {f"${entity}": "found" for entity in entities},
                                "intent": "confirm",
                            },
                            "deny": {
                                "updates": {
                                    entity: {
                                        "value": None,
                                        "known": False,
                                        "interpretation": "json",
                                    } for entity in entities
                                },
                                "assignments": {
                                    f"${entity}": "didnt-find" for entity in entities
                                },
                                "intent": "deny",
                            },
                            "fallback": {
                                        "updates": {
                                            "can-do_agent_fallback": {"value": True, "interpretation": "json"},
                                        },
                                        "assignments": {},
                                        "intent": "fallback",
                                    }
                                }
                    }
                }
            }
            clarify["intents"] = {
                act_intent: processed["intents"][act_intent]
                for act_intent in ["confirm", "deny"]
            }
            processed["actions"][f"clarify__{act}"] = clarify
            del processed["actions"][act]["clarify"]
    return processed


if __name__ == "__main__":
    base = Path(__file__).parent.parent
    f = str((base / "yaml_samples/test.yaml").resolve())
    print(json.dumps(preprocess_yaml(f), indent=4))
