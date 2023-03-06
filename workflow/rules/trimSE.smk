rule trimse:
    input:
        "data/{sample}_se.{ext}",
    output:
        "trimmed/{trtool}/{sample}_se.{ext}",
    log:
        "trimmed/{trtool}/logs/{sample}_se.{ext}.trimmomatic.log"
    params:
        # list of trimmers (see manual)
        trimmer=[config['trimmparams']['adapter']],
        # optional parameters
        extra=config['trimmparams']['extra'],
        compression_level=config['trimmparams']['compression']
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/trimmomatic/se"
