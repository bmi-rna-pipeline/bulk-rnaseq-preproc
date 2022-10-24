if gdf.fa[0].endswith('fasta'):
    fafile = "genome/{name}.fasta"
else:
    fafile = "genome/{name}.fa"

rule prepare_reference:
    input:
        # reference FASTA with either the entire genome or transcript sequences
        reference_genome=fafile,
    output:
        # one of the index files created and used by RSEM (required)
        seq="genome/rsemindex/{name}.seq",
        # RSEM produces a number of other files which may optionally be specified as output; these may be provided so that snakemake is aware of them, but the wrapper doesn't do anything with this information other than to verify that the file path prefixes match that of output.seq.
        # # for example,
        # grp="genome/rsemindex/{name}.grp",
        # ti="genome/rsemindex/{name}.ti",
    params:
        # optional additional parameters, for example for gtf file,
        # if building the index against a reference transcript set
        extra="--gtf genome/{name}.gtf",
    threads: config['threads']
    log:
        "genome/rsemindex/logs/{name}.prepare-reference.log",
    wrapper:
        "https://raw.githubusercontent.com/bmi-rna-pipeline/snakemake-wrappers/master/bio/rsem/prepare-reference"