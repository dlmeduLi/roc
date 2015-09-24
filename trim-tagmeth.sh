#!/bin/bash

usage()
{
	echo "usage: `basename $0` tagmethPath"
}

if [ $# != 1 ] 
then
	usage
	exit -1
fi

input_path=$1
if [ ! -d $1 ]
then
	echo "error: file path ${input_path} does not exist"
	exit -1
fi

tagmeth_files=`find ${input_path} -maxdepth 1 -type f | sort -V`
for tagmeth_file in ${tagmeth_files} 
do
	echo "converting ${tagmeth_file} ..."
	chrname=`basename ${tagmeth_file}`
	output_file="${chrname}.tagmeth"

	awk -v chr=${chrname} -v outfile=${output_file} ' 
		function mergePos(pos1, pos2)
		{
			if(pos1 == "NA" && pos2 != "NA")
			{
				ret = pos2;
			}
			else if(pos1 != "NA" && pos2 == "NA")
			{
				ret = pos1;
			}
			else if(pos1 != "NA" && pos2 != "NA")
			{
				ret = pos1","pos2;
			}
			else
			{
				ret = "NA";
			}
		
			return ret;
		}	

		function addCount(count1, count2)
		{
			ret = 0;
		
			if(count1 != "NA")
			{
				ret += count1;
			}

			if(count2 != "NA")
			{
				ret += count2;
			}

			return ret;
		}
	
		NR>1 && $2 != "NA" && $3 != "NA" && $4 !="NA" && !($6 == "NA" && $7 == "NA") && !($10 == "NA" && $11 == "NA" && $14 == "NA" && $15 == "NA"){ 
		tagname=$1; 
		type="P";
		cvt=$16;
		if($15 == "G2A")
		{
			pos=$2 - 1;
		} 
		else 
		{
			pos=$2;
		}
		len = $5 - $2; 
	
		mpos = mergePos($10, $14);
		upos = mergePos($11, $15);	
		xpos = "NA";
	
		mcount = addCount($8, $12);
		ucount = addCount($9, $13);
		xcount = 0;	
		
		printf("%s\t%s\t%s\t%s\t%ld\t%d\t%s\t%s\t%s\t%d\t%d\t%d\n", tagname, type, cvt, chr, pos, len, mpos, upos, xpos, mcount, ucount, xcount) > outfile;}' ${tagmeth_file} 

done
