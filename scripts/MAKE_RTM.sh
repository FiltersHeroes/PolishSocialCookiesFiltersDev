#!/bin/bash

RTM_MODE="true"

# Sciezka to miejsce, w którym znajduje się skrypt
sciezka=$(dirname "$0")

cd $sciezka/..

. $sciezka/VICHS.sh $i

ost_zmieniony_plik=$(git diff -z --name-only | xargs -0)

for j in $ost_zmieniony_plik; do

    if [[ "$j" == "cookies_filters/adblock_cookies.txt"* ]]; then
        cp -r ~/git/PolishSocialCookiesFiltersDev/cookies_filters/adblock_cookies.txt ~/git/polish-ads-filter/cookies_filters/
    fi

    if [[ "$j" == "cookies_filters/cookies_uB_AG.txt"* ]]; then
        cp -r ~/git/PolishSocialCookiesFiltersDev/cookies_filters/cookies_uB_AG.txt ~/git/polish-ads-filter/cookies_filters/
    fi

    if [[ "$j" == "adblock_social_filters/adblock_social_list.txt"* ]]; then
        cp -r ~/git/PolishSocialCookiesFiltersDev/adblock_social_filters/adblock_social_list.txt ~/git/polish-ads-filter/adblock_social_filters/
    fi

    if [[ "$j" == "adblock_social_filters/social_filters_uB_AG.txt"* ]]; then
        cp -r ~/git/PolishSocialCookiesFiltersDev/adblock_social_filters/social_filters_uB_AG.txt ~/git/polish-ads-filter/adblock_social_filters/
    fi

done

cd ~/git/polish-ads-filter
ost_zmieniony_plik_RTM=$(git diff -z --name-only | xargs -0)

for k in $ost_zmieniony_plik_RTM; do
    if [[ "$k" == "adblock_social_filters/adblock_social_list.txt"* ]]; then
        if [[ "$lista" != *" 👍"* ]] ;then
            lista+=" "👍
        fi
        wersja="$(grep -oP "(?<=! Version: )[^ ]+" $k)"
        git add adblock_social_filters/adblock_social_list.txt
        git commit -S -m "Update 👍 to version $wersja

Co-authored-by: krystian3w <35370833+krystian3w@users.noreply.github.com>"
    fi

    if [[ "$k" == "adblock_social_filters/social_filters_uB_AG.txt"* ]]; then
        if [[ "$lista" != *" 👍"* ]] ;then
            lista+=" "👍
        fi
        wersja="$(grep -oP "(?<=! Version: )[^ ]+" $k)"
        git add adblock_social_filters/social_filters_uB_AG.txt
        git commit -S -m "Update 👍 - Supplement to version $wersja

Co-authored-by: krystian3w <35370833+krystian3w@users.noreply.github.com>"
    fi

    if [[ "$k" == "cookies_filters/adblock_cookies.txt"* ]]; then
        if [[ "$lista" != *" 🍪"* ]] ;then
            lista+=" "🍪
        fi
        wersja="$(grep -oP "(?<=! Version: )[^ ]+" $k)"
        git add cookies_filters/adblock_cookies.txt
        git commit -S -m "Update 🍪 to version $wersja

Co-authored-by: krystian3w <35370833+krystian3w@users.noreply.github.com>"
    fi

    if [[ "$k" == "cookies_filters/cookies_uB_AG.txt"* ]]; then
        if [[ "$lista" != *" 🍪"* ]] ;then
            lista+=" "🍪
        fi
        wersja="$(grep -oP "(?<=! Version: )[^ ]+" $k)"
        git add cookies_filters/cookies_uB_AG.txt
        git commit -S -m "Update 🍪 - Supplement to version $wersja

Co-authored-by: krystian3w <35370833+krystian3w@users.noreply.github.com>"
    fi
done

if [[ "$lista" == *" 🍪"* ]] && [[ "$lista" == *" 👍"* ]]; then
    lista="🍪 & 👍"
fi

today_date=$(date +"%Y%m%d")

# Wysyłanie zmienionych plików do repozytorium git
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
