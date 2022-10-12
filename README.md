# Plan4Dial

Generates a chatbot given a simple YAML configuration using automated planning for conversation navigation and machine learning for NLU.

## Documentation
https://qumulab.github.io/plan4dial/

## Requirements
**Note: Currently, Plan4Dial only supports Linux/WSL due to the restrictions on the RBP planner.**  
For ease of use and reducing the chance of import or versioning errors, it is recommended that you use a virtual environment such as `venv`.  
Run `pip install -r requirements.txt` to install the necessary libraries before using.  
Run `python -m spacy download en_core_web_md` to download the appropriate Spacy model. Along with Rasa, this is used for NLU.

## Usage/Tutorial
### 1. Create a YAML config file that defines your bot.
Let's go through an example. Suppose we want to create a chatbot that helps you decide what to do on your day off. This will be a fairly simple bot that picks a restaurant and outing location based on the user's preferences.   

(For later reference, the full YAML file as well as the output files can be found [here](https://github.com/QuMuLab/plan4dial/tree/main/plan4dial/local_data/gold_standard_bot)).  

First, create a YAML file and pick a name for the domain:

```
---
name: day-planner

...
```

There are three main parts to the YAML file you will need to define. They are `context variables`, `intents`, and `actions`.

#### Context Variables
The first step is to define the context variables. Context variables are variables that your bot will store throughout the course of the conversation to keep track of the context gathered so far. One of the most common use cases is to store information gathered from the user. In this case, we will want to keep track of the user's preferences, so let's define them:

### 2. Deploy the bot with HOVOR.


## Citing This Work
Coming soon!
