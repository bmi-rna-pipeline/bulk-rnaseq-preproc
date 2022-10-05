ref = config['rRNApath']

rule touch:
    input:
        expand("02_trimmomatic/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)
    output:
        directory("02_trimmomatic")
    shell:
        """
        touch {input}
        """

rule sort:
    input:
        expand("02_trimmomatic/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)
    params:
        PE1 = expand("02_trimmomatic/{sample}_1.fastq.gz", sample=SAMPLES),
        PE2 = expand("02_trimmomatic/{sample}_2.fastq.gz", sample=SAMPLES),
        tmp1 = expand("03_sortmeRNA/tmp/{sample}_1.fastq.gz", sample=SAMPLES, read=READS),
        tmp2 = expand("03_sortmeRNA/tmp/{sample}_2.fastq.gz", sample=SAMPLES, read=READS),
        mtmp = expand("03_sortmeRNA/tmp/{sample}_merged.fastq.gz", sample=SAMPLES)
    output:
        expand("03_sortmeRNA/tmp/{sample}_merged.fastq.gz", sample=SAMPLES)
    log:
        expand("03_sortmeRNA/log/{sample}.rrna.log", sample=SAMPLES)
    run:
        for i in range(0, len(SAMPLES)):
            inreads1 = params.PE1[i]
            inreads2 = params.PE2[i]
            sereads = input[i]
            intmp1 = params.tmp1[i]
            intmp2 = params.tmp2[i]
            merged = params.mtmp[i]
            logN = log[i]
            shell('''
                mkdir -p 03_sortmeRNA
                mkdir -p 03_sortmeRNA/log
                mkdir -p 03_sortmeRNA/tmp
                echo 'merging into tmp files...' 2>&1 | tee -a {logN}
                ''')
            if ENDS == 'PE':
                shell(
                    '''
                    zcat {inreads1} > {intmp1}
                    zcat {inreads2} > {intmp2}
                    {ref}/scripts/merge-paired-reads.sh \
                    {intmp1} {intmp2} {merged} 2>&1 | tee -a {logN}
                    '''
                    )
            else:
                shell(
                    '''
                    cp {sereads} {merged}
                    '''
                    )

rule rrna:
    input:
        merged = expand("03_sortmeRNA/tmp/{sample}_merged.fastq.gz", sample=SAMPLES)
    params:
        pref = expand("03_sortmeRNA/{sample}_rRNA.tmp.fq", sample=SAMPLES),
        filtered = expand("03_sortmeRNA/{sample}_filtered.tmp.fq", sample=SAMPLES),
        nthread = THREADS
    output:
        expand("03_sortmeRNA/{sample}_rRNA.tmp.fq.gz", sample=SAMPLES),
        expand("03_sortmeRNA/{sample}_filtered.tmp.fq.gz", sample=SAMPLES)
    log:
        expand("03_sortmeRNA/log/{sample}.rrna.log", sample=SAMPLES)
    run:
        for i in range(0, len(SAMPLES)):
            merged = input.merged[i]
            prefix = params.pref[i]
            prefixF = params.filtered[i]
            logN = log[i]
            if ENDS == 'PE':
                shell('''
                    echo 'Running sortmeRNA for {ENDS} reads...' 2>&1 | tee -a {logN}
                    sortmerna --ref {ref}/rRNA_databases/silva-bac-16s-id90.fasta,{ref}/index/silva-bac-16s-db:{ref}/rRNA_databases/silva-bac-23s-id98.fasta,{ref}/index/silva-bac-23s-db:{ref}/rRNA_databases/silva-arc-16s-id95.fasta,{ref}/index/silva-arc-16s-db:{ref}/rRNA_databases/silva-arc-23s-id98.fasta,{ref}/index/silva-arc-23s-db:{ref}/rRNA_databases/silva-euk-18s-id95.fasta,{ref}/index/silva-euk-18s-db:{ref}/rRNA_databases/silva-euk-28s-id98.fasta,{ref}/index/silva-euk-28s:{ref}/rRNA_databases/rfam-5s-database-id98.fasta,{ref}/index/rfam-5s-db:{ref}/rRNA_databases/rfam-5.8s-database-id98.fasta,{ref}/index/rfam-5.8s-db \
                    --reads {merged} --fastx \
                    --aligned {prefix} --other {prefixF} \
                    --log -v --paired_in -a {params.nthread} 2>&1 | tee -a {logN}
                    '''
                    )
            else:
                shell('''
                    echo 'Running sortmeRNA for {ENDS} reads...' 2>&1 | tee -a {logN}
                    sortmerna --ref {ref}/rRNA_databases/silva-bac-16s-id90.fasta,{ref}/index/silva-bac-16s-db:{ref}/rRNA_databases/silva-bac-23s-id98.fasta,{ref}/index/silva-bac-23s-db:{ref}/rRNA_databases/silva-arc-16s-id95.fasta,{ref}/index/silva-arc-16s-db:{ref}/rRNA_databases/silva-arc-23s-id98.fasta,{ref}/index/silva-arc-23s-db:{ref}/rRNA_databases/silva-euk-18s-id95.fasta,{ref}/index/silva-euk-18s-db:{ref}/rRNA_databases/silva-euk-28s-id98.fasta,{ref}/index/silva-euk-28s:{ref}/rRNA_databases/rfam-5s-database-id98.fasta,{ref}/index/rfam-5s-db:{ref}/rRNA_databases/rfam-5.8s-database-id98.fasta,{ref}/index/rfam-5.8s-db \
                    --reads {merged} --fastx \
                    --aligned {prefix} --other {prefixF} \
                    --log -v -a {params.nthread} 2>&1 | tee -a {logN}
                    '''
                    )

rule clean:
    input:
        rrna = expand("03_sortmeRNA/{sample}_rRNA.tmp.fq.gz", sample=SAMPLES),
        filtered = expand("03_sortmeRNA/{sample}_filtered.tmp.fq.gz", sample=SAMPLES)
    output:
        rrnav = expand("03_sortmeRNA/{sample}_rRNA.tmp.verified.fq.gz", sample=SAMPLES),
        filtv = expand("03_sortmeRNA/{sample}_filtered.tmp.verified.fq.gz", sample=SAMPLES)
    log:
        expand("03_sortmeRNA/log/{sample}.rrna.log", sample=SAMPLES)
    run:
        for i in range(0, len(SAMPLES)):
            inrrna = input.rrna[i]
            infilt = input.filtered[i]
            out = output.rrnav[i]
            outf = output.filtv[i]
            logN = log[i]
            shell('''
                grep -v -e '^$' {infilt} > {out} 2>&1 | tee -a {logN}
                grep -v -e '^$' {inrrna} > {outf} 2>&1 | tee -a {logN}
                rm {infilt} {inrrna} 2>&1 | tee -a {logN}
                ''')

rule unmerge:
    input:
        tmp1 = expand("03_sortmeRNA/{sample}_rRNA.tmp.verified.fq.gz", sample=SAMPLES),
        tmp2 = expand("03_sortmeRNA/{sample}_filtered.tmp.verified.fq.gz", sample=SAMPLES)
    output:
        expand("03_sortmeRNA/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS),
        expand("03_sortmeRNA/{sample}_{read}.rRNA.fastq.gz", sample=SAMPLES, read=READS)
    params:
        filtered1 = expand("03_sortmeRNA/{sample}_1.fastq.gz", sample=SAMPLES),
        filtered2 = expand("03_sortmeRNA/{sample}_2.fastq.gz", sample=SAMPLES),
        rRNA1 = expand("03_sortmeRNA/{sample}_1.rRNA.fastq.gz", sample=SAMPLES),
        rRNA2 = expand("03_sortmeRNA/{sample}_2.rRNA.fastq.gz", sample=SAMPLES)
    log:
        expand("03_sortmeRNA/log/{sample}.rrna.log", sample=SAMPLES)
    run:
        for i in range(0, len(SAMPLES)):
            intmp1 = input.tmp1[i]
            intmp2 = input.tmp2[i]
            outf1 = params.filtered1[i]
            outf2 = params.filtered2[i]
            outR1 = params.rRNA1[i]
            outR2 = params.rRNA2[i]
            logN = log[i]
            if ENDS == 'PE':
                shell('''
                    echo "unmerging PE reads..." 2>&1 | tee -a {logN}
                    {ref}/scripts/unmerge-paired-reads.sh {intmp2} {outf1} {outf2} 2>&1 | tee -a {logN}
                    {ref}/scripts/unmerge-paired-reads.sh {intmp1} {outR1} {outR2} 2>&1 | tee -a {logN}
                    ''')
            else:
                shell('''
                    echo "renaming SE reads..." 2>&1 | tee -a {logN}
                    rename "s/_rRNA.tmp.verified.fq/.rRNA.fastq/" *.fq
                    rename "s/_filtered.tmp.verified.fq/.fastq/" *.fq
                    ''')
            shell('''
                echo "removing tmp files..." 2>&1 | tee -a {logN}
                rm {intmp1} 2>&1 | tee -a {logN}
                rm {intmp2} 2>&1 | tee -a {logN}
                ''')

rule rrnaqc:
    input:
        expand("03_sortmeRNA/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)
    output:
        expand("01_fastqc/filtered/{sample}_{read}_fastqc.html", sample=SAMPLES, read=READS),
        expand("01_fastqc/filtered/{sample}_{read}_fastqc.zip", sample=SAMPLES, read=READS)
    params:
        outdir = f"{DATAPATH}/01_fastqc/filtered",
        qc1 = expand("03_sortmeRNA/{sample}_1.fastq.gz", sample=SAMPLES),
        qc2 = expand("03_sortmeRNA/{sample}_2.fastq.gz", sample=SAMPLES)
    log: 
        expand("01_fastqc/log/{sample}.filtered.log", sample=SAMPLES)
    run:
        for i in range(0, len(SAMPLES)):
            inparams = f'{params.qc1[i]} {params.qc2[i]}'
            logN = log[i]
            shell(
                '''
                mkdir -p 01_fastqc
                mkdir -p 01_fastqc/filtered
                echo 'fastqc Version:' 2>&1 | tee -a {logN}
                fastqc --version  2>&1 | tee -a {logN}
                echo Running fastqc on filtered files... 2>&1 | tee -a {logN}
                fastqc {inparams} --outdir {params.outdir} 2>&1 | tee -a {logN}
                ''')
