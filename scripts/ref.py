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

names = os.path.splitext(fasta[0])[0].split('/')[-1]

afiles = ('./genome/*.gtf', './genome/*.gff3', './genome/*.gff') # the tuple of file types

annotation = []
for files in afiles:
    annotation.extend(glob.glob(files))

a = annotation[0]

if a.endswith('gtf'):
    os.rename(a, f'./genome/{names}.gtf')
elif a.endswith('gff3'):
    os.rename(a, f'./genome/{names}.gff3')
elif a.endswith('gff'):
    os.rename(a, f'./genome/{names}.gff')

new = ('./genome/*.gtf', './genome/*.gff3', './genome/*.gff') # the tuple of file types

annotation = []
for files in new:
    annotation.extend(glob.glob(files))

refdf = pd.DataFrame({"name": [], "fa":[], "annot":[]})

refdf["name"] = [names]
refdf["fa"] = fasta
refdf["annot"] = annotation

refdf.to_csv(f"{DATAPATH}/config/genome.csv", index=False)