#!/bin/bash
workpath=/home/t152427
defpath=/home/t152427/def
ctlpath=/home/t152427/ctl
schema=$1
srcdef_file=$2
srcdef=`echo $srcdef_file | cut -d"." -f1`

#get start and end line numbers between '(' and ')' in table definitions
start_line=`grep -n "^[[:space:]]*(" ${defpath}/$srcdef_file | cut -d: -f1`
end_line=`grep -n "^[[:space:]]*)" ${defpath}/$srcdef_file | cut -d: -f1`
#replacing datatypes
sed -n "$start_line,${end_line}p" ${defpath}/${srcdef_file} > ${defpath}/${srcdef}_T
sed -i '/^[()]/d' ${defpath}/${srcdef}_T
sed -i 's/\([[:space:]]TIMESTAMP\)/ TIMESTAMP(0)/g' ${defpath}/${srcdef}_T
sed -i 's/\([[:space:]]DATE[[:space:]]\)/ TIMESTAMP(0) /g' ${defpath}/${srcdef}_T
sed -i 's/\([[:space:]]SMALLDATETIME\)/ TIMESTAMP(0)/g' ${defpath}/${srcdef}_T
sed -i 's/[[:space:]]TIME[[:space:]]/ DATE FORMAT 'yyyy-mm-dd' /g' ${defpath}/${srcdef}_T
sed -i 's/[[:space:]]TIME,/ DATE FORMAT 'yyyy-mm-dd' ,/g' ${defpath}/${srcdef}_T
sed -i 's/\([[:space:]]CHARACTER(\)/ CHAR(/g' ${defpath}/${srcdef}_T
sed -i 's/\([[:space:]]NUMBER(\)/ DECIMAL(/g' ${defpath}/${srcdef}_T
sed -i 's/\([[:space:]]NUMERIC(\)/ DECIMAL(/g' ${defpath}/${srcdef}_T
sed -i 's/[[:space:]]INT[[:space:]]*,/ INTEGER,/g'  ${defpath}/${srcdef}_T
sed -i 's/[[:space:]]BIT/ BYTEINT/g' ${defpath}/${srcdef}_T
sed -i 's/\([[:space:]]CHAR([0-9]*)\)/\1 CHARACTER SET LATIN NOT CASESPECIFIC/g' ${defpath}/${srcdef}_T
sed -i 's/\([[:space:]]VARCHAR([0-9]*)\)/\1 CHARACTER SET LATIN NOT CASESPECIFIC/g' ${defpath}/${srcdef}_T
sed -i 's/\([[:space:]]MONEY[[:space:]]\)/ DECIMAL(19,4) /g' ${defpath}/${srcdef}_T
sed -i 's/\([[:space:]]TINYINT[[:space:]]\)/ INTEGER /g' ${defpath}/${srcdef}_T

sed -i -e '$s/$/,\n  DW_INSERT_TIMESTAMP TIMESTAMP(0) DEFAULT CURRENT_TIMESTAMP(0),\n  DW_LAST_UPD_TIMESTAMP TIMESTAMP(0) DEFAULT CURRENT_TIMESTAMP(0),\n  DW_BATCH_ID INTEGER/' ${defpath}/${srcdef}_T



table_ct=${defpath}/${srcdef}_ct
cp ${defpath}/table.def $table_ct

sed -i -e "/@col/r ${defpath}/${srcdef}_T" -e "/@col/d" $table_ct
sed -i "s/@tbl/$srcdef/g"  $table_ct
sed -i "s/@schema/$schema/g"  $table_ct
pk=`grep 'PRIMARY KEY[[:space:]]*(\(.*\))' ${defpath}/$srcdef_file | sed 's/.*(\(.*\));*/\1/'`
pk=`echo "$pk" | sed s/[[:space:]]*//g`
sed -i "s/@pk/$pk/g" $table_ct 
