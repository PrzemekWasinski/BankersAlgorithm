#!/bin/bash

#Get inputs for processes and resources
read -p "Enter number of processes: " process_amount
read -p "Enter number of resource types: " resource_amount

#Matrixes for max resource requests and current allocation
declare -A process_matrix
declare -A allocation_matrix

#Available resources and sequence
available=()
sequence=()
sequence_length=0
new_length=0

#Get inputs for process matrix
for ((i = 0; i < process_amount; i++)); do
	for ((j = 0; j < resource_amount; j++)); do
		read -p "Enter Max Resource Request R$j for Process P$i: " resource_request
		process_matrix[$i,$j]=$resource_request
	done
done

#Print Process Matrix
echo
echo "Processes matrix:"
echo -n "    "

for ((i = 0; i < resource_amount; i++)); do
	echo -n "R$i "
done
echo

for ((i = 0; i < process_amount; i++)); do
	echo -n "P$i: "
	for ((j = 0; j < resource_amount; j++)); do
		echo -n "${process_matrix[$i,$j]}  "
	done
	echo
done
echo

#Get inputs for allocation atrix
for ((i = 0; i < process_amount; i++)); do
	for ((j = 0; j < resource_amount; j++)); do
		read -p "Enter allocated resource R$j for Process P$i: " allocated_resource
		allocation_matrix[$i,$j]=$allocated_resource
	done
done

#Print allocation matrix
echo
echo "Allocation Matrix:"
echo -n "    "

for ((i = 0; i < resource_amount; i++)); do
	echo -n "R$i "
done
echo

for ((i = 0; i < process_amount; i++)); do
	echo -n "P$i: "
	for ((j = 0; j < resource_amount; j++)); do
		echo -n "${allocation_matrix[$i,$j]}  "
	done
	echo
done
echo

#Get inputs for available resources
for ((i = 0; i < resource_amount; i++)); do
	read -p "Enter available resource R$i: " available_resource
	available[$i]=$available_resource
done

#Print available resources
echo "Available array: ${available[@]}"
echo

#Function to check if system is safe
function is_system_safe() {
	sequence=()
	sequence_length=0
	local temp_available=("${available[@]}")
	local finished=()
	
	for ((i = 0; i < process_amount; i++)); do
		finished[$i]=false
	done

	while [[ $sequence_length -lt $process_amount ]]; do
		progress_made=false

		for ((i = 0; i < process_amount; i++)); do
			if [[ ${finished[$i]} == true ]]; then
				continue
			fi

			passed=true
			for ((j = 0; j < resource_amount; j++)); do
				need=$(( ${process_matrix[$i,$j]} - ${allocation_matrix[$i,$j]} ))
				if [[ ${temp_available[$j]} -lt $need ]]; then
					passed=false
					break
				fi
			done

			if [[ $passed == true ]]; then
				sequence+=("P$i")
				sequence_length=$((sequence_length+1))
				for ((j = 0; j < resource_amount; j++)); do
					temp_available[$j]=$(( temp_available[$j] + allocation_matrix[$i,$j] ))
				done
				finished[$i]=true
				progress_made=true
			fi
		done

		if [[ $progress_made == false ]]; then
			return 1 
		fi
	done

	return 0  
}

#Check if system is safe
if is_system_safe; then
	echo "System is in a safe state, safe sequence: ${sequence[@]}"

    read -p "Would you like to run a process again? (y/n): " continue

    if [[ $continue == "y" ]]; then
        read -p "Select a process to run (P0 - P$((process_amount-1))): " selected_process

        if [[ $selected_process -lt 0 || $selected_process -ge $process_amount ]]; then
            echo "Invalid input!"
            exit 1
        fi

        #Get new max resource requests
        echo "Enter new max resource requests for process (P$selected_process):"
        for ((j = 0; j < resource_amount; j++)); do
            read -p "New resource request R$j for process (P$selected_process): " new_max_request
            process_matrix[$selected_process,$j]=$new_max_request
        done

        #Check if system is safe
        if is_system_safe; then
            echo "System is in a safe state, safe sequence: ${sequence[@]} "
        else
            echo "System not in a safe state"
        fi
    fi
else
	echo "System not in a safe state "
fi
