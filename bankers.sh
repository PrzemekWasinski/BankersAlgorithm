 #!/bin/bash

# Get inputs for processes and resources and validate them
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

# Define process request matrix, allocation matrix, available resources, and safe sequence
declare -A process_matrix
declare -A allocation_matrix
available=()
sequence=()

# Get inputs for available resources and validate them
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

# Print available resources
echo
echo "Available resources: ${available[@]}"
echo

# Get inputs for process matrix and validate them
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

# Print process matrix
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

# Get inputs for allocation matrix and validate them
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

# Print allocation matrix
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

check_safety() {
	safe=true
    sequence_length=0
    sequence=()

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
                done
                progress=true
            fi
        done

        if [[ $progress == false ]]; then
            safe=false
            break
        fi
    done

    # Output if the system is in a safe state
    if [[ $safe == true ]]; then
        echo "System is in safe state"
        echo "Safe sequence: ${sequence[@]}"
    else
        echo "System not in a safe state"
        exit 1 
    fi
}

check_safety

while true; do
    read -p "Would you like to add a new process? [Y/n]: " continue

    if [[ $continue == "y" || $continue == "Y" ]]; then
        new_process=()
        new_allocation=()

        # Get max resource request and allocated resources for the new process
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
            while true; do
                read -p "Enter allocated resource R$i for the new process: " new_allocated_res
                if [[ "$new_allocated_res" =~ ^[0-9]+$ && "$new_allocated_res" -ge 0 ]]; then
                    new_allocation[$i]=$new_allocated_res
                    break
                else
                    echo "Invalid input!"
                fi
            done
        done

        # Update process and allocation matrices
        for ((j = 0; j < resource_amount; j++)); do
			process_matrix[$process_amount,$j]=${new_process[$j]}
			allocation_matrix[$process_amount,$j]=${new_allocation[$j]}
		done
        process_amount=$((process_amount+1))

        check_safety

    elif [[ $continue == "n" || $continue == "N" ]]; then
        echo "See you later!"
        break
    else
        echo "Invalid input!"
    fi
done