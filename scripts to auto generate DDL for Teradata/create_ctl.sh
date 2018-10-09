#!/bin/bash
workpath=/home/t152427
defpath=/home/t152427/def
ctlpath=/home/t152427/ctl
filenm=$1
if [ $2 == "insert" ]
then
template=ctl_template_insert.txt
else 
template=ctl_template_merge.txt
fi
#get start and end line numbers between '(' and ')' in table definitions

start_line=`grep -n "^(" ${defpath}/$filenm | cut -d: -f1`
end_line=`grep -n "^)" ${defpath}/$filenm | cut -d: -f1`
#replacing datatypes to VARCHAR type
sed -n "$start_line,${end_line}p" ${defpath}/${filenm} > ${defpath}/${filenm}_1
sed -i s/"CHARACTER SET LATIN NOT CASESPECIFIC"//g ${defpath}/${filenm}_1
sed -i s/"CHARACTER SET UNICODE NOT CASESPECIFIC"//g ${defpath}/${filenm}_1
sed -i s/"[[:space:]]CHAR("/" VARCHAR("/g  ${defpath}/${filenm}_1 
sed -i s/"[[:space:]]INTEGER"/" VARCHAR(10)"/g  ${defpath}/${filenm}_1 
sed -i s/"[[:space:]]NOT NULL"/""/g ${defpath}/${filenm}_1 
sed -i s/"[[:space:]]NULL"/""/g ${defpath}/${filenm}_1
sed -i s/"[[:space:]]TIMESTAMP(0)"/" VARCHAR(19)"/g ${defpath}/${filenm}_1 
sed -i s/"[[:space:]]TIMESTAMP(6)"/" VARCHAR(26)"/g ${defpath}/${filenm}_1 
sed -i s/"[[:space:]]TIMESTAMP(3)"/" VARCHAR(26)"/g ${defpath}/${filenm}_1
sed -i s/"[[:space:]]BYTEINT"/" VARCHAR(1)"/g ${defpath}/${filenm}_1 
sed -i s/"[[:space:]]*[^_]DATE[^_]"/" VARCHAR(10)"/g ${defpath}/${filenm}_1
sed -i /"DW_INSERT_TIMESTAMP"/d ${defpath}/${filenm}_1
sed -i /"DW_LAST_UPD_TIMESTAMP"/d ${defpath}/${filenm}_1

while read line
do
echo $line
check_string=`echo "$line" | grep "DECIMAL"`
if [  ! -z "$check_string" ] 
then
echo "Decimal type column:$line:"
expstring=`echo "$line" | sed "s/^.*DECIMAL(\([0-9]*\),*[[:space:]]*[0-9]*).*$/\1/g" `
echo " Decinal type lenth :$expstring:"
expval=`echo "${expstring}+1 " | bc`
echo " Decinal type lenth : $expval "
echo "$line" |  sed "s/DECIMAL(\([0-9]*\),*[[:space:]]*[0-9]*)/VARCHAR(${expval})/g" >> ${defpath}/${filenm}_def
else
echo $line >> ${defpath}/${filenm}_def
fi
done < ${defpath}/${filenm}_1;

sed -i s/"^[()]"/""/g ${defpath}/${filenm}_def 
sed -i '1d;$d' ${defpath}/${filenm}_def
#create control fil eand update the definition
ctl_fl_nm=${filenm}.ctl
cp $template ${ctlpath}/${ctl_fl_nm}
sed -i -e "/@def/r ${defpath}/${filenm}_def" -e "/@def/d" ${ctlpath}/${ctl_fl_nm}
sed s/"[[:space:]]*VARCHAR([0-9,]*[)]"/""/g ${defpath}/${filenm}_def > ${defpath}/${filenm}_ins

#prepare the update query
cp ${defpath}/${filenm}_ins ${defpath}/${filenm}_upd

#prepare the whre clause
where=`grep 'UNIQUE PRIMARY INDEX\([[:space:]]*\)(\(.*\))' ${defpath}/$filenm | sed 's/.*(\(.*\));*/\1/'`
where_1=`echo $where | sed 's/[[:space:]]*//g' | awk -F"," 'BEGIN {OFS="=:"}  {for(i=1;i<=NF;i++)if(length($i) != 0) print $i,$i}'`
where_2=`echo $where_1 | sed 's/[[:space:]]/ and /g'`

echo "where:$where:"
echo "where_1:$where_1:"
echo "where_2:$where_2:"
#Remove PK columns from update set clause 
set -a $where
for i in $where
do
echo "i in where :$i:"
j=`echo $i | sed s/[[:space:]]*$//g | sed s/[[:space:]]*,[[:space:]]*//g`
echo "j in where :$j:"
sed -i s/^$j[[:space:]]*,// ${defpath}/${filenm}_upd
done
sed -i '/^[[:space:]]*$/d' ${defpath}/${filenm}_upd
sed -i '/^$/d' ${defpath}/${filenm}_upd

sed   -i 's/\(^[A-Z_]*\)/\1 = :\1/g'  ${defpath}/${filenm}_upd
#Update control file with Update, insert defintions
sed -i -e "/@upd/r ${defpath}/${filenm}_upd" -e "/@upd/d" ${ctlpath}/${ctl_fl_nm}
sed -i -e "/@ins/r ${defpath}/${filenm}_ins" -e "/@ins/d" ${ctlpath}/${ctl_fl_nm}
sed -i  's/\(^[A-Z_]*\)/:\1/g' ${defpath}/${filenm}_ins
sed -i -e "/@val/r ${defpath}/${filenm}_ins" -e "/@val/d" ${ctlpath}/${ctl_fl_nm}

#replacing table name
sed -i s/@tbl/${filenm}_mv/g ${ctlpath}/${ctl_fl_nm}
#Upate  where clasue to include with PK columns
sed -i s/@whr/"$where_2"/g ${ctlpath}/${ctl_fl_nm}

rm  ${defpath}/${filenm}_1 ${defpath}/${filenm}_def ${defpath}/${filenm}_ins ${defpath}/${filenm}_upd
 

