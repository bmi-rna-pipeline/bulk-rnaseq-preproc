rule pre:
    input:
        tmpfile = expand("04_STAR/tmp/{sample}.Aligned.toTranscriptome.out.bam", sample=SAMPLES)
    output:
        outfile = expand("05_RSEM/{sample}.Aligned.toTranscriptome.sortedByCoord.out.bam", sample=SAMPLES)
    params:
        nthread = THREADS
    run:
        for i in range(0, len(SAMPLES)):
            inparams = input.tmpfile[i]
            outparams = output.outfile[i]
            if ENDS == 'PE':
                shell(
                    '''
                    cat <( samtools view -H {inparams} ) <( samtools view -@ {params.nthread} {inparams} | awk '{{printf "%s", $0 " "; getline; print}}' | sort -S 50G -T 05_RSEM/tmp | tr " " "\n" ) | samtools view -@ {params.nthread} -bS - > {outparams}
                    '''
                    )
            else:
                shell(
                    '''
                    cat <( samtools view -H {inparams} ) <( samtools view -@ {params.nthread} {inparams} | sort -S 50G -T 05_RSEM/tmp ) | samtools view -@ {params.nthread} -bS - > {outparams}
                    '''
                    )

rule rsem:
    input:
        files = expand("05_RSEM/{sample}.Aligned.toTranscriptome.sortedByCoord.out.bam", sample=SAMPLES)
    output:
        expand("05_RSEM/{sample}.genes.results", sample=SAMPLES),
        expand("05_RSEM/{sample}.isoforms.results", sample=SAMPLES)
    params:
        ends = ENDS,
        org = ORG,
        strand = STRAND,
        prefix = expand("05_RSEM/{sample}", sample=SAMPLES),
        nthread = THREADS, 
        ref = REF
    log:
        expand("05_RSEM/log/rsem.log", sample=SAMPLES)
    run:
        shell(
            '''
            mkdir -p 05_RSEM/log
            echo 'RSEM Version:' 2>&1 | tee -a {log}
            rsem-calculate-expression --version 2>&1 | tee -a {log}
            echo 'Running RSEM for {params.strand} {params.ends} reads...' 2>&1 | tee -a {log}
            '''
            )
        for i in range(0, len(SAMPLES)):
            inparams = input.files[i]
            pref = params.prefix[i]
            if config['stranded']:
                shell(
                    '''
                    rsem-calculate-expression \
                    --bam \
                    --estimate-rspd \
                    --calc-ci \
                    --no-bam-output \
                    --seed 12345 \
                    -p {params.nthread} \
                    --ci-memory 30000 \
                    --paired-end \
                    --strandedness reverse \
                    {inparams} \
                    ./generef/indices/{params.ref}_rsem \
                    {pref} 2>&1 | tee -a {log}
                    '''
                    )
            else:
                shell(
                    '''
                    rsem-calculate-expression \
                    --bam \
                    --estimate-rspd \
                    --calc-ci \
                    --no-bam-output \
                    --seed 12345 \
                    -p {params.nthread} \
                    --ci-memory 30000 \
                    --paired-end \
                    {inparams} \
                    ./generef/indices/{params.ref}_rsem \
                    {pref} 2>&1 | tee -a {log}
                    '''
                    )

rule plot:
    input:
        expand("05_RSEM/{sample}.genes.results", sample=SAMPLES),
        expand("05_RSEM/{sample}.isoforms.results", sample=SAMPLES)
    output:
        expand("05_RSEM/{sample}.Quant.pdf", sample=SAMPLES)
    params:
        prefix = expand("05_RSEM/{sample}", sample=SAMPLES)
    log:
        expand("05_RSEM/log/rsem.log", sample=SAMPLES)
    run:
        for i in range(0, len(SAMPLES)):
            pref = params.prefix[i]
            plot = output[i]
            shell('rsem-plot-model {pref} {plot} >> {log} 2>&1')