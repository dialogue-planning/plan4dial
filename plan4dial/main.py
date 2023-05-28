"""
Main file responsible for generating the files that will be sent to HOVOR
(`contingent-plan-executor`) for executor.
Authors:
- Rebecca De Venezia
"""

import json
import os
import subprocess
import yaml
import sys
from for_generating.parsers.json_config_parser import convert_yaml
from for_generating.parsers.pddl_parser import parse_to_pddl
from for_generating.parsers.parse_for_rasa import make_nlu_file
from for_generating.parsers.pddl_for_rollout import rollout_config
from rasa.model_training import train_nlu


def generate_files(yaml_filename: str, output_folder: str, rbp_path: str):
    """
    Responsible for generating the files that will be sent to HOVOR
    (`contingent-plan-executor`) for execution.

    Args:
        yaml_filename (str): The path to the filled out YAML configuration.
        output_folder (str): Output folder where the files will be stored.
        rbp_path (str): Path to the `rbp <https://github.com/QuMuLab/rbp>`_ directory
            so the planner can be run. This can be a path directly to the
            executable .sif file.
        train (bool, optional): Determines if training is required. It is best to set
            to False if you made changes to the YAML that require some new output
            files, but the NLU model is not affected (no changes in the Rasa NLU YAML
            configuration). Defaults to True.

    Raises:
        (Exception): Raised if the planner was not able to find a valid plan. Happens
            if the YAML configuration (and by proxy, the PDDL) is invalid in some way
            (i.e. missing actions, can't get out of a loop, etc.)
    """
    # make a new directory for this domain if it doesn't exist
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    # convert to hovor json config
    converted_json = convert_yaml(
        yaml.load(open(yaml_filename, "r"), Loader=yaml.FullLoader)
    )
    with open(f"{output_folder}/data.json", "w") as writer:
        writer.write(json.dumps(converted_json, indent=4))
    # convert to PDDL
    domain, problem = parse_to_pddl(converted_json)
    domain_str, problem_str = (
        f"{output_folder}/domain.pddl",
        f"{output_folder}/problem.pddl",
    )
    with open(domain_str, "w") as writer:
        writer.write(domain)
    with open(problem_str, "w") as writer:
        writer.write(problem)

    # train rasa NLU model
    writer = open(f"{output_folder}/nlu.yml", "w")
    # parse for rasa. need to use the original YAML because some of the NLU
    # information is lost in the JSON configuration.
    yaml.dump(
        make_nlu_file(yaml.load(open(yaml_filename, "r"), Loader=yaml.FullLoader)),
        writer,
    )
    train_nlu(
        config="./plan4dial/for_generating/nlu_config.yml",
        nlu_data=f"{output_folder}/nlu.yml",
        output=f"{output_folder}",
        fixed_model_name="nlu_model",
    )

    print(f"Using rbp from path: {rbp_path}")
    print(f"with domain string path: {domain_str}")
    print(f"with problem string path: {problem_str}")

    # generate PDDL files; convert policy.out to a prp.json file; wait until complete
    subprocess.run([rbp_path, domain_str, problem_str, "--output-format", "3"])
    print("Ran the subprocess to generate pddl files.")
    try:
        with open("policy.out") as file:
            plan_data = {"plan": json.load(file)}
    except FileNotFoundError as err:
        raise Exception("PDDL is invalid.") from err
    with open(f"{output_folder}/data.prp.json", "w") as file:
        json.dump(plan_data, file, indent=4)
    # delete extra output files
    os.remove("./output.sas")
    # generate configuration for rollout
    rollout_data = rollout_config(converted_json)
    with open(f"{output_folder}/rollout_config.json", "w") as f:
        json.dump(rollout_data, f, indent=4)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        bot_name = sys.argv[1]
    else:
        bot_name = "gold_standard_bot"
    # we can hardcode the path as it will stay the same in docker container
    dirname = f"/root/app/plan4dial/local_data/{bot_name}"
    generate_files(
        f"{dirname}/{bot_name}.yml",
        f"{dirname}/output_files",
        "/root/rbp.sif",
    )
    print("Completed")
