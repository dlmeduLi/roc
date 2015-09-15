#!/usr/bin/env python

from __future__ import print_function

import re
import os
import os.path
import optparse
import sys
import csv
import random

def FormatPosList(posList):
	if(len(posList) == 0):
		return 'NA'
	return ','.join(map(str, posList))


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
	
	# build CG list
	# CG list format {pos:[[tagindex, offsetindex]]}
	
	dictCG = {str(m.start() + 1) :[] for m in re.finditer('CG', refSeq)}

	# analyse tags

	print('[*] Loading and parsing tagmeth...')

	# tagmeth data structure 
	# tagitem = ['tagname', 'type', 'cvt', 'chr', pos, len, meth=[[25, 'M'], [35, 'U'], ['45', 'X']]]
	#
	tagmeth = []
	with open(inputFileName, 'rb') as csvfile :
		tags = csv.reader(csvfile, delimiter = '\t')
		# next(tags, None)  # skip the headers
		index = 0
		for tag in tags:
			posList = []

			# parse tag positions 
			
			if(tag[6] != 'NA' ):
				poses = tag[6].split(',')
				posList += [[int(p), 'M'] for p in poses]

			if(tag[7] != 'NA'):
				poses = tag[7].split(',')
				posList += [[int(p), 'U'] for p in poses]

			if(tag[8] != 'NA'):
				poses = tag[8].split(',')
				posList += [[int(p), 'X'] for p in poses]

			del tag[6:12]
			tag.append(posList)

			# register the tag

			basePos = int(tag[4])
			basePos -= 1
			tag[4] = basePos
			offsetIndex = 0
			for pos in posList:
				abPos = str(pos[0] + basePos)
				if(abPos in dictCG):
					dictCG[abPos].append([index, offsetIndex])
				else:
					abPos = str(pos[0] + basePos - 1)
					if(abPos in dictCG):
						tag[4] = basePos - 1
						dictCG[abPos].append([index, offsetIndex])
					else:
						print('warning: can not find cg position ', abPos, ' in cg list', tag)
				offsetIndex += 1

			tagmeth.append(tag)
			index += 1

	# shuffle cg methylation states

	for cgPos, tagList in dictCG.iteritems():
		
		# gather methylation state list

		listMeth = []
		for tag in tagList:
			tagItem = tagmeth[tag[0]]
			listMeth += [tagItem[6][tag[1]][1]]
	
		# shuffle meth states
		
		random.shuffle(listMeth)
		
		# assign them back
		
		mIndex = 0
		for tag in tagList:
			tagItem = tagmeth[tag[0]]
			tagItem[6][tag[1]][1] = listMeth[mIndex]
			mIndex += 1

	# write out the results

	for tagItem in tagmeth: 
		meth = []
		unmeth = []
		undt = []
		for m in tagItem[6] : 
			if (m[1] == 'M'):
				meth += [m[0]]
			elif (m[1] == 'U'):
				unmeth += [m[0]]
			elif (m[1] == 'X'):
				undt += [m[0]]

		outputFile.write('%s\t%s\t%s\t%s\t%15ld\t%s\t%s\t%s\t%s\t%d\t%d\t%d\n' % (tagItem[0], tagItem[1], tagItem[2], 
			tagItem[3], tagItem[4], tagItem[5], 
			FormatPosList(meth), 
			FormatPosList(unmeth), 
			FormatPosList(undt),
			len(meth), len(unmeth), len(undt)))

	print('[*] Complete')

if __name__ == '__main__':
	main()
