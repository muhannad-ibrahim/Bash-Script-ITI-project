#! /bin/bash
shopt -s extglob
export LC_COLLATE=C
Red='\033[0;31m'
Green='\033[0;32m'
DefaultColor='\033[0m'
PS3="Hit ur choice : "
sep="|" 		# used to be the seperator between fields.  
rSep="\n"		# used to new line 	
pKey="" 		# used to be primary key
clear;

		echo "**********************************************************************"
		echo "*                    Database Management System                      *"
		echo "*                                                                    *"
		echo "*                            Main Menu                               *"
		echo "**********************************************************************"
function main_menu {
	COLUMNS=12               # Set the select menu to appear on separate lines.
	select choice in 'Create Database' 'List Databases' 'Connect To Database' 'Drop Databse' 'Exit'
	do
	case $REPLY in
		1) clear ; create_database
			;;
		2) clear ; list_databases
			;;
		3) clear ; connect_database
			;;
		4) clear ; drop_database
			;;
		5) clear ; exit 
			;;
		*) echo -e $Red"Invaild choice."$DefaultColor
	esac
	done
}

function connect_database {
	echo -n "Enter the name of the database you want to Use : "
	read dbName
	cd ~/Bash_project/$dbName 2>> /dev/null	
	if [[ $? == 0 ]] #for checking if database exists or not
	then 	
		echo ""
		echo -e $Green"Connected to $dbName successfully."$DefaultColor
		echo ""
		tables_menu
	else
		echo ""
		echo -e $Red"Database $dbName wasn't found."$DefaultColor
		echo ""
		main_menu
	fi
}

function create_database {
	echo -n "Enter the name of the database : "
	read dbName
	if [[ $dbName != +([a-zA-Z0-9_-]) ]]
	then
		echo -e $Red"Only database names with characters, numbers, (-) and (_) are allowed."$DefaultColor
		create_database
	else

		if ! [[ -d  ~/Bash_project/$dbName ]] 	#for checking if database exists or not 	
		then	
			mkdir -p ~/Bash_project/$dbName	
			echo -e $Green"Database $dbName has been created successfully."$DefaultColor
		else
			echo -e $Red"Error!! database $dbName already exists."$DefaultColor
		fi
		main_menu
	fi
}

function list_databases { 
	cd ~/Bash_project 2>> /dev/null
	if [[ $? == 0 ]]
	then
		echo "******************** Databases **********************"
		echo -e $Green`ls`$DefaultColor
		echo "*****************************************************"  		
		main_menu
	else
		echo -e $Red"There's no any database to list, Try to create one :)"$DefaultColor
		main_menu
	fi
}

function drop_database { 
	echo -n "Enter the name of the database you want to drop : "
	read dbName
	rm -r ~/Bash_project/$dbName 2>> /dev/null	
	if [[ $? == 0 ]]  	
	then
		echo -e $Green"Database $dbName has been dropped successfully."$DefaultColor
	else
		echo -e $Red"Database not found."$DefaultColor
	fi
	main_menu
}

#***************************************************************************************************************************
function tables_menu {
		COLUMNS=12
		select choice in 'Create Table' 'List Tables' 'Drop Table' 'Insert Into Table' 'Select From Table' 'Delete From Table' 'Update Table' 'Back To Main Menu' 'Exit'
		do
		case $REPLY in
			1) clear ; create_table
				;;
			2) clear ; echo "********************* Tables *********************" ; echo -e $Green`ls .`$DefaultColor ; 
			   echo "**************************************************"; tables_menu
				;;
			3) clear ; drop_table
				;;
			4) clear ; insert
				;;
			5) clear ; select_from_table 
				;;
			6) clear ; delete_from_table
				;;
			7) clear ; update
				;;
			8) clear ; main_menu
				;;
			9) clear ; exit
				;;
			*) echo -e $Red"Invaild choice."$DefaultColor; tables_menu
		esac
		done
}

function create_table {
	typeset -i colNum
	echo -n "Enter name of the table : "
	read tableName
	
	if [[ $tableName != +([a-zA-Z0-9_-]) ]] # in MySQL there is no naming conventions on tables, but we made our own convnetions.
	then	
		echo -e $Red"Only use characters, numbers, (-) and (_)."$DefaultColor
	
	elif [[ -f ~/Bash_project/$dbName/$tableName ]] #for checking if it's exist or not 	
	then	
		echo -e $Red"Error table $tableName already exists."$DefaultColor
		create_table
		
	else 
  		metaData="Field"$sep"Type"$sep"key" # used to collect the tuple of data 

		echo -n "Enter the number of columns : "
		read columnNumber

		if [[ $columnNumber != +([0-9]) || $columnNumber -eq 0 ]]
		then
			echo -e $Red"Number is not correct, please enter a positive number"$DefaultColor
			create_table
		else
			for ((i=1; i<=$columnNumber; i++))
			do
				echo -n "Enter column $i Name : "
				read colName
				if [[ $colName != +([a-zA-Z0-9_-]) ]]
				then
					echo -e $Red"Enter a vaild column name."$DefaultColor
					i=$i-1
				elif [[ "$metaData" == *"$colName"* ]]
				then
					echo -e $Red"This column ($colName) already exist."$DefaultColor
					i=$i-1
				else
					echo "Enter column $i Datatype of $colName : "
					select choice in "int" "str"
					do
						case $REPLY in
							1) colDataType="int"
								break
								;;
							2) colDataType="str"
								break
								;;
							*) echo -e $Red"Wrong data type"$DefaultColor
						esac
					done
					
					if [[ $pKey == "" ]]; then
					echo -e "Make PrimaryKey ? "
					
					select var in "yes" "no"
					do
						case $var in
						yes ) pKey="PK";
						metaData+=$rSep$colName$sep$colDataType$sep$pKey;
						break;;
						no )
						metaData+=$rSep$colName$sep$colDataType$sep""
						break;;
						* ) echo "Wrong Choice" ;;
						esac
					done
					else
						metaData+=$rSep$colName$sep$colDataType$sep""
					fi
					if [[ $i == $columnNumber ]]; then
						temp=$temp$colName
					else
						temp=$temp$colName$sep
					fi
				fi
			done
		fi	
		touch .$tableName
		echo -e $metaData  >> .$tableName
		touch $tableName
		echo -e $temp >> $tableName
		if [[ $? == 0 ]]
		then
			clear
			echo -e $Green"Table Created Successfully"$DefaultColor
			tables_menu
		else
			echo -e $Red"Error Creating Table $tableName"$DefaultColor
			tables_menu
		fi			
	fi
}

function drop_table { 
	echo -n "Enter name of the table you want to drop : "
	read tableName
	if [[ -f ~/Bash_project/$dbName/$tableName ]]	
	then
		rm ~/Bash_project/$dbName/$tableName 2>> /dev/null	
		echo -e $Green"Table $dbName has been dropped successfully"$DefaultColor
	else
		echo -e $Red"Table not found"$DefaultColor
	fi
	tables_menu
}

#***************************************************************************************************************************

function insert {
	echo -n "Enter table name : "
	read tableName
	if ! [[ -f ~/Bash_project/$dbName/$tableName ]]	
	then	
		echo -e $Red"Table not found"$DefaultColor
		tables_menu
	fi
	totalLines=`awk 'END{print NR}' ~/Bash_project/$dbName/.$tableName`
	sep="|"
  	rSep="\n"
	typeset -i pk=$i-1

	for ((i=2; i<=$totalLines; i++))
	do	
		fieldName=$(awk -F$sep 'NR=='$i' {print $1}' .$tableName)       # instead of using {if NR=='$i' print $1} use shorthand NR=='$i'
 	    	fieldDataType=$( awk -F$sep 'NR=='$i' {print $2}' .$tableName)
	    	fieldKey=$( awk -F$sep 'NR=='$i' {print $3}' .$tableName)
	    	echo -n "$fieldName ($fieldDataType) = "
	    	read InsertedData

		if [[ $fieldDataType == "int" ]] 
		then
			if [[ $fieldKey != "PK" ]]
			then
      				while [[ $InsertedData != +([\-0-9]) ]]
				do
        				echo -e $Red"Invalid DataType !!"$DefaultColor
	        			echo -n "$fieldName ($fieldDataType) = "
        				read InsertedData
				done
			else
				while [[ $InsertedData -le 0 ]]
				do
        				echo -e $Red"Invalid DataType !!"$DefaultColor
	        			echo -n "$fieldName ($fieldDataType) = "
        				read InsertedData
				done
			fi
		elif [[ $fieldDataType == "str" ]]
		then
			while [[ $InsertedData != +([a-zA-Z0-9_-"\ "]) ]]
			do
				echo -e $Red"Invalid DataType !!"$DefaultColor
	        		echo -n "$fieldName ($fieldDataType) = "
        			read InsertedData
			done
    		fi

		if [[ $fieldKey == "PK" ]] 
		then
		      	while [[ true ]] 
			do	
				typeset -i pk=$i-1
				if [[ $InsertedData == `cut -d"|" -f"$pk" ~/Bash_project/$dbName/$tableName | grep -w "$InsertedData"` ]]
				then
			  		echo -e $Red"Invalid input for Primary Key !!"$DefaultColor
				else
			  		break;
				fi
				echo -n "$fieldName ($fieldDataType) = "
				read InsertedData
		      	done
		fi

			
		if [[ $i == $totalLines ]] 
		then
      			row=$row$InsertedData$rSep
    		else
      			row=$row$InsertedData$sep
    		fi	
	done
	echo -e $row >> $tableName
	if [[ $? == 0 ]]
	then
		echo -e $Green"Data Inserted Successfully"$DefaultColor
	else
	    	echo -e $Red"Error Inserting Data into Table $tableName"$DefaultColor
	fi
	
	row=""
	tables_menu
}

function update {
	echo -n "Enter table name : "
	read tableName
	if ! [[ -f ~/Bash_project/$dbName/$tableName ]]	
	then	
		echo -e $Red"Table not found"$DefaultColor
		tables_menu
	fi
	sep="|"
	
	echo -n "Enter name of condition field : "
	read condition

	typeset -i fieldNumber=$(awk -F$sep '{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$condition'") print i}}}' $tableName 2>> /dev/null)

	if [[ $fieldNumber ==  "" ]]
	then
		echo  -e $Red"cannot find the field"$DefaultColor
		tables_menu
	else
		echo -n "Enter Value of condition field : "
		read value
		
		columnNumber=$(awk -F$sep -v x="$value" '{if ($'$fieldNumber'==x) print $'$fieldNumber'}' $tableName 2>> /dev/null)

		lineNumber=$(awk -F$sep -v x="$value" '{if ($'$fieldNumber'==x) print NR }' $tableName 2>> /dev/null)

		if [[ $columnNumber == "" ]]
		then
			
			echo  -e $Red"cannot find the vaule you entered"$DefaultColor
			tables_menu
		else
				
			echo -n "Enter field name to assign value to it : "
			read field

			newField=$(awk -F$sep '{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tableName 2>> /dev/null) #return column number of field entered by user just in first line that contains attributes name
			typeset -i count
			typeset -i counter 
			count=$(awk -F$sep -v x="$value" '{for(i=1;i<=NF;i++) {if($i==x && i=="'$fieldNumber'") print i} }' $tableName 2>> /dev/null | wc -l)
			if [[ $newField == "" ]]
			then
				echo  -e $Red"cannot find the field"$DefaultColor
				tables_menu
			else
				isKey=$(awk -F$sep '{if($1=="'$field'") print $3}' .$tableName 2>> /dev/null)
				echo -n "Enter new value : "
        			read newValue

				if [[ $isKey == "PK" && $count -eq 1 ]] 
				then
				      	while [[ true ]] 
					do	
						if [[ $newValue == `cut -d"|" -f"$newField" ~/Bash_project/$dbName/$tableName | grep -w $newValue 2>> /dev/null` ]]
						then
					  		echo -e $Red"This value cannot be dublicated, It's a primary key !!"$DefaultColor
						else
					  		break;
						fi
						echo -n "Enter new value again : "
						read newValue
				      	done
					while [[ true ]] 
					do	
						if [[ $newValue != +([a-zA-Z_-"\ "]) && $newValue -le 0 ]]
						then
					  		echo -e $Red"This value cannot be less than one, It's a primary key !!"$DefaultColor
						else
					  		break;
						fi
						echo -n "Enter new value again : "
						read newValue
				      	done
				elif [[ $isKey == "PK" && $count -gt 1 ]]
				then
					echo $count
					echo -e $Red"This value cannot ddddbe dublicated, It's a primary key !!"$DefaultColor
					echo -e $Red"Row hasn't updated!"$DefaultColor
					tables_menu
				fi
				if [[ $count -gt 1 ]]
				then 
					for LN in $lineNumber
					do
						oldValue=$(awk -F$sep '{if(NR=='$LN'){for(i=1;i<=NF;i++){if(i=='$newField') print $i}}}' $tableName 2>> /dev/null)
						sed -i "$LN s/$oldValue/$newValue/g" $tableName 2>> /dev/null
					done
				elif [[ $count -eq 1 ]]
				then
					oldValue=$(awk -F$sep '{if(NR=='$lineNumber'){for(i=1;i<=NF;i++){if(i=='$newField') print $i}}}' $tableName 2>> /dev/null)
					sed -i "$lineNumber s/$oldValue/$newValue/g" $tableName 2>> /dev/null
				fi
				if [[ $? == 0 ]]
				then
					echo -e $Green"Row Updated Successfully."$DefaultColor
				else 
					echo -e $Red"Row hasn't updated!"$DefaultColor
				fi
				tables_menu		
			fi
		fi		
	fi
}

#***************************************************************************************************************************

function select_from_table { 
	COLUMNS=12
	select choice in "Select All Data" "Select records without condition" "Select records with condition" "Back to tables menu" "Back to main menu" "Exit"
	do
	case $REPLY in
	1) clear ; select_all_data
		;;
	2) clear ; select_without_condition
		;;
	3) clear ; select_with_condition
		;;
	4) clear ; tables_menu
		;;
	5) clear ; main_menu
		;;
	6) clear ; exit
		;;
	*) echo -e $Red"Invalid option"$DefaultColor
	esac
	done
}

function select_all_data {
	echo -n "Table name to select from : "
	read tableName
	if [[ -f ~/Bash_project/$dbName/$tableName ]]	
	then
		echo " "
                column -t -s"|" -o"  |  " ~/Bash_project/$dbName/$tableName
		echo " "
	else
		echo -e $Red"Table not found"$DefaultColor
	fi
select_from_table
}
	
function select_without_condition {
	echo -n "Table name to select from : "
	read tableName
	if ! [[ -f ~/Bash_project/$dbName/$tableName ]]
	then
		echo -e $Red"Enter a correct Table Name"$DefaultColor
		select_without_condition
	fi

	typeset -i TotalFields=$(awk -F "|" 'NR==1 {print NF}' ~/Bash_project/$dbName/$tableName)
	echo -n "Number of columns : "
	read NumOfCols
	if [[ NumOfCols -gt 0 && NumOfCols -le $TotalFields ]]
	then
		for ((i=1; i<=$NumOfCols; i++))
		do
			echo -n "Enter $i column : "
			read selectedCols

			typeset -i fieldNum=$(awk -F "|" 'NR==1 {for(i=1; i<=NF; i++) if($i=="'$selectedCols'") print i}' ~/Bash_project/$dbName/$tableName)
			if ! [[ $fieldNum -eq 0 ]]
			then
				echo `cut -f"$fieldNum" -d"|" ~/Bash_project/$dbName/$tableName` >> newfile
			else
				echo -e $Red"Enter a correct name of column."$DefaultColor
				echo -e $Red"Redirect to select with condition option again ..."$DefaultColor
				select_without_condition
			fi
		done
		numCols=`awk '{ if(NR==1) print NF}' newfile`

		for ((j=1; j<=$numCols; j++))
		do
			echo `cut -f"$j" -d" " newfile`
		done
		`rm newfile`

	else
		echo -e $Red"Enter a correct column Name"$DefaultColor
	fi
select_from_table
}


function select_with_condition {
	echo -n "Enter table name : "
	read tableName
	if ! [[ -f ~/Bash_project/$dbName/$tableName ]]	
	then	
		echo -e $Red"Table not found"$DefaultColor
		select_with_condition
	fi
	
	typeset -i TotalFields=$(awk -F$sep 'NR==1 {print NF}' ~/Bash_project/$dbName/$tableName)
	echo -n "Number of columns : "
	read NumOfCols

	if ! [[ NumOfCols -gt 0 && NumOfCols -le $TotalFields ]]
	then
		echo -e $Red"Number of columns you entered is not less than total fields"$DefaultColor
	else
		echo -n "Enter name of condition field : "
		read condition
		fieldNumber=$(awk -F$sep '{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$condition'") print i}}}' $tableName 2>> /dev/null)

		if [[ $fieldNumber ==  "" ]]
		then
			echo  -e $Red"cannot find the field"$DefaultColor
			tables_menu
		else
			echo -n "Enter Value of condition field : "
			read value 
			columnNumber=$(awk -F$sep -v x="$value" '{if ($'$fieldNumber'== x) print $'$fieldNumber'}' $tableName 2>> /dev/null)
			
			if [[ $columnNumber == "" ]]
			then
				
				echo  -e $Red"cannot find the vaule you entered"$DefaultColor
				tables_menu
			else
				if [[ NumOfCols -gt 0 && NumOfCols -le $TotalFields ]]
				then
					for ((i=1; i<=$NumOfCols; i++))
					do
						echo -n "Enter $i selected column name: "
						read selectedCols

						fieldNum=$(awk -F$sep 'NR==1 {for(i=1; i<=NF; i++) if($i=="'$selectedCols'") print i}' ~/Bash_project/$dbName/$tableName)
						if ! [[ $fieldNum -eq 0 ]]
						then
							awk -F$sep 'NR=="1" {print $'$fieldNum'}' $tableName >> newfile
							awk -F$sep -v x="$value" '{for(i=1; i<=NF; i++) if($i==x && i=='$fieldNumber') print $'$fieldNum' }' $tableName >> newfile
							echo `cut -f1 newfile` >> newfile2
							`rm newfile`
						else
							clear
							echo -e $Red"Enter a correct name of column."$DefaultColor
							echo -e $Red"Redirect to select with condition option again ..."$DefaultColor
							select_with_condition
						fi
					done

					numCols=`awk '{ if(NR==1) print NF}' newfile2`
					for ((j=1; j<=$numCols; j++))
					do
						echo `cut -f"$j" -d" " newfile2`
					done
					`rm newfile2`

				else
					echo -e $Red"Enter a correct column Name"$DefaultColor
				fi
			fi
		fi
	fi
	

select_from_table
}

#***************************************************************************************************************************

function delete_from_table {
	select choice in "Delte all records" "Delete with condition"
	do
	case $REPLY in
	1) delete_all_records
		break
		;;
	2) delete_with_condition
	esac
	done	
}

function delete_all_records {
	echo -n "Enter table name : "
	read tableName
	if ! [[ -f ~/Bash_project/$dbName/$tableName ]]	
	then	
		echo -e $Red"Table not found"$DefaultColor
		delete_all_records
	else
		sed -i '2,$d' ~/Bash_project/$dbName/$tableName
		echo -e $Green"All Records Deleted Successfully"$DefaultColor
		tables_menu
	fi
}

function delete_with_condition {
	echo -n "Enter table name to delete from : "
	read tableName
	if ! [[ -f ~/Bash_project/$dbName/$tableName ]]	
	then	
		echo -e $Red"Table not found"$DefaultColor
		delete_with_condition
	fi
	sep="|"
	
	echo -n "Enter name of condition field : "
	read condition

	fieldNumber=$(awk -F$sep '{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$condition'") print i}}}' $tableName 2>> /dev/null)

	if [[ $fieldNumber ==  "" ]]
	then
		echo  -e $Red"cannot find the field"$DefaultColor
		delete_with_condition
	else
		echo -n "Enter Value of condition field : "
		read value
		
		columnNumber=$(awk -F$sep -v x="$value" '{if ($'$fieldNumber'==x) print $'$fieldNumber'}' $tableName 2>> /dev/null)

		lineNumber=$(awk -F$sep -v x="$value" '{if ($'$fieldNumber'==x) print NR }' $tableName 2>> /dev/null)

		if [[ $columnNumber == "" ]]
		then
			
			echo  -e $Red"cannot find the vaule you entered"$DefaultColor
			delete_with_condition
		else
			while [[ $lineNumber != "" ]] 
			do	
				lineNum=$( awk -F$sep -v x="$value" '{if ($'$fieldNumber'==x) print NR }' $tableName | sed -n '1p')
				sed -i "$lineNum d" ~/Bash_project/$dbName/$tableName
				lineNumber=$(awk -F$sep -v x="$value" '{if ($'$fieldNumber'==x) print NR }' $tableName 2>> /dev/null)
		      	done
	
			echo -e $Green"Records Deleted Successfully"$DefaultColor
			tables_menu

		fi
	fi
}


main_menu #to call main menu function at the first run !










