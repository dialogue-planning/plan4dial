# Plan4Dial

Generates a chatbot given a simple YAML configuration using automated planning for conversation navigation and machine learning for NLU.

## Documentation
https://qumulab.github.io/plan4dial/

## Requirements - Local Install
**Note: Currently, Plan4Dial only supports Linux/WSL due to the restrictions on the RBP planner.**  
For ease of use and reducing the chance of import or versioning errors, it is recommended that you use a virtual environment such as `venv`.  
Run `pip install -r requirements.txt` to install the necessary libraries before using.  
Run `python -m spacy download en_core_web_md` to download the appropriate Spacy model. Along with Rasa, this is used for NLU.

## Requirements - Docker
To ensure development works identically accross systems, Docker should be used to run Plan4Dial.  
Inside the repository, follow these steps to run with Docker:
1. Retrieve a copy of the rbp.sif executable from Christian Muise (christian.muise@queensu.ca) and place this in the cloned repository.
2. Build the docker image from Dockerfile: `docker build -t plan4dial:latest .`
3. Run a bash session inside a new docker container: `docker run -it --name plan4dial --rm --volume $(pwd)/plan4dial:/root/app/plan4dial --net=host --privileged plan4dial:latest sh`
    - OR if you are using Windows in CMD run: `docker run -it --name plan4dial --rm --volume %cd%/plan4dial:/root/app/plan4dial --net=host --privileged plan4dial:latest sh`
4. Run the command in the bash session: `python plan4dial/main.py gold_standard_bot`
5. Now you should see output files were created and successful output in the bash session in the container. You can copy these output files out from the filesystem outside the container, the /plan4dial subdirectory is mounted. 

Note: You can make changes to python files inside subfolder /plan4dial without rebuilding the docker container as it is mounted as as simple volume. 

## Usage/Tutorial
See [here](https://qumulab.github.io/plan4dial/tutorial.html) for the full tutorial.

## Citing This Work
Coming soon!
