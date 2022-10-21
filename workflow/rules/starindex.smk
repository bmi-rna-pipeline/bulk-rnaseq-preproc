rule star_index:
    priority: config['index']['priority']
    input:
        fasta=expand("{fa}", fa = FASTA),
        gtf=expand("{name}.gtf", name = NAME)
    output:
        directory("genome/starindex/"),
    threads: config['threads']
    params:
        extra="",
    log:
        "genome/starindex/star_index.log",
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/star/index"