import pandas as pd
import os
import re
import glob
import csv

DATAPATH = os.getcwd()

filecnt = len([fn for fn in os.listdir("./data/")])
filenames = [str([fn for fn in os.listdir("./data/")][i] for i in range(0, filecnt))]

fqpath = [f"{DATAPATH}/data/" + str([fn for fn in os.listdir("./data/")][i]) for i in range(0, filecnt)]

sampleread = [os.path.splitext(os.path.basename(fqpath[i]))[0].split('.')[0] for i in range(0, len(fqpath))] 
extension = [os.path.splitext(os.path.basename(fqpath[i]))[1].split('.')[1] for i in range(0, len(fqpath))]
full = [f"{sampleread[i]}.{extension[i]}" for i in range(0, len(fqpath))]

reads = []
for i in range(0, len(fqpath)):
    if fqpath[i].split('.f')[0].endswith('_2'):
      reads.append('2')
    else:
      reads.append('1')

sampleID = ['_'.join((sampleread[i].split('_'))[:-1]) for i in range(0, filecnt)]

sampledf = pd.DataFrame({"sample_name":[], "fq":[], "reads":[]})

sampledf["sample_name"] = sampleID
sampledf["fq"] = full
sampledf["full"] = fqpath
sampledf["reads"] = reads

sampledf.to_csv(f"{DATAPATH}/config/samples.csv", index=False)