.. Plan4Dial documentation master file, created by
   sphinx-quickstart on Sun Oct  2 22:23:42 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to Plan4Dial's documentation!
=====================================

.. _why:

Why Plan4Dial?
--------------

Plan4Dial uses automated planning to create dialogue agents that are robust and flexible. 
The use of planning eliminates the need for painstakingly handcrafting complex dialogue trees.
It's also not necessary to hardcode which actions follow other actions (like in Rasa).

In the above cases, it is extremely difficult to modify your chatbot late in development -- Plan4Dial offers the solution.

The declarative framework Plan4Dial uses allows you to get a bot running quickly and throw in new actions and variables with ease.
It uses Rasa purely for NLU and a planning specification to navigate the conversation.

Although Plan4Dial is implemented with a solid framework to get you started, it also supports custom action implementation for your chatbot needs.

🤖 Time to get chatting! 🤖



.. autosummary::
   :toctree: generated
   :recursive:

   plan4dial

.. toctree::
   tutorial
