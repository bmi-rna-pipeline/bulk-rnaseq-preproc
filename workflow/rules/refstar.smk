if config['annotation'] == "gtf":
    annot = expand("generef/{ref}.gtf", ref=REF)
else:
    annot = expand("generef/{ref}.gff3", ref=REF)

rule refstar:
    input:
        fa = expand("{path}/generef/{ref}.fa", path=DATAPATH, ref=REF),
        annotation = annot
    log:
        expand("generef/indices/{ref}_star.log", ref=REF)
    params:
        refname = REF
    run:
        shell('''
            mkdir -p generef/indices
            touch {log}
            echo "STAR Version:" 2>&1 | tee -a {log}
            STAR --version 2>&1 | tee -a {log}
            echo "Creating index files for STAR..." 2>&1 | tee -a {log}
            ''')
        if ORG == 'EUK':
            if config['annotation'] == "gtf":
                shell(
                    '''
                    STAR --runMode genomeGenerate --genomeDir generef/indices \
                    --genomeFastaFiles {input.fa} \
                    --sjdbGTFfile {input.annotation} \
                    --sjdbOverhang 100 --outFileNamePrefix {params.refname} 2>&1 | tee -a {log}
                    '''
                    )
            else:
                shell(
                    '''
                    STAR --runMode genomeGenerate --genomeDir generef/indices \
                    --genomeFastaFiles {input.fa} \
                    --sjdbGTFfile {input.annotation} \
                    --sjdbGTFtagExonParentTranscript Parent \
                    --sjdbOverhang 100 --outFileNamePrefix {params.refname} 2>&1 | tee -a {log}
                    '''
                    )
        else:
             shell(
                '''
                STAR --runMode genomeGenerate --genomeDir generef/indices \
                --genomeFastaFiles {input.fa} \
                --sjdbGTFfile {input.annotation} \
                --sjdbGTFfeatureExon exon \
                --sjdbGTFtagExonParentTranscript ID \
                --sjdbGTFtagExonParentGene Parent \
                --sjdbOverhang 0 --outFileNamePrefix {params.refname} 2>&1 | tee -a {log}
                '''
                )