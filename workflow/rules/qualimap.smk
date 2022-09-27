if config['annotation'] == "gtf":
    annot = expand("generef/{ref}.gtf", ref=REF)
else:
    annot = expand("generef/{ref}.gff3", ref=REF)

if ENDS == 'PE':
    if STRAND == 'stranded':
        libtype = " -pe -p strand-specific-reverse "
    else:
        libtype = " -pe "
else:
    if STRAND == 'stranded':
        libtype = " -p strand-specific-reverse "
    else:
        libtype = ""

rule sam:
    input:
        genome = expand("04_STAR/{sample}.Aligned.sortedByCoord.out.bam", sample=SAMPLES)
    output:
        namesort = expand("06_qualimap/{sample}.namesort.bam", sample=SAMPLES),
        reheader = expand("06_qualimap/{sample}.namesort.reheader.bam", sample=SAMPLES)
    params:
        nthread = THREADS
    run:
        for i in range(0, len(SAMPLES)):
            inparams = input.genome[i]
            outsort = output.namesort[i]
            outhead = output.reheader[i]
            shell(
                '''
                samtools sort -n -@ {params.nthread} -o {outsort} {inparams}
                samtools view -H {outsort} | sed 's/SO:coordinate/SO:queryname/' | samtools reheader - {outsort} > {outhead}
                '''
                )

rule qualimap:
    input:
        namesort = expand("06_qualimap/{sample}.namesort.bam", sample=SAMPLES),
        reheader = expand("06_qualimap/{sample}.namesort.reheader.bam", sample=SAMPLES),
        annotation = annot
    output:
        pdf = expand("06_qualimap/{sample}.report.pdf", sample=SAMPLES)
    log:
        expand("06_qualimap/log/{sample}.qualimap.log", sample=SAMPLES)
    params:
        nMemory = "16G",
        lib = libtype,
        rep = expand("{sample}.report.pdf", sample=SAMPLES)
    run:
        for i in range(0, len(SAMPLES)):
            insort = input.namesort[i]
            inhead = input.reheader[i]
            report = params.rep[i]
            logN = log[i]
            shell('''
                qualimap rnaseq --java-mem-size={params.nMemory} -s {params.lib} -oc count -gtf {input.annotation} -outdir 06_qualimap -outfile {report} -bam {inhead}  2>&1 | tee -a {logN}
                rm {insort} {inhead}
                '''
                )
