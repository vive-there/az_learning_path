#!/bin/bash
# Pseudo random between 1 and 20
roll=$(($RANDOM % 20 + 1))
lucky=7
unlucky=13
bad=1
half=10
perfect=20
if [[ $roll -gt $half ]]
then
    echo "More than half ${roll}"
    if [[ $roll -eq $perfect ]]
    then
        echo "It is perfect ${roll}"
    elif [[ $roll -eq $unlucky ]]
    then
        echo "You are unlucky ${roll}"
    else
        echo "Try again ${roll}"
    fi
else
    if [[ $roll -eq $lucky ]]
    then
      echo "Youre lucky ${roll}"
    elif [[ $roll -eq $bad ]]
    then
      echo "It is bad ${roll}"
    else
      echo "Value ${roll}"
    fi
fi

# if numeric

