# Plexil Documentation Source

This repository serves to present the Plexil documentation built with Sphinx.

There currently exists a built version in `docs` folder. Open
`index.html` with your favorite browser and check the current compiled
version. The generated documentation also can be found at:
https://plexil-group.github.io/plexil_docs/

The *PLEXIL* source repository can be found at the main *PLEXIL*
project page, at: https://github.com/plexil-group/plexil

## Build instructions

1. Install prerequisites: 
 * Python 3
 * pip

2. `make bootstrap` installs Sphinx and several other Python
   utilities, and sets up a Python virtual environment for Sphinx.

3. `source _venv/bin/activate` activates the virtual environment.

4. `make` with no arguments will display a list of possible output
   formats.

5. `make html` builds the documentation as HTML files.  The resulting
   files are in the `_build/html` subdirectory; the index page is
   `_build/html/index.html`.

6. When you are satisified with the results, publish the
   documentation.  (To be supplied.)
