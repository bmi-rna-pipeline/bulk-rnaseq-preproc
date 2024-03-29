if config['ends'] == 'SE':
    trim1 = "trimmed/{trtool}/{{sample}}_se.{ext}".format(trtool=config['trim'], ext=EXT[0])
    trim2 = ""
else:
    trim1 = "trimmed/{trtool}/{{sample}}_1.{ext}".format(trtool=config['trim'], ext=EXT[0])
    trim2 = "trimmed/{trtool}/{{sample}}_2.{ext}".format(trtool=config['trim'], ext=EXT[0])

rule star:
    input:
        # use a list for multiple fastq files for one sample
        # usually technical replicates across lanes/flowcells
        fq1=trim1,
        fq2=trim2,
        # path to STAR reference genome index
        idx="genome/starindex/",
    output:
        # see STAR manual for additional output files
        aln="aligned/{altool}/pe/{sample}.Aligned.sortedByCoord.out.bam",
        trn="aligned/{altool}/pe/{sample}.Aligned.toTranscriptome.out.bam",
        log="aligned/{altool}/pe/{sample}.Log.out",
        sj="aligned/{altool}/pe/{sample}.SJ.out.tab",
        log_final="aligned/{altool}/pe/{sample}/Log.final.out",
    log: 
        "aligned/{altool}/pe/logs/{sample}_star.log",
    params:
        # optional parameters
        extra=config['starparams']['extra'],
        quant=config['starparams']['quant'],
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/star/align"


rule star_se:
    input:
        # use a list for multiple fastq files for one sample
        # usually technical replicates across lanes/flowcells
        fq1=trim1,
        # path to STAR reference genome index
        idx="genome/starindex/",
    output:
        # see STAR manual for additional output files
        aln="aligned/{altool}/se/{sample}.Aligned.sortedByCoord.out.bam",
        trn="aligned/{altool}/se/{sample}.Aligned.toTranscriptome.out.bam",
        log="aligned/{altool}/se/{sample}.Log.out",
        sj="aligned/{altool}/se/{sample}.SJ.out.tab",
        log_final="aligned/{altool}/se/{sample}/Log.final.out",
    log: 
        "aligned/{altool}/se/logs/{sample}_star.log",
    params:
        # optional parameters
        extra=config['starparams']['extra'],
        quant=config['starparams']['quant'],
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/star/align"