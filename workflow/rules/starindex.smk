if gdf.fa[0].endswith('fasta'):
    fafile = expand("genome/{name}.fasta", name = NAME)
else:
    fafile = expand("genome/{name}.fa", name = NAME)

rule star_index:
    input:
        fasta=fafile,
        gtf=expand("genome/{name}.gtf", name = NAME)
    output:
        directory("genome/starindex"),
    threads: config['threads']
    params:
        extra="",
    log:
        "genome/starindex/logs/star_index.log",
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/star/index"