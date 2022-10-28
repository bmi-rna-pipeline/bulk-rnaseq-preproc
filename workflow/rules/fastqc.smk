if config['ends'] == 'PE':
    html = expand("qc/{{qctool}}/{{sample}}_{read}_fastqc.html", read=READS)
    zip = expand("qc/{qctool}/{{sample}}_{read}_fastqc.zip", read=READS)
elif config['ends'] == 'SE':
    html = "qc/{qctool}/{sample}_fastqc.html"
    zip = "qc/{qctool}/{sample}_fastqc.zip"

rule fastqc:
    input:
        get_fastqs,
    output:
        html = html,
        zip = zip
    message:
        shell('''
        echo fastqc version:
        fastqc --version
        ''')
    log:
        expand("qc/{{qctool}}/logs/{{sample}}_{read}.fastqc.log", read=READS)
    threads: config['threads']
    wrapper:
         "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/fastqc"
