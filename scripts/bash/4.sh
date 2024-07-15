#!/bin/bash

echo "What's your favorite season"
select season in Spring Summer Autumn Winter
do
  if [[ $season = Spring ]]
  then
    echo "I love ${season} too"
    break
  elif [[ $season = Summer ]]
  then
    echo "${season} is too hot"
    break;
  elif [[ ${season} = Autumn ]]
  then
    echo "${season} is wonderful"
    break;
  elif [[ ${season} = Winter ]]
  then
    echo "It is cold in ${season}"
    break;
  else
    echo "I do not know this season. Try again"
  fi
done