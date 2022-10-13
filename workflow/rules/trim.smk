rule trim:
    input:
        expand("data/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)
    output:
        protected(expand("02_trimmomatic/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)),
        protected(expand("02_trimmomatic/{sample}_{read}.se.fastq.gz", sample=SAMPLES, read=READS))
    params:
        nthread = THREADS,
        ends = ENDS,
        ad = config['adapter'],
        op = config['options'],
        P1 = expand("{path}/02_trimmomatic/{sample}_1.fastq.gz", sample=SAMPLES, path=DATAPATH),
        U1 = expand("{path}/02_trimmomatic/{sample}_1.se.fastq.gz", sample=SAMPLES, path=DATAPATH),
        P2 = expand("{path}/02_trimmomatic/{sample}_2.fastq.gz", sample=SAMPLES, path=DATAPATH),
        U2 = expand("{path}/02_trimmomatic/{sample}_2.se.fastq.gz", sample=SAMPLES, path=DATAPATH),
        SE = expand("{path}/02_trimmomatic/{sample}_SE.fastq.gz", sample=SAMPLES, read=READS, path=DATAPATH)
    log:
        out = expand("02_trimmomatic/log/{sample}.log", sample=SAMPLES),
        trimlog = expand("02_trimmomatic/log/{sample}.trimlog.txt", sample=SAMPLES)
    run:
        shell('''
            mkdir -p 02_trimmomatic
            mkdir -p 02_trimmomatic/log
            echo "Trimmomatic Version:" 2>&1 | tee -a {log.out}
            java -Xmx4g -jar /Trimmomatic-0.39/trimmomatic-0.39.jar -version 2>&1 | tee -a {log.out}
            echo "Running trimmomatic for {ENDS} reads..." 2>&1 | tee -a {log.out}
            ''')
        for i in range(0, len(SAMPLES)):
            inparams = getSample()[i]
            outparams = f'{params.P1[i]} {params.U1[i]} {params.P2[i]} {params.U2[i]}'
            SEoutparams = params.SE[i]
            trimlog = log.trimlog[i]
            outlog = log.out[i]
            if ENDS == 'PE':
                shell(
                    '''
                    java -Xmx4g -jar /Trimmomatic-0.39/trimmomatic-0.39.jar \
                    PE -threads {params.nthread} \
                    {inparams} \
                    {outparams} \
                    {params.ad} \
                    {params.op} \
                    -trimlog {trimlog} \
                    2>&1 | tee -a {outlog}
                    '''
                    )
            else:
                shell(
                    '''
                    java -Xmx4g -jar /Trimmomatic-0.39/trimmomatic-0.39.jar \
                    SE -threads {params.nthread} \
                    {inparams} \
                    {SEoutparams} \
                    {params.ad} \
                    {params.op} \
                    -trimlog {trimlog} 2>&1 | tee -a {outlog}
                    '''
                    )

rule trimqc:
    input:
        expand("02_trimmomatic/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)
    output:
        expand("01_fastqc/trimmed/{sample}_{read}_fastqc.html", sample=SAMPLES, read=READS),
        expand("01_fastqc/trimmed/{sample}_{read}_fastqc.zip", sample=SAMPLES, read=READS)
    params:
        outdir = f"{DATAPATH}/01_fastqc/trimmed",
        qc1 = expand("02_trimmomatic/{sample}_1.fastq.gz", sample=SAMPLES),
        qc2 = expand("02_trimmomatic/{sample}_2.fastq.gz", sample=SAMPLES)
    log: 
        expand("01_fastqc/log/{sample}.trimmed.log", sample=SAMPLES)
    run:
        for i in range(0, len(SAMPLES)):
            inparams = f'{params.qc1[i]} {params.qc2[i]}'
            logN = log[i]
            shell(
                '''
                mkdir -p 01_fastqc
                mkdir -p 01_fastqc/trimmed
                echo 'fastqc Version:' 2>&1 | tee -a {logN}
                fastqc --version  2>&1 | tee -a {logN}
                echo Running fastqc on trimmed files... 2>&1 | tee -a {logN}
                fastqc {inparams} --outdir {params.outdir} 2>&1 | tee -a {logN}
                ''')