if config['annotation'] == "gtf":
    annot = expand("generef/{ref}.gtf", ref=REF)
else:
    annot = expand("generef/{ref}.gff3", ref=REF)

rule refrsem:
    input:
        fa = expand("{path}/generef/{ref}.fa", path=DATAPATH, ref=REF),
        annotation = annot
    params:
        refname = REF,
        nthread = THREADS
    log:
        expand("generef/indices/{ref}_rsem.log", ref=REF)
    run:
        shell('''
            mkdir -p generef/indices
            touch {log}
            echo "RSEM Version:" 2>&1 | tee -a {log}
            rsem-calculate-expression --version 2>&1 | tee -a {log}
            echo "Creating index files for RSEM..." 2>&1 | tee -a {log}
            ''')
        if ORG == 'EUK':
            if config['annotation'] == "gtf":
                shell(
                    '''
                    rsem-prepare-reference \
                    --gtf {input.annotation} \
                    -p {params.nthread} \
                    {input.fa} \
                    ./generef/indices/{params.refname}_rsem 2>&1 | tee -a {log}
                    '''
                    )
            else:
                shell(
                    '''
                    rsem-prepare-reference \
                    --gff3 {input.annotation} \
                    -p {params.nthread} \
                    {input.fa} \
                    ./generef/indices/{params.refname}_rsem 2>&1 | tee -a {log}
                    '''
                    )
        else:
             shell(
                '''
                rsem-prepare-reference \
                --gff3 {input.annotation} \
                --gff3-genes-as-transcripts \
                -p {params.nthread} \
                {input.fa} \
                ./generef/indices/{params.refname}_rsem 2>&1 | tee -a {log}
                '''
                )