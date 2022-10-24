rule star_pe_multi:
    input:
        # use a list for multiple fastq files for one sample
        # usually technical replicates across lanes/flowcells
        fq1=get_trimmed,
        # path to STAR reference genome index
        idx="genome/starindex/",
    output:
        # see STAR manual for additional output files
        aln="aligned/pe/{sample}.Aligned.sortedByCoord.out.bam",
        trn="aligned/pe/{sample}.Aligned.toTranscriptome.out.bam",
        log="aligned/pe/{sample}.Log.out",
        sj="aligned/pe/{sample}.SJ.out.tab",
        log_final="star/pe/{sample}/Log.final.out",
    message:
        shell('''
            echo STAR version:
            STAR --version
            ''')
    log:
        "aligned/pe/logs/{sample}_star.log",
    params:
        # optional parameters
        extra="--outSAMtype BAM SortedByCoordinate",
        quant="--quantMode TranscriptomeSAM",
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/star/align"


rule star_se:
    input:
        fq1="trimmed/{sample}.fastq",
        # path to STAR reference genome index
        idx="genome/starindex",
    output:
        # see STAR manual for additional output files
        aln="aligned/se/{sample}.Aligned.sortedByCoord.out.bam",
        trn="aligned/se/{sample}.Aligned.toTranscriptome.out.bam",
        log="aligned/se/{sample}/Log.out",
        log_final="aligned/se/{sample}/Log.final.out",
    message:
        shell('''
            echo STAR version:
            STAR --version
            ''')
    log:
        "aligned/se/logs/{sample}_star.log",
    params:
        # optional parameters
        extra="--outSAMtype BAM SortedByCoordinate",
        quant="--quantMode TranscriptomeSAM",
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/star/align"