if config['ends'] == 'PE':
    bamfile = "star/pe/{sample}.Aligned.toTranscriptome.out.bam"
elif config['ends'] == 'SE':
    bamfile = "star/se/{sample}.Aligned.toTranscriptome.out.bam"

rule samtools_sort:
    input:
        bamfile
    output:
        "star/{sample}.Aligned.toTranscriptome.sorted.bam"
    params:
        "-m 4G"
    threads: config['threads']
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/samtools/sort"