#!/bin/bash

read -p "Are you sure you want to continue (y/n)? " choice
if [[ $choice =~ ^[Yy]$ ]]
then
  echo "You selected to continue"
else
  echo "Good bye!"
  exit 5
fi


while [[ 1 -eq 1 ]]
do
  echo "We are here again."
  choice=""
  read -p "Are you sure you want to continue (y/n)? " choice
  if [[ $choice =~ ^[Yy]$ ]]
  then
    echo "Continue"
    break;
  elif [[ $choice =~ ^[Nn]$ ]]
  then
    echo "Good bye!"
    break;
  else
    echo "Invalid input"
  fi
done