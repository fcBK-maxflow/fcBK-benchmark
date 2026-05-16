.PHONY: clean data lint requirements

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PYTHON_INTERPRETER = python
bench_io_arg = dimacs_to_bbk
bench_json = "mypath/bench_config_serial.json"
FILE = "path/to/dafault/testfile.max"
bench_out = "testing_serial_default.txt"
ALGO = bk mbk mbk_r cbk fcbk

ifeq (,$(shell which conda))
HAS_CONDA=False
else
HAS_CONDA=True
endif

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using flake8
lint:
	flake8 src

## Running maxflow on a single file with one/multiple algorithms using "make demo". Optional arguments are: 'testfile="path_to.bbk"', and 'ALGO="list of algos"'.
demo:
	./build/demo $(FILE) $(ALGO)

## Convert between different file formats using "make bench_io FILE='path_to.file'. Possible arguments is: bench_io_arg=X, where X are commands from https://github.com/patmjen/maxflow_algorithms
bench_io:
	./build/bench_io $(bench_io_arg) $(FILE)

## Run benchmarking using "make bench". Possible arguments are: bench_json='path_to.json' and bench_out='path_to.txt'
bench:
	./build/bench $(bench_json) > $(bench_out)

bench_debug:
	gdb -iex 'file ./build/bench' -iex 'run $(bench_json) > $(bench_out)' -iex quit

## Build the project, assuming full_build has been run. This overwrites the demo, bench_io, and bench executables with the newest code!
rebuild:
	cd build;\
	cmake --build .;

## Rebuild entire project. This deletes and recreates the "build" folder!
full_build:
	if [ -d "build" ]; then \
		rm -r build; \
	fi
	mkdir build
	cd build; \
	cmake ..;\
	cmake --build .;\

## Rebuild entire project into 32 bit variant. This deletes and recreates the "build" folder!
full_build32:
	if [ -d "build" ]; then \
		rm -r build; \
	fi
	mkdir build
	cd build; \
	cmake -DCOMPILE_32_BIT=ON ..;\
	cmake --build .;\

## Rebuild entire project in debug mode. This deletes and recreates the "debug" folder!
full_debug:
	if [ -d "build" ]; then \
		rm -r build; \
	fi
	mkdir build
	cd build; \
	cmake -DCMAKE_BUILD_TYPE="Debug" ..;\
	cmake --build . --target all;\

full_debug32:
	if [ -d "build" ]; then \
		rm -r build; \
	fi
	mkdir build
	cd build; \
	cmake -DCMAKE_BUILD_TYPE="Debug" -DCOMPILE_32_BIT=ON ..;\
	cmake --build . --target all;\

demo_debug:
	gdb -iex 'file ./build/demo' -iex 'run $(FILE) $(ALGO)' -iex quit

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################



#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')