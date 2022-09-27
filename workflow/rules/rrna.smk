ref = searchdb(config['rRNApath'])
refparams = getRef()

rule rrna:
    params:
        al = expand("03_sortmeRNA/aligned/{sample}", sample=SAMPLES),
        un = expand("03_sortmeRNA/unaligned/{sample}", sample=SAMPLES),
        sample = SAMPLES
    output:
        aligned = expand("03_sortmeRNA/aligned/{sample}_{read}.fastq", sample=SAMPLES, read=READS),
        unaligned = expand("03_sortmeRNA/unaligned/{sample}_{read}.fastq", sample=SAMPLES, read=READS)
    log:
        expand("03_sortmeRNA/log/{sample}.rrna.log", sample=SAMPLES)
    run:
        for i in range(0, len(SAMPLES)):
            readparams = readsSample()[i]
            sampleN = params.sample[i]
            aligned = params.al[i]
            unaligned = params.un[i]
            logN = log[i]
            shell('''
                mkdir -p 03_sortmeRNA
                mkdir -p 03_sortmeRNA/log
                echo 'sortmeRNA Version:' 2>&1 | tee -a {log}
                sortmerna --version 2>&1 | tee -a {log}
                echo 'Running sortmeRNA for {ENDS} reads: {sampleN}'
                ''')
            if ENDS == 'PE':
                shell(
                    '''
                    sortmerna \
                    {refparams} \
                    {readparams} \
                    --workdir 03_sortmeRNA \
                    --aligned {aligned} \
                    --other {unaligned} \
                    --fastx --paired_out True \
                    2>&1 | tee -a {logN}
                    rm -rf 03_sortmeRNA/kvdb
                    '''
                    )
            else:
                shell(
                    '''
                    sortmerna \
                    {refparams} \
                    {readparams} \
                    --workdir 03_sortmeRNA \
                    --aligned {aligned} \
                    --other {unaligned} \
                    --fastx 2>&1 | tee -a {logN}
                    rm -rf 03_sortmeRNA/kvdb
                    '''
                    )

rule gzip:
    input:
        aligned = expand("03_sortmeRNA/aligned/{sample}_{read}.fastq", sample=SAMPLES, read=READS),
        unaligned = expand("03_sortmeRNA/unaligned/{sample}_{read}.fastq", sample=SAMPLES, read=READS)
    output:
        expand("03_sortmeRNA/aligned/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS),
        expand("03_sortmeRNA/unaligned/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)
    shell:
        '''
        gzip {input.aligned}
        gzip {input.unaligned}
        '''

rule rrnaqc:
    input:
        expand("03_sortmeRNA/unaligned/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)
    output:
        expand("01_fastqc/filtered/{sample}_{read}_fastqc.html", sample=SAMPLES, read=READS),
        expand("01_fastqc/filtered/{sample}_{read}_fastqc.zip", sample=SAMPLES, read=READS)
    params:
        outdir = DATAPATH
    log: 
        expand("01_fastqc/log/{sample}.trimqc.log", sample=SAMPLES, read=READS)
    shell: 
        '''
        mkdir -p 01_fastqc/filtered/
        mkdir -p 01_fastqc/filtered/log
        echo 'fastqc Version:' 2>&1 | tee -a {log}
        fastqc --version  2>&1 | tee -a {log}
        echo Running fastqc on raw files... 2>&1 | tee -a {log}
        fastqc {input} --outdir {params.outdir}/01_fastqc/filtered 2>&1 | tee -a {log}
        '''