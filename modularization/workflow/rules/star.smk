rule star_pe_multi:
    input:
        # use a list for multiple fastq files for one sample
        # usually technical replicates across lanes/flowcells
        fq1=["reads/{sample}_1.fastq", "reads/{sample}_2.fastq"],
        # path to STAR reference genome index
        idx="genome/starindex/",
    output:
        # see STAR manual for additional output files
        aln="star/pe/{sample}.Aligned.sortedByCoord.out.bam",
        aln="star/pe/{sample}.Aligned.toTranscriptome.out.bam",
        log="logs/pe/{sample}.Log.out",
        sj="star/pe/{sample}.SJ.out.tab",
    log:
        "logs/pe/{sample}.log",
    params:
        # optional parameters
        extra="--outSAMtype BAM SortedByCoordinate",
    threads: config['threads']
    wrapper:
        "master/bio/star/align"


rule star_se:
    input:
        fq1="reads/{sample}.fastq",
        # path to STAR reference genome index
        idx="index",
    output:
        # see STAR manual for additional output files
        aln="star/se/{sample}.Aligned.sortedByCoord.out.bam",
        aln="star/se/{sample}.Aligned.toTranscriptome.out.bam",
        log="logs/se/{sample}/Log.out",
        log_final="logs/se/{sample}/Log.final.out",
    log:
        "logs/se/{sample}.log",
    params:
        # optional parameters
        extra="--outSAMtype BAM SortedByCoordinate",
    threads: config['threads']
    wrapper:
        "master/bio/star/align"