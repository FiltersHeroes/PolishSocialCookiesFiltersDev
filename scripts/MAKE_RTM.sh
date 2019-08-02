#!/bin/bash

RTM_MODE="true"

# Sciezka to miejsce, w którym znajduje się skrypt
sciezka=$(dirname "$0")

cd $sciezka/..

if [ "$CI" = "true" ]; then
. $sciezka/VICHS.sh cookies_filters/cookies_uB_AG.txt cookies_filters/adblock_cookies.txt adblock_social_filters/social_filters_uB_AG.txt adblock_social_filters/adblock_social_list.txt
else
. $sciezka/VICHS.sh $i
fi

ost_zmieniony_plik=$(git diff -z --name-only | xargs -0)

if [ "$CI" = "true" ]; then
    cd ..
    git clone git@github.com:hawkeye116477/polish-ads-filter.git
    cd ./project
fi

for j in $ost_zmieniony_plik; do

    if [[ "$j" == "cookies_filters/adblock_cookies.txt"* ]]; then
        cp -r ./cookies_filters/adblock_cookies.txt ../polish-ads-filter/cookies_filters/
    fi

    if [[ "$j" == "cookies_filters/cookies_uB_AG.txt"* ]]; then
        cp -r ./cookies_filters/cookies_uB_AG.txt ../polish-ads-filter/cookies_filters/
    fi

    if [[ "$j" == "adblock_social_filters/adblock_social_list.txt"* ]]; then
        cp -r ./adblock_social_filters/adblock_social_list.txt ../polish-ads-filter/adblock_social_filters/
    fi

    if [[ "$j" == "adblock_social_filters/social_filters_uB_AG.txt"* ]]; then
        cp -r ./adblock_social_filters/social_filters_uB_AG.txt ../polish-ads-filter/adblock_social_filters/
    fi

done

cd ../polish-ads-filter
ost_zmieniony_plik_RTM=$(git diff -z --name-only | xargs -0)

for k in $ost_zmieniony_plik_RTM; do
    if [[ "$k" == "adblock_social_filters/adblock_social_list.txt"* ]]; then
        if [[ "$lista" != *" 👍"* ]] ;then
            lista+=" "👍
        fi
        wersja="$(grep -oP "(?<=! Version: )[^ ]+" $k)"
        git add adblock_social_filters/adblock_social_list.txt
        git commit -m "Update 👍 to version $wersja

Co-authored-by: krystian3w <35370833+krystian3w@users.noreply.github.com>"
    fi

    if [[ "$k" == "adblock_social_filters/social_filters_uB_AG.txt"* ]]; then
        if [[ "$lista" != *" 👍"* ]] ;then
            lista+=" "👍
        fi
        wersja="$(grep -oP "(?<=! Version: )[^ ]+" $k)"
        git add adblock_social_filters/social_filters_uB_AG.txt
        git commit -m "Update 👍 - Supplement to version $wersja

Co-authored-by: krystian3w <35370833+krystian3w@users.noreply.github.com>"
    fi

    if [[ "$k" == "cookies_filters/adblock_cookies.txt"* ]]; then
        if [[ "$lista" != *" 🍪"* ]] ;then
            lista+=" "🍪
        fi
        wersja="$(grep -oP "(?<=! Version: )[^ ]+" $k)"
        git add cookies_filters/adblock_cookies.txt
        git commit -m "Update 🍪 to version $wersja

Co-authored-by: krystian3w <35370833+krystian3w@users.noreply.github.com>"
    fi

    if [[ "$k" == "cookies_filters/cookies_uB_AG.txt"* ]]; then
        if [[ "$lista" != *" 🍪"* ]] ;then
            lista+=" "🍪
        fi
        wersja="$(grep -oP "(?<=! Version: )[^ ]+" $k)"
        git add cookies_filters/cookies_uB_AG.txt
        git commit -m "Update 🍪 - Supplement to version $wersja

Co-authored-by: krystian3w <35370833+krystian3w@users.noreply.github.com>"
    fi
done

if [[ "$lista" == *" 🍪"* ]] && [[ "$lista" == *" 👍"* ]]; then
    lista="🍪 & 👍"
fi

today_date=$(date +"%Y%m%d")

# Wysyłanie zmienionych plików do repozytorium git
if [ "$CI" = "true" ]; then
GIT_SLUG=$(git ls-remote --get-url | sed "s|https://||g" | sed "s|git@||g" | sed "s|:|/|g")
git push https://"PolishJarvis":"${GH_TOKEN}"@"${GIT_SLUG}" HEAD:master > /dev/null 2>&1
echo "Wait"
hub pull-request -f -m "Update $lista ($today_date)

*Bip*, *bup*, wynik końcowy, RTM, *bip*!"
else
echo "Czy chcesz teraz wysłać do gita zmienione pliki?"
select yn in "Tak" "Nie"; do
    case $yn in
        Tak )
        git push
        printf "Podaj rozszerzony opis PR, np 'Fix #1, fix #2' (bez ciapek; jeśli nie chcesz rozszerzonego opisu, to możesz po prostu nic nie wpisywać): "
        read roz_opis
        hub pull-request -m "Update $lista ($today_date)

        ${roz_opis}"
        break;;
        Nie ) break;;
esac
done
fi
