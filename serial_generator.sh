#!/bin/bash

function convert_dec_to_base() {
    BASE=$1
    DEC_NUM=$2
    declare -r DIGITS="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    digit_value=""
    dec_value=$DEC_NUM

    until [ $dec_value == 0 ]; do

	rem_value=$((dec_value % $BASE))
	dec_value=$((dec_value / $BASE))
	digit=${DIGITS:$rem_value:1}
	digit_value="${digit}${digit_value}"
    done
}

# generate a unique serial number using timestamp
# convert to base 36 to compact it
dec_value=$(date +'%Y%m%d%H%M%S%N')
convert_dec_to_base 36 $dec_value
echo $digit_value

