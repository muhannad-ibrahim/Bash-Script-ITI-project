#!/bin/bash
shopt -s extglob
export LC_COLLATE=C
Red='\033[0;31m'
Green='\033[0;32m'
DefaultColor='\033[0m'

function create_database {
	echo "Enter name of the database : "
	read dbName
	mkdir -p ~/Bash_project/$dbName	
	if [[ $? == 0 ]] #for checking if it's exist or not 	
	then	
		echo "Database $dbName has been created successfully"
	else
		echo "Error database $dbName already exists"
	fi
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
		touch ~/Bash_project/$dbName/$tableName
		echo "Table $tableName has been created successfully"
		echo "Enter the number of columns"
		read columnNumber
		if [[ $columnNumber != +([0-9]) || $columnNumber -eq 0 ]]
		then
			echo "Number is not correct, please enter a positive number"
		else
			for ((i=1; i<$columnNumber; i++))
			do
				echo "Enter column $i Name"
				read colName
				if [[ $colName != +([a-zA-Z0-9_-]) ]]
				then
					echo "Enter a vaild column number"
				else
					echo "Enter column $i Datatype"
					echo -en "$colName:" >> ~/Bash_project/$dbName/$tableName
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
				fi
			done
		fi				
	fi
}

function list_tables { 
	cd ~/Bash_project/$dbName 2>> /dev/null
	if [[ $? == 0 ]]
	then
		ls
	else
		echo "There's no any tables to show, Try to create one :)"
	fi
}

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
}

function list_databases { 
	cd ~/Bash_project 2>> /dev/null
	if [[ $? == 0 ]]
	then
		ls  
	else
		echo "There's no any database to show, Try to create one :)"
	fi
}

function connect_database {
	# Just trial Not the function we want
	echo "Enter name of the database you want to Use: "
	read dbName
	cd ~/Bash_project/$dbName 2>> /dev/null	
	if [[ $? == 0 ]] #for checking if it's exist or not
	then 		
		echo "Connected to $dbName database"
		clear
		select choice in 'Create Table' 'List Tables' 'Drop Table' 'Insert into Table' 'Select From Table' 'Delete From Table' 'Update Table' 'Back' 'Exit'
		do
		case $REPLY in
			1) create_table
				;;
			2) list_tables
				;;
			3) drop_table
				;;
			4) #insert_into_table
				;;
			5) #select_from_table 
				;;
			6) #delete_from_table
				;;
			7) #update_table
				;;
			8) #need to return to main menu
				;;
			9) exit
				;;
			*) echo "Invaild choice"
		esac
		done	
	else
		echo "Database $dbName not exists"
	fi
}

function drop_database { 
	echo "Enter name of the database you want to drop: "
	read dbName
	rm -r ~/Bash_project/$dbName 2>> /dev/null	
	if [[ $? == 0 ]]  	
	then
		echo "Database $dbName has been dropped successfully"
	else
		echo "Database not found"
	fi
}

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
	*) echo "Invaild choice"
esac
done
