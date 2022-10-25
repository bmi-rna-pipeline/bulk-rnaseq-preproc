rule trim_galore_se:
    input:
        "data/{sample}.{ext}",
    output:
        "trimmed/{trtool}/{sample}_trimmed.fq.gz",
        "trimmed/{trtool}/{sample}_trimming_report.txt",
    params:
        extra="--illumina -q 20",
    log:
        "trimmed/{trtool}/logs/{sample}_trimgalore.log",
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/trim_galore/se/"

rule trim_rename:
    input:
        "trimmed/{trtool}/{sample}_trimmed.fq.gz",
    output:
        "trimmed/{trtool}/{sample}.{ext}",
    shell:
        '''
        mv {input} {output}
        '''