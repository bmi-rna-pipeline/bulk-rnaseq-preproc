# RNA-Seq Pre-Processing Snakemake Pipeline
## RNA-Seq data pre-processing Snakemake Pipeline for BMI Lab, SNUH

### Snakemake 기본 설명

#### Getting Started
1. Environment Setup
    - 도커 이미지로 도커 컨테이너를 만들어준다
    
        ```bash
        docker run -it --memory="512G" --cpus=128 --name [본인이름_컨테이너명] bmi_rnaseq_preproc
        ```
    
2. Snakemake directory preparation
    - Snakemake 파일들을 다운받고 unzip한다.
        
        ```bash
        
        ```
        
    - ‘SnakemakeFiles’ 폴더명을 원하는데로 수정할 수 있지만, SnakemakeFiles내의 폴더명 (data, generef, workflow)은 유지한다.
    - data 폴더에 전처리할 fastq파일을 저장하면 된다. {sample ID}_{read number}.fastq.gz 또는 {sample ID}_{read number}.fq.gz 로 되어있어야 snakemake가 돌아가기 때문에 수정해야한다면 해야한다.
        - PE의 경우: sample1_1.fastq.gz, sample1_2.fastq.gz와 비슷한 형식
            - 예시: sample_001.fq.gz파일을  sample_1.fq.gz로 바꿔준다
                
                ```bash
                cd data
                rename "s/001.fq.gz/1.fq.gz/" *.fq.gz
                ```
                
        - SE의 경우: sample1_SE.fastq.gz, sample2_SE.fastq.gz와 비슷한 형식
            - 예시: sample1.fq.gz를 sample1_SE.fz.gz로 바꿔준다
                
                ```bash
                cd data
                rename "s/.fq.gz/_SE.fq.gz/" *.fq.gz
                ```
                

    - generef 파일은 reference fasta파일과 gtf/gff파일이 넣어야 된다.
        - Fasta 파일은 .fa 또는 .fasta 확장자 파일 한개 (여러개일 경우 오류가 생긴다)
        - gtf/gff 파일은 .gtf 또는 .gff3 확장자 파일 한개 (여러개일 경우 오류가 생기고, gtf 또는 gff3중 하나여야한다. 파일 확장자에 따라 config 파일 수정 필요.)
        - Fasta와 gtf/gff 파일명은 무관 
        - .gz 파일로 압축되어 있으면 gunzip으로 압축 해제 후 실행
    - snakemake를 실행 전 directory tree는 아래와 비슷한 형태여야한다. (Working Directory 이름은 본인이 설정)
        
        ```
        Working Directory
        |
        └── workflow
        |	|  Snakefile
        |	|  config.yaml
        |	|  
        |	└── rules
        |		|  fastqc.smk
        |		|  trim.smk
        |		|  star.smk
        |		|  ...
        |
        └── data
        |	|  sample1_1.fastq.gz
        |	|  sample1_2.fastq.gz
        |	|  sample2_1.fastq.gz
        |	|  ...
        |
        └── generef
        |	|  reference.fa
        |	|  reference.gtf
        |	|
        |
        └── rrnadb (optional)
        	| 
        	| ...
        ```
        
    - sortmeRNA를 돌려야하는 경우, 원하는 경로에 rRNA database를 다운받아, config파일에서 rRNApath를 수정한다.
        
        ```bash
        mkdir rrnadb
        cd rrnadb
        wget https://github.com/biocore/sortmerna/releases/download/v4.3.4/database.tar.gz
        tar zcf database.tar.gz
        rm database.tar.gz
        ```


#### Configuration and snakefile
- Configuration 설정
    - Snakefile 자체의 파라미터는 config 파일 위쪽 설정들을 수정
    - threads: 사용할 thread 수를 설정
        - 모든 툴이 이 설정을 따라 thread수를 정해 이용하게 되지만, snakemake의 cores 파라미터가 우선으로, 그에 따라 thread수도 조정이 될 수 있다.
    - stranded: stranded일 경우 True, unstranded인 경우 False로 설정
    - sortmeRNA: rrna 필터링을 할지에 따라 True 또는 False로 설정.
        - False로 설정 후 rrna 필터링을 하려고 하면 오류가 난다.
        - 분석 진행 중 rrna 필터링이 필요하다고 생각되면 config 파일을 수정 후 rrna rule을 실행하면 된다.
        - rRNApath는 rRNA database 폴더의 full path를 적어준다.
    - organism: EUK 또는 PRO로 설정
        - Eukaryote면 EUK, prokaryote면 PRO로 지정한다.
        - STAR의 설정이 organism 값에 맞춰 바뀐다. 세부적 파라미터는 직접 수정 필요.
    - annotation: 사용할 annotation 파일 확장자에 따라 gtf 또는 gff으로 설정
    - adapter options: trimmomatic에서 사용할 adapter 위치 등 설정
    - STAR parameters
        - organism의 설정 따라 자동으로 정해진다.
        - 세부 파라미터 수정과 추가는 필요시 가능.
        - 매뉴얼 참고: [STAR Manual](https://github.com/alexdobin/STAR/blob/master/doc/STARmanual.pdf)

- Snakefile의 기본 설명
    - Snakefile을 보면 위쪽에는 wildcard들을 정해놨다.
        - THREADS는 사용할 threads를 config.yaml에서 지정하면 된다.
        - DATAPATH는 current working directory로 정해진다. (working directory내에 cd되어있는 상태로 snakemake를 사용해야한다.)
        - SAMPLES는 data 파일에 있는 샘플명으로 지정된다. (test_1.fq.gz, test_2.fq.gz, sample_1.fq.gz, sample_2.fq.gz의 파일들이 있는 경우 SAMPLES는 'test'와 'sample'로 설정된다.)
        - ENDS는 data 파일에 {SAMPLES}_2.fq.gz 파일이 존재하면 “PE”, _SE.fq.gz와 같은 파일이 존재하면 “SE”로 설정된다.
        - READS는 ENDS의 값이 “PE”면 1과 2로 설정되고, “SE”면 SE로 설정된다.
        - REF은 fasta파일의 이름으로 설정된다. (gtf/gff 파일 이름이 fasta파일과 같은 이름으로 자동으로 수정된다.)
        - STRAND는 config.yaml 파일을 통해 설정한다..
        - ORG는 config.yaml에서 EUK 또는 PRO로 설정한다.
    - Snakefile의 rule all input들은 최종적으로 나올 모든 rule들의 output file 이름들이다.
        - rrna 필터링을 True로 하는 경우에는 rule all input에 sortmeRNA output 파일이 추가된다.

#### Snakemake 실행
- Working directory에 cd가 되어있는 것을 확인 후 진행한다.
- 일단 dry run을 실행해본다. Dry run은 실제로 돌아가는 것이 아니기 때문에 dry run이 된다고 해도 파이프라인 전체가 된다는 보장은 아니다.
    
    ```bash
    snakemake -n
    ```
    
- snakemake는 전체를 한꺼번에 돌리거나,
    
    ```bash
    snakemake --cores 2
    ```
    
    rule 하나씩 돌릴 수 있다. Rules의 이름은 rules폴더의 smk파일들의 이름과 동일하다.
    
    `--cores` 로 core 수를 설정해줘야한다.
    
    ```bash
    snakemake fastqc --cores 2
    snakemake trim --cores 2
    ```
    
- 중간에 에러가 나거나 멈추면, `--rerun-incomplete` 으로 이어서 돌릴 수 있다
    
    ```bash
    snakemake --cores 2 --rerun-incomplete
    ```

### Snakemake 과정

#### Rules 실행 순서
- Bulk RNA-Seq 전처리의 흐름대로 실행된다고 보면 되지만, 필요한 파일이 존재하면 동시에 여러 rule이 진행될 수 있다.
    - 예시: fastq 파일을 사용하는 rules, fastqc와 trim 둘이 동시에 실행될 수 있다. Raw 파일의 quality control report를 먼저 보고 trimming을 하고 싶으면, fastqc 룰을 개별로 먼저 진행한 후 나머지는 진행해도 좋다.

        ```bash
        # run fastqc rule independently
        snakemake fastqc --cores 2

        # run everything else
        snakemake --cores 2 --rerun-incomplete
        ```
- 각 rule을 실행시 과정:
    1. fastqc: quality control of raw data
    2. trim: trimming과 trimmed data의 qc
    3. rrna: filtering rRNA과 filtered data의 qc (optional)
    4. refstar, refrsem: create reference index for alignment and quantification
    4. star: alignment
    5. rsem: quantification

#### Snakemake rules의 원리
- Snakemake는 각 rule의 output file들이 존재하지 않으면, 그 rule을 실행하여 output files가 만들어지도록 진행되는 과정이다.
- Snakemake는 각 rule의 실행에 필요한 input files가 존재해야 실행된다. 존재하지 않으면 input files가 나올 때까지 필요한 다른 rule들을 실행한다.
- Snakefile의 rule all의 input 파일들은 모든 rule들이 진행되면 생성될 output file들이다.

### Troubleshooting & Issues
- Snakemake 실행에 문제가 있으면, raw data와 (fastq) genome reference 파일들을 (fasta, gtf/gff) 확인하고, 확장자와 형태가 맞는지 확인한다.
- Config 파일에 오타가 없고, 데이터에 맞도록 수정이 되어있음을 꼭 확인한다.
- 각 툴의 파라미터 설정에 오류가 있는 경우, 데이터와 파라미터가 맞지 않는 경우, 데이터에 문제가 있는 경우 등을 고려한다.
- Snakefile, config.yaml, 그리고 smk 파일의 코드에 오류가 있을 경우, GitHub 담당자에게 문의한다.
