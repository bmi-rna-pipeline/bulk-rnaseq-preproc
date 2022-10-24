rule trim_galore_pe:
    input:
        ["data/{sample}_1.{ext}", "data/{sample}_2.{ext}"],
    output:
        "trimmed/{sample}_1.{ext}",
        "trimmed/{sample}_1.{ext}.report.txt",
        "trimmed/{sample}_2.{ext}",
        "trimmed/{sample}_2.{ext}.report.txt",
    params:
        extra="--illumina -q 20",
    log:
        "trimmed/logs/{sample}.{ext}_trimgalore.log",
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/trim_galore/pe/"