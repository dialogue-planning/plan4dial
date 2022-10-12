Tutorial
=========

Requirements
------------
**Note: Currently, Plan4Dial only supports Linux/WSL due to the restrictions on the RBP planner.**  
For ease of use and reducing the chance of import or versioning errors, it is recommended that you use a virtual environment such as ``venv``.

| Run ``pip install -r requirements.txt`` to install the necessary libraries before using.  
| Run ``python -m spacy download en_core_web_md`` to download the appropriate Spacy model. This is used for NLU along with Rasa.

Usage Steps
--------------
1. Create a YAML config file that defines your bot.
+++++++++++++++++++++++++++++++++++++++++++++++++++
Let's go through an example. Suppose we want to create a chatbot that helps you decide what to do on your day off. This will be a fairly simple bot that picks a restaurant and outing location based on the user's preferences.   

(For later reference, the full YAML file as well as the output files can be found `here <https://github.com/QuMuLab/plan4dial/tree/main/plan4dial/local_data/gold_standard_bot>`_).  

First, create a YAML file and pick a name for the domain:

.. code-block:: yaml
   :linenos:

   ---
   name: day-planner


There are three main parts to the YAML file you will need to define.
They are ``context variables``, ``intents``, and ``actions``. We will examine each of these in turn.

Context Variables
.................
Context variables are variables that your bot will store throughout the course of the conversation to keep track of the context gathered so far.
Without context variables, the bot would not be able to store information from one line of dialogue to the next.

| One of the most common use cases of context variables is to store information gathered from the user. However, they can also be used internally to keep track of states in the conversation, the most common example being an indication of when the "goal" is reached.

In this case, we know we want to keep track of the user's preferences, which include options for cuisine, allergy/food restrictions, budget, and outing type. 

.. code-block:: yaml
   :linenos:
   :lineno-start: 3

    context_variables:
        cuisine:
            type: enum
            known:
                type: fflag
                init: false
            options:
                - Mexican
                - Italian
                - Chinese
                - Dessert
        have_allergy:
            type: flag
            init: false
            known:
                type: flag
                init: false
        food_restriction:
            type: enum
            known:
                type: flag
                init: false
            options:
                - dairy-free
                - gluten-free
        budget:
            type: enum
            known:
            type: flag
            init: false
            options:
            - low
            - high
  outing_type:
    type: enum
    known:
      type: fflag
      init: false 
    options:
      high-energy:
        variations:
          - fun
          - exciting
          - social
      low-energy:
        variations:
          - chill
          - relaxing
          - laid-back

Here, we have filled out 3 parameters for t


2. Deploy the bot with HOVOR.
+++++++++++++++++++++++++++++
