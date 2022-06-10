import yaml
import json
from pathlib import Path
from copy import deepcopy


def preprocess_yaml(filename: str):
    loaded_yaml = yaml.load(open(filename, "r"), Loader=yaml.FullLoader)
    processed = deepcopy(loaded_yaml)
    for act, act_config in loaded_yaml["actions"].items():
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
                                    }
                                },
                                "intent": eff_config["valid-intent"],
                            },
                            "unclear": {
                                "updates": {
                                    eff_config["entity"]: {
                                        "value": f"${eff_config['entity']}",
                                        "known": "maybe",
                                    }
                                },
                                "follow_up": {"clarify": f"clarify__{act}"},
                            },
                }
                if "valid-follow-up" in eff_config:
                    new_eff["valid"]["follow_up"] = eff_config["valid-follow-up"]
                if "unclear-intent" in eff_config:
                    new_eff["unclear"]["intent"] = eff_config["unclear-intent"]

                new_eff = {"validate-response": {"oneof": {"outcomes": new_eff}}}
            elif eff == "yes-no":
                new_eff = {
                            "confirm": {
                                "updates": {
                                    eff_config["entity"]: {
                                        "value": f"${eff_config['entity']}",
                                        "known": True,
                                    }
                                },
                                "intent": "confirm",
                            },
                            "deny": {
                                "updates": {
                                    eff_config["entity"]: {
                                        "value": None,
                                        "known": False,
                                    }
                                },
                                "intent": "deny",
                            },
                }
                if "valid-follow-up" in eff_config:
                    new_eff["valid"]["follow_up"] = eff_config["valid-follow-up"]
                if "unclear-intent" in eff_config:
                    new_eff["unclear"]["intent"] = eff_config["unclear-intent"]
                new_eff = {"yes-no": {"oneof": {"outcomes": new_eff}}}
            processed["actions"][act]["effects"] = new_eff
        if "clarify" in act_config:
            clarify_act = {}
            entity = act_config["clarify"]["entity"]
            clarify_act["type"] = act_config["type"]
            clarify_act["subtype"] = act_config["subtype"]
            clarify_act["message_variants"] = act_config["clarify"]["message_variants"]
            clarify_act["condition"] = {entity: {"known": "maybe"}}
            clarify_act["effects"] = {
                "yes-no": {
                    "oneof": {
                        "outcomes": {
                            "confirm": {
                                "updates": {
                                    entity: {"value": f"${entity}", "known": True}
                                },
                                "intent": "confirm",
                            },
                            "deny": {
                                "updates": {"entity": {"value": None, "known": False}},
                                "intent": "deny",
                            },
                        }
                    }
                }
            }
            del processed["actions"][act]["clarify"]
        processed["actions"][f"clarify__{act}"] = clarify_act
    return processed


if __name__ == "__main__":
    base = Path(__file__).parent.parent
    f = str((base / "yaml_samples/order_pizza.yaml").resolve())
    print(json.dumps(preprocess_yaml(f), indent=4))
