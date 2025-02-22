#!/bin/bash

# Get inputs for processes and resources
process_amount=0
resource_amount=0

while true; do
    read -p "Enter number of processes: " process_input
    read -p "Enter number of resource types: " resource_input

    if [[ "$process_input" =~ ^[0-9]+$ && "$process_input" -ge 0 && "$resource_input" =~ ^[0-9]+$ && "$resource_input" -ge 0 ]]; then
        process_amount=$process_input
        resource_amount=$resource_input
        break
    else
        echo "Invalid input!"
    fi
done

echo

declare -A process_matrix
declare -A allocation_matrix

# Available resources and sequence
available=()
sequence=()
sequence_length=0
new_length=0

#Get inputs for process matrix
for ((i = 0; i < process_amount; i++)); do
	for ((j = 0; j < resource_amount; j++)); do
        while true; do
            read -p "Enter Max resource request R$j for Process P$i: " resource_req
            if [[ "$resource_req" =~ ^[0-9]+$ && "$resource_req" -ge 0 ]]; then
                process_matrix[$i,$j]=$resource_req
                break
            else
                echo "Invalid input!"
            fi
        done
	done
done

#Print process matrix
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

#Get inputs for allocation matrix
for ((i = 0; i < process_amount; i++)); do
	for ((j = 0; j < resource_amount; j++)); do
        while true; do
            read -p "Enter allocated resource R$j for Process P$i: " allocated_resource
            if [[ "$allocated_resource" =~ ^[0-9]+$ && "$allocated_resource" -ge 0 ]]; then 
                allocation_matrix[$i,$j]=$allocated_resource
                break
            else
                echo "Invalid input"
            fi
        done
	done
done

#Print allocation atrix
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
	while true; do
		read -p "Enter available resource R$i: " available_resource
		if [[ "$available_resource" =~ ^[0-9]+$ && "$available_resource" -ge 0 ]]; then
			available[$i]=$available_resource
			break
		else 
			echo "Invalid input!"
		fi
	done
done

#Print available resources
echo "Available resources: ${available[@]}"
echo

#Function to check if system has enough resources
function is_system_safe() {
	sequence=()
	sequence_length=0
	temp_available=("${available[@]}") 
	finished=()
	
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
	echo "System is in safe state"
	echo "Safe sequence: ${sequence[@]}"

	while true; do
		read -p "Would you like to run a process again? (y/n): " continue

		if [[ $continue == "y" || $continue == "n" ]]; then
			if [[ $continue == "y" ]]; then
				selected_process=0
				while true; do
					read -p "Select a process to run P0 - P$((process_amount-1)): " rerun_input

					if [[ "$rerun_input" =~ ^[0-9]+$ && "$rerun_input" -ge 0 && $rerun_input -le $((process_amount-1)) ]]; then
						selected_process=$rerun_input
						break
					else
						echo "Invalid input!"
					fi
				done

				#Get new max resource requests
				echo "Enter new max resource requests for process P$selected_process:"
				for ((j = 0; j < resource_amount; j++)); do
					while true; do
						read -p "New resource request R$j for process P$selected_process: " new_max_req
						if [[ "$new_max_req" =~ ^[0-9]+$ && "$new_max_req" -ge 0 ]]; then
							process_matrix[$selected_process,$j]=$new_max_req
							break
						else 
							echo "Invalid input!"
						fi
					done
				done

				#Check if system is safe with new resource requests
				if is_system_safe; then
					echo "System is in safe state"
					echo "Safe sequence: ${sequence[@]}"
				else
					echo "System not in safe state"
				fi
			fi
			break
		else
			echo "Invalid input!"
		fi
	done
else
	echo "System not in safe state"
fi
