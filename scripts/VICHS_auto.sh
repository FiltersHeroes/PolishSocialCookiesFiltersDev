#!/bin/bash

# Sciezka to miejsce, w którym znajduje się skrypt
sciezka=$(dirname "$0")

aktualna_godzina=$(date +"%H")

cd "$sciezka"/.. || exit

"$sciezka"/VICHS.sh cookies_filters/cookies_uB_AG.txt cookies_filters/adblock_cookies.txt adblock_social_filters/social_filters_uB_AG.txt adblock_social_filters/adblock_social_list.txt

last_file=$(git log --since="10 minutes ago" --name-only --pretty=format: | sort | uniq)

function search() {
    grep "$1" <<< "$last_file"
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


if [ "$CI" = "true" ]; then
    if [[ "$aktualna_godzina" == "13" ]]; then
        last_file=$(git log --since="15 hours 58 minutes ago" --name-only --pretty=format: | sort | uniq)
    else
        last_file=$(git log --since="3 hours 58 minutes ago" --name-only --pretty=format: | sort | uniq)
    fi
else
    last_file=$(git log --since="10 minutes ago" --name-only --pretty=format: | sort | uniq)
fi

if [ ! -z $(search "sections/adblock_social_list/popupy.txt") ] || [ ! -z $(search "sections/adblock_social_list/popupy_ogolne.txt") ]; then
    if [[ "$PAF" != "true" ]]; then
        PAF="true"
    fi
fi

if [[ ! -z $(search "sections/adblock_social_list/uBO_AG/popupy") ]]; then
    if [[ "$PAF_supp" != "true" ]]; then
        PAF_supp="true"
    fi
fi


if [ "$lista" ]; then
    "$sciezka"/VICHS.sh $lista
fi

if [ "$MAIN_FILTERLIST" ]; then
    FORCED="true" "$sciezka"/VICHS.sh $MAIN_FILTERLIST
fi

if [ "$PAF" ] || [ "$PAF_supp" ]; then
    cd ..
fi

if [ "$CI" = "true" ]; then
    if [ "$PAF" ] || [ "$PAF_supp" ]; then
        git clone git@github.com:PolishFiltersTeam/PolishAnnoyanceFilters.git
    fi
fi

if [ "$PAF" ] || [ "$PAF_supp" ]; then
    cd ./PolishAnnoyanceFilters || exit
fi

if [ "$PAF" ] && [ ! "$PAF_supp" ]; then
    ./scripts/VICHS.sh ./PPB.txt ./PAF_pop-ups.txt
elif [ "$PAF_supp" ]; then
    FORCED="true" ./scripts/VICHS.sh ./PAF_pop-ups_supp.txt ./PPB.txt ./PAF_pop-ups.txt
fi
