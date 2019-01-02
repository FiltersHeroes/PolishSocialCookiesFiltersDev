#!/bin/bash

ost_commit_katalog=$(dirname $(git diff-tree --no-commit-id --name-only -r master))
if [ "$ost_commit_katalog" == "sections/adblock_social_list" ]; then
    katalog=adblock_social_filters
    plik=adblock_social_list.txt
elif [ "$ost_commit_katalog" == "sections/adblock_cookies" ]; then
    katalog=cookies_filters
    plik=adblock_cookies.txt
elif [ "$ost_commit_katalog" == "sections/adblock_cookies/uBO_AG" ]; then
    katalog=cookies_filters
    plik=cookies_uB_AG.txt
elif [ "$ost_commit_katalog" == "sections/adblock_social_list/uBO_AG" ]; then
    katalog=adblock_social_filters
    plik=social_filters_uB_AG.txt
fi;


./scripts/VICHS.sh $katalog/$plik
