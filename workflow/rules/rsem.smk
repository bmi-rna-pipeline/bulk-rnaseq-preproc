rule calculate_expression:
    input:
        # input.bam or input.fq_one must be specified (and if input.fq_one, optionally input.fq_two if paired-end)
        # an aligned to transcriptome BAM
        bam=expand("aligned/{altool}/{{sample}}.Aligned.toTranscriptome.sorted.bam", altool=config['align']),
        # one of the index files created by rsem-prepare-reference; the file suffix is stripped and passed on to rsem
        seq=expand("genome/rsemindex/{name}.seq", name = NAME),
    output:
        # genes_results must end in .genes.results; this suffix is stripped and passed to rsem as an output name prefix
        # this file contains per-gene quantification data for the sample
        genes_results="quant/{qtool}/{sample}.genes.results",
        # isoforms_results must end in .isoforms.results and otherwise have the same prefix as genes_results
        # this file contains per-transcript quantification data for the sample
        isoforms_results="quant/{qtool}/{sample}.isoforms.results",
    threads: config['threads']
    params:
        # optional, specify if sequencing is paired-end
        pref = lambda wildcards: expand("genome/rsemindex/{name}", name = NAME),
        paired_end=True,
        # additional optional parameters to pass to rsem, for example,
        extra="--seed 12345 --estimate-rspd --no-bam-output",
    log:
        "quant/{qtool}/logs/calculate_expression.{sample}.log",
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/rsem/calculate-expression"