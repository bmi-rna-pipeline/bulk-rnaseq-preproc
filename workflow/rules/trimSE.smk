rule trimse:
    input:
        "data/{sample}.{ext}"
    output:
        "trimmed/{sample}.{ext}",
    message:
        shell('''
        echo Trimmomatic version:
        trimmomatic -version
        ''')
    log:
        "trimmed/logs/{sample}.{ext}.trimmomatic.log"
    params:
        # list of trimmers (see manual)
        trimmer=["TRAILING:3"],
        # optional parameters
        extra="",
        compression_level="-9"
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/trimmomatic/se"