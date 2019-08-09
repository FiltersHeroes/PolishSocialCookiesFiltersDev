#!/bin/bash

# Sciezka to miejsce, w którym znajduje się skrypt
sciezka=$(dirname "$0")

aktualna_godzina=$(date +"%H")

cd "$sciezka"/.. || exit

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

    if [[ "$i" == "sections/adblock_cookies"* ]] && [[ "$i" != "sections/adblock_cookies/uBO_AG"* ]]; then
        if [[ "$lista" != *" cookies_filters/adblock_cookies.txt"* ]]; then
            lista+=" "cookies_filters/adblock_cookies.txt
        fi
    fi

    if [[ "$i" == "sections/adblock_cookies/uBO_AG"* ]]; then
        if [[ "$lista" != *" cookies_filters/cookies_uB_AG.txt"* ]] && [[ "$lista" != *" cookies_filters/adblock_cookies.txt"* ]]; then
            lista+=" "cookies_filters/cookies_uB_AG.txt
            lista_g+=" "cookies_filters/adblock_cookies.txt
        fi
    fi

    if [[ "$i" == "sections/adblock_social_list"* ]] && [[ "$i" != "sections/adblock_social_list/uBO_AG"* ]]; then
        if [[ "$lista" != *" adblock_social_filters/adblock_social_list.txt"* ]]; then
            lista+=" "adblock_social_filters/adblock_social_list.txt
        fi
    fi

    if [[ "$i" == "sections/adblock_social_list/uBO_AG"* ]]; then
        if [[ "$lista" != *" adblock_social_filters/social_filters_uB_AG.txt"* ]] && [[ "$lista" != *" adblock_social_filters/adblock_social_list.txt"* ]]; then
            lista+=" "adblock_social_filters/social_filters_uB_AG.txt
            lista_g+=" "adblock_social_filters/adblock_social_list.txt
        fi
    fi

    if [[ "$i" == "sections/adblock_social_list/popupy.txt"* ]]; then
        if [[ "$PAF" != "true" ]]; then
            PAF="true"
        fi
    fi

    if [[ "$i" == "sections/adblock_social_list/uBO_AG/popupy"* ]]; then
        if [[ "$PAF" != "true" ]]; then
            PAF_supp="true"
        fi
    fi

done


if [ "$lista" ]; then
    . "$sciezka"/VICHS.sh $lista
fi

if [ "$lista_g" ]; then
    FORCED="true"
    . "$sciezka"/VICHS.sh $lista_g
    unset FORCED
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
    . ./scripts/VICHS.sh ./PPB.txt ./PAF_pop-ups.txt
elif [ "$PAF_supp" ]; then
    FORCED="true"
    . ./scripts/VICHS.sh ./PAF_pop-ups_supp.txt ./PPB.txt ./PAF_pop-ups.txt
    unset FORCED
fi
