import os
from os.path import isfile, join, dirname, abspath

def getSample():
    targets = list()
    if ENDS == "PE":
        for n in range(0, len(SAMPLES)):
            targets.append(f"{DATAPATH}/data/{SAMPLES[n]}_1.fastq.gz {DATAPATH}/data/{SAMPLES[n]}_2.fastq.gz")
    else:
        for n in range(0, len(SAMPLES)):
            targets.append(f"{DATAPATH}/data/{SAMPLES[n]}_SE.fastq.gz")
    return targets

def readsSample():
    targets = list()
    if ENDS == "PE":
        for n in range(0, len(SAMPLES)):
            targets.append(f" --reads {DATAPATH}/02_trimmomatic/{SAMPLES[n]}_1.fastq.gz --reads {DATAPATH}/02_trimmomatic/{SAMPLES[n]}_2.fastq.gz")
    else:
        for n in range(0, len(SAMPLES)):
            targets.append(f" --reads {DATAPATH}/02_trimmomatic/{SAMPLES[n]}_SE.fastq.gz")
    return targets

def searchdb(path):
    dbfiles = list()
    DB = [f for f in os.listdir(path) if isfile(join(path, f))]
    for i in range(0, len(DB)):
        dbfiles.append(f"{path}/{DB[i]}")
    return dbfiles

def getRef():
    targets = list()
    for n in range(0, len(ref)):
        targets.append(f" --ref {ref[n]}")
    return targets

def starIn():
    targets = list()
    if config['sortmeRNA'] == True:
        if ENDS == "PE":
            for n in range(0, len(SAMPLES)):
                targets.append(f"03_sortmeRNA/unaligned/{SAMPLES[n]}_1.fastq.gz 03_sortmeRNA/unaligned/{SAMPLES[n]}_2.fastq.gz")
        else:
            for n in range(0, len(SAMPLES)):
                targets.append(f"03_sortmeRNA/unaligned/{SAMPLES[n]}_SE.fastq.gz")
    else:
        if ENDS == "PE":
            for n in range(0, len(SAMPLES)):
                targets.append(f"02_trimmomatic/{SAMPLES[n]}_1.fastq.gz 02_trimmomatic/{SAMPLES[n]}_2.fastq.gz")
        else:
            for n in range(0, len(SAMPLES)):
                targets.append(f"02_trimmomatic/{SAMPLES[n]}_SE.fastq.gz")
    return targets