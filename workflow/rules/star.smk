if config['organism'] == 'EUK':
    addparams = config['EUK']
else:
    addparams = config['PRO']

if config['sortmeRNA']:
    if config['gzip']:
        starinput = expand("03_sortmeRNA/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)
    else:
        starinput = expand("03_sortmeRNA/{sample}_{read}.fastq", sample=SAMPLES, read=READS)
else:
    if config['gzip']:
        starinput = expand("02_trimmomatic/{sample}_{read}.fastq.gz", sample=SAMPLES, read=READS)
    else:
        starinput = expand("02_trimmomatic/{sample}_{read}.fastq", sample=SAMPLES, read=READS)

rule star:
    input:
        starinput
    output:
        protected(expand("04_STAR/{sample}.Aligned.sortedByCoord.out.bam", sample=SAMPLES)),
        protected(expand("04_STAR/{sample}.Aligned.toTranscriptome.out.bam", sample=SAMPLES)),
        protected(expand("04_STAR/{sample}.Log.final.out", sample=SAMPLES)),
        protected(expand("04_STAR/{sample}.SJ.out.tab", sample=SAMPLES))
    log:
        expand("04_STAR/log/star.log", sample=SAMPLES)
    params:
        vals = config['STAR'],
        add = addparams,
        ends = config['PE'],
        gz = config['SE']
        org = ORG,
        out = expand("./04_STAR/{sample}.", sample=SAMPLES),
        nthread = THREADS
    run:
        shell(
            '''
            mkdir -p 04_STAR
            mkdir -p 04_STAR/log
            touch {log}
            echo "STAR Version:" 2>&1 | tee -a {log}
            STAR --version 2>&1 | tee -a {log}
            echo "Running STAR for {params.ends} reads..." 2>&1 | tee -a {log}
            echo "STAR parameters set for organism = {params.org}: {params.vals} {params.add}" 2>&1 | tee -a {log}
            '''
            )
        if ENDS == "PE":
            shell(
                '''
                STAR \
                --genomeDir ./generef/indices/ \
                --readFilesIn {input} \
                --outSAMunmapped Within \
                {params.vals} \
                {params.add} \
                {params.gz} \
                --outFileNamePrefix {params.out} \
                --runThreadN {params.nthread} \
                --genomeLoad LoadAndKeep \
                --limitBAMsortRAM 50000000000 \
                --outSAMtype BAM SortedByCoordinate \
                --quantMode TranscriptomeSAM \
                --outSAMheaderCommentFile commentsENCODElong.txt \
                --outSAMheaderHD @HD VN:1.4 SO:coordinate 2>&1 | tee -a {log}
                '''
                )
        else:
            shell(
                '''
                STAR \
                --genomeDir ./generef/indices/ \
                --readFilesIn {input} \
                --outSAMunmapped Within \
                {params.vals} \
                {params.add} \
                {params.gz} \
                --outFileNamePrefix {params.out} \
                --runThreadN {params.nthread} \
                --genomeLoad LoadAndKeep \
                --limitBAMsortRAM 50000000000 \
                --outSAMtype BAM SortedByCoordinate \
                --quantMode TranscriptomeSAM \
                --outSAMstrandField intronMotif \
                --outSAMheaderCommentFile commentsENCODElong.txt \
                --outSAMheaderHD @HD VN:1.4 SO:coordinate 2>&1 | tee -a {log}
                '''
                )