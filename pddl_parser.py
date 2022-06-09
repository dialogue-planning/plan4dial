import json
from typing import Dict, List
import yaml
import tarski
from tarski.syntax import land
from tarski.io import fstrips as iofs


def parse_predicates(context_variables: Dict, actions: List[str], lang: tarski.FirstOrderLanguage):
    for var, var_config in context_variables.items():
        if "known" in var_config:
            lang.predicate(f"have_{var}")
            if var_config["known"]["type"] == "fflag":
                lang.predicate(f"maybe-have_{var}")
    for act in actions:
        lang.predicate(f"can-do_{act}")


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
    writer = iofs.FstripsWriter(problem)
    print(writer.get_predicates())
    # writer.write("domain.pddl", "problem.pddl")
    

if __name__ == "__main__":
    parse_to_pddl("yaml_samples/order_pizza.yaml")
