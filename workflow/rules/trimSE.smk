rule trimse:
    input:
        "data/{sample}_{read}.{ext}",
    output:
        "trimmed/{trtool}/{sample}_{read}.{ext}",
    log:
        "trimmed/{trtool}/logs/{sample}_{read}.{ext}.trimmomatic.log"
    params:
        # list of trimmers (see manual)
        trimmer=[config['trimmparams']['adapter']],
        # optional parameters
        extra=config['trimmparams']['extra'],
        compression_level=config['trimmparams']['compression']
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/trimmomatic/se"
