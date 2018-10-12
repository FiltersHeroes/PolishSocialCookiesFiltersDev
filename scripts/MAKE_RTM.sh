#!/bin/bash
for i in "$@"; do
    # FILTR to nazwa pliku, który chcemy zaktualizować
    FILTR=$(basename $i .txt)

    # Sciezka to miejsce, w którym znajduje się skrypt
    sciezka=$(dirname "$0")

    TEMPLATE=$sciezka/../templates/${FILTR}.template
    KONCOWY=$i
    TYMCZASOWY=$sciezka/../${FILTR}.temp
    SEKCJE_KAT=$sciezka/../sections/${FILTR}


    # Podmienianie zawartości pliku końcowego na zawartość template'u
    cp -R $TEMPLATE $KONCOWY

    # Usuwanie pustych linii z sekcji
    find ${SEKCJE_KAT} -type f -exec sed -i '/^$/d' {} \;

    # Sortowanie sekcji z pominięciem tych, które zawierają specjalne instrukcje
    find ${SEKCJE_KAT} -type f ! -iname ""*_specjalne_instrukcje.txt"" -exec sort -uV -o {} {} \;

    # Obliczanie ilości sekcji (wystąpień słowa @include w template'cie
    END=$(grep -o -i '@include' ${TEMPLATE} | wc -l)

    # Doklejanie sekcji w odpowiednie miejsca
    for (( n=1; n<=$END; n++ ))
    do
        SEKCJA=$(grep -oP -m 1 '@include \K.*' $KONCOWY)
        sed -e '0,/^@include/!b; /@include/{ r '${SEKCJE_KAT}/${SEKCJA}.txt'' -e 'd }' $KONCOWY > $TYMCZASOWY
        cp -R $TYMCZASOWY $KONCOWY
    done

    # Usuwanie tymczasowego pliku
    rm -r $TYMCZASOWY

    # Przejście do katalogu, w którym znajduje się lokalne repozytorium git
    cd $sciezka/..

    # Ustawianie nazwy kodowej (krótszej nazwy listy filtrów) do opisu commita w zależności od tego, co jest wpisane w polu „Codename:". Jeśli nie ma takiego pola, to trzeba podać nazwę kodową dla listy filtrów.
    if grep -q "! Codename" $i; then
        filtr=$(grep -oP -m 1 '! Codename: \K.*' $i);
    else
        printf "Podaj nazwę kodową dla listy filtrów $(basename $i): "
        read filtr
    fi

    # Ustawienie polskiej strefy czasowej
    export TZ=":Poland"

    # Aktualizacja daty i godziny w polu „Last modified"
    export LC_ALL=en_US.UTF-8
    modified=$(date +"%a, %d %b %Y")
    sed -i "s|@modified|$modified|g" $i

    # Aktualizacja wersji
    wersja="$(date +"%Y%m%d") RTM"
    sed -i "s|@wersja|$wersja|g" $i

    # Aktualizacja pola „aktualizacja"
    export LC_ALL=pl_PL.UTF-8
    aktualizacja=$(date +"%a, %d %b %Y")
    sed -i "s|@aktualizacja|$aktualizacja|g" $i

    # Aktualizacja sumy kontrolnej
    # Założenie: kodowanie UTF-8 i styl końca linii Unix
    # Usuwanie starej sumy kontrolnej i pustych linii
    grep -v '! Checksum: ' $i | grep -v '^$' > $i.chk
    # Pobieranie sumy kontrolnej... Binarny MD5 zakodowany w Base64
    suma_k=`cat $i.chk | openssl dgst -md5 -binary | openssl enc -base64 | cut -d "=" -f 1`
    # Zamiana atrapy sumy kontrolnej na prawdziwą
    sed -i "/! Checksum: /c\! Checksum: $suma_k" $i
    rm -r $i.chk
done

ost_zmieniony_plik=$(git diff -z --name-only | xargs -0)

for i in $ost_zmieniony_plik; do

    if [[ "$i" == "cookies_filters/adblock_cookies.txt"* ]]]; then
        cp -r ~/git/PolishSocialCookiesFiltersDev/cookies_filters/adblock_cookies.txt ~/git/polish-ads-filter/cookies_filters/
    
    if [[ "$i" == "cookies_filters/cookies_uB_AG.txt"* ]]; then
        cp -r ~/git/PolishSocialCookiesFiltersDev/cookies_filters/cookies_uB_AG.txt ~/git/polish-ads-filter/cookies_filters/
    fi

    if [[ "$i" == "adblock_social_filters/adblock_social_list.txt"* ]]; then
        cp -r ~/git/PolishSocialCookiesFiltersDev/adblock_social_filters/adblock_social_list.txt ~/git/polish-ads-filter/adblock_social_filters/
        
    if [[ "$i" == "adblock_social_filters/social_filters_uB_AG.txt"* ]]; then
        cp -r ~/git/PolishSocialCookiesFiltersDev/adblock_social_filters/social_filters_uB_AG.txt ~/git/polish-ads-filter/adblock_social_filters/
    fi

done

cd ~/git/polish-ads-filter
wersja="$(date +"%Y%m%d") RTM"
ost_zmieniony_plik_RTM=$(git diff -z --name-only | xargs -0)

for j in $ost_zmieniony_plik_RTM; do
    if [[ "$j" == "adblock_social_filters/adblock_social_list.txt"* ]]; then
        if [[ "$lista" != *" 👍"* ]] ;then
            lista+=" "👍
        fi
        git add adblock_social_filters/adblock_social_list.txt
        git commit -S -m "Update 👍 to version $wersja"
    fi

    if [[ "$j" == "adblock_social_filters/social_filters_uB_AG.txt"* ]]; then
        if [[ "$lista" != *" 👍"* ]] ;then
            lista+=" "👍
        fi
        git add adblock_social_filters/social_filters_uB_AG.txt
        git commit -S -m "Update 👍 - Supplement to version $wersja"
    fi

    if [[ "$j" == "cookies_filters/adblock_cookies.txt"* ]]; then
        if [[ "$lista" != *" 🍪"* ]] ;then
            lista+=" "🍪
        fi
        git add cookies_filters/adblock_cookies.txt
        git commit -S -m "Update 🍪 to version $wersja"
    fi

    if [[ "$j" == "cookies_filters/cookies_uB_AG.txt"* ]]; then
        if [[ "$lista" != *" 🍪"* ]] ;then
            lista+=" "🍪
        fi
        git add cookies_filters/cookies_uB_AG.txt
        git commit -S -m "Update 🍪 - Supplement to version $wersja"
    fi
done

if [[ "$lista" == *" 🍪"* ]] && [[ "$lista" == *" 👍"* ]]; then
    lista="🍪 & 👍"
fi

# Wysyłanie zmienionych plików do repozytorium git
echo "Czy chcesz teraz wysłać do gita zmienione pliki?"
select yn in "Tak" "Nie"; do
    case $yn in
        Tak )
        git push
        printf "Podaj rozszerzony opis PR, np 'Fix #1, fix #2' (bez ciapek; jeśli nie chcesz rozszerzonego opisu, to możesz po prostu nic nie wpisywać): "
        read roz_opis
        hub pull-request -m "Update $lista to version $wersja

        ${roz_opis}"
        break;;
        Nie ) break;;
esac
done
