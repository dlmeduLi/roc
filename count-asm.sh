#!/bin/bash

usage()
{
	echo "`basename $0` annotated-asm-path"
}

if [ $# != 1 ]
then
	usage
	exit -1
fi

asm_path=$1
if [ ! -d ${asm_path} ] 
then
	echo "asm file path ${asm_path} does not exist"
	exit -1
fi

out_file=`basename ${asm_path}`".stats.csv"
echo "sample	asm	repeat	imprint" > ${out_file}
asm_files=`find ${asm_path} -maxdepth 1 -type f -name "*.annotated.csv" | sort -V`
for asm_file in ${asm_files}
do
	echo "processing ${asm_file} ..."
	asm_count=`grep ASM ${asm_file} | wc -l`
	repeat_count=`grep REPEAT ${asm_file} | wc -l`
	imprint_count=`grep IMPRINTED ${asm_file} | awk '{print $6}' | uniq | wc -l`
	echo `basename ${asm_file}` ${asm_count} ${repeat_count} ${imprint_count} >> ${out_file}
done
