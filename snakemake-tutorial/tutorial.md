# Snakemake Pipeline Tutorial

#### Setup
0. Download
    - Github에서 sample data와 reference를 다운받는다.
    
1. Data setup
    - “data” 폴더를 보면 샘플 데이터가 포함되어 있다.
        - 샘플 데이터는 Saccharomyces cerevisiae (yeast) fastq파일로, **[GSE212193](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE212193)**의 일부 데이터이다.
        - wt_KOH_ls_y3 샘플의 read 1과 2, wt_ctrl_ls_y1 샘플의 read 1과 2가 있는 PE 데이터이다.
    - 먼저, “data” 폴더를 확인하고, fastq.gz 또는 fq.gz 파일인지 확인한다.
        - 투토리얼 샘플 데이터는 gz로 압축되어있지 않은 파일이므로, 압축을 해준다.
            
            ```bash
            cd data
            gzip *
            ```
            
        - 만약 read 1과 2가 각각 “_1”과 “_2”로 끝나지 않으면, 바꿔주어야 한다. 
        투토리얼 샘플 데이터는 “_r1”, “_r2”의 형식이기 때문에, 아래와 같이 바꾼다.
            
            ```bash
            rename "s/_r1.fastq.gz/_1.fastq.gz/" *.fastq.gz
            rename "s/_r2.fastq.gz/_2.fastq.gz/" *.fastq.gz
            ```
            

2. Reference files setup
    - 투토리얼 샘플의 “generef” 폴더를 보면 Saccharomyces cerevisiae (yeast)에 대한 fasta 파일과 gtf 파일이 포함되어있다.
    - 투토리얼 샘플 reference 파일들은 gz로 압축되어있기 때문에, 압축을 풀어준다.
        
        ```bash
        cd generef
        gunzip *
        ```

    - fasta 파일과 gtf 파일의 파일명이 일치해야하지만, snakemake 실행시, 자동으로 gtf 파일명이 fasta 파일과 동일하도록 수정되기 때문에 직접 수정할 필요는 없다.

3. Config 파일 setup
    - config.yaml 파일을 확인해, 수정할 항목을 수정하여 저장한다 (chmod으로 권한 수정을 해야할수도 있다).
        - stranded: True or False로 설정 (투토리얼 샘플 데이터는 True)
        - sortmeRNA: True or False로 설정. rRNA를 제거해야 하는 경우 True로 설정해준다.
            - 투토리얼에서는 True로 설정하여 직접 해보면 좋지만, 오래 걸리기 때문에 만약 시간이 부족하면 False로 설정해도 된다.
        - rRNApath: rRNA database가 있는 폴더의 absolute path를 지정해준다.
            - sortmeRNA가 False인 경우, 지정을 하지 않거나, #를 달아주어도 무관.
            - rRNA database가 없는 경우 원하는 경로에 다운로드 후 config 파일에 경로 수정.
                
                ```bash
                mkdir /home/rnadb
                cd /home/rnadb
                wget https://github.com/biocore/sortmerna/releases/download/v4.3.4/database.tar.gz
                tar -xvf database.tar.gz
                rm database.tar.gz
                ```

        - annotation: 가지고 있는 annotation 파일 확장자에 따라 gtf 또는 gff 둘 중 하나로 수정해준다. 투토리얼에서는 annotation파일이 gtf 파일이므로 gtf로 되어있음을 확인한다.
        - organism: Eukaryote면 EUK, prokaryote면 PRO라고 해준다. 투토리얼 샘플 데이터는 eukaryote이므로 EUK로 되어있음을 확인한다.
        - adapter: adapter명을 필요대로 수정해준다. 투토리얼에서는 “TruSeq3-PE.fa:2:30:10”으로 되어있음을 확인한다.
        - STAR options: Eukaryote와 prokaryote 설정이 나눠져있다. 필요시 수정하면 되지만, 일단 투토리얼에서는 그대로 진행한다.


#### Snakemake 실행
Snakemake 실행
- Working directory에 cd 해준다. 투토리얼은 snakemake-tutorial 폴더에 cd되어있으면 된다.
    
    ```bash
    cd snakemake-tutorial
    ```
    
- 일단, dry run을 실행해주어, 코드나 파일명에 문제가 없는지 확인한다. 만약 여기서 에러가 난다면, data 폴더와 generef 폴더의 파일들의 확장자와 형식을 다시 확인한다.
    
    ```bash
    snakemake -n
    ```
    
- Dry run이 정상적으로 진행된다면, core 수를 정해서 snakemake를 실행해준다.
    - 전체실행
        
        ```bash
        snakemake --cores 2
        ```
        
    - 각 툴 실행 예시
        
        ```bash
        # run fastqc
        snakemake fastqc --cores 2
        
        # run trimmomatic
        snakemake trim --cores 2
        
        # run STAR
        snakemake star --cores 2
        ```
        
        - 만약 순서대로 진행하지 않은 경우, snakemake에서 필요한 rule을 먼저 실행한다. 예를 들어, star rule을 실행했는데 “02_trimmomatic” 폴더에 필요한 파일들이 없는 경우, trim rule이 먼저 실행 된다.
    - snakemake 정지 혹은 오류 후, `--rerun-incomplete` 옵션을 사용하여 다시 진행할 수 있다.
        
        ```bash
        # run full pipeline
        snakemake --cores 2 --rerun-incomplete
        
        # or run one rule of pipeline
        snakemake rsem --cores 2 --rerun-incomplete
        ```

Data source:

[Mangkalaphiban K, He F, Ganesan R, Wu C et al. Transcriptome-wide investigation of stop codon readthrough in Saccharomyces cerevisiae. PLoS Genet 2021 Apr;17(4):e1009538. PMID: 33878104](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE162780)