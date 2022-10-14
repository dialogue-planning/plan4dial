Tutorial
=========
 
Requirements
------------
**Note: Currently, Plan4Dial only supports Linux/WSL due to the restrictions on the RBP planner.**  

| For ease of use and reducing the chance of import or versioning errors, it is recommended that you use a virtual environment such as ``venv``.
| Run ``pip install -r requirements.txt`` to install the necessary libraries before using.  
| Run ``python -m spacy download en_core_web_md`` to download the appropriate Spacy model. This is used for NLU along with Rasa.

Usage Steps
--------------
Create a YAML config file that defines your bot.
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

1. Define the Context Variables
...............................

Context variables are variables that your bot will store throughout the course of the conversation to keep track of the context gathered so far.
Without context variables, the bot would not be able to store information from one line of dialogue to the next.

One of the most common use cases of context variables is to store information gathered from the user. However, they can also be used internally to keep track of states in the conversation, the most common example being an indication of when the "goal" is reached.

In this case, we know we want to keep track of the user's preferences, which include options for location, cuisine, allergy/food restrictions, budget, and outing type. 
Let's examine the context variables for location, cuisine, and food restrictions first.

.. code-block:: yaml
   :linenos:
   :lineno-start: 3

      context_variables:
        # user's location
        location:
          type: json
          extraction:
            method: spacy
            config_method: gpe
          known:
            type: fflag
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


.. _types:

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
|            | i.e. Spacy GPE.                                                    |
|            |                                                                    |
|            | **NOTE**: Currently, only Spacy is compatible with this            |
|            | option.                                                            |
+------------+--------------------------------------------------------------------+

So, "location" is of type ``json`` because we want to use `Spacy GPE <https://spacy.io/usage/spacy-101#annotations-ner>`_ for location extraction. (In the case of location, it makes the most sense to use a model finely tuned to detect location, instead of Rasa, which is trained only on the examples you provide).
You can see that under ``extraction``, we specified both the method ``spacy`` and the configuration for NER (named entity recognition), in this case `gpe` for location.

*cuisine* is of type ``enum`` because we only want it to have 4 valid values: *Mexican*, *Italian*, *Chinese*, and *dessert*. *food_restriction* is of type ``enum`` for the same reason.

*have_allergy*, which determines if the user has an allergy (in which case we need to get their *food_restriction*), is of type ``flag``. That is, they either do or don't have an allergy. For this variable, you can also see that it has an ``init`` option. This is only available to ``flag`` or ``fflag`` type variables, and it allows you to set an initial value for the variable and change the initial state of the conversation. In this case, we default the variable to ``false``.

.. _known:

Each variable also has a ``known`` option which determines the knowledge we have about the variable. The ``known`` ``type`` can only be set to either ``flag`` or ``fflag``, and functions in the same way. This parameter is extermely important as conversation navigation is often predicated on what context we know, maybe know, or don't know so far.

In most cases, the ``known``'s ``init`` setting is set to ``false``, but the ``type`` setting depends on what makes the most sense for the variable. Often in the case of ``enum`` type variables like *cuisine*, it makes the most sense to allow for a little variance in user input. They may something that somewhat resembles one of the available options, and it is helpful to store their answer, classify it as "maybe known", and clarify the user's intention.
For simpler variables like *have_allergy*, a ``known`` ``type`` setting of ``flag`` should suffice.  

With this in mind, let's add the rest of the context variables.

.. code-block:: yaml
   :linenos:
   :lineno-start: 40

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
   :linenos:
   :lineno-start: 102

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

**NOTE**: No intents can extract the exact same entities. Why?

- At every step in the conversation, we need to be able to know what information we have and don't have.
  Each intent's ``entities`` indicates what information is gained when that intent is successfully extracted.
  As a result, an intent will not be chosen unless all the entities were extracted.

- As you will later see, each intent is mapped to an action outcome.
  That means that we decide what path to take next in the conversation depending on what the intent is.

- Having two or more intents that extract the same entities causes ambiguity in two ways.
  First, it will likely be harder to extract the "correct" intent because the duplicate intents will be too similar to each other.
  Second, there is functionally no reason for multiple intents to accomplish the exact same goal but map to different outcomes.
  If you want to handle things differently depending on the extracted *value* of the entities, that is a separate process handled in the actions (to be seen later).

If this is a bit confusing, it may make more sense after reviewing the ``actions`` section below and coming back to this.

**NOTE**: All ``utterances`` must include *exactly* all the entities listed under ``entities``; no more, no less.

3. Define the Actions
.....................

``actions`` are the core of dialogue agent design as they specify what your agent can do and when.
We use a **declarative** specification powered by automated planning that allows you to treat actions as separate pieces of a puzzle.
You won't have to draw out complex dialogue trees that you will have to completely dismantle if you decide late in the game that you want to add a new action near the top.
Instead, actions are chosen based on what is true in the state of the world. 
Only actions whose ``preconditions`` are satisfied are executed.

It is important to reiterate that ``actions`` refer only to the actions that the dialogue agent can take, and that chatbot creation is seen primarily through the lens of the agent's perspective.
User utterances are only handled by deciphering ``intents`` as described above

There are **four** types of actions:

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

Let's start with a simple action to get the ball rolling.
We'll create an action ``get-have-allergy`` that asks the user if they have an allergy or not, which expects a simple yes/no response.

.. code-block:: yaml
   :linenos:
   :lineno-start: 165

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

+------------+--------------------------------------------------------------------+
| parameters | definition                                                         |
+============+====================================================================+
| updates    | A boolean value; can only be set to ``true`` or ``false``.         |
+------------+--------------------------------------------------------------------+
| fflag      | "Fuzzy flag"; can only be set to ``true``, ``false``, or ``maybe``.|
+------------+--------------------------------------------------------------------+
| enum       | Can only be set to the values set under the ``options`` list.      |
+------------+--------------------------------------------------------------------+
| json       | Used if you want to use an alternate extraction method,            |
|            | i.e. Spacy GPE.                                                    |
|            |                                                                    |
|            | **NOTE**: Currently, only Spacy is compatible with this            |
|            | option.                                                            |
+------------+--------------------------------------------------------------------+

updates:
Necessary for pretty much every outcome.
Here you define the changing ``value``s of context variables.
You also define how the ``known`` status of each variable has updated.
This is **extremely important** to do correctly as "knowing what you know" is a huge part of conversation navigation!
**NOTE** if you want to set the variable to the value taken from the user, precede
the variable name with ``$``.


Deploy the bot with HOVOR.
++++++++++++++++++++++++++
