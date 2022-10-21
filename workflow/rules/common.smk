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
FASTA = gdf.fa
GTF = gdf.annot
NAME = gdf.name

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
            [directory("./genome/")]
        )

    if config['qc']['fastqc']:
        wanted_input.extend(
            expand(
                ["fastqc/{id.sample_name}_{id.reads}_fastqc.html",
                "fastqc/{id.sample_name}_{id.reads}_fastqc.zip"], 
                id=df[['sample_name', 'reads']].itertuples()
            )
        )

    if config['trim']['trimmomatic'] and config['ends'] == 'PE':
        wanted_input.extend(
            expand(
                ["trimmed/{id.sample_name}_{id.reads}.{ext}",
                "trimmed/{id.sample_name}_{id.reads}.se.{ext}"], 
                id=df[['sample_name', 'reads']].itertuples(), ext = config['extension']
            )
        )
    elif config['trim']['trimmomatic'] and config['ends'] == 'SE':
        wanted_input.extend(
            expand(
                ["trimmed/{id.sample_name}.{ext}"], 
                id=df[['sample_name']].itertuples(), ext = config['extension']
            )
        )

    if config['align']['star']:
        wanted_input.extend(
            [directory("genome/starindex/")]
        )
    
    if config['align']['star'] and config['ends'] == 'PE':
        wanted_input.extend(
            expand(
                ["star/pe/{id.sample_name}.Aligned.sortedByCoord.out.bam",
                "star/pe/{id.sample_name}.Aligned.toTranscriptome.out.bam",
                "star/pe/{id.sample_name}.Log.out",
                "star/pe/{id.sample_name}.SJ.out.tab",
                "star/{id.sample_name}.Aligned.toTranscriptome.sorted.bam",],
                id=df[['sample_name']].itertuples()
            )
        )
    elif config['align']['star'] and config['ends'] == 'SE':
        wanted_input.extend(
            expand(
                ["star/se/{id.sample_name}.Aligned.sortedByCoord.out.bam",
                "star/se/{id.sample_name}.Aligned.toTranscriptome.out.bam",
                "star/se/{id.sample_name}.Log.out",
                "star/se/{id.sample_name}.SJ.out.tab",
                "star/{id.sample_name}.Aligned.toTranscriptome.sorted.bam",],
                id=df[['sample_name']].itertuples()
            )
        )

    if config['quant']['rsem']:
        wanted_input.extend(
            expand(
                ["genome/rsemindex/{a.name}.seq",
                "rsem/{id.sample_name}.genes.results",
                "rsem/{id.sample_name}.isoforms.results"],
                a=gdf[['name']].itertuples(), id=df[['sample_name']].itertuples()
            )
        )

    return wanted_input