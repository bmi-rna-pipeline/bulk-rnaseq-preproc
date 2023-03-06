rule fastqc:
    input:
        expand("data/{{sample}}_{{read}}.{ext}", ext=EXT[0])
    output:
        html = "qc/{qctool}/{sample}_{read}_fastqc.html",
        zip = "qc/{qctool}/{sample}_{read}_fastqc.zip"
    log:
        "qc/{qctool}/logs/{sample}_{read}.fastqc.log"
    threads: config['threads']
    wrapper:
         "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/fastqc"
