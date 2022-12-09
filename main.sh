#!/bin/bash
function create_database {
	echo "Enter name of the database : "
	read dbName
	#if [[ dbName ]] #for checking if it's exist or not 	
	mkdir ~/Bash_project/$dbName
	echo "Database $dbName has been created successfully"
}

function list_databases { 	
	ls -d */
}

function connect_database {
	# Just trial Not the function we want
	echo "Enter name of the database you want to Use: "
	read dbName
	#if [[ dbName ]] #for checking if it's exist or not 	
	cd ~/Bash_project/$dbName
	ls -l
	echo "Connected to $dbName database"	

}

function drop_database { 
	echo "Enter name of the database you want to drop: "
	read dbName
	#if [[ dbName ]] #for checking if it's exist or not 	
	rm -r ~/Bash_project/$dbName
	echo "Database $dbName has been dropped successfully"	

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
