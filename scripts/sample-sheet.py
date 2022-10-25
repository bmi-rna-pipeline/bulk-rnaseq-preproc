import pandas as pd
import os
import re
import glob
import csv

DATAPATH = os.getcwd()

filecnt = len([fn for fn in os.listdir("./data/")])
filenames = [str([fn for fn in os.listdir("./data/")][i] for i in range(0, filecnt))]

list = ['./data/*.fastq.gz', './data/*.fq.gz', './data/*.fastq', './data/*.fq']
ext = ['fastq.gz', 'fq.gz', 'fastq', 'fq']

extension = []
fqfiles = []
for f in list:
  fqfiles.extend(glob.glob(f))

for fq in fqfiles:
  for n in range(0, 3):
    if fq.endswith(ext[n]):
      extension.append(ext[n])

sampleread = [os.path.splitext(os.path.basename(fqfiles[i]))[0].split('.')[0] for i in range(0, len(fqfiles))] 

fq = [os.path.splitext(fqfiles[i])[0].split('.') for i in range(0, len(fqfiles))]

full = [f"{sampleread[i]}.{extension[i]}" for i in range(0, len(fqfiles))]

reads = []
for i in range(0, len(fqfiles)):
    if fqfiles[i].split('.f')[0].endswith('_2'):
      reads.append('2')
    else:
      reads.append('1')

sampleID = [(sampleread[i]).split('_')[0] for i in range(0, len(fqfiles))]

sampledf = pd.DataFrame({"sample_name":[], "fq":[], "reads":[], "ext": []})

sampledf["sample_name"] = sampleID
sampledf["fq"] = full
sampledf["full"] = fqfiles
sampledf["reads"] = reads
sampledf["ext"] = extension

sampledf.to_csv(f"{DATAPATH}/config/samples.csv", index=False)