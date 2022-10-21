rule star_pe_multi:
    input:
        # use a list for multiple fastq files for one sample
        # usually technical replicates across lanes/flowcells
        fq1=["trimmed/{sample}_1.fastq", "trimmed/{sample}_2.fastq"],
        # path to STAR reference genome index
        idx="genome/starindex",
    output:
        # see STAR manual for additional output files
        aln="star/pe/{sample}.Aligned.sortedByCoord.out.bam",
        trn="star/pe/{sample}.Aligned.toTranscriptome.out.bam",
        log="star/pe/{sample}.Log.out",
        sj="star/pe/{sample}.SJ.out.tab",
        log_final="star/pe/{sample}/Log.final.out",
    message:
        shell('''
            echo STAR version:
            STAR --version
            ''')
    log:
        "star/pe/logs/{sample}.log",
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
        aln="star/se/{sample}.Aligned.sortedByCoord.out.bam",
        trn="star/se/{sample}.Aligned.toTranscriptome.out.bam",
        log="star/se/{sample}/Log.out",
        log_final="star/se/{sample}/Log.final.out",
    message:
        shell('''
            echo STAR version:
            STAR --version
            ''')
    log:
        "star/se/logs/{sample}.log",
    params:
        # optional parameters
        extra="--outSAMtype BAM SortedByCoordinate",
        quant="--quantMode TranscriptomeSAM",
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/star/align"