adaptertype = config['adapter']

rule trim:
    output:
        PE1 = expand("02_trimmomatic/{sample}_1.fastq.gz", sample=SAMPLES),
        SE1 = expand("02_trimmomatic/{sample}_1.se.fastq.gz", sample=SAMPLES),
        PE2 = expand("02_trimmomatic/{sample}_2.fastq.gz", sample=SAMPLES),
        SE2 = expand("02_trimmomatic/{sample}_2.se.fastq.gz", sample=SAMPLES),
        seOUT = expand("02_trimmomatic/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS),
        trimlog = "02_trimmomatic/trimlog.txt"
    params:
        nthread = THREADS,
        ends = ENDS,
        adapter = adaptertype
    log:
        out = expand("02_trimmomatic/log/trim.out.log"),
        trimlog = expand("02_trimmomatic/log/{sample}.trimlog.txt", sample=SAMPLES)
    run:
        for i in range(0, len(SAMPLES)):
            inparams = getSample()[i]
            outparams = trimOut()[i]
            log = log.trimlog[i]
            options = config['options']
            shell('''
                mkdir -p 02_trimmomatic
                mkdir -p 02_trimmomatic/log
                echo "Trimmomatic Version:" 2>&1 | tee -a {log.out}
                java -Xmx4g -jar /Trimmomatic-0.39/trimmomatic-0.39.jar -version 2>&1 | tee -a {log.out}
                echo "Running trimmomatic for {params.ends} reads..." 2>&1 | tee -a {log.out}
                ''')
            if ENDS == 'PE':
                shell(
                    '''
                    java -Xmx4g -jar /Trimmomatic-0.39/trimmomatic-0.39.jar \
                    {params.ends} -threads {params.nthread} \
                    -trimlog {log} \
                    {inparams} \
                    {outparams} \
                    {params.adapter} \
                    {options} 2>&1 | tee -a {log.out}
                    '''
                    )
            else:
                shell(
                    '''
                    java -Xmx4g -jar /Trimmomatic-0.39/trimmomatic-0.39.jar \
                    {params.ends} -threads {params.nthread} \
                    -trimlog {log} \
                    {inparams} \
                    {outparams} \
                    {params.adapter} \
                    {options} 2>&1 | tee -a {log.out}
                    '''
                    )

rule trimqc:
    input:
        expand("02_trimmomatic/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)
    output:
        expand("01_fastqc/trimmed/{sample}_{read}_fastqc.html", sample=SAMPLES, read=READS),
        expand("01_fastqc/trimmed/{sample}_{read}_fastqc.zip", sample=SAMPLES, read=READS)
    params:
        outdir = DATAPATH
    log: 
        expand("01_fastqc/log/{sample}.trimqc.log", sample=SAMPLES, read=READS)
    shell: 
        '''
        mkdir -p 01_fastqc/trimmed/
        mkdir -p 01_fastqc/trimmed/log
        echo 'fastqc Version:' 2>&1 | tee -a {log}
        fastqc --version  2>&1 | tee -a {log}
        echo Running fastqc on raw files... 2>&1 | tee -a {log}
        fastqc {input} --outdir {params.outdir}/01_fastqc/trimmed 2>&1 | tee -a {log}
        '''