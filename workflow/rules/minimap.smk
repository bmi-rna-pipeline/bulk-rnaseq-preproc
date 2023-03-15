if config['miniparams']['useindex'] == False:
    if gdf.fa[0].endswith('fasta'):
        fafile = "genome/{name}.fasta"
    else:
        fafile = "genome/{name}.fa"
else:
    fafile = "genome/minimapindex/{name}.mmi"

rule minimap2:
    input:
        target=fafile.format(name = NAME[0]),  # can be either genome index or genome fasta
        query="data/{{sample}}_{read}.{ext}".format(ext=EXT[0], read=READS[0]),
    output:
        "aligned/{altool}/{sample}_aln.sorted.bam",
    log:
        "aligned/{altool}/logs/{sample}_minimap.log",
    params:
        # optional parameters
        extra=config['miniparams']['extra'],
        sort=config['miniparams']['sorting'],
        sortext=config['miniparams']['sort_extra'],
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/minimap2/aligner"
