import json
import yaml
import os
import subprocess
import spacy
from pathlib import Path
from plan4dial.parsing.json_config_parser import convert_yaml
from plan4dial.parsing.pddl_parser import parse_to_pddl
from plan4dial.parsing.parse_for_rasa import make_nlu_file
from plan4dial.parsing.pddl_for_rollout import rollout_config
from rasa.model_training import train_nlu


def generate_files(
    yaml_filename: str, domain_name: str, rbp_path: str, train: bool = False
):
    dirname = f"./output_files/{domain_name}"
    # make a new directory for this domain if it doesn't exist
    if not os.path.exists(dirname):
        os.makedirs(dirname)
    # convert to hovor json config
    writer = open(f"{dirname}/{domain_name}.json", "w")
    converted_json = convert_yaml(yaml_filename)
    writer.write(json.dumps(converted_json, indent=4))
    # convert to PDDL
    domain, problem = parse_to_pddl(converted_json)
    domain_str, problem_str = f"{dirname}/{domain_name}_domain.pddl", f"{dirname}/{domain_name}_problem.pddl"
    writer = open(domain_str, "w")
    writer.write(domain)
    writer = open(problem_str, "w")
    writer.write(problem)
    writer = open(f"{dirname}/{domain_name}_nlu.yml", "w")
    # parse for rasa
    yaml.dump(make_nlu_file(yaml_filename), writer)
    # train rasa NLU model
    if train:
        # download the spacy model if needed; wait until complete
        try:
            spacy.load("en_core_web_md")
        except OSError:
            subprocess.run(["python -m spacy download en_core_web_md"])
        train_nlu(
            config=f"./output_files/config.yml",
            nlu_data=f"{dirname}/{domain_name}_nlu.yml",
            output=f"{dirname}",
            fixed_model_name=f"{domain_name}-model"
        )
    # # generate PDDL files; convert policy.out to a prp.json file; wait until complete
    # subprocess.run([f"{rbp_path}/prp", domain_str, problem_str, "--output-format", "3"])
    # with open(f"policy.out") as f:
    #     plan_data = {f"plan": json.load(f)}
    # with open(f"{dirname}/{domain_name}.prp.json", "w") as f:
    #     json.dump(plan_data, f, indent=4)
    # # delete extra output files
    # os.remove("./policy.out")
    # os.remove("./output.sas")
    # for rollout
    rollout_data = rollout_config(converted_json)
    with open(f"{dirname}/{domain_name}_rollout_config.json", "w") as f:
        json.dump(rollout_data, f, indent=4)


if __name__ == "__main__":
    generate_files(
        "./plan4dial/yaml_samples/end_message_v2.yml",
        "end_message_v2",
        str((Path(__file__).parent.parent / "rbp").resolve()),
        False
    )
