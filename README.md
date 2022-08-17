# Plan4Dial

Generates and trains a chatbot given a simple YAML configuration using automated planning for conversation navigation.

## Requirements
**Note: Currently, Plan4Dial only supports Linux/WSL due to the restrictions on the RBP planner.**
Simply run `pip install -r requirements.txt` to install the necessary libraries before using.

## Usage
### 1. Create a YAML config file that specifies context variables, intents, and actions that your bot can take.
Let's create a simple example to see how this works. Suppose we want to create a chatbot that helps you decide what to do on your day off.
#### Context Variables
The first step is to define the context variables. Context variables are variables that your bot will store throughout the course of the conversation to keep track of the context gathered so far. One of the most common use cases is to store information gathered from the user. In this case, we will want to keep track of the user's preferences, so let's define them:

## Citing This Work
Coming soon!
