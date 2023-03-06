if gdf.fa[0].endswith('fasta'):
    fafile = "genome/{name}.fasta"
else:
    fafile = "genome/{name}.fa"

rule minimap2_index:
    input:
        target=fafile,
    output:
        "genome/minimapindex/{name}.mmi"
    log:
        "genome/minimapindex/logs/{name}.log"
    params:
        extra=""  # optional additional args
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/minimap2/index"