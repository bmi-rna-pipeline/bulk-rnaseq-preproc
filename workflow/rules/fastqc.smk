if config['ends'] == 'PE':
    html = expand("qc/{{qctool}}/{{sample}}_{read}_fastqc.html", read=["1", "2"])
    zip = expand("qc/{{qctool}}/{{sample}}_{read}_fastqc.zip", read=["1", "2"])
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
        "qc/{qctool}/logs/{sample}.fastqc.log"
    threads: config['threads']
    wrapper:
         "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/fastqc"
