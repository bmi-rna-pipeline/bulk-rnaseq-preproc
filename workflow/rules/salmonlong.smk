if gdf.fa[0].endswith('fasta'):
    fafile = "genome/{name}.fasta"
else:
    fafile = "genome/{name}.fa"

rule salmon_quant_long:
    input:
        bam=expand("aligned/{altool}/{{sample}}_aln.sorted.bam", altool=config['align']),
        index=fafile.format(name = NAME[0]),
    output:
        gene_count="quant/{qtool}/{sample}/quant.sf",
    threads: config['threads']
    params:
        extra=config['salmonparams']['extra'],
        outfile = "quant/{qtool}/{sample}"
    log:
        "quant/{qtool}/{sample}/logs/salmon.log",
    shell:
        '''
        salmon quant -t {input.index} -l A -a {input.bam} -o {params.outfile} -p {threads} --incompatPrior 1 --noErrorModel
        '''