#!/bin/bash

# Sciezka to miejsce, w którym znajduje się skrypt
sciezka=$(dirname "$0")

cd $sciezka/..

ost_zmieniony_plik=$(git diff -z --name-only | xargs -0)

for i in $ost_zmieniony_plik; do

    if [[ "$i" == "sections/adblock_cookies"* ]]; then
        if [[ "$lista" != *" cookies_filters/adblock_cookies.txt"* ]] ;then
            lista+=" "cookies_filters/adblock_cookies.txt
        fi
    fi
    
    if [[ "$i" == "sections/cookies_uB_AG"* ]]; then
        if [[ "$lista" != *" cookies_filters/cookies_uB_AG.txt"* ]] ;then
            lista+=" "cookies_filters/cookies_uB_AG.txt
        fi
    fi
    
    if [[ "$i" == "sections/adblock_social_list"* ]]; then
        if [[ "$lista" != *" adblock_social_filters/adblock_social_list.txt"* ]] ;then
            lista+=" "adblock_social_filters/adblock_social_list.txt
        fi
    fi
    
    if [[ "$i" == "sections/social_filters_uB_AG"* ]]; then
        if [[ "$lista" != *" adblock_social_filters/social_filters_uB_AG.txt"* ]] ;then
            lista+=" "adblock_social_filters/social_filters_uB_AG.txt
        fi
    fi

done

$sciezka/VICHS.sh $lista
