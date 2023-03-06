rule minimap2:
    input:
        target=expand("genome/minimapindex/{name}.mmi", name = NAME),  # can be either genome index or genome fasta
        query="data/{{sample}}.{ext}".format(ext=EXT[0]),
    output:
        "aligned/{altool}/{sample}_aln.sorted.bam",
    log:
        "aligned/{altool}/pe/logs/{sample}_minimap.log",
    params:
        # optional parameters
        extra=config['miniparams']['extra'],
        sort=config['miniparams']['sorting'],
        sortext=config['miniparams']['sort_extra'],
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/minimap2/aligner"