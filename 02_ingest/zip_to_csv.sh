#!/bin/bash
echo ${YEAR:=2021}  # default if YEAR not set
for month in `seq -w 1 12`; do 
   unzip $YEAR$month.zip
   # Unzipped file pattern {random_numbers}_ONTIME_REPORTING.csv
   mv *ONTIME_REPORTING.csv $YEAR$month.csv
   rm $YEAR$month.zip
done
