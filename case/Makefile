SHELL = /bin/bash

.PHONY: tests install

REPO_URL ?= https://github.com/tomblind/local-lua-debugger-vscode
REPO_DIR ?= local-lua-debugger-vscode

default: tests

lua-dap:
	test -d "$(REPO_DIR)" || git clone $(REPO_URL)
	cd $(REPO_DIR) && npm install && npm run build

tests:
	nvim -l tests/busted.lua tests

inspect:
	nvim -u ./tests/busted.lua
