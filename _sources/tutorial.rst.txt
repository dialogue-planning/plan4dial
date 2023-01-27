Tutorial
=========
 
Requirements - Local Install
----------------------------
**Note: Currently, Plan4Dial only supports Linux/WSL due to the restrictions on the RBP planner.**  
**Note: Please use a version of Python < 3.10 because of issues with Rasa compatibility**.  

| For ease of use and reducing the chance of import or versioning errors, it is recommended that you use a virtual environment such as ``venv``.
| Run ``pip install -r requirements.txt`` to install the necessary libraries before using.  
| Run ``python -m spacy download en_core_web_md`` to download the appropriate Spacy model. This is used for NLU along with Rasa.

Requirements - Docker
---------------------

| To ensure development works identically accross systems, Docker should be used to run Plan4Dial.  
| Inside the repository, follow these steps to run with Docker:
| Retrieve a copy of the rbp.sif executable from Christian Muise (christian.muise@queensu.ca) and place this in the cloned repository.
| Build the docker image from Dockerfile: ``docker build -t plan4dial:latest .``
| Run a bash session inside a new docker container: ``docker run -it --name plan4dial --rm --volume $(pwd)/plan4dial:/root/app/plan4dial --net=host --privileged plan4dial:latest sh``
| Run the command in the bash session: ``python plan4dial/main.py gold_standard_bot``
| Now you should see output files were created and successful output in the bash session in the container. You can copy these output files out from the filesystem outside the container, as the /plan4dial subdirectory is mounted.

Note: You can make changes to python files inside subfolder /plan4dial without rebuilding the docker container as it is mounted as as simple volume. 


Usage Steps
--------------

Create a YAML config file that defines your bot.
+++++++++++++++++++++++++++++++++++++++++++++++++++

Let's go through an example. Suppose we want to create a chatbot that helps you decide what to do on your day off. This will be a fairly simple bot that picks a restaurant and outing location based on the user's preferences.   

(For later reference, the full YAML file as well as the output files can be found `here <https://github.com/QuMuLab/plan4dial/tree/main/plan4dial/local_data/gold_standard_bot>`_).  

First, create a YAML file and pick a name for the domain:

.. code-block:: yaml

   ---
   name: day-planner


There are three main parts to the YAML file you will need to define.
They are ``context variables``, ``intents``, and ``actions``. We will examine each of these in turn.

1. Define the Context Variables
...............................

Context variables are variables that your bot will store throughout the course of the conversation to keep track of the context gathered so far.
Without context variables, the bot would not be able to store information from one line of dialogue to the next.

One of the most common use cases of context variables is to store information gathered from the user. However, they can also be used internally to keep track of states in the conversation, the most common example being an indication of when the "goal" is reached.

In this case, we know we want to keep track of the user's preferences, which include options for location, cuisine, allergy/food restrictions, budget, and outing type. 
Let's examine the context variables for location, cuisine, and food restrictions first.

.. code-block:: yaml

      context_variables:
        # user's location
        location:
          type: json
          extraction:
            method: spacy
            config_method: gpe
          known:
            type: flag
            init: false
        # user's preferred cuisine; must map to one of the 4 options
        cuisine:
          type: enum
          known:
            type: fflag
            init: false
          options:
            - Mexican
            - Italian
            - Chinese
            - dessert
        # indicates if the user has an allergy
        have_allergy:
          type: flag
          init: false
          known:
            type: flag
            init: false
        # food restrictions/allergies that the bot can take into account
        food_restriction:
          type: enum
          known:
            type: flag
            init: false
          options:
            - dairy-free
            - gluten-free

We can see that each context variable has been assigned a type: ``json``, ``enum``, and ``flag`` respectively. We can also see that another type, ``fflag``, exists under the ``known`` section of *cuisine* (more on this later).

These are the only **four** types that we can define in the YAML. They are defined as follows:


.. _variable_types:

+------------+--------------------------------------------------------------------+
| type       | definition                                                         |
+============+====================================================================+
| flag       | A boolean value; can only be set to ``true`` or ``false``.         |
+------------+--------------------------------------------------------------------+
| fflag      | "Fuzzy flag"; can only be set to ``true``, ``false``, or ``maybe``.|
+------------+--------------------------------------------------------------------+
| enum       | Can only be set to the values set under the ``options`` list.      |
+------------+--------------------------------------------------------------------+
| json       | Used if you want to use an alternate extraction method,            |
|            | i.e. Spacy GPE. Optionally can add an ``options`` list like an     |
|            | enum.                                                              |
|            |                                                                    |
|            | **NOTE**: Currently, only Spacy is compatible with this            |
|            | option.                                                            |
+------------+--------------------------------------------------------------------+

So, "location" is of type ``json`` because we want to use `Spacy GPE <https://spacy.io/usage/spacy-101#annotations-ner>`_ for location extraction. (In the case of location, it makes the most sense to use a model finely tuned to detect location, instead of Rasa, which is trained only on the examples you provide).
You can see that under ``extraction``, we specified both the method ``spacy`` and the configuration for NER (named entity recognition), in this case `gpe` for location.
Note that if we were to specify cities under "options", only those extracted location would be viable.
However, since we are leaving it out, any city the user enters is valid.

*cuisine* is of type ``enum`` because we only want it to have 4 valid values: *Mexican*, *Italian*, *Chinese*, and *dessert*. *food_restriction* is of type ``enum`` for the same reason.

*have_allergy*, which determines if the user has an allergy (in which case we need to get their *food_restriction*), is of type ``flag``. That is, they either do or don't have an allergy. For this variable, you can also see that it has an ``init`` option. This is only available to ``flag`` or ``fflag`` type variables, and it allows you to set an initial value for the variable and change the initial state of the conversation. In this case, we default the variable to ``false``.

.. _known:

Each variable also has a ``known`` option which determines the knowledge we have about the variable.
The ``known`` ``type`` can only be set to either ``flag`` or ``fflag``, and functions in the same way.
This parameter is extermely important as conversation navigation is often predicated on what context we know, maybe know, or don't know so far.

In most cases, the ``known``'s ``init`` setting is set to ``false``, but the ``type`` setting depends on what makes the most sense for the variable.
Often in the case of ``enum`` type variables like *cuisine*, it makes the most sense to allow for a little variance in user input.
They may something that somewhat resembles one of the available options, and it is helpful to store their answer, classify it as "maybe known", and clarify the user's intention.
For simpler variables like *have_allergy*, a ``known`` ``type`` setting of ``flag`` should suffice.  

With this in mind, let's add the rest of the context variables.

.. code-block:: yaml

      # possible budget options
      budget:
        type: enum
        known:
          type: flag
          init: false
        options:
          - low
          - high
      # user's outing preferences
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
      # activated if there is a conflict between the user's cuisine preference and food restrictions
      conflict:
        type: flag
        init: false
        known:
          type: flag
          init: false
      # possible restaurant options
      restaurant:
        type: enum
        known:
          type: flag
          init: false
        options:
          - Guac Grill
          - Alfredo's Pizza Café
          - Mandarin
          - Geneva Crepes
      # possible outing options
      outing:
        type: enum
        known:
          type: flag
          init: false
        options:
          - Stages
          - Stauffer Library
          - Broadway Theater
          - Smith's Golfing Club
      # ends the conversation if true
      goal:
        type: flag
        init: false
        known:
          type: flag
          init: false

While most of this you've already seen, let's draw attention to a couple things.

In *outing_type*, we've supplied some ``variations`` under the ``options`` the user can provide. 
These indicate that if the user utters any of the variations, the bot will **map the user's utterance back to the original option**. 
While I've only given a few examples for simplicity, it is extremely important to supply lots of training examples to make your model more robust. 
There is an exception to this rule, though. In the case of *outing*, although the variable is of ``type`` ``enum``, the variable value will be set internally based on the user's preferences instead of through directly analyzing the user's input. 
Since this will be completely in the control of the bot designer and not reliant on the NLU, no variations need to be provided there.

Also, a ``flag`` *goal* variable is mandatory for every bot as it determines when the conversation ends (more on this later). 

You're all set to define context variables for your bot! Let's move on to the next step: intents.

2. Define the Intents
.....................

The next step is to define the intents. 
Intents are characterizations of what the user is trying to say. For example, if the user says "yes", then their intent is to "confirm" the bot's statement.
Intents are parsed/analyzed using Rasa NLU.
They are important as we need to be able to map arbitrary user input to tangible results that determines where to go next in the conversation.
**NOTE**: We do not use Rasa for anything other than off-the-shelf NLU (more information can be found :ref:`here <why>`).

An intent is made up these parts:

1. **utterances**: Examples of utterances that constitute that intent.
Similar to context variable ``variations``, it is best to supply as many of these as you can, as these will be passed off to Rasa as training examples.
Ideally, you shouldn't have intents with utterances that are too similar to one another, as this will make it harder for the model to pinpoint what the user wants.

2. **entities**: (Optional) Any entities that are extracted with this intent.
Entities are variables that are extracted from the user.
Within the intent, each entity must be preceded with a ``$`` symbol to indicate the location of the entity in the utterance.


Let's see what the intents for our ``day-planner`` bot look like:

.. code-block:: yaml

      intents:
        confirm:
          utterances:
            - "yes"
            - yeah
            - that's it
            - "Y"
            - mhm
            - confirm
            - yes please
        deny:
          utterances:
            - "no"
            - not at all
            - that's not what i meant
            - absolutely not
            - i don't want that
            - nah
            - no thanks
            - no thank you
        share_location:
          entities:
            - location
          utterances:
            - I live in $location.
            - I am located in $location.
            - Can you help me find things to do in $location?
        share_cuisine:
          entities:
            - cuisine
          utterances:
            - I want to eat $cuisine.
            - Do you have restaurants of type $cuisine?
            - Are there any $cuisine restaurants in the area?
        share_allergies:
          entities:
            - food_restriction
          utterances:
            - I have to eat $food_restriction.
            - I can only eat foods that are $food_restriction.
            - I am allergic to any foods that are not $food_restriction.
        share_all_outing_preferences:
          entities:
            - budget
            - outing_type
          utterances:
            - I have a $budget budget and I would prefer a $outing_type atmosphere today.
            - I am operating within a $budget budget and I want to go to a $outing_type place.
            - I can do activities with a $budget budget and I want to find the most $outing_type place in the city.
        share_budget:
          entities:
            - budget
          utterances:
            - I have a $budget budget.
            - I am operating within a $budget budget.
            - I can do activities with a $budget budget.
        share_outing_type:
          entities:
            - outing_type
          utterances:
            - I would prefer a $outing_type atmosphere today.
            - I want to go to a $outing_type place.
            - What is the most $outing_type place in the city?


**NOTE**: All ``utterances`` must include *exactly* all the entities listed under ``entities``; no more, no less.
In practice, this does not mean that all entities will actually be extracted at runtime, but it needs to be indicated
what the intent is actually trying to accomplish.

3. Define the Actions
.....................

``actions`` are the core of dialogue agent design as they specify what your agent can do and when.
We use a **declarative** specification powered by automated planning that allows you to treat actions as separate pieces of a puzzle.
You won't have to draw out complex dialogue trees that you will have to completely dismantle if you decide late in the game that you want to add a new action near the top.
Instead, actions are chosen based on what is true in the state of the world. 
Only actions whose ``preconditions`` are satisfied are executed.

It is important to reiterate that ``actions`` refer only to the actions that the dialogue agent can take, and that chatbot creation is seen primarily through the lens of the agent's perspective.
User utterances are only handled by deciphering ``intents`` as described above.

There are **four** types of actions:

.. _action_types:

+------------+--------------------------------------------------------------------+
| type       | definition                                                         |
+============+====================================================================+
| dialogue   | Actions where the agent utters something to the user.              |
|            |                                                                    |
|            | Often the user's intent is extracted, which is then used to        |
|            | determine the outcome.                                             |
|            |                                                                    |
|            | However, the agent can also utter a message without taking any     |
|            | user input.                                                        |
|            |                                                                    |
|            | This happens if you only specify a single outcome for a dialogue   | 
|            | action as the agent knows it will end up in the same place         |
|            | regardless of what the user says, and so skips getting input       |
|            | entirely.                                                          |
+------------+--------------------------------------------------------------------+
| system     | Actions that are completely internal the agent, usually changing   |
|            | the value of some context variable based on logic.                 |
+------------+--------------------------------------------------------------------+
| api        | Actions that make API calls, the status of which determines the    |
|            | outcome.                                                           |
|            |                                                                    |
|            | **NOTE**: Still in development.                                    |
+------------+--------------------------------------------------------------------+
| custom     | Custom actions created by you, the bot designer.                   |
|            | These allow you to create action templates which speeds up action  |
|            | creation.                                                          |
|            |                                                                    |
|            | These are written in Python and stored under                       |
|            | ``plan4dial/for_generating/custom_actions``.                       |
|            |                                                                    |
|            | :py:func:`slot_fill                                                |
|            | <plan4dial.for_generating.custom_actions.slot_fill.slot_fill>`     |
|            | is a useful example available for use.                             |
|            |                                                                    |
|            | These action will end up being one of the above types, but can be  |
|            | configured in a custom way.                                        |
+------------+--------------------------------------------------------------------+

There is also an important subtype you should know.

The **Context dependent determination** subtype can only be applied to system actions.
Using this subtype indicates that you are going to have mini if-elif statements (called contexts) that determine which outcome is executed.
This is different than "vanilla"/non-subtyped system actions which don't check any context when activated and execute the single outcome.

A **context** is one (or multiple) settings to context variables.
For example, some outcome A could depend on  *location* being "Toronto",
while outcome B could depend on *time* being "12 pm".

We will see examples of every type (other than api) and subtype in our ``day-planner`` example.

Let's start by examining a simple :ref:`dialogue action <action_types>`.
We'll create an action ``get-have-allergy`` that asks the user if they have an allergy or not, which expects a simple yes/no response.

.. code-block:: yaml

      actions:
        get-have-allergy:
          type: dialogue
          message_variants:
            - Do you have any allergies? (Y/N)
          condition:
            have_allergy:
              known: false 
          effect:
            set-allergy:
              oneof:
                outcomes:
                  indicate_allergy:
                    updates:
                      have_allergy:
                        value: true
                        known: true
                    intent: confirm
                    follow_up: get-allergy
                  indicate_no_allergy:
                    updates:
                      have_allergy:
                        known: true
                        value: false
                      conflict:
                        known: true
                        value: false
                    intent: deny

We can see that actions take a number of parameters, including ``type`` as discussed above.

``message_variants`` are messages that the agent can utter when this action takes place.
This parameter can only be supplied for dialogue actions.
You can supply as many messages as you want, and one will be randomly selected at runtime.

The ``condition`` is what you would think of as a "precondition" in automated planning.
Whatever you supply in the ``condition`` is what must be true for the action to take place.
This offers a lot more flexibility than determining a hard-coded sequence of actions through a dialogue tree
as you don't need to know all the details about where exactly in the conversation the action takes place,
you only need to know in what states it's allowed to trigger. 
This also allows for inserting new actions at any point in development with ease.

In this case, the only condition is that we don't know if the user has an allergy or not yet.

The ``effect`` is what occurs when the action takes place. 
It consists of a name (in this case ``set-allergy``), followed by ``oneof`` and a list of ``outcomes``.
As the names suggest, only one of the outcomes will be executed depending on the factors at play.

Each outcome also consists of a name, in this case ``indicate_allergy`` and ``indicate_no_allergy``.

There are **four** different parameters that outcomes can take.
Outcomes can use multiple and need at least one.

+---------------------+------------------------------------------------------------------------+
| parameters          | definition                                                             |
+=====================+========================================================================+
| updates             | Used in practically every outcome.                                     |
|                     | Here you define the changing ``value`` s of context variables.         |
|                     |                                                                        |
|                     | You also define how the ``known`` status of each variable has updated. |
|                     |                                                                        |
|                     | This is **extremely important** to do correctly as "knowing what you   |
|                     | know" is a huge part of conversation navigation!                       |
|                     |                                                                        |
|                     | **NOTE** if you want to set the variable to the value taken from the   |
|                     | user, precede the variable name with ``$``.                            |
+---------------------+------------------------------------------------------------------------+
| intent              | Used for dialogue actions with > 1 outcome,                            |
|                     | where the user's input will be disambiguated.                          |
|                     |                                                                        |
|                     | By specifying the intent, you are indicating that this outcome will be |
|                     | the course of action taken when the user's input matches that intent.  |
+---------------------+------------------------------------------------------------------------+
| follow_up           | Forces a particular action to "follow up" this outcome.                |
|                     |                                                                        |
|                     | This is meant to be situational and not used for every single action,  |
|                     | in which case you are essentially building a dialogue tree.            |
+---------------------+------------------------------------------------------------------------+
| response_variants   | A response, or message, that the bot will utter *after* the action has |
|                     | been executed.                                                         |
|                     |                                                                        |
|                     | Any one of the variants will be picked at random at runtime.           |
+---------------------+------------------------------------------------------------------------+
| context             | Only used in actions with type ``system`` and subtype                  |
|                     | **Context dependent determination**.                                   |
|                     |                                                                        |
|                     | Specifies what context must be true in order for the outcome to take   |
|                     | place.                                                                 |
+---------------------+------------------------------------------------------------------------+

With this in mind, we can see that the outcome ``indicate_allergy`` is triggered when the user answers with ``confirm``.
The ``updates`` indicate that ``have_allergy`` is set to a value of ``true`` and is now ``known``.
We also force a ``follow_up`` where we try to determine what the user's allergy is.

In the outcome ``indicate_no_allergy``, we can see that ``conflict`` is set to a value of false.
This is because we know that if the user has no allergies, we will never come across a conflict between their allergies and their chosen cuisine.

Next, let's take a look at the actions that actually extract information from the user.

``get_outing``, the action where we try to extract both the user's budget and preference of outing, is the most comprehensive example:

.. code-block:: yaml

  get_outing:
    type: custom
    subtype: slot_fill
    parameters:
      action_name: get_outing
      entities:
        - budget
        - outing_type
      intent: share_all_outing_preferences
      message_variants:
        - What kind of outing would you like to go to? Please specify both your budget (high or low) and the type of atmosphere you're looking for (i.e. fun, relaxing, etc.)
      fallback_message_variants:
        - Sorry, that isn't a valid outing preference.
      config_entities:
        budget:
          fallback_message_variants:
            - Sorry, that isn't a valid budget option. Please select either high or low.
          single_slot_message_variants:
            - What is your budget preference? Please select either high or low.
          single_slot_intent: share_budget
        outing_type:
          fallback_message_variants:
            - Sorry, that isn't a valid outing type.
          single_slot_message_variants:
            - What is your preferred outing type? Use a descriptive adjective like fun, high-energy, relaxing, etc.
          single_slot_intent: share_outing_type
          clarify_message_variants:
            - Sorry, I wasn't quite sure about your outing type preference. Did you want a(n) $outing_type atmosphere?
      additional_updates:
        - outcome:
            budget:
              known: true
          response_variants:
            - Ok, I'll take that into account.
        - outcome:
            outing_type:
              known: true
          response_variants:
            - Great choice!

We can see that this action is configured quite differently than the rest -
this is because it is a :ref:`custom action <action_types>`.

In this case, the action is built from the :py:func:`slot_fill <plan4dial.for_generating.custom_actions.slot_fill.slot_fill>`
template, which is provided by default in Plan4Dial.
This template allows you to extract any number of entities, and even accounts for all the possible combinations of certainties --
i.e. budget is ``known`` and outing_type is ``maybe`` ``known``, vice versa, etc.

If you go to the source code of the function, you'll see that the parameters of the custom action are provided under ``parameters``
of ``get_outing``. A full explanation of what each parameter is can be seen in the documentation for :py:func:`slot_fill <plan4dial.for_generating.custom_actions.slot_fill.slot_fill>`.

The values for location, cuisine, and food restrictions are extracted with the same custom action:

.. code-block:: yaml

  get-location:
    type: custom
    subtype: slot_fill
    parameters:
      action_name: get-location
      intent: share_location
      entities:
        - location
      message_variants:
        - Where are you located?
      fallback_message_variants:
        - Sorry, that isn't a valid location.
      additional_updates:
        - outcome:
            location:
              known: true
          response_variants:
            - Tailoring your results to what's available in $location...
  get-cuisine:
    type: custom
    subtype: slot_fill
    parameters:
      action_name: get-cuisine
      entities:
        - cuisine
      intent: share_cuisine
      message_variants:
        - What is your cuisine of choice? Mexican, Italian, Chinese, and dessert restaurants are in the area.
      fallback_message_variants:
        - Sorry, that isn't a valid cuisine. 
      config_entities:
        cuisine:
          fallback_message_variants:
            - Sorry, that still isn't a valid cuisine.
          clarify_message_variants:
            - I didn't quite get your cuisine preference. Do you want to eat $cuisine?
      additional_updates:
        - outcome:
            cuisine:
              known: true
          response_variants:
            - Cuisine preference has been logged.
  get-allergy:
    type: dialogue
    message_variants:
      - What type of allergy do you have? (I currently account for dairy and gluten allergies).
    fallback_message_variants:
      - Sorry, I don't recognize that type of allergy.
    condition:
      have_allergy:
        known: true
        value: true
    effect:
      set-allergy:
        oneof:
          outcomes:
            update_allergy:
              updates:
                food_restriction:
                  value: $food_restriction
                  known: true
              intent: share_allergies

Next, let's take a look at a simple :ref:`system action <action_types>` our bot will use.

.. code-block:: yaml

  reset-preferences:
    type: system
    condition:
      conflict:
        known: true
        value: true
    effect:
      reset:
        oneof:
          outcomes:
            reset-values:
              updates:
                have_allergy:
                  known: false
                food_restriction:
                  known: false
                cuisine:
                  known: false
                conflict:
                  known: false 
              response_variants:
                - Sorry, but there are no restaurants that match your allergy and cuisine preferences. Try entering a different set of preferences.

We can see that a :ref:`system action <action_types>` is only concerned with changing the values of some context variables given that a given state is true.

The purpose of this action in particular is to reset the user's inputs for allergies/food restriction as well as cuisine choice and the conflict flag when a conflict has been detected.
The response variants indicate what the bot will tell the user after it performed the action.

Note that since this is a "vanilla" system action, we have only specified one outcome, so the execution of this action is deterministic.
We will now see an example where the special subtype of system action uses multiple outcomes.

Let's take a look at the action ``check-conflicts``:

.. code-block:: yaml

  check-conflicts:
    type: system
    subtype: Context dependent determination
    condition:
      location:
        known: true
      have_allergy:
        known: true
        value: true
      food_restriction:
        known: true
      cuisine:
        known: true
      conflict:
        known: false
    effect:
      check-conflicts:
        oneof:
          outcomes:
            restriction-dessert:
              updates:
                conflict:
                  known: true
                  value: true
              context:
                cuisine:
                  value: dessert
                food_restriction:
                  value: dairy-free
            restriction-mexican:
              updates:
                conflict:
                  known: true
                  value: true
              context:
                cuisine:
                  value: Mexican
                food_restriction:
                  value: gluten-free
            no-restriction-1:
              updates:
                conflict:
                  known: true
                  value: false
              context:
                cuisine:
                  value: Italian
            no-restriction-2:
              updates:
                conflict:
                  known: true
                  value: false
              context:
                cuisine:
                  value: Chinese
            no-restriction-3:
              updates:
                conflict:
                  known: true
                  value: false
              context:
                cuisine:
                  value: dessert
                food_restriction:
                  value: gluten-free               
            no-restriction-4:
              updates:
                conflict:
                  known: true
                  value: false
              context:
                cuisine:
                  value: Mexican
                food_restriction:
                  value: dairy-free

For the sake of making a good example, we have arbitrarily decided that there are two possible conflicts with the user's choices:
there are no gluten-free Mexican restaurants or dairy-free dessert places in the area.
With this in mind, we need to check if there's a conflict with the user's responses.

The ``precondition`` of ``check-conflicts`` ensures we've gathered all the information on location, food restrictions, and cuisine that the user specified.
It also ensures that we don't know the conflict yet (so we don't loop back on the same action).

Unlike the first :ref:`system action <action_types>` example, this action has multiple outcomes.
But without any input from the user (which is only taken in :ref:`dialogue action <action_types>`),
how will the outcome be chosen? The answer lies in the ``context`` provided in each outcome.

When this type of action is executed, the outcome determiner will run through each outcome and select the one whose ``context`` setting is a *subset of the current state of the world*.

In this case, that means setting the value to ``conflict`` depending on what combination of input the user entered previously.

**NOTE**: This specification will become shorter and cleaner with the closing of `#4 <https://github.com/QuMuLab/plan4dial/issues/4>`_. 

**And that's all the action types!** Now you have every piece of the puzzle you need to specify your bot.
There are a few actions we didn't cover, but they are all more examples of the above.

You can see the full YAML file at ``plan4dial/plan4dial/local_data/gold_standard_bot/gold_standard_bot.yml``. 

Generate the files needed to test the bot with HOVOR.
+++++++++++++++++++++++++++++++++++++++++++++++++++++++

Call :py:func:`generate_files <plan4dial.main.generate_files>`.

Then, clone HOVOR from `this branch <https://github.com/QuMuLab/contingent-plan-executor/tree/create_bot_integrate_rollout>`_.

In the repo you just cloned, navigate to ``local_main.py`` and run ``run_local_conversation`` with your output files directory as the parameter.
