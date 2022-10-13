import glob

gff = glob.glob("./generef/*.gff3")
gtf = glob.glob("./generef/*.gtf")

if len(gff) == 0:
    filename = gtf[0]
if len(gtf) == 0:
    filename = gff[0]
else:
    filename = "No annotation file"

rule gff:
    input:
        og = filename
    output:
        expand("./generef/{ref}.gtf", ref=REF)
    params:
        path = DATAPATH,
        ref = REF,
        gtfname = generef/{REF}.gtf
    run:
        if len(gff) == 0:
            os.rename({input.og}, {params.gtfname})
        if len(gtf) == 0:
            shell("gffread {input.og} -T -o {params.gtfname}")
        else:
            print(filename)