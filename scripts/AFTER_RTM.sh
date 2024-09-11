#!/bin/bash
SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
MAIN_PATH=$(git -C "$SCRIPT_PATH" rev-parse --show-toplevel)

cd "$MAIN_PATH"/.. || exit
if [ "$CIRCLECI" = "true" ]; then
    git clone git@github.com:FiltersHeroes/PolishAnnoyanceFilters.git
else
    git clone https://github.com/FiltersHeroes/PolishAnnoyanceFilters.git
fi
cd ./PolishAnnoyanceFilters || exit
SFLB.py PAF_supp.txt PPB.txt
