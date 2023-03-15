if EXT[0].endswith('gz'):
    fqgz = "trimmed/{{trtool}}/{{sample}}_se.{ext}"
else:
    fqgz = "trimmed/{{trtool}}/{{sample}}_se.{ext}.gz"

rule trim_galore_se:
    input:
        "data/{{sample}}_se.{ext}".format(ext=EXT[0]),
    output:
        "trimmed/{trtool}/{sample}_se_trimmed.fq.gz",
        "trimmed/{trtool}/{sample}_se_trimming_report.txt",
    params:
        extra="--illumina -q 20",
    log:
        "trimmed/{trtool}/logs/{sample}_se.trimgalore.log",
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/trim_galore/se/"

rule trim_rename:
    input:
        "trimmed/{trtool}/{sample}_se_trimmed.fq.gz",
    output:
        fqgz.format(ext=EXT[0]),
    shell:
        '''
        mv {input} {output}
        '''

rule trim_se_format:
    input:
        "trimmed/{trtool}/{sample}_se.{ext}.gz",
    output:
        "trimmed/{trtool}/{sample}_se.{ext}",
    shell:
        '''
        gunzip -c {input} > {output}
        '''