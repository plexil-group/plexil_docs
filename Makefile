# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
PYTHON        = python3
SPHINXOPTS    =
SPHINXBUILD   = ${PYTHON} -m sphinx
SPHINXPROJ    = PLEXIL
SOURCEDIR     = .
BUILDDIR      = _build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

bootstrap:
	@${PYTHON} -m virtualenv _venv
	@(source _venv/bin/activate ; python -m pip install sphinx sphinx_readable_theme)
	@echo Type 'source _venv/bin/activate' prior to continuing

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
