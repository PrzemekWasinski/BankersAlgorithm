#!bin/bash

read -p "Enter number of processes: " process_amount

read -p "Enter number of resource types: " resource_amount

declare -A processes
declare -A allocation_matrix

available=()

#
for ((i = 0; i < process_amount; i++)); do
	for ((j = 0; j < resource_amount; j++)); do
		read -p "Enter Max Resource Request R$j for Process P$i: " resource_request
		processes[$i, $j]="$resource_request"
	done
done

echo "Processes matrix: "
echo

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
	echo
done

for ((i = 0; i < process_amount; i++)); do
	for ((j = 0; j < resource_amount; j++)); do
		allocation_matrix[$i, $j]=$(( ( RANDOM % 5 )  + 1 ))
	done
done

echo
echo "Allocation Matrix:"
echo

echo -n "   "
for ((i = 0; i < resource_amount; i++)); do
	echo -n "R$i "
done

echo
for ((i = 0; i < process_amount; i++)); do
	echo -n "P$i: "
	for ((j = 0; j < resource_amount; j++)); do
		echo -n "${allocation_matrix[$i, $j]} "
	done
	echo
done

for ((i = 0; i < resource_amount; i++)); do
	read -p "Enter available resource R$i: " available_resource
	available[i]="$available_resource"
done

echo "Available array: ${available[@]}"

for ((i = 0; i < process_amount; i++)); do
	for ((j = 0; j < resource_amount; j++)); do
		if [[ ${available[$j]} -ge ${processes[$i, $j]} ]]; then
			echo "yes"
		else
			echo "no"
		fi
	done
done

