#!bin/bash

read -p "Enter number of processes: "  processes

read -p "Enter number of resource types: "  resources

available=()



for ((i = 0; i < resources; i++)); do
	read -p "Enter available resource R$i: "  available_resource
	available[i]="$available_resource"
done

echo "Available array: ${available[@]}"


