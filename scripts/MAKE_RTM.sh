#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath -s "$0")")
MAIN_PATH=$(git -C "$SCRIPT_PATH" rev-parse --show-toplevel)

cd "$MAIN_PATH"/.. || exit

FORKED_REPO="PolishRoboDogForks/polish-ads-filter.git"

if [ "$CI" = "true" ]; then
    if [ "$CIRCLECI" = "true" ]; then
        git clone -b RTM --single-branch git@github.com:"$FORKED_REPO"
    else
        git clone -b RTM --single-branch https://github.com/"$FORKED_REPO"
    fi
fi

cp -r "$MAIN_PATH"/sections/ ./polish-ads-filter/
cp -r "$MAIN_PATH"/templates/ ./polish-ads-filter/
cp -r "$MAIN_PATH"/scripts/VICHS_upstream.config ./polish-ads-filter/scripts/
cp -r "$MAIN_PATH"/scripts/wiadomosci_powitalne.txt ./polish-ads-filter/scripts/
mv ./polish-ads-filter/scripts/VICHS_upstream.config ./polish-ads-filter/scripts/VICHS.config

cd ./polish-ads-filter || exit

V_CHANGED_FILES_FILE="$MAIN_PATH"/../polish-ads-filter/changed_files/V_CHANGED_FILES.txt
if [ -f "$V_CHANGED_FILES_FILE" ]; then
    rm -rf "$V_CHANGED_FILES_FILE"
fi

RTM="true" SAVE_CHANGED_FN="true" VICHS.sh cookies_filters/cookies_uB_AG.txt cookies_filters/adblock_cookies.txt adblock_social_filters/social_filters_uB_AG.txt adblock_social_filters/adblock_social_list.txt

V_CHANGED_FILES=$(cat "$V_CHANGED_FILES_FILE")

function search() {
    echo "$V_CHANGED_FILES" | grep "$1"
}

function addListToVarIfAnotherListUpdated() {
    if [[ -z $(search "$1") ]] && [[ -n $(search "$2") ]]; then
        if ! grep -q "$1" <<<"${MAIN_FILTERLIST[*]}"; then
            MAIN_FILTERLIST+=("$1")
        fi
    fi
}

addListToVarIfAnotherListUpdated "cookies_filters/adblock_cookies.txt" "cookies_filters/cookies_uB_AG.txt"
addListToVarIfAnotherListUpdated "adblock_social_filters/adblock_social_list.txt" "adblock_social_filters/social_filters_uB_AG.txt"

if [[ -z $(search "cookies_filters/adblock_cookies.txt") ]] && [[ -n $(search "cookies_filters/cookies_uB_AG.txt") ]]; then
    cookies="true"
fi

if [ "${MAIN_FILTERLIST[*]}" ]; then
    RTM="true" FORCED="true" VICHS.sh "${MAIN_FILTERLIST[@]}"
fi

for k in $V_CHANGED_FILES; do
    if [[ "$k" == "adblock_social_filters/adblock_social_list.txt"* ]] || [[ "$k" == "adblock_social_filters/social_filters_uB_AG.txt"* ]]; then
        if [[ "$lista" != *" 👍🏻"* ]]; then
            lista+=" "👍🏻
        fi
    fi

    if [[ "$k" == "cookies_filters/adblock_cookies.txt"* ]] || [[ "$k" == "cookies_filters/cookies_uB_AG.txt"* ]]; then
        if [[ "$lista" != *" 🍪"* ]]; then
            lista+=" "🍪
        fi
    fi
done

if [[ "$lista" == *" 🍪"* ]] && [[ "$lista" == *" 👍🏻"* ]]; then
    lista="🍪 & 👍🏻"
fi

today_date=$(date +"%Y%m%d")

if [ ! "$RTM_PR_MESSAGE" ]; then
    RTM_PR_MESSAGE=$(shuf -n 1 ./scripts/wiadomosci_powitalne.txt)
fi

# Wysyłanie PR do upstream
if [ "$CI" = "true" ]; then
    git clean -xdf
    echo "Wysyłanie PR..."
    gh pr create -B master -H PolishRoboDogForks:RTM -R MajkiIT/polish-ads-filter --title "Update $lista ($today_date)" --body "$RTM_PR_MESSAGE"
    cd ..
    if [ "$CIRCLECI" = "true" ]; then
        git clone git@github.com:PolishFiltersTeam/PolishAnnoyanceFilters.git
    else
        git clone https://github.com/PolishFiltersTeam/PolishAnnoyanceFilters.git
    fi
    cd ./PolishAnnoyanceFilters || exit
    if [ "$cookies" ]; then
        FORCED="true" VICHS.sh ./PAF_supp.txt ./PPB.txt
    else
        VICHS.sh ./PAF_supp.txt ./PPB.txt
    fi
else
    echo "Czy chcesz teraz wysłać PR do upstream?"
    select yn in "Tak" "Nie"; do
        case $yn in
        Tak)
            printf "Podaj rozszerzony opis PR, np 'Fix #1, fix #2' (bez ciapek; jeśli nie chcesz rozszerzonego opisu, to możesz po prostu nic nie wpisywać): "
            read -r roz_opis
            gh pr create -B master -H RTM -R MajkiIT/polish-ads-filter --title "Update $lista ($today_date)" --body "${roz_opis}"
            cd ../PolishAnnoyanceFilters || exit
            if [ "$cookies" ]; then
                FORCED="true" VICHS.sh ./PAF_supp.txt ./PPB.txt
            else
                VICHS.sh ./PAF_supp.txt ./PPB.txt
            fi
            break
            ;;
        Nie) break ;;
        esac
    done
fi
