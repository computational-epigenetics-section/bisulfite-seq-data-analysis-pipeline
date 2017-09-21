#!/usr/bin/python
####################################################
# Beta, relatively mature
# Bins genomic data into 200 base pair bins
#
# Jack Duryea
# Waterland lab, Baylor College of Medicine
# <duryea@bcm.edu>
####################################################

#####################################################
# Modified by Anthony 9/6/2017
# Small changes for Python 3.5 compatibility
######################################################


from operator import add
import pandas as pd
import numpy as np
import os
import sys
from collections import defaultdict


"""
Input:
1. bin size
2. An unzipped .cov file containing CpG positions (must be in agreement with annotation)
	Must be in the format:["Chr", "Position", "End","Perc","Methy","Not Methy"]

Output:
A .csv file containing CpG methylation percentage for each bin

Pandas must be intalled for this script to run. It is useful to use a python virtual environment 
if running on a cluster.

Usage:
python bin_methylation_py3.py 200 sample.chrY.bismark.cov

Happy binning!

"""

# Finds methylation values for each bin of size bin_size in the coverage file
# Returns a data frame with USCS coordinates for each bin, avg methylation values, bin names (rightmost UCSC coord)
# as well as the number of CpGs in each bin that were covered by bismark
def create_bin_methylation(bin_size, filename):
	df_cov = pd.read_table(filename, header=None)
	cols = ['Chromosome', 'Position', 'End', 'Perc', 'Methylated', 'Unmethylated']
	df_cov.columns = cols
	print(df_cov.columns)
	df_cov = df_cov.ix[:,-6:]

	# Mapping from a bin name to the number of CpGs in the bin
	bin_coverage = defaultdict(lambda:0)
	bin_data = defaultdict(lambda:[0,0]) # Mapping from bin number to a tuple consisting of #methylated reads and #unmethy. reads

	# Go through each CpG, count reads, find bin number, also keep track of how many CpGs are covered in each bin
	for index, line in df_cov.iterrows():
		# Split line into components
		chrm_name = str(line["Chromosome"])
		start = int(line["Position"])
		end = int(line["End"])

		num_methylated_reads = line["Methylated"]
		num_unmethylated_reads = line["Unmethylated"]

		bin_number = (start-1)//bin_size # Using integer division is the key here
		bin_label = (bin_number*bin_size) + bin_size

		bin_data[bin_label] = list(map(add, bin_data[bin_label], [num_methylated_reads,num_unmethylated_reads]))
		bin_coverage[bin_label] += 1

	# Keep track of data for dataframe
	coords = []
	bin_names = []
	methylations = []
	cpgs_covered = []

	# Append bin data do lists so we can add them to the data frame
	sorted_keys = list(bin_data.keys())
	sorted_keys.sort()
	for _bin in sorted_keys:

		# Coordinates
		bin_name = chrm_name + "_" + str(_bin)
		bin_start_loc = _bin - bin_size
		bin_end_loc = _bin
		UCSC_browser_coordinates = chrm_name + ":" + str(bin_start_loc) + "-" +  str(bin_end_loc)

		# Methylation percentage
		bin_methylation_data = bin_data[_bin]
		avg_methylation = 0
		if bin_methylation_data[0]+bin_methylation_data[1] != 0: # Denominator is not 0
			avg_methylation  = 100.0*bin_methylation_data[0]/(bin_methylation_data[0]+bin_methylation_data[1])

		# Append data to lists
		coords.append(UCSC_browser_coordinates)
		bin_names.append(bin_name)
		methylations.append(avg_methylation)
		cpgs_covered.append(bin_coverage[_bin])

	# Create date frame
	dataframe_data = {"UCSC Browser Coordinates":coords,"Bin Name":bin_names,"Avg Methylation":methylations,"CpGs Covered":cpgs_covered}
	return pd.DataFrame.from_dict(dataframe_data)


## Script begins

# Inputs from command linecd
bin_size = int(sys.argv[1]) # E.g. 200
filename = sys.argv[2] #An unzipped .cov file containing CpG positions (must be in agreement with annotation, Must be in the format:["Chr", "Position", "End","Perc","Methy","Not Methy"]

# Checks to see if the input file is an unzipped .cov file
suffix = filename[filename.rfind(".")+1:]
if suffix != "cov":
	sys.exit()

# Get a prefix to name the file
prefix = filename[:filename.rfind(".")]
chrm_name = filename[filename.find("chr"):filename.find(".", filename.find("chr"))]
new_file_name = prefix + "."  + "bins.csv"

# Computes bin data and saves the file
df = create_bin_methylation(bin_size,filename)
rearranged_cols = ["UCSC Browser Coordinates","Bin Name","Avg Methylation","CpGs Covered"]
df = df.reindex_axis(rearranged_cols, axis=1)
df.to_csv(new_file_name)







