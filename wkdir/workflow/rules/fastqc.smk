rule fastqc:
    input:
        expand("data/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)
    output:
        expand("01_fastqc/{sample}_{read}_fastqc.html", sample=SAMPLES, read=READS),
        expand("01_fastqc/{sample}_{read}_fastqc.zip", sample=SAMPLES, read=READS)
    params:
        outdir = f"{DATAPATH}/01_fastqc",
        qc1 = expand("data/{sample}_1.fastq.gz", sample=SAMPLES),
        qc2 = expand("data/{sample}_2.fastq.gz", sample=SAMPLES)
    log:
        expand("01_fastqc/log/{sample}.fastqc.log", sample=SAMPLES)
    run:
        for i in range(0, len(SAMPLES)):
            inparams = f'{params.qc1[i]} {params.qc2[i]}'
            logN = log[i]
            shell(
                '''
                mkdir -p 01_fastqc
                mkdir -p 01_fastqc/log
                echo 'fastqc Version:' 2>&1 | tee -a {logN}
                fastqc --version  2>&1 | tee -a {logN}
                echo Running fastqc on raw files... 2>&1 | tee -a {logN}
                fastqc {inparams} --outdir {params.outdir} 2>&1 | tee -a {logN}
                ''')