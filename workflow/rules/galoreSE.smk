rule trim_galore_se:
    input:
        "data/{sample}.{ext}",
    output:
        "trimmed/{sample}.{ext}",
        "trimmed/{sample}.{ext}.report.txt",
    params:
        extra="--illumina -q 20",
    log:
        "trimmed/logs/{sample}.{ext}_trimgalore.log",
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/trim_galore/se/"