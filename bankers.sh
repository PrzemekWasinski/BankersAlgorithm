#!bin/bash

read -p "Enter number of processes: " process_amount

read -p "Enter number of resource types: " resource_amount

declare -A process_matrix
declare -A allocation_matrix

available=()
sequence=()
sequence_length=0
new_length=0

#Get inputs for the process matrix
for ((i = 0; i < process_amount; i++)); do
	for ((j = 0; j < resource_amount; j++)); do
		read -p "Enter Max Resource Request R$j for Process P$i: " resource_request
		process_matrix[$i, $j]="$resource_request"
	done
done

#Print Process Matrix
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
		echo -n "${process_matrix[$i, $j]}  "
	done
	echo
done

echo

#Fill allocation matrix with random numbers
for ((i = 0; i < process_amount; i++)); do
	for ((j = 0; j < resource_amount; j++)); do
		read -p "Enter allocated resource R$j for Process P$i: " allocated_resource
		allocation_matrix[$i, $j]="$allocated_resource"
	done
done

#Print allocation matrix
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
		echo -n "${allocation_matrix[$i, $j]}  "
	done
	echo
done

echo

#Get inputs for available resources
for ((i = 0; i < resource_amount; i++)); do
	read -p "Enter available resource R$i: " available_resource
	available[i]="$available_resource"
done

#Print available resources
echo "Available array: ${available[@]}"

#Check if available resources can run the processes
is_safe=true

while [[ $sequence_length -lt $process_amount ]] do
	for ((i = 0; i < process_amount; i++)); do
		passed=true
		for ((j = 0; j < resource_amount; j++)); do
			need=${process_matrix[$i, $j]}-${allocation_matrix[$i, $j]}
			if [[ "${available[$j]}" -lt "$need" ]]; then
				passed=false
			fi
		done

		echo "$passed"
		
		if [[ "$passed" == "true" ]]; then
			$new_length=$(($sequence_length+1))
			for ((j = 0; j < resource_amount; j++)); do
				new_available=${available[$j]}+${allocation_matrix[$i, $j]}
				available[$j]=$new_available
			done
		fi

		if [[ $new_length -gt $sequence_length ]]; then
			$sequence_length=$new_length
		else
			$is_safe=false
		fi
	done

	if [[ "$is_safe" == "false" ]]; then
		exit
		echo "Not in a safe state"
	fi
done

if [[ "$is_safe" == "true" ]]; then
	echo "In a safe state"
fi

