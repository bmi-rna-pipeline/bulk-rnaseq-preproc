from snakemake.utils import validate
import pandas as pd
import numpy as np

df = pd.read_csv(config['samples'], dtype='str').set_index(
    ["sample_name", "reads", "fq", "ext"], drop=False)

gdf = pd.read_csv(config['genome'], dtype='str').set_index(
    ["name", "fa", "annot"], drop=False)

SAMPLES = df.sample_name
READS = df.reads
FULL = df.fq
EXT = df.ext
FASTA = gdf.fa
GTF = gdf.annot
NAME = gdf.name
EXTOP = ['fastq.gz', 'fq.gz', 'fastq', 'fq']

wildcard_constraints:
    sample = "|".join(df.sample_name),
    read = "|".join(df.reads),
    full = "|".join(df.fq),
    fasta = "|".join(gdf.fa),
    ann = "|".join(gdf.annot),
    ext = "|".join(df.ext),

def is_single_end(sample, read):
    """Determine whether single-end."""
    fq2_not_present = df.loc[pd.isnull(df['reads'])]
    return fq2_not_present["sample_name"]

def get_fastqs(wildcards):
    """Get raw FASTQ files from unit sheet."""
    if config['ends'] == 'SE':
        return [f'data/{df.loc[(wildcards.sample), "fq"]}']
    else:
        for i in range(0, len(df)):
            u = df.loc[(wildcards.sample), ["fq"]].dropna()
            return [f'data/{u.fq[i]}', f'data/{u.fq[i + 1]}']

def get_trimmed(wildcards):
    """Get raw FASTQ files from unit sheet."""
    if config['ends'] == 'SE':
        return [f'trimmed/{config["trim"]}/{df.loc[(wildcards.sample), "fq"]}']
    else:
        for i in range(0, len(df)):
            u = df.loc[(wildcards.sample), ["fq"]].dropna()
            return [f'trimmed/{config["trim"]}/{u.fq[i]}', f'trimmed/{config["trim"]}/{u.fq[i + 1]}']

def all_input(wildcards):
    """
    Function defining all requested inputs for the rule all (below).
    """
    wanted_input = []

    wanted_input.extend(
            [directory("./genome/")]
        )

    if config['qc']=='fastqc':
        wanted_input.extend(
            expand(
                ["qc/{tool}/{id.sample_name}_{id.reads}_fastqc.html",
                "qc/{tool}/{id.sample_name}_{id.reads}_fastqc.zip"], 
                id=df[['sample_name', 'reads']].itertuples(), tool= config['qc']
            )
        )

    if config['trim']=='trimmomatic' and config['ends'] == 'PE':
        wanted_input.extend(
            expand(
                ["trimmed/{tool}/{id.sample_name}_{id.reads}.{id.ext}",
                "trimmed/{tool}/{id.sample_name}_{id.reads}.se.{id.ext}"], 
                id=df[['sample_name', 'reads', 'ext']].itertuples(), tool= config['trim']
            )
        )
    elif config['trim']=='trimmomatic' and config['ends'] == 'SE':
        wanted_input.extend(
            expand(
                ["trimmed/{tool}/{id.sample_name}.{id.ext}"], 
                id=df[['sample_name', 'ext']].itertuples(), tool= config['trim']
            )
        )

    if config['trim']=='trimgalore' and config['ends'] == 'PE':
        wanted_input.extend(
            expand(
                ["trimmed/{tool}/{id.sample_name}_{id.reads}.{id.ext}",
                "trimmed/{tool}/{id.sample_name}_{id.reads}.{id.ext}.report.txt"], 
                id=df[['sample_name', 'reads', 'ext']].itertuples(), tool= config['trim']
            )
        )
    elif config['trim']=='trimgalore' and config['ends'] == 'SE':
        wanted_input.extend(
            expand(
                ["trimmed/{tool}/{id.sample_name}.{id.ext}",
                "trimmed/{tool}/{id.sample_name}.{id.ext}.report.txt"], 
                id=df[['sample_name', 'ext']].itertuples(), tool= config['trim']
            )
        )

    if config['align']=='star':
        wanted_input.extend(
            [directory("genome/starindex/")]
        )
    
    if config['align']=='star' and config['ends'] == 'PE':
        wanted_input.extend(
            expand(
                ["aligned/{tool}/pe/{id.sample_name}.Aligned.sortedByCoord.out.bam",
                "aligned/{tool}/pe/{id.sample_name}.Aligned.toTranscriptome.out.bam",
                "aligned/{tool}/pe/{id.sample_name}.Log.out",
                "aligned/{tool}/pe/{id.sample_name}.SJ.out.tab",
                "aligned/{tool}/{id.sample_name}.Aligned.toTranscriptome.sorted.bam",],
                id=df[['sample_name']].itertuples(), tool= config['align']
            )
        )
    elif config['align']=='star' and config['ends'] == 'SE':
        wanted_input.extend(
            expand(
                ["aligned/{tool}/se/{id.sample_name}.Aligned.sortedByCoord.out.bam",
                "aligned/{tool}/se/{id.sample_name}.Aligned.toTranscriptome.out.bam",
                "aligned/{tool}/se/{id.sample_name}.Log.out",
                "aligned/{tool}/se/{id.sample_name}.SJ.out.tab",
                "aligned/{tool}/{id.sample_name}.Aligned.toTranscriptome.sorted.bam",],
                id=df[['sample_name']].itertuples(), tool= config['align']
            )
        )

    if config['quant']=='rsem':
        wanted_input.extend(
            expand(
                ["genome/rsemindex/{a.name}.seq",
                "quant/{tool}/{id.sample_name}.genes.results",
                "quant/{tool}/{id.sample_name}.isoforms.results"],
                a=gdf[['name']].itertuples(), id=df[['sample_name']].itertuples(), tool=config['quant']
            )
        )

    if config['quant']=='htseq':
            wanted_input.extend(
                expand(
                    ["quant/{tool}/{id.sample_name}_count.tsv"],
                    id=df[['sample_name']].itertuples(), tool= config['quant']
                )
            )

    return wanted_input