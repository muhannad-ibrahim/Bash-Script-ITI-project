#!/bin/bash
function create_database {
	echo "Enter name of the database : "
	read dbName
	mkdir -p ~/Bash_project/$dbName	
	if [[ $? == 0 ]] #for checking if it's exist or not 	
	then	
		echo "Database $dbName has been created successfully"
	else
		echo "Error database already exists"
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
		#tables_menu #function nedd to be implemented	
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
