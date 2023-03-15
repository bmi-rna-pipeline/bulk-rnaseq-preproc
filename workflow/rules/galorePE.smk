if EXT[0].endswith('gz'):
    fqgz1 = "trimmed/{{trtool}}/{{sample}}_1.{ext}"
    fqgz2 = "trimmed/{{trtool}}/{{sample}}_2.{ext}"
else:
    fqgz1 = "trimmed/{{trtool}}/{{sample}}_1.{ext}.gz"
    fqgz2 = "trimmed/{{trtool}}/{{sample}}_2.{ext}.gz"

rule trim_galore_pe:
    input:
        "data/{{sample}}_1.{ext}".format(ext=EXT[0]),
        "data/{{sample}}_2.{ext}".format(ext=EXT[0]),
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
        trim1 = fqgz1.format(ext=EXT[0]),
        trim2 = fqgz2.format(ext=EXT[0]),
    shell:
        '''
        mv {input.r1} {output.trim1}
        mv {input.r2} {output.trim2}
        '''

rule trim_se_format:
    input:
        r1 = fqgz1.format(ext=EXT[0]),
        r2 = fqgz2.format(ext=EXT[0]),
    output:
        o1 = "trimmed/{trtool}/{sample}_1.{ext}",
        o2 = "trimmed/{trtool}/{sample}_2.{ext}",
    shell:
        '''
        gunzip -c {input.r1} > {output.o2}
        gunzip -c {input.r2} > {output.o2}
        '''