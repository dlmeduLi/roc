#!/bin/bash

usage()
{
	echo "usage: `basename $0` tagmethPath refseqPath"
}

if [ $# != 2 ]
then
	usage
	exit -1
fi 

tagmeth_path=$1
if [ ! -d $1 ]
then
	echo "error: tagmeth path \"$1\" does not exist."
	exit -1
fi

refseq_path=$2
if [ ! -d $2 ]
then
	echo "error: refseq path \"$2\" does not exist."
	exit -1
fi

script_path=`dirname $0`
randomtag_cmd="${script_path}/randomtag.py"
tagmeth_files=`find ${tagmeth_path} -maxdepth 1 -type f -name *.tagmeth`
for tagmeth_file in ${tagmeth_files} 
do
	chrname=`basename ${tagmeth_file}`
	chrname=${chrname%.*}
	refseq_file="${refseq_path}/${chrname}.fa"
	if [ ! -f ${refseq_file} ]
	then
		echo "warning: refseq file \"${refseq_file}\" does not exist."
	else	
		echo "randomizing ${tagmeth_file}..."
		CMD="${randomtag_cmd} ${tagmeth_file} ${chrname} ${refseq_file} -o ./${chrname}.random.tagmeth"
		${CMD}
	fi
done
