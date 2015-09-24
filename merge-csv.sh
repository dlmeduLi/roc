#!/bin/bash

usage()
{
	echo "`basename $0` result-path"
}

if [ $# != 1 ]
then
	usage
	exit -1	
fi

result_path=$1
if [ ! -d ${result_path} ]
then
	echo "error: path ${result_path} does not exist!"
	exit -1
fi 

sample_paths=`find ${result_path} -maxdepth 1 -type d -not -name .`
for sample_path in ${sample_paths}
do
	sample=`basename ${sample_path}`
	echo "processing sample ${sample} ..."	
	
	# merge csv files
	
	asm_csv_file="${sample}.asm.csv"
	rm -f "${asm_csv_file}"
	find ${sample_path} -maxdepth 1 -type f -name "*.csv" | sort -V | xargs -I {} cat {} >> ${asm_csv_file}
	
	# merge meth wig files

	# meth_wig_file="${sample}.idx.meth.wig"
	# rm -f "${meth_wig_file}"
	# find ${sample_path} -maxdepth 1 -type f -name "*.idx.meth.wig" | sort -V | xargs -I {} cat {} >> ${meth_wig_file}
	
	# umeth_wig_file="${sample}.idx.umeth.wig"
	# rm -f "${umeth_wig_file}"
	# find ${sample_path} -maxdepth 1 -type f -name "*.idx.umeth.wig" | sort -V | xargs -I {} cat {} >> ${umeth_wig_file}

done


