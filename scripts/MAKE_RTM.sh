#!/bin/bash

# Sciezka to miejsce, w którym znajduje się skrypt
sciezka=$(dirname "$0")

cd "$sciezka/".. || exit

if [ "$CI" = "true" ]; then
    PSCD=project
else
    PSCD=PolishSocialCookiesFiltersDev
fi

cd ..

if [ "$CI" = "true" ]; then
    git clone -b RTM --single-branch git@github.com:hawkeye116477/polish-ads-filter.git
fi

cp -r ./"$PSCD"/sections/ ./polish-ads-filter/
cp -r ./"$PSCD"/templates/ ./polish-ads-filter/
cp -r ./"$PSCD"/scripts/VICHS.sh ./polish-ads-filter/scripts/
cp -r ./"$PSCD"/scripts/VICHS.config ./polish-ads-filter/scripts/
cp -r ./"$PSCD"/scripts/FOP.py ./polish-ads-filter/scripts/
cp -r ./"$PSCD"/scripts/wiadomosci_powitalne.txt ./polish-ads-filter/scripts/

cd ./polish-ads-filter || exit

RTM="true" ./scripts/VICHS.sh cookies_filters/cookies_uB_AG.txt cookies_filters/adblock_cookies.txt adblock_social_filters/social_filters_uB_AG.txt adblock_social_filters/adblock_social_list.txt

ost_plik=$(git log --since="10 minutes ago" --name-only --pretty=format: | sort | uniq)

function search() {
    echo "$ost_plik" | grep "$1"
}

function addListToVarIfAnotherListUpdated() {
    if [[ -z $(search "$1") ]] && [[ -n $(search "$2") ]]; then
        if ! grep -q "$1" <<< "${MAIN_FILTERLIST[*]}"; then
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
    RTM="true" FORCED="true" ./scripts/VICHS.sh "${MAIN_FILTERLIST[@]}"
fi

for k in $ost_plik; do
    if [[ "$k" == "adblock_social_filters/adblock_social_list.txt"* ]] || [[ "$k" == "adblock_social_filters/social_filters_uB_AG.txt"* ]]; then
        if [[ "$lista" != *" 👍"* ]] ;then
            lista+=" "👍
        fi
    fi

    if [[ "$k" == "cookies_filters/adblock_cookies.txt"* ]] || [[ "$k" == "cookies_filters/cookies_uB_AG.txt"* ]]; then
        if [[ "$lista" != *" 🍪"* ]] ;then
            lista+=" "🍪
        fi
    fi
done

if [[ "$lista" == *" 🍪"* ]] && [[ "$lista" == *" 👍"* ]]; then
    lista="🍪 & 👍"
fi

today_date=$(date +"%Y%m%d")
powitanie=$(shuf -n 1 ./scripts/wiadomosci_powitalne.txt)
# Wysyłanie PR do upstream
if [ "$CI" = "true" ]; then
echo "Wysyłanie PR..."
hub pull-request -b MajkiIT:master -r krystian3w -l cookies,social -m "Update $lista ($today_date)

$powitanie"
cd ..
git clone git@github.com:PolishFiltersTeam/PolishAnnoyanceFilters.git
cd ./PolishAnnoyanceFilters || exit
if [ "$cookies" ]; then
    FORCED="true" ./scripts/VICHS.sh ./PAF_supp.txt ./PPB.txt
else
    ./scripts/VICHS.sh ./PAF_supp.txt ./PPB.txt
fi
else
echo "Czy chcesz teraz wysłać PR do upstream?"
select yn in "Tak" "Nie"; do
    case $yn in
        Tak )
        printf "Podaj rozszerzony opis PR, np 'Fix #1, fix #2' (bez ciapek; jeśli nie chcesz rozszerzonego opisu, to możesz po prostu nic nie wpisywać): "
        read -r roz_opis
        hub pull-request -m "Update $lista ($today_date)

        ${roz_opis}"
        cd ../PolishAnnoyanceFilters || exit
        if [ "$cookies" ]; then
            FORCED="true" ./scripts/VICHS.sh ./PAF_supp.txt ./PPB.txt
        else
            ./scripts/VICHS.sh ./PAF_supp.txt ./PPB.txt
        fi
        break;;
        Nie ) break;;
esac
done
fi
