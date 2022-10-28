if gdf.annot[0].endswith('gtf'):
    filename = "{name}.gtf"
elif gdf.annot[0].endswith('gff3'):
    filename = "{name}.gff3"
elif gdf.annot[0].endswith('gff'):
    filename = "{name}.gff"

rule gff:
    priority: 0
    input:
        og = filename,
    output:
        directory("./genome/"),
    params:
        gtfname = "./genome/{name}.gtf",
    run:
        if filename.endswith('gff3') or filename.endswith('gff'):
            shell("gffread {input.og} -T -o {params.gtfname}")
        shell("python ./scripts/ref.py")