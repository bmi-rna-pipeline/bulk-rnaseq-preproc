rule fastqc:
    input:
        get_fastqs
    output:
        html = "qc/{sample}_{read}_fastqc.html",
        zip = "qc/{sample}_{read}_fastqc.zip"
    message:
        shell('''
        echo fastqc version:
        fastqc --version
        ''')
    log:
        "qc/log/{sample}_{read}.fastqc.log"
    threads: config['threads']
    wrapper:
         "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/fastqc"