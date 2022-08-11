import json
import yaml
import os
from pathlib import Path
from plan4dial.parsing.json_config_parser import convert_yaml
from plan4dial.parsing.pddl_parser import parse_to_pddl
from plan4dial.parsing.parse_for_rasa import make_nlu_file
from plan4dial.parsing.pddl_for_rollout import rollout_config
#from rasa.model_training import train_nlu


def generate_files(
    yaml_filename: str, domain_name: str, rbp_path: str, train: bool = False
):
    # convert to hovor json config
    writer = open(
        str((Path(__file__).parent / "output_files" / f"{domain_name}.json").resolve()),
        "w",
    )
    converted_json = convert_yaml(yaml_filename)
    writer.write(json.dumps(converted_json, indent=4))
    # convert to PDDL
    domain, problem = parse_to_pddl(converted_json)
    domain_str, problem_str = str(
        (Path(__file__).parent / "output_files" / f"{domain_name}_domain.pddl").resolve()
    ), str(
        (
            Path(__file__).parent / "output_files" / f"{domain_name}_problem.pddl"
        ).resolve()
    )
    writer = open(domain_str, "w")
    writer.write(domain)
    writer = open(problem_str, "w")
    writer.write(problem)
    writer = open(
        str(
            (
                Path(__file__).parent / "output_files" / f"{domain_name}_nlu.yaml"
            ).resolve()
        ),
        "w",
    )
    # parse for rasa
    yaml.dump(make_nlu_file(yaml_filename), writer)
    # train rasa NLU model
    if train:
        train_nlu(
            config=f"./{domain_name}/config.yml",
            nlu_data=f"./{domain_name}/nlu.yml",
            output=f"./{domain_name}",
            fixed_model_name=f"{domain_name}-model"
        )
    # generate PDDL files; convert policy.out to a prp.json file
    cmd =  f"{str((Path(rbp_path)  / 'prp').resolve())} {domain_str} {problem_str} --output-format 3"
    os.system(cmd)
    with open(f"policy.out") as f:
        plan_data = {f"plan": json.load(f)}
    with open(
        str(
            (
                Path(__file__).parent / "output_files" / f"{domain_name}.prp.json"
            ).resolve()
        ),
        "w",
    ) as f:
        json.dump(plan_data, f, indent=4)
    # delete extra output files
    os.remove("policy.out")
    os.remove("output.sas")
    # for rollout
    rollout_data = rollout_config(converted_json)
    with open(
        str(
            (
                Path(__file__).parent / "output_files" / f"{domain_name}_rollout_config.json"
            ).resolve()
        ),
        "w",
    ) as f:
        json.dump(rollout_data, f, indent=4)


if __name__ == "__main__":
    generate_files(
        str(
            (
                Path(__file__).parent
                / "plan4dial"
                / "yaml_samples"
                / "advanced_custom_actions_test_v3.yaml"
            ).resolve()
        ),
        "pizza",
        str((Path(__file__).parent.parent / "rbp").resolve()),
        False
    )
