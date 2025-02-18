#!bin/bash

read -p "Enter number of processes: " process_amount

read -p "Enter number of resource types: " resource_amount

declare -A processes

available=()

for ((i = 0; i < process_amount; i++)); do
	for ((j = 0; j < resource_amount; j++)); do
		read -p "Enter Max Resource Request R$j for Process P$i: " resource_request
		processes[$i, $j]="$resource_request"
	done
done

echo -n "    "
for ((i = 0; i < resource_amount; i++)); do
	echo -n	"R$i "
done

echo

for ((i = 0; i < process_amount; i++)); do
	echo -n "P$i: "
	for ((j = 0; j < resource_amount; j++)); do
		echo -n "${processes[$i, $j]}  "
	done
	echo " "
done

for ((i = 0; i < resource_amount; i++)); do
	read -p "Enter available resource R$i: " available_resource
	available[i]="$available_resource"
done

echo "Available array: [${available[@]}]"


