#!/bin/bash
# Include my shared functions
. $HOME/azure/repos/az_learning_path/scripts/shared/shared_funcs.sh

echo "Number of parameters $#"
echo "All parameters in single string - $*"
echo "All parameters in list $@"
echo "The exit code of last completed foreground code $?"
echo "The PID $$"
echo "The last argument of last completed command $_"

testParameter=$1
echo "Parameter is ${testParameter} and length is ${#testParameter}"
echo "Uppercase the first character ${testParameter^}"
echo "Uppercase all characters ${testParameter^^}"
echo "Lowercase the first character ${testParameter,}"
echo "Lowercase all characters ${testParameter,,}"
echo "Reverese the case of the first character ${testParameter~}"
echo "Reverse the case of all characters ${testParameter~~}"
echo ${testParameter}

#Assign default value if parameter is not set
#pizzaName was not assigned before so default value will be Pepperoni
echo "Pizza ${pizzaName:='Pepperoni'}"
echo $pizzaName

pizzaMargherita="Margherita"
# not set pepperoni because pizzaMargherita was already assigned
echo "Pizza ${pizzaMargherita:='Pepperoni'}"
echo $pizzaMargherita

# if param1 is assigned use Test
param1="12"
echo "Param ${param1:+Test}"

az group create --name test122 --location eeee
or_exit "Could not create az group"


