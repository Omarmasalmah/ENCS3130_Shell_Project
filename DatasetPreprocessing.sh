#!/bin/bash

# Flag to track whether a dataset has been read from a file
dataset_read=false
# Flag to track whether a dataset has been saved
dataset_saved=false

# Main menu loop
while true; do
  # Print the menu
  echo "Menu:"
  echo "r) Read a dataset from a file"
  echo "p) Print the names of the features"
  echo "l) Encode a feature using label encoding"
  echo "o) Encode a feature using one-hot encoding"
  echo "m) Apply MinMax scaling"
  echo "s) Save the processed dataset"
  echo "e) Exit"

  # Read the user's choice
  echo -n "Enter your choice: "
  read choice

  # Perform the selected action
  case $choice in
    r)
      # Action for reading a dataset from a file
      echo "Please input the name of the dataset file: "
      read file_name
      if [ ! -f "$file_name" ]; then
          echo "File does not exist."
      else
	      if [ ! -f "temp.txt" ]; then
	      	touch "temp.txt" 
	     fi
	     #copy the contents of a file to a new file
	      cat "$file_name" > "new_file.txt"
		line_count=$(wc -l < $file_name)
		header_line=$(head -n 1 $file_name)
		header_line=$(echo "$header_line" | sed 's/[[:space:]]*$//')
		first_line=$(head -n 1 $file_name | tr -s ";" " " | cut -d" " -f1-)
		line1_count=$(echo $first_line |wc -w)
     
		 second_line=$(tail -n +2 $file_name | head -n 1 |tr -s ";" " " | cut -d" " -f1- | wc -w)

		# Code to check the format of the data in the dataset file goes here
		if [ "$second_line" !=  "$line1_count" ]; then		
		echo "The format of the data in the dataset file is wrong."
		break
		else
		echo "The file has been read"
		fi
		declare -a minmax_array

		# If the format is correct, set the dataset_read flag to true
		dataset_read=true
      fi
;;

    p)
      # Action for printing the names of the features
      if [ "$dataset_read" = false ]; then
        echo "You must first read a dataset from a file."
      else
      echo "**************************************************************"
	echo "$header_line" | tr ";" '  '
      echo "**************************************************************"
	fi
      ;;
    l)
      # Action for label encoding a feature
      if [ "$dataset_read" = false ]; then
        echo "You must first read a dataset from a file."
      else

      echo "Please input the name of the categorical feature for label encoding: "
        read feature_name
#clear the file	
>"temp.txt"	
	# Set up a flag to track whether featurename was found
	found=false
	#to count the number of column	
	counter=0
	features=$(echo $first_line | tr ";" '\n')

	for feature in $features
	do
	counter=$((counter+1))
	if [ "$feature_name" = "$feature" ]; then
	         # If the value is not in the array, add it and assign it a new code
	 if [[ ! " ${minmax_array[*]} " =~ " $feature_name" ]]; then
	#add the feature to min-max array 
	minmax_array+=($feature_name)
      fi
	found=true
	break
	
fi
done
	header_line=$(head -n 1 $file_name)
	echo "$header_line" > "temp.txt" 
	
	if $found 
	then
	
	# Create a dictionary
	declare -A value_code
	declare -A val
	code=0
	line_count=0
	
	while read line; do
	 line_count=$((line_count+1))
  
  	# Skip the first line that contain the sataset
  	if [ "$line_count" -eq 1 ]; then
    	continue
  	fi
	values=$(echo $line |cut -d";" -f$counter)
	
	 for value in $values; do
	 if [ -z "${value_code[$value]}" ]; then
    	# If the value is not in the dictionary, add it and assign it a new code
	value_code[$value]=$code
    	code=$((code + 1))
  	fi
	if [ -z "${val[$value]}" ]; then
	val[$value]=$value

	fi
	#set a new values
	modified_line=$(sed "s/${val[$value]}/${value_code[$value]}/g" <<< "$line")
	echo "$modified_line" >> "temp.txt"
	done
	
	done <"new_file.txt"
	cat "temp.txt" > "new_file.txt"

	# to access all the elements
	for key in "${!value_code[@]}"; do
  	
	echo "Value: $key, Code: ${value_code[$key]}"	
	done
	
	else
	echo "The name of categorical feature is wrong"
	fi
	label_encoded=true
	fi
      ;;
    o)
      # Action for one-hot encoding a feature
      if [ "$dataset_read" = false ]; then
        echo "You must first read a dataset from a file."
      else
      echo "Please input the name of the categorical feature for one-hot encoding: "
        read feature_name
        # Set up a flag to track whether featurename was found
        found=false
#clear file
>"temp.txt"
        #to count the number of column  
        counter=0
        declare -a header_array
        features=$(echo $first_line | tr ";" '\n') 
            
        for feature in $features
        do
        counter=$((counter+1))
        if [ "$feature_name" = "$feature" ]; then
        header_array+=($feature)       
        # If the value is not in the dictionary, add it and assign it a new code
	   if [[ ! " ${minmax_array[*]} " =~ " $feature_name" ]]; then
	minmax_array+=($feature_name)
      fi
     
        found=true
        break

fi
done

        header_line=$(head -n 1 $file_name)
	header_line=$(echo "$header_line" | sed 's/[[:space:]]*$//' | sed "s/$feature_name;//")

        if $found 
        then

        # Create a dictionary
        declare -a values_array
	code=0
        line_count=0
	
        while read line; do
         line_count=$((line_count+1))
  
        # Skip the first line that contain the sataset
        if [ "$line_count" -eq 1 ]; then
        continue
        fi
        values=$(echo $line |cut -d";" -f$counter)

         for value in $values; do
          if [[ ! " ${values_array[*]} " =~ " $value " ]]; then
	
	values_array+=($value)
        fi
	done

	str=$(IFS=';'; echo "${values_array[*]}")
        
	done < "new_file.txt"
	
	header_line="$header_line$str;"
	echo "$header_line" > "temp.txt"


        values=$(echo $line |cut -d";" -f$counter)

	
	num=0
	while read line; do

	num=$((num+1))
  
       
        values=$(echo $line |cut -d";" -f$counter)

	# initialize array encoded data
  	array=()
	for val in "${values_array[@]}"; do
	
	if [ "$val" == "$values" ]; then

	array+=("1;")
    else
        array+=("0;")

    fi
  done

	oneHot_data=""
	for i in "${array[@]}"; do
  	oneHot_data+="$i"
	done
	
  	
	if [ "$num" -ge 2 ]; then
        
       	  if [ "$num" -ge "$line_count" ]; then
    	  break
  	  fi

  	  line=$(echo "$line" | sed 's/[[:space:]]*$//' | sed "s/$values;//")
  	modified_line="$line$oneHot_data"
        echo "$modified_line" >> "temp.txt"
     fi
      
        done <"new_file.txt"
        cat "temp.txt" > "new_file.txt"

        else
        echo "The name of categorical feature is wrong"
        fi
	oneHot_encoded=true
        fi
      ;;
    m)
      # Action for applying MinMax scaling
	if [ "$dataset_read" = false ]; then
        echo "You must first read a dataset from a file."
      else
       	echo "Please input the name of feature to be scaled: "
        read feature_name
        find=false
        checked=false
        count=0

>"temp.txt"
        l_count=0
        featur=$(echo $first_line | tr ";" '\n') 
	for feature in $featur
	do
	count=$((count+1))
	if [ "$feature_name" = "$feature" ]; then
        find=true
        break
        fi

	done

if $find
	then
         #check if the entered feature are encoded 
       	for key in "${minmax_array[@]}"; do
      	if [ "$feature_name" = "$key"  ]; then
        	checked=true
        fi
        done
 
        values=$(tail -n +2 "new_file.txt" |cut -d";" -f$count)

	for value in "${values[@]}"; do
	#check if the feature is numeric
	if [[ -z "`echo "$value" | sed 's/./\0\n/g' | grep -v [0-9] | tr -d '\n'`" ]]; then
	checked=true
	fi
	done
	
    if $checked; then   
        # Initialize the minimum and maximum values to the first element of the array
	min=${values[0]}
	max=${values[0]}

	# finds the minimum and maximum values in a list of values
	min=`echo $values | tr ' ' '\n' | sort -n | head -1`
	max=`echo $values | tr ' ' '\n' | sort -n | tail -1`
    

        	
        arr=()
        dm=$((max-min))
        echo "==============================="
	values=(`echo "$values"`)
		
		
	for value in "${values[@]}"; do 
		
		vi=$(echo "scale=2;$value-$min" | bc -l)
		res=$(echo "scale=2;$vi/$dm" | bc -l | awk '{printf "%.2f\n", $0}')
		echo "$res"
		arr+=($res)
	done
	#print the array that contain scaled feature
	echo $(echo "[${arr[@]}]" | tr ' ' ,)
        echo "==============================="

	# Print the minimum and maximum values
	echo "Minimum value: $min"
	echo "Maximum value: $max"
      else
         echo "This feature is categorical feature and must be encoded first "
      fi

        
        else
        echo "Feature not found"
        fi
  
        
	fi
	;;

    s)
      # Action for saving the processed dataset
      if [ "$dataset_read" = false ]; then
	echo "The processed dataset is not saved. Are you sure you want to exist"
      
      else
        echo "Please input the name of the file to save the processed dataset"
	read filename 
	
	if [ ! -f "$filename" ]; then
	      	touch $filename 
	 fi
	#copy the data to file for saving 
	cat "new_file.txt" >> $filename
	#change the flag of save 
	dataset_saved=true   
      fi
      ;;
    e)
      # Exit the program
      if [ "$dataset_saved" = false ]; then
      echo "The processed dataset is not saved. Are you sure you want to exit?"
      read confrim1
      if [ "$confrim1" = "yes" ];then
      echo "Exiting the program."
      exit
      fi
      else
      echo "Are you sure you want to exit?"
      read confrim2
      if [ "$confrim2" = "yes" ];then
      echo "Exiting the program."
      exit
      fi
      
      fi
      
      ;;
    *)
      # Invalid choice
      echo "Invalid choice. Please try again."
	;;     

esac
done