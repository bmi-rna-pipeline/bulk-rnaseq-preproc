from snakemake.utils import validate
import pandas as pd
import numpy as np

df = pd.read_csv(config['samples'], dtype='str').set_index(
    ["sample_name", "reads", "fq"], drop=False)

gdf = pd.read_csv(config['genome'], dtype='str').set_index(
    ["name", "fa", "annot"], drop=False)

SAMPLES = df.sample_name
READS = df.reads
FULL = df.fq
EXT = config['extension']

wildcard_constraints:
    sample = "|".join(df.sample_name),
    read = "|".join(df.reads),
    full = "|".join(df.fq),
    fasta = "|".join(gdf.fa),
    ann = "|".join(gdf.annot),

def is_single_end(sample, read):
    """Determine whether single-end."""
    fq2_not_present = df.loc[pd.isnull(df['reads'])]
    return fq2_not_present["sample_name"]

def get_fastqs(wildcards):
    """Get raw FASTQ files from unit sheet."""
    if is_single_end(wildcards.sample, wildcards.read) is not None:
        return df.loc[(wildcards.sample, wildcards.read), "full"]
    else:
        for i in range(0, len(df)):
            u = df.loc[(wildcards.sample, wildcards.read), ["full"]].dropna()
            return [f"{u.fq[i]}", f"{u.fq[i + 1]}"]

def all_input(wildcards):
    """
    Function defining all requested inputs for the rule all (below).
    """
    wanted_input = []

    wanted_input.extend(
        expand(
            ["fastqc/{id.sample_name}_{id.reads}_fastqc.html",
            "fastqc/{id.sample_name}_{id.reads}_fastqc.zip"], 
            id=df[['sample_name', 'reads']].itertuples()
        )
    )

    if config['trim']['trimmomatic']:
        wanted_input.extend(
            expand(
                ["trimmed/{id.sample_name}_{id.reads}.{ext}",
                "trimmed/{id.sample_name}_{id.reads}.se.{ext}"], 
                id=df[['sample_name', 'reads']].itertuples(), ext = config['extension']
            )
        )
    return wanted_input