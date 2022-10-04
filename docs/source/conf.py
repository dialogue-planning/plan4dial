# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

import os
import sys
sys.path.insert(0, os.path.abspath('../plan4dial/plan4dial'))  # Source code dir relative to this file
sys.path.insert(0, os.path.abspath('../plan4dial'))  # outer directory
sys.path.insert(0, os.path.abspath('../..')) # home path

# Turn on sphinx.ext.autosummary and set autodoc options
autosummary_generate = True
autodoc_default_options = {
    'members':          True,
    'undoc-members':    True,
    'private-members':  True,
    'special-members':  True,
    'inherited-members':True,
    'show-inheritance': True
}

project = 'Plan4Dial'
copyright = '2022, Rebecca De Venezia @ QuMuLab'
author = 'Rebecca De Venezia @ QuMuLab'
release = '1.0.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
   'sphinx.ext.autodoc', # gets docstrings from Python code
   'sphinx.ext.autosummary', # auto-generates .rst files
   'sphinx.ext.napoleon', # allows for Google/numpy style docstrings
   'sphinx.ext.viewcode' # adds link to the source code in the docs
]

templates_path = ['_templates']
exclude_patterns = []



# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'alabaster'
html_static_path = ['_static']
