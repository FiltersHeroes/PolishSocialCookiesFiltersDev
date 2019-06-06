#!/bin/bash

# Sciezka to miejsce, w którym znajduje się skrypt
sciezka=$(dirname "$0")

aktualna_godzina=$(date +"%H")

cd $sciezka/..

if [ "$CI" = "true" ]; then
    if [[ "$aktualna_godzina" == "13" ]]; then
    ost_plik=$(git log --since="5 hours 58 minutes ago" --name-only --pretty=format: | sort | uniq)
    else
    ost_plik=$(git log --since="3 hours 58 minutes ago" --name-only --pretty=format: | sort | uniq)
    fi
else
    ost_plik=$(git diff -z --name-only | xargs -0)
fi

for i in $ost_plik; do

    if [[ "$i" == "sections/adblock_cookies/uBO_AG"* ]]; then
        if [[ "$lista" != *" cookies_filters/cookies_uB_AG.txt"* ]]; then
            lista+=" "cookies_filters/cookies_uB_AG.txt
        fi
    fi

    if [[ "$i" == "sections/adblock_cookies"* ]]; then
        if [[ "$lista" != *" cookies_filters/adblock_cookies.txt"* ]]; then
            lista+=" "cookies_filters/adblock_cookies.txt
        fi
    fi

    if [[ "$i" == "sections/adblock_social_list/uBO_AG"* ]]; then
        if [[ "$lista" != *" adblock_social_filters/social_filters_uB_AG.txt"* ]]; then
            lista+=" "adblock_social_filters/social_filters_uB_AG.txt
        fi
    fi

    if [[ "$i" == "sections/adblock_social_list"* ]]; then
        if [[ "$lista" != *" adblock_social_filters/adblock_social_list.txt"* ]]; then
            lista+=" "adblock_social_filters/adblock_social_list.txt
        fi
    fi

done


if [ "$lista" ]; then
    $sciezka/VICHS.sh $lista
fi
