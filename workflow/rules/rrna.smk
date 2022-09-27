ref = searchdb(config['rRNApath'])
refparams = getRef()

rule rrna:
    params:
        al = expand("03_sortmeRNA/aligned/{sample}", sample=SAMPLES),
        un = expand("03_sortmeRNA/unaligned/{sample}", sample=SAMPLES),
        sample = SAMPLES
    output:
        alfwd = expand("03_sortmeRNA/aligned/{sample}_fwd.fq.gz", sample=SAMPLES),
        alrev = expand("03_sortmeRNA/aligned/{sample}_rev.fq.gz", sample=SAMPLES),
        unfwd = expand("03_sortmeRNA/unaligned/{sample}_fwd.fq.gz", sample=SAMPLES),
        unrev = expand("03_sortmeRNA/unaligned/{sample}_rev.fq.gz", sample=SAMPLES)
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
                    --fastx -out2 \
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

rule rename:
    input:
        alfwd = expand("03_sortmeRNA/aligned/{sample}_fwd.fq.gz", sample=SAMPLES),
        alrev = expand("03_sortmeRNA/aligned/{sample}_rev.fq.gz", sample=SAMPLES),
        unfwd = expand("03_sortmeRNA/unaligned/{sample}_fwd.fq.gz", sample=SAMPLES),
        unrev = expand("03_sortmeRNA/unaligned/{sample}_rev.fq.gz", sample=SAMPLES)
    output:
        expand("03_sortmeRNA/aligned/{sample}_{read}.rrna.fastq.gz", sample=SAMPLES, read=READS),
        expand("03_sortmeRNA/unaligned/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)
    params:
        path = ["03_sortmeRNA/aligned/", "03_sortmeRNA/unaligned/"]
    run:
        shell('echo "rRNA filtering completed, renaming files..."')
        dat = []
        for n in params.path:
            dat.append(os.listdir(os.path.dirname(n)))
        for files in dat[0]:
            if files.endswith('_fwd.fq.gz'):
                os.rename(params.path[0] + files, f"{params.path[0]}{files.split('_fwd')[0]}_1.rrna.fastq.gz")
            elif files.endswith('_rev.fq.gz'):
                os.rename(params.path[0] + files, f"{params.path[0]}{files.split('_rev')[0]}_2.rrna.fastq.gz")
        for files in dat[1]:
            if files.endswith('_fwd.fq.gz'):
                os.rename(params.path[1] + files, f"{params.path[1]}{files.split('_fwd')[0]}_1.fastq.gz")
            elif files.endswith('_rev.fq.gz'):
                os.rename(params.path[1] + files, f"{params.path[1]}{files.split('_rev')[0]}_2.fastq.gz")

rule rrnaqc:
    input:
        expand("03_sortmeRNA/unaligned/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)
    output:
        expand("01_fastqc/filtered/{sample}_{read}_fastqc.html", sample=SAMPLES, read=READS),
        expand("01_fastqc/filtered/{sample}_{read}_fastqc.zip", sample=SAMPLES, read=READS)
    params:
        outdir = DATAPATH
    log: 
        expand("01_fastqc/filtered/log/filteredqc.log", sample=SAMPLES, read=READS)
    shell: 
        '''
        echo "Running fastqc on filtered files..."
        mkdir -p 01_fastqc/filtered/
        mkdir -p 01_fastqc/filtered/log
        echo 'fastqc Version:' 2>&1 | tee -a {log}
        fastqc --version  2>&1 | tee -a {log}
        echo Running fastqc on raw files... 2>&1 | tee -a {log}
        fastqc {input} --outdir {params.outdir}/01_fastqc/filtered 2>&1 | tee -a {log}
        '''