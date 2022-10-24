rule htseq_count:
    input:
        # input.bam or input.sam must be specified
        # an aligned to transcriptome BAM
        bam="aligned/{sample}.Aligned.toTranscriptome.sorted.bam",
        gtf = expand("genome/{name}.gtf", name = NAME),
    output:
        # Supported formats: tsv, csv, mtx, h5ad, loom
        countfiles="quant/{sample}_count.tsv"
    params:
        # optional, specify if sequencing is paired-end
        paired_end=True,
        # additional optional parameters to pass to rsem, for example, 
        # "--stranded=<yes/no/reverse>"
        extra="--stranded yes",
    log:
        "quant/logs/{sample}_htseq.log",
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/htseq"
