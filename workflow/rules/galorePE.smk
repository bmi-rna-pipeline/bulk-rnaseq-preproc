rule trim_galore_pe:
    input:
        ["data/{sample}_1.{ext}", "data/{sample}_2.{ext}"],
    output:
        "trimmed/{trtool}/{sample}_1.{ext}",
        "trimmed/{trtool}/{sample}_1.{ext}.report.txt",
        "trimmed/{trtool}/{sample}_2.{ext}",
        "trimmed/{trtool}/{sample}_2.{ext}.report.txt",
    params:
        extra="--illumina -q 20",
    log:
        "trimmed/{trtool}/logs/{sample}.{ext}_trimgalore.log",
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/trim_galore/pe/"