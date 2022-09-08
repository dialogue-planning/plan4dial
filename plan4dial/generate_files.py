import json
import yaml
import os
import subprocess
#import spacy
from pathlib import Path
from plan4dial.parsers.json_config_parser import convert_yaml
from plan4dial.parsers.pddl_parser import parse_to_pddl
from plan4dial.parsers.parse_for_rasa import make_nlu_file
from plan4dial.parsers.pddl_for_rollout import rollout_config
#from rasa.model_training import train_nlu


def generate_files(
    yaml_filename: str, output_folder: str, rbp_path: str, train: bool = False
):
    # make a new directory for this domain if it doesn't exist
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    # convert to hovor json config
    writer = open(f"{output_folder}/configuration_data.json", "w")
    converted_json = convert_yaml(yaml_filename)
    writer.write(json.dumps(converted_json, indent=4))
    # convert to PDDL
    domain, problem = parse_to_pddl(converted_json)
    domain_str, problem_str = f"{output_folder}/domain.pddl", f"{output_folder}/problem.pddl"
    writer = open(domain_str, "w")
    writer.write(domain)
    writer = open(problem_str, "w")
    writer.write(problem)
    writer = open(f"{output_folder}/nlu.yml", "w")

    # train rasa NLU model
    # if train:
    #     # parse for rasa
    #     yaml.dump(make_nlu_file(yaml_filename), writer)
    #     # download the spacy model if needed; wait until complete
    #     try:
    #         spacy.load("en_core_web_md")
    #     except OSError:
    #         subprocess.run(["python -m spacy download en_core_web_md"])
    #     train_nlu(
    #         config=f"nlu_config.yml",
    #         nlu_data=f"{output_folder}/nlu.yml",
    #         output=f"{output_folder}",
    #         fixed_model_name=f"nlu_model"
    #     )
    # generate PDDL files; convert policy.out to a prp.json file; wait until complete
    subprocess.run([f"{rbp_path}/prp", domain_str, problem_str, "--output-format", "3"])
    try:
        with open(f"policy.out") as f:
            plan_data = {f"plan": json.load(f)}
    except FileNotFoundError:
        raise Exception("PDDL is invalid.")
    with open(f"{output_folder}/plan_data.prp.json", "w") as f:
        json.dump(plan_data, f, indent=4)
    # delete extra output files
    os.remove("./policy.out")
    os.remove("./output.sas")
    # for rollout
    rollout_data = rollout_config(converted_json)
    with open(f"{output_folder}/rollout_config.json", "w") as f:
        json.dump(rollout_data, f, indent=4)


if __name__ == "__main__":
    generate_files(
        "./plan4dial/local_data/gold_standard_bot/gold_standard_bot.yml",
        "./plan4dial/local_data/gold_standard_bot/output_files",
        str((Path(__file__).parent.parent / "rbp").resolve()),
        True
    )
