#!/bin/bash

cd $1


runlines() {
    while read line; do
        echo '$' $line

        $line
        if [ $? != 0 ]
        then
            echo -e "\e[31m'$line' failed\e[0m\n"
            exit $1 # status
        fi

        echo -e "\e[32m'$line' passed\e[0m\n"

    done
}

exit_nz() {
    if [ $1 != 0 ]
    then
        exit $1
    fi
}


jq ".dep | .[]" -r < peterci.json | runlines 3
exit_nz $?



jq ".script | .[]" -r < peterci.json | runlines 1
exit_nz $?
