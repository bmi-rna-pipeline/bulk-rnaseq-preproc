rule fastqc:
    input:
        expand("data/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)
    output:
        expand("01_fastqc/{sample}_{read}_fastqc.html", sample=SAMPLES, read=READS),
        expand("01_fastqc/{sample}_{read}_fastqc.zip", sample=SAMPLES, read=READS)
    params:
        outdir = DATAPATH
    log: 
        expand("01_fastqc/log/{sample}.fastqc.log", sample=SAMPLES, read=READS)
    shell: 
        '''
        mkdir -p 01_fastqc
        mkdir -p 01_fastqc/log
        echo 'fastqc Version:' 2>&1 | tee -a {log}
        fastqc --version  2>&1 | tee -a {log}
        echo Running fastqc on raw files... 2>&1 | tee -a {log}
        fastqc {input} --outdir {params.outdir}/01_fastqc 2>&1 | tee -a {log}
        '''