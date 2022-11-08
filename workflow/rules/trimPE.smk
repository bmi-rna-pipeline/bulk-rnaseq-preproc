rule trimpe:
    input:
        r1 = "data/{sample}_1.{ext}",
        r2 = "data/{sample}_2.{ext}"
    output:
        r1 = "trimmed/{trtool}/{sample}_1.{ext}",
        r2 = "trimmed/{trtool}/{sample}_2.{ext}",
        r1_unpaired = "trimmed/{trtool}/{sample}_1.se.{ext}",
        r2_unpaired = "trimmed/{trtool}/{sample}_2.se.{ext}"
    log:
        "trimmed/{trtool}/logs/{sample}.{ext}.trimmomatic.log"
    params:
        # list of trimmers (see manual)
        trimmer=[config['trimmomatic']['adapter']],
        # optional parameters
        extra=config['trimmomatic']['extra'],
        compression_level=config['trimmomatic']['compression']
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/trimmomatic/pe"
