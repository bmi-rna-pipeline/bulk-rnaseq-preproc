rule fastqc:
    input:
        get_fastqs
    output:
        html = "fastqc/{sample}_{read}_fastqc.html",
        zip = "fastqc/{sample}_{read}_fastqc.zip"
    message:
        shell('''
        echo fastqc version:
        fastqc --version
        ''')
    log:
        "fastqc/log/{sample}_{read}.log"
    threads: config['threads']
    wrapper:
         "master/bio/fastqc"