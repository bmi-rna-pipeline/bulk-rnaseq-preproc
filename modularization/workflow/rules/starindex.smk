rule star_index:
    input:
        fasta="{name}.fasta",
    output:
        directory("{name}"),
    message:
        "Testing STAR index"
    threads: 1
    params:
        extra="",
    log:
        "logs/star_index_{name}.log",
    wrapper:
        "v1.17.2/bio/star/index"