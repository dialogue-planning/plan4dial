Plan4Dial
=========

.. _why:

Why Use Plan4Dial?
------------------

Dialogue planning uses automated planning to generate dialogue graphs, which eliminates the need to painstakingly craft these graphs by hand and creates robust and maintainable agents.
**Plan4Dial is the first open and readily available modern framework for dialogue planning development.**

With just one user-specified YAML file as input, Plan4Dial offers:

* Direct translation to PDDL, eliminating the need to tediously handwrite PDDL
* Full specification + training of an NLU model through `Rasa's NLU-only interface <https://rasa.com/docs/rasa/nlu-only/>`_, along with `custom pipeline components <https://rasa.com/docs/rasa/components/>`_
* The ability to specify how individual entities are extracted `(example here) <https://github.com/dialogue-planning/plan4dial/blob/5cb3cc7493ab691b06fbb9f80c99de039b8ebb40/plan4dial/local_data/gold_standard_bot/gold_standard_bot.yml#L7>`_
* Support for `custom action templates <https://github.com/dialogue-planning/plan4dial/tree/main/plan4dial/for_generating/custom_actions>`_
* The ability to run and deploy agents through our extension of `IBM's Hovor <https://github.com/dialogue-planning/contingent-plan-executor>`_ and our embeddable web UI, `WIDGET <https://github.com/dialogue-planning/widget>`_
* Support for `custom outcome determiners <https://github.com/dialogue-planning/contingent-plan-executor/tree/main/contingent_plan_executor/hovor/outcome_determiners>`_ (created in Hovor)

The declarative nature of Plan4Dial allows you to get a chatbot running quickly and throw in new actions and variables at any point in development.

Framework Flow
---------------
.. image:: figs/flow.png

Here we detail the design flow of our approach.

First, the developer writes a YAML file `(example YAML file here) <https://github.com/dialogue-planning/plan4dial/tree/main/plan4dial/local_data/gold_standard_bot/gold_standard_bot.yml>`_ which contains a declarative description of their agent. 
The file is then passed to Plan4Dial, which `converts the file to raw PDDL and attempts to generate a plan <https://github.com/dialogue-planning/plan4dial/tree/main/plan4dial/main.py>`_. 
The valid plan, if found, is then passed to Hovor to `execute the conversation <https://github.com/dialogue-planning/contingent-plan-executor/blob/main/README.md>`_, either through the CLI or through `WIDGET <https://github.com/dialogue-planning/widget>`_ (which calls the endpoints defined in Hovor).

See the :ref:`tutorial` for an in-depth explanation on how to specify the YAML file.

🤖 Time to get chatting! 🤖

.. autosummary::
   :toctree: generated
   :recursive:

   plan4dial

.. toctree::
   tutorial
