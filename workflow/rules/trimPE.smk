rule trimpe:
    input:
        r1 = "data/{sample}_1.{ext}",
        r2 = "data/{sample}_2.{ext}"
    output:
        r1 = "trimmed/{trtool}/{sample}_1.{ext}",
        r2 = "trimmed/{trtool}/{sample}_2.{ext}",
        r1_unpaired = "trimmed/{trtool}/{sample}_1.se.{ext}",
        r2_unpaired = "trimmed/{trtool}/{sample}_2.se.{ext}"
    message:
        shell('''
        echo Trimmomatic version:
        trimmomatic -version
        ''')
    log:
        "trimmed/{trtool}/logs/{sample}.{ext}.trimmomatic.log"
    params:
        # list of trimmers (see manual)
        trimmer=[config['trim']['adapter']],
        # optional parameters
        extra=config['trim']['params'],
        compression_level="-9"
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/trimmomatic/pe"
