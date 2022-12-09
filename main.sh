#!/bin/bash
function create_database {
	echo "Enter name of the database : "
	read dbName
	#if [[ dbName ]] #for checking if it's exist or not 	
	mkdir ~/Bash_project/$dbName
	echo "Database has been created successfully"
}
select choice in 'Create Database' 'List Databases' 'Connect To Database' 'Drop Databse' 'Exit'
do
case $REPLY in
	1) create_database
		;;
	2) #list_database
		;;
	3) #connect_database
		;;
	4) #drop_databse
		;;
	5) exit 
		;;
	*) echo "Invaild choice"
esac
done
	
