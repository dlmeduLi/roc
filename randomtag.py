#!/usr/bin/env python

from __future__ import print_function

import re
import os
import os.path
import optparse
import sys
import pysam

def main():

	# parse the command line options

	usage = 'usage: %prog [options] input.tagmeth chr chr.fa -o random.tagmeth'
	parser = optparse.OptionParser(usage=usage, version='%prog 0.1.0')
	parser.add_option('-o', '--output-file', dest='outputfile',
						help='write the result to output file')
	
	(options, args) = parser.parse_args()
	if(len(args) != 3):
		parser.print_help()
		sys.exit(0)
	
	inputFileName = args[0]
	chrname = args[1]
	refSeqFileName = args[2]
	baseFileName = os.path.splitext(os.path.basename(inputFileName))[0]
	outputFileName =  'random.' + baseFileName + '.tagmeth'
	logFileName = baseFileName + '.tagmeth.log'

	# load input files

	print('[*] Initializing...')

	if(not os.path.exists(inputFileName)):
		print('error: Failed to open file "', inputFileName, '"')
		sys.exit(-1)
	
	if(not os.path.exists(refSeqFileName)):
		print('error: Reference sequence file "', refSeqFileName, '"', ' doest not exist.')
		sys.exit(-1)

	# prepare output files

	if(options.outputfile):
		outputFileName = options.outputfile
	try:
		outputFile = open(outputFileName, 'w')
	except IOError:
		print('error: write to output file failed!')
		sys.exit(-1)

	# load reference sequence

	refSeq = ''
	with open(refSeqFileName, 'r') as refSeqFile :
		for line in refSeqFile:
			if(line[0] == '>'):
				continue

			refSeq += line.strip().upper()
	refSeqFile.close()

	# analyse algnments

	print('[*] Analyzing...')
	

	print('[*] Complete')

if __name__ == '__main__':
	main()
