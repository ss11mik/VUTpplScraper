#!/bin/bash
# ss11mik
# 2023

input=$1

parse () {

    studenti=$(grep $input -we "student $1" | wc -l)
    echo " studenti:" $studenti


    if [ $studenti -ne 0 ]; then
        studentky=$(grep $input -we "student $1" | grep -e "á " | wc -l)
        studentkyProcent=$(bc <<< "scale=2; $studentky * 100 / $studenti")
        echo " studentky: $studentky ($studentkyProcent %)"

        # has Bc., but not Ing. nor Mgr. in name
        studentiBc=$(grep $input -we "student $1" | grep "Bc\." | grep -v -e "Ing\." -e "Mgr\." | wc -l)
        echo " studenti s Bc.:" $studentiBc

        if [ $studentiBc -ne 0 ]; then
            studentkyBc=$(grep $input -we "student $1" | grep "Bc\." | grep -v -e "Ing\." -e "Mgr\." | grep -e "á " | wc -l)
            studentkyBcProcent=$(bc <<< "scale=2; $studentkyBc * 100 / $studentiBc")
            echo " studentky s Bc.: $studentkyBc ($studentkyBcProcent %)"
        fi
    fi


    zamestnanci=$(grep $input -we "zaměstnanec $1" | wc -l)
    echo " zaměstnanci:" $zamestnanci

    if [ $zamestnanci -ne 0 ]; then
        zamestnankyne=$(grep $input -we "zaměstnanec $1" | grep -e "á " | wc -l)
        zamestnankyneProcent=$(bc <<< "scale=2; $zamestnankyne * 100 / $zamestnanci")
        echo " zaměstnankyně: $zamestnankyne ($zamestnankyneProcent %)"

        echo -n " profesoři: "
        # in the data, there is found both "Prof." and "prof."
        grep $input -we "zaměstnanec $1" | grep -we "Prof\." -we "prof\." | wc -l

        echo " studenti/zaměstnanci:" $(bc <<< "scale=2; $studenti / $zamestnanci")
    fi


    echo -n " externisté: "
    grep $input -we "externista $1" | wc -l
}

faculty () {
    echo ""
    echo "$1:"

    echo -n " celkem: "
    grep $input -we "$1" | wc -l

    parse $1
}

whole_vut () {
    echo "Celé VUT:"

    echo -n " celkem: "
    cat $input | wc -l

    parse "*"

    echo -n " bez role: "
    grep -E "\- $" $input | wc -l
}


stats () {

    faculty FIT
    faculty FEKT
    faculty FSI
    faculty FCH
    faculty FA
    faculty FAST
    faculty FaVU
    faculty FP

    echo ""

    faculty CESA
    faculty ÚSI
    faculty ICV
    faculty CEITEC

    echo ""

    faculty KAMB

    echo ""

    whole_vut

}

stats
