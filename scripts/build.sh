#!/bin/bash

# SCRIPT_PATH to miejsce, w którym znajduje się skrypt
SCRIPT_PATH=$(dirname "$(realpath -s "$0")")

# MAIN_PATH to miejsce, w którym znajduje się główny katalog repozytorium
# Zakładamy, że skrypt znajduje się gdzieś w repozytorium git,
# w którym są pliki listy filtrów, którą chcemy zaktualizować.
# Jednakże jeżeli skrypt znajduje się gdzieś indziej, to
# zezwalamy na nadpisanie zmiennej MAIN_PATH.
if [ -z "$MAIN_PATH" ]; then
    MAIN_PATH=$(git -C "$SCRIPT_PATH" rev-parse --show-toplevel)
fi

cd "$MAIN_PATH" || exit

V_CHANGED_FILES_FILE="$SCRIPT_PATH"/V_CHANGED_FILES.txt
if [ -f "$V_CHANGED_FILES_FILE" ]; then
    rm -rf "$V_CHANGED_FILES_FILE"
fi

SAVE_CHANGED_FN="true" "$SCRIPT_PATH"/VICHS.sh cookies_filters/cookies_uB_AG.txt cookies_filters/adblock_cookies.txt adblock_social_filters/social_filters_uB_AG.txt adblock_social_filters/adblock_social_list.txt

V_CHANGED_FILES=$(cat "$V_CHANGED_FILES_FILE")

function search() {
    grep "$1" <<< "$V_CHANGED_FILES"
}

function addListToVarIfAnotherListUpdated() {
    if [[ -z $(search "$1") ]] && [[ -n $(search "$2") ]]; then
        if ! grep -q "$1" <<< "$MAIN_FILTERLIST"; then
            MAIN_FILTERLIST+=" "$1
        fi
    fi
}

addListToVarIfAnotherListUpdated "cookies_filters/adblock_cookies.txt" "cookies_filters/cookies_uB_AG.txt"
addListToVarIfAnotherListUpdated "adblock_social_filters/adblock_social_list.txt" "adblock_social_filters/social_filters_uB_AG.txt"

if [ -n "$(search "sections/adblock_social_list/popupy.txt")" ] || [ -n "$(search "sections/adblock_social_list/popupy_ogolne.txt")" ] ||
[ -n "$(search "sections/adblock_social_list/widgety_kontaktowe.txt")" ]; then
    if [[ "$PAF" != "true" ]]; then
        PAF="true"
    fi
fi

if [[ -n $(search "sections/adblock_social_list/uBO_AG/popupy") ]]; then
    if [[ "$PAF_supp" != "true" ]]; then
        PAF_supp="true"
    fi
fi

if [ "$MAIN_FILTERLIST" ]; then
    FORCED="true" "$SCRIPT_PATH"/VICHS.sh "$MAIN_FILTERLIST"
fi

if [ "$PAF" ] || [ "$PAF_supp" ]; then
    cd "$MAIN_PATH"/.. || exit
    if [ "$CI" = "true" ]; then
        if [ "$CIRCLECI" = "true" ]; then
            git clone git@github.com:PolishFiltersTeam/PolishAnnoyanceFilters.git
        else
            git clone https://github.com/PolishFiltersTeam/PolishAnnoyanceFilters.git
        fi
    fi
    cd ./PolishAnnoyanceFilters || exit
fi

if [ "$PAF" ] && [ ! "$PAF_supp" ]; then
    ./scripts/VICHS.sh ./PPB.txt ./PAF_pop-ups.txt
elif [ "$PAF_supp" ]; then
    FORCED="true" ./scripts/VICHS.sh ./PAF_pop-ups_supp.txt ./PPB.txt ./PAF_pop-ups.txt
fi

cd "$MAIN_PATH" || exit
rm -rf "$V_CHANGED_FILES_FILE"
