#!/usr/bin/bash
mkdir database 2> /dev/null #make a directory database which have all databases
cd database #get in database directory
sep=, #declaring var sep to make tables in csv file


function createtable {
	echo *_______________________________________________________________*
	echo what is the name of table you want?"(only name without .csv)"
read tbname
if [ -f "$tbname.csv" ]
       then
	       echo already exist enter another name for table
       elif [ -z "$tbname.csv" ]
       then echo table name cannot be null.
       else
touch $tbname.csv
echo how many columns you want to add?
read colno

for (( i=0 ; i<$colno ;i+=1 ))
do
	
	echo metadata of column $((i+1)) = 
	read val
	metadata[$i]="${val} $sep"


       
done
echo table name is $tbname >> $tbname.csv
echo number of columns are $colno >> $tbname.csv
echo columns names are  ${metadata[*]} >> $tbname.csv
echo ${metadata[*]} >> $tbname.csv
fi
connecttoDB
}
function listtables  {
	echo *_______________________________________________________________*
ls
connecttoDB
}
#list data of specific table
function listtable {
	echo *_______________________________________________________________*
	echo which table you want to list? "(only name without .csv)"
read tb 2> /dev/null
if [ -f "$tb.csv" ]
       then
awk -F,  '{print $0}' $tb.csv
else 
	echo $tb is not a table 
fi
connecttoDB
}

#delete tables from database using pkey
function droptables {
	echo *_______________________________________________________________*
	echo which table you want to drop?"(only name without .csv)"
read tb
if [ -f "$tb.csv" ]
       then

rm $tb.csv
else
	echo $tb not a table 2> /dev/null
fi

}

#insert records to tables with unique pkey
function inserttotable {
	echo *_______________________________________________________________*
	echo which table you want to insert to?"(only name without .csv)"
read tb
if [ -f "$tb.csv" ]
       then

colno=`awk -F, 'END {print NF}' $tb.csv`
echo how many rows do you want?
read rows
for (( i=0; i<$rows ;i+=1))
do
	for (( j=0; j<$colno-1 ; j+=1 ))
	do
		 if [[ j -eq 0 ]]
		     then echo enter primary key in first column
                     echo data of column $((j+1)) =
typeset -i coldt
typeset -i ch
		    
	       	while  [ true ]
			do 
				read coldt
				case $coldt in
                               *[0-9]*)

				ch=0
				ch=`awk -F, '{if ($1=='$coldt'){ print $1 }}' $tb.csv`

				if test $ch -ne $coldt
				then data[$j]="${coldt} $sep"

					break
				else    echo primary key must be unique!
                               #read coldt
		       fi
	 ;;
                   *) echo not valid primary key enter only numbers
                           ;;
           esac
	       
  done
	    
   else
		echo enter data of column $((j+1))
		read dt
		data[$j]="${dt} $sep"
	fi		
          done
echo  ${data[*]} >> $tb.csv
done
if test  $? == 0 
then
	echo data added successfully
else
	echo couldn\'t add this data please try again
fi
else echo $tb not a table 2> /dev/null
fi
connecttoDB
}
#display data of specific record by pkey 
function selectfromtable {
	echo *_______________________________________________________________*
	echo which table you want to select from ?"(only name without .csv)"
read tb
if [ -f "$tb.csv" ]
       then

echo which row do you want? please enter primary key of this table
read row
clear
echo your selection is:
echo *_______________________________________________________________*
awk -F, '{{if(($1=='$row')){print $0 }}}' $tb.csv
echo *_______________________________________________________________*
else 
	echo $tb not a table 2> /dev/null
fi
connecttoDB
}
#delete records from table by pkey
function deletefromtable {
	echo *_______________________________________________________________*
	echo which table do you want to delete from?"(only name without .csv)"
read tb
if [ -f "$tb.csv" ]
       then

echo enter primary key of which row you want to delete
read pk
row=`awk -F, '{{if(($1=='$pk')){print NR}}}' $tb.csv`
sed -i ''$row'd' $tb.csv
echo line $row deleted successfully
else
	echo $tb not a table 
fi
connecttoDB
}
#declare which database to connect to
function whichdb {
	echo *_______________________________________________________________*
echo which database you want to connect to?
read 
if [ -d $REPLY ]
then cd $REPLY
	connecttoDB
else 2> /dev/null
echo not a database, please insert a valid database! 
#menu
fi
}
function connecttoDB {
	echo *_______________________________________________________________*
        echo menu:
        PS3="your choice is:"
	
select table in "Create table" "List tables"  "List specified table" "Drop tables" "Insert into table" "Select from table" "Delete from table" "back to main menu"
do
        case $table in
                "Create table") createtable
                        ;;
                "List tables") listtables
                        ;;
		"List specified table")listtable
			;;
                "Drop tables")droptables
                        ;;
                "Insert into table")inserttotable
                        ;;
                "Select from table")selectfromtable
                        ;;
                "Delete from table")deletefromtable
                        ;;
                "back to main menu")cd ..
			menu
                        ;;
                *)echo not valid coice
                        ;;
 esac
done

}
function createDB {
	echo *_______________________________________________________________*
echo enter database name to be created
read db
if [ -d "$db" ]
       then
       echo "$db already exists"
       echo $db cannot be created

       else  
	mkdir $db
echo $db database has been created successfully
fi
}
function listDB {	
	echo *_______________________________________________________________*
	ls  
}
function dropDB {
	echo *_______________________________________________________________*
echo which database you want to drop?
read
if test `ls $REPLY 2> /dev/null`==0
then
rmdir $REPLY 2> /dev/null
else
	rm -r $REPLY 2> /dev/null
fi
if  test  $? == 0 
then
echo $REPLY has been droped
else
	
	echo $REPLY cannot be dropped
fi

}
echo main menu:
PS3="your choise is:"
function menu {
	clear
	echo *_______________________________________________________________*
	echo main menu:
select choice in "Create DataBase" "List DataBases" "Connect To DataBase" "Drop DataBase" "exit" 
do
	echo *_______________________________________________________________*
	case $choice in
		"Create DataBase")  createDB
			;;
		"List DataBases") listDB
			;;
		"Connect To DataBase") whichdb
			;;
		"Drop DataBase") dropDB
                        ;;
		"exit") exit
			;;
		*)echo not valid choice
			;;
	esac
	
done
}
menu


