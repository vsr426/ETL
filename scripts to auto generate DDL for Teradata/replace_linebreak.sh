#!/bin/bash
filenm=$1
delcnt=$2
newline=''
echo "File Name $filenm"
echo "Actual Delimiter count $delcnt"
count=0
while read line
do
	cnt=$((`echo "$line" | sed 's/[^~]//g' | wc -c`))
	if [ $cnt == $delcnt ]
	then
	count=$(($count+1))
	echo "Line Number $count looks good"
	echo "Line NUmber : $count   --> $$line"
	echo "$line" >> ${filenm}_new
	newline=''
	else
	count=$(($count+1))
	newline=`echo "$newline$line"`
	echo "Line NUmber : $count   --> $newline"
		newcnt=$((`echo "$newline" | sed 's/[^~]//g' | wc -c`))
		#echo $$newcnt
		if [ $newcnt == $delcnt ]
		then
		echo "$newline" >> ${filenm}_new
		newline=''
		else
		echo "Line Number $count has new line character will me merged with next line"
		fi
fi
done < $filenm