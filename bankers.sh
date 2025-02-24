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

#Define process request matrix, allocation matrix, available resources and safe sequence
declare -A process_matrix
declare -A allocation_matrix
available=()
sequence=()

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
echo
echo "Available resources: ${available[@]}"
echo

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
	echo
done

#Print process matrix
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
	echo
done

#Print allocation atrix
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

#Function to check if system has enough resources
is_safe() {
    sequence=()
    sequence_length=0

    while [[ $sequence_length -lt $process_amount ]]; do
        progress=false

        for ((i = 0; i < process_amount; i++)); do
            if [[ " ${sequence[@]} " =~ "P$i" ]]; then
                continue
            fi

            passed=true
            for ((j = 0; j < resource_amount; j++)); do
                need=$(( ${process_matrix[$i,$j]} - ${allocation_matrix[$i,$j]} ))

                if [[ ${available[$j]} -lt $need ]]; then
                    passed=false
                    break
                fi
            done

            if [[ $passed == true ]]; then
                sequence+=("P$i")
                sequence_length=$((sequence_length+1))
                for ((j = 0; j < resource_amount; j++)); do
                    available[$j]=$(( available[$j] + allocation_matrix[$i,$j] ))
					allocation_matrix[$i,$j]=0
                done
                progress=true
            fi
        done

        if [[ $progress == false ]]; then
            return 1
        fi
    done

    return 0
}

#Check if system is in safe state
if is_safe; then
	echo "System is in safe state"
	echo "Safe sequence: ${sequence[@]}"
	echo

	while true; do
		read -p "Would you like to run another process? [Y/n]: " continue

		if [[ $continue == "y" || $continue == "n" || $continue == "Y" || $continue == "N" ]]; then
			if [[ $continue == "y" || $continue == "Y" ]]; then
				new_process=()
				safe=true

				for ((i = 0; i < resource_amount; i++)); do
					while true; do
						read -p "Enter max resource request R$i for the new process: " new_max_req
						if [[ "$new_max_req" =~ ^[0-9]+$ && "$new_max_req" -ge 0 ]]; then
							new_process[$i]=$new_max_req
							break
						else
							echo "Invalid input!"
						fi
					done
				done

				for ((i = 0; i < resource_amount; i++)); do
					if [[ ${available[$i]} -lt ${new_process[$i]} ]]; then
						safe=false
					fi
				done
				
				echo
				if [[ $safe == true ]]; then
					echo "System in safe state"
					echo
				else
					echo "System not in a safe state"
					break
				fi
			elif [[ $continue == "n" || $continue == "N" ]]; then
				echo
				echo "See you later"
				break
			fi
		else
			echo "Invalid input!"
		fi
	done
else
	echo "System not in a safe state"
fi
