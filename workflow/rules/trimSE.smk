rule trimse:
    input:
        get_fastqs,
    output:
        "trimmed/{trtool}/{sample}.{ext}",
    message:
        shell('''
        echo Trimmomatic version:
        trimmomatic -version
        ''')
    log:
        "trimmed/{trtool}/logs/{sample}.{ext}.trimmomatic.log"
    params:
        # list of trimmers (see manual)
        trimmer=["TRAILING:3"],
        # optional parameters
        extra="",
        compression_level="-9"
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/trimmomatic/se"

rule trim_rename:
    input:
        "trimmed/{trtool}/{sample}trimmed.fq.gz",
    output:
        "trimmed/{trtool}/{sample}.{ext}",
    shell:
        '''
        mv {input} {output}
        '''