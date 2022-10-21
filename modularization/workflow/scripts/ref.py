import pandas as pd
import os
import re
import glob
import csv

DATAPATH = os.getcwd()

filecnt = len([fn for fn in os.listdir("./genome/")])

fafiles = ('./genome/*.fa', './genome/*.fasta') # the tuple of file types
fasta = []
for files in fafiles:
    fasta.extend(glob.glob(files))

names = os.path.splitext(glob.glob('./generef/*')[0])[0].split('/')[-1]

afiles = ('./genome/*.gtf', './genome/*.gff3', './genome/*.gff') # the tuple of file types
annotation = []
for files in afiles:
    annotation.extend(glob.glob(files))

refdf = pd.DataFrame({"name": [], "fa":[], "annot":[]})

refdf["name"] = names
refdf["fa"] = fasta
refdf["annot"] = annotation

refdf.to_csv(f"{DATAPATH}/config/genome.csv", index=False)