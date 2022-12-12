#!/bin/bash
shopt -s extglob
export LC_COLLATE=C
Red='\033[0;31m'
Green='\033[0;32m'
DefaultColor='\033[0m'

function main_menu {
	select choice in 'Create Database' 'List Databases' 'Connect To Database' 'Drop Databse' 'Exit'
	do
	case $REPLY in
		1) create_database
			;;
		2) list_databases
			;;
		3) connect_database
			;;
		4) drop_database
			;;
		5) exit 
			;;
		*) echo -e $Red"Invaild choice"$DefaultColor
	esac
	done
}

function connect_database {
	echo "Enter name of the database you want to Use: "
	read dbName
	cd ~/Bash_project/$dbName 2>> /dev/null	
	if [[ $? == 0 ]] #for checking if it's exist or not
	then 		
		echo -e $Green"Connected to $dbName successfully"$DefaultColor
		tables_menu
	else
		echo -e $Red"Database $dbName wasn't found"$DefaultColor
		main_menu
	fi
}

function create_database {
	echo "Enter name of the database : "
	read dbName
	mkdir -p ~/Bash_project/$dbName	
	
	if [[ $? == 0 ]] 	#for checking if it's exist or not 	
	then	
		echo -e $Green"Database $dbName has been created successfully"$DefaultColor
	else
		echo -e $Red"Error database $dbName already exists"$DefaultColor
	fi
	main_menu
}

function list_databases { 
	cd ~/Bash_project 2>> /dev/null
	if [[ $? == 0 ]]
	then
		echo -e $Green`ls`$DefaultColor  		
		main_menu
	else
		echo -e $Red"There's no any database to show, Try to create one :)"$DefaultColor
		main_menu
	fi
}

function drop_database { 
	echo "Enter name of the database you want to drop: "
	read dbName
	rm -r ~/Bash_project/$dbName 2>> /dev/null	
	if [[ $? == 0 ]]  	
	then
		echo -e $Green"Database $dbName has been dropped successfully"$DefaultColor
	else
		echo -e $Red"Database not found"$DefaultColor
	fi
	main_menu
}
#******************************************************************************************
function tables_menu {
		select choice in 'Create Table' 'List Tables' 'Drop Table' 'Insert into Table' 'Select From Table' 'Delete From Table' 'Update Table' 'Back' 'Exit'
		do
		case $REPLY in
			1) create_table
				;;
			2) echo "*************" ; echo -e $Green`ls .`$DefaultColor ; echo "*************"; tables_menu
				;;
			3) drop_table
				;;
			4) insert
				;;
			5) #select_from_table 
				;;
			6) #delete_from_table
				;;
			7) #update_table
				;;
			8) clear ; main_menu
				;;
			9) exit
				;;
			*) echo -e $Red"Invaild choice"$DefaultColor; tables_menu
		esac
		done
}

function create_table {
	typeset -i colNum
	echo "Enter name of the table : "
	read tableName
	
	if [[ $tableName != +([a-zA-Z0-9_-]) ]] # in MySQL there is no naming conventions on tables we can remove this check
	then	
		echo "Only use characters, numbers dash and underscore"
	
	elif [[ -f ~/Bash_project/$dbName/$tableName ]] #for checking if it's exist or not 	
	then	
		echo "Error table $tableName already exists"
	
	else 
		sep="|" 							# used to be the seperator between data  
  		rSep="\n"							# used to new line 	
  		pKey="" 							# used to be primary key
  		metaData="Field"$sep"Type"$sep"key" # used to collect the tuple of data 

		echo "Enter the number of columns"
		read columnNumber

		if [[ $columnNumber != +([0-9]) || $columnNumber -eq 0 ]]
		then
			echo "Number is not correct, please enter a positive number"
		
		else
			for ((i=1; i<=$columnNumber; i++))
			do
				echo "Enter column $i Name"
				read colName
				if [[ $colName != +([a-zA-Z0-9_-]) ]]
				then
					echo "Enter a vaild column name"
				else
					echo "Enter column $i Datatype of $colName"
					select choice in "str" "int"
					do
						case $REPLY in
							1) colDataType="str"
								break
								;;
							2) colDataType="int"
								break
								;;
							*) echo "Wrong data type"
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
			echo "Table Created Successfully"
			tables_menu
		else
			echo "Error Creating Table $tableName"
			tables_menu
		fi			
	fi
}

#function list_tables { 
#	cd ~/Bash_project/$dbName 2>> /dev/null
#	if [[ $? == 0 ]]
#	then
#		ls
#	else
#		echo "There's no any tables to show, Try to create one :)"
#	fi
#}

function drop_table { 
	echo "Enter name of the table you want to drop: "
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

function insert {
	echo "Enter table name: "
	read tableName
	if ! [[ -f ~/Bash_project/$dbName/$tableName ]]	
	then	
		echo -e $Red"Table not found"$DefaultColor
		tables_menu
	fi
	totalLines=`awk 'END{print NR}' .$tableName`
	sep="|"
  	rSep="\n"

	for ((i=2; i<=$totalLines; i++))
	do	
		fieldName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' .$tableName)
	    	fieldType=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' .$tableName)
	    	fieldKey=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $3}' .$tableName)
	    	echo -e "$fieldName ($fieldType) = "
	    	read data

		if [[ $fieldType == "int" ]] 
		then
      			while ! [[ $data =~ ^[0-9]*$ ]]
			do
        			echo -e $Red"invalid DataType !!"$DefaultColor
	        		echo -e "$fieldName ($fieldType) = "
        			read data
			done
		elif [[ $fieldType == "str" ]]
		then
			while ! [[ $data = +([a-zA-Z0-9_-]) ]]
			do
				echo -e $Red"invalid DataType !!"$DefaultColor
	        		echo -e "$fieldName ($fieldType) = "
        			read data
			done
    		fi

		if [[ $fieldKey == "PK" ]] 
		then
		      	while [[ true ]] 
			do
				if [[ $data =~ ^[`awk 'BEGIN{FS="|" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' $tableName`]$ ]]
				then
			  		echo -e $Red"invalid input for Primary Key !!"$DefaultColor
				else
			  		break;
				fi
				echo -e "$fieldName ($fieldType) = "
				read data
		      	done
		fi

			
		if [[ $i == $totalLines ]] 
		then
      			row=$row$data$rSep
    		else
      			row=$row$data$sep
    		fi	
	done
	echo -e $row >> $tableName
	if [[ $? == 0 ]]
	then
		echo $Green"Data Inserted Successfully"$DefaultColor
	else
	    	echo $Red"Error Inserting Data into Table $tableName"$DefaultColor
	fi
	
	row=""
	tables_menu
}




main_menu
