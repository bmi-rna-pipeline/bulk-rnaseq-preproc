rule trim_galore_pe:
    input:
        get_fastqs,
    output:
        "trimmed/{trtool}/{sample}_1_val_1.fq.gz",
        "trimmed/{trtool}/{sample}_1_trimming_report.txt",
        "trimmed/{trtool}/{sample}_2_val_2.fq.gz",
        "trimmed/{trtool}/{sample}_2_trimming_report.txt",
    params:
        extra="--illumina -q 20",
    log:
        "trimmed/{trtool}/logs/{sample}_trimgalore.log",
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/trim_galore/pe/"

rule trim_rename:
    input:
        r1 = "trimmed/{trtool}/{sample}_1_val_1.fq.gz",
        r2 = "trimmed/{trtool}/{sample}_2_val_2.fq.gz",
    output:
        trim1 = "trimmed/{trtool}/{sample}_1.{ext}",
        trim2 = "trimmed/{trtool}/{sample}_2.{ext}",
    shell:
        '''
        mv {input.r1} {output.trim1}
        mv {input.r2} {output.trim2}
        '''