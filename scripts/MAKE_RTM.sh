#!/bin/bash

RTM_MODE="true"

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
    git clone git@github.com:hawkeye116477/polish-ads-filter.git
fi

cp -r ./"$PSCD"/sections/ ./polish-ads-filter/
cp -r ./"$PSCD"/templates/ ./polish-ads-filter/
cp -r ./"$PSCD"/scripts/VICHS.sh ./polish-ads-filter/scripts/
cp -r ./"$PSCD"/scripts/VICHS.config ./polish-ads-filter/scripts/

cd ./polish-ads-filter || exit

. ./scripts/VICHS.sh cookies_filters/cookies_uB_AG.txt cookies_filters/adblock_cookies.txt adblock_social_filters/social_filters_uB_AG.txt adblock_social_filters/adblock_social_list.txt

if [ "$CI" = "true" ]; then
    git remote add upstream git@github.com:MajkiIT/polish-ads-filter.git
    git fetch upstream
fi

ost_zmieniony_plik_RTM=$(git diff --stat origin/master upstream/master -z --name-only | xargs -0)
for k in $ost_zmieniony_plik_RTM; do
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

# Wysyłanie PR do upstream
if [ "$CI" = "true" ]; then
hub pull-request -f -b MajkiIT:master -m "Update $lista ($today_date)

*Bip*, *bup*, wynik końcowy, RTM, *bip*!" > /dev/null 2>&1
cd ..
git clone git@github.com:PolishFiltersTeam/PolishAnnoyanceFilters.git
cd ./PolishAnnoyanceFilters || exit
./scripts/VICHS.sh ./PAF_supp.txt ./PPB.txt
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
        ./scripts/VICHS.sh ./PAF_supp.txt ./PPB.txt
        break;;
        Nie ) break;;
esac
done
fi
