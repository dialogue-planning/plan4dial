import json
import os
import subprocess
import yaml
from for_generating.parsers.json_config_parser import convert_yaml
from for_generating.parsers.pddl_parser import parse_to_pddl
from for_generating.parsers.parse_for_rasa import make_nlu_file
from for_generating.parsers.pddl_for_rollout import rollout_config

from rasa.model_training import train_nlu


def generate_files(
    yaml_filename: str, output_folder: str, rbp_path: str, train: bool = True
):
    """Main file responsible for generating the files that will be sent to
    HOVOR (`contingent-plan-executor`) for executor.

    Args:
        yaml_filename (str): The path to the filled out YAML configuration. 
        output_folder (str): Output folder where the files will be stored.
        rbp_path (str): Path to the `rbp` directory so the planner can be run.
        train (bool, optional): Determines if training is required. It is best to
        set to False if you made changes to the YAML that require some new output
        files, but the NLU model is not affected (no changes in the Rasa NLU YAML
        configuration). Defaults to True.

    Raises:
        (Exception): Raised if the planner was not able to find a
        valid plan. Happens if the YAML configuration (and by proxy, the PDDL) is
        invalid in some way (i.e. missing actions, can't get out of a loop, etc.)
    """
    # make a new directory for this domain if it doesn't exist
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    # convert to hovor json config
    converted_json = convert_yaml(yaml.load(open(yaml_filename, "r"), Loader=yaml.FullLoader))
    with open(f"{output_folder}/data.json", "w") as writer:
        writer.write(json.dumps(converted_json, indent=4))
    # # convert to PDDL
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
    if train:
        writer = open(f"{output_folder}/nlu.yml", "w")
        # parse for rasa. need to use the original YAML because some of the NLU
        # information is lost in the JSON configuration.
        yaml.dump(make_nlu_file(yaml.load(open(yaml_filename, "r"), Loader=yaml.FullLoader)), writer)
        train_nlu(
            config=f"./plan4dial/generate_files/nlu_config.yml",
            nlu_data=f"{output_folder}/nlu.yml",
            output=f"{output_folder}",
            fixed_model_name=f"nlu_model",
        )
    # generate PDDL files; convert policy.out to a prp.json file; wait until complete
    subprocess.run([f"{rbp_path}/prp", domain_str, problem_str, "--output-format", "3"])

    try:
        with open(f"policy.out") as f:
            plan_data = {f"plan": json.load(f)}
    except FileNotFoundError as err:
        raise Exception("PDDL is invalid.") from err
    with open(f"{output_folder}/data.prp.json", "w") as f:
        json.dump(plan_data, f, indent=4)
    # delete extra output files
    os.remove("./policy.out")
    os.remove("./output.sas")
    # generate configuration for rollout
    rollout_data = rollout_config(converted_json)
    with open(f"{output_folder}/rollout_config.json", "w") as f:
        json.dump(rollout_data, f, indent=4)


if __name__ == "__main__":
    dirname = "./plan4dial/local_data/gold_standard_bot"
    generate_files(
        f"{dirname}/gold_standard_bot.yml",
        f"{dirname}/output_files",
        "/home/vivi/rbp",
        True,
    )
