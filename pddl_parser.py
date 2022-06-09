from typing import Dict, List
import yaml
import tarski
import tarski.fstrips as fs
from tarski.io import fstrips as iofs
from tarski.syntax.formulas import land


def return_certainty_predicates(pred_name: str, known: bool, lang: tarski.FirstOrderLanguage):
    if known == True:
        return [lang.get_predicate(f"have_{pred_name}")(), ~lang.get_predicate(f"maybe-have_{pred_name}")()]
    elif known == False:
        return [~lang.get_predicate(f"have_{pred_name}")(), ~lang.get_predicate(f"maybe-have_{pred_name}")()]
    elif known == "maybe":
        return [~lang.get_predicate(f"have_{pred_name}")(), lang.get_predicate(f"maybe-have_{pred_name}")()]

def parse_predicates(context_variables: Dict, actions: List[str], lang: tarski.FirstOrderLanguage):
    for var, var_config in context_variables.items():
        if "known" in var_config:
            lang.predicate(f"have_{var}")
            if var_config["known"]["type"] == "fflag":
                lang.predicate(f"maybe-have_{var}")
        else:
            lang.predicate(var)
    for act in actions:
        lang.predicate(f"can-do_{act}")

def parse_actions(actions: Dict, lang: tarski.FirstOrderLanguage, problem: tarski.fstrips.Problem):
    parsed_actions = {}
    for act, act_config in actions.items():
        parsed_actions[act] = {"precondition": {}, "effects": {}}
        # do for now until you move out preprocessing
        if act != "check-order-availability":
            continue
        for cond, cond_config in act_config["condition"].items():
            parsed_actions[act]["precondition"][cond] = []
            for cond_config_key, cond_config_val in cond_config.items():
                if cond_config_key == "known":
                    parsed_actions[act]["precondition"][cond].extend(return_certainty_predicates(cond, cond_config_val, lang))
        parsed_actions[act]["precondition"][cond] = land(*parsed_actions[act]["precondition"][cond])
        for eff, eff_config in act_config["effects"].items():
            parsed_actions[act]["effects"][eff] = {}
            for eff_type in eff_config:
                for out, out_config in eff_config[eff_type]["outcomes"].items():
                    outcome_effects = []
                    if "updates" in out_config:
                        for update_var, update_config in out_config["updates"].items():
                            if "known" in update_config:
                                outcome_effects.extend(return_certainty_predicates(update_var, update_config["known"], lang))
                    parsed_actions[act]["effects"][eff][out] = [[fs.DelEffect(s) for s in e.subformulas] if e.connective.name == "Not" else fs.AddEffect(e) for e in outcome_effects]
    return parsed_actions

def parse_to_pddl(filename: str):
    # load in the yaml
    loaded_yaml = yaml.load(open(filename, "r"), Loader=yaml.FullLoader)
    # set up the tarski language
    lang = tarski.language("dial_lang", theories=["equality"])
    # define the problem
    problem = tarski.fstrips.create_fstrips_problem(
        domain_name="dial_domain", problem_name="dial_problem", language=lang
    )
    parse_predicates(loaded_yaml["context-variables"], loaded_yaml["actions"].keys(), lang)
    parsed_actions = parse_actions(loaded_yaml["actions"], lang, problem)
    for act in parsed_actions:
        for cond in parsed_actions[act]["precondition"].values():
            print(cond)

    writer = iofs.FstripsWriter(problem)
    print(writer.get_predicates())
    print(writer.get_actions())
    # writer.write("domain.pddl", "problem.pddl")
    

if __name__ == "__main__":
    parse_to_pddl("yaml_samples/order_pizza.yaml")
