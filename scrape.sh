#!/bin/bash
# ss11mik
# 2023

# vut-zpravy:
# crops results to 100 rows
# searches in both name and surname
# minimum of 3 letters, can be overcome by dots
# dot has no effect ("n......o..va.k" matches "Novák")
# case insensitive
# diacritics insensitive

# cookies.txt: file with valid login cookies for www.vut.cz
# e.g. exported by cookies.txt browser extension


outdir=$(date +"%y%m%d_%H%M")
mkdir -p $outdir


requests=0

scrape () {
    for i in {a..z}; do

        query=$1$i

        echo -n $query ": "
        response=$(curl -s -b cookies.txt  "https://www.vut.cz/intra/vut-zpravy?action=ajax&term=$query..&ajax=0")

        echo $response | jq -rs '.[][][] .value' | xargs -0 printf "%b" | tee -a $outdir/$query.txt | wc -l

        ((requests++))
        if [ $(( $requests % 128)) -eq 127 ]; then
            # print stats once in a while
            echo " " $requests " requests done"
        fi

        if [ $(echo $response | wc -c) -eq 1 ]; then
            # error, probably invalid cookies
            # response is only 1 byte
            echo "Invalid response, are cookies valid?"
            echo "stopped at:" $query
            exit 1
        fi


        # better not DoS the API
        sleep 0.5

        if [ $(cat $outdir/$query.txt | wc -l) -ge 100 ]; then
            # probably more than 100 entries, needs to be explored by more queries
            scrape $query

        elif [ $(cat $outdir/$query.txt | wc -c) -le 1 ]; then
            # an empty result:
            #   {"options":[]}
            # result of 1 row might still be valid, must be compared to 1 Byte!
            rm $outdir/$query.txt
        fi

    done
}



echo "run time:"
time scrape ""

echo ""
echo "requests made:" $requests
echo "requests with non-empty response:" $(ls -l $outdir | wc -l)

cat $outdir/* | sort | uniq > vut_$outdir.txt
