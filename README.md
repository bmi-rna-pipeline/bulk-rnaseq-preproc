# RNA-Seq Pre-Processing Snakemake Pipeline
## RNA-Seq data pre-processing Snakemake Pipeline for BMI Lab, SNUH

### Snakemake 기본 설명

#### Getting Started
1. Environment Setup
    - 이미지로 도커 컨테이너를 만들어준다. 사용하는 서버에 snuhbmi/preproc 이미지가 없으면 docker pull을 먼저 해준다.
    
        ```bash
        docker pull snuhbmi/preproc
        docker run -it --memory="512G" --cpus=128 --name [본인이름_컨테이너명] snuhbmi/preproc
        ```
    
2. Snakemake directory preparation
    - Working directory로 사용할 폴더에 cd를 한 후, data와 genome 파일을 만들어준다.
        ```bash
        mkdir data genome
        ```
    - Working directory에 snakemake 파일들을 다운받는다.
        
        ```bash
        svn checkout https://github.com/bmi-rna-pipeline/bulk-rnaseq-preproc/trunk/workflow
        svn checkout https://github.com/bmi-rna-pipeline/bulk-rnaseq-preproc/trunk/scripts
        ```
        
    - Working directory의 폴더명은 원하는데로 수정할 수 있지만, 그 외의 폴더명 (data, genome, workflow)은 유지한다.
    - data 폴더에 전처리할 fastq파일을 저장하면 된다. {sample ID}\_{read number} 또는 SE의 경우 {sample ID}로 되어있어야 snakemake가 돌아가기 때문에 수정이 필요하면 한다.
        - PE의 경우: sample1_1.fastq, sample1_2.fastq.gz와 비슷한 형식
            - 예시: sample_001.fq.gz파일을  sample_1.fq.gz로 바꿔준다
                
                ```bash
                cd data
                rename "s/001.fq.gz/1.fq.gz/" *.fq.gz
                ```
                
        - SE의 경우: sample1.fq, sample2.fastq.gz와 비슷한 형식 (_1 또는 _2로 끝나지 않게끔 한다.)
        - 확장자를 확인 후 config 파일 수정

    - genome 파일은 reference fasta파일과 gtf/gff파일이 넣어야 된다.
        - Fasta 파일은 .fa 또는 .fasta 확장자 파일 한개 (여러개일 경우 오류가 생긴다)
        - gtf/gff 파일은 .gtf 또는 .gff3 확장자 파일 한개 (여러개일 경우 오류가 생기고, gtf 또는 gff3중 하나여야한다. 파일 확장자에 따라 config 파일 수정 필요.)
        - Fasta와 gtf/gff 파일명은 무관 
        - .gz 파일로 압축되어 있으면 gunzip으로 압축 해제 후 실행
    - snakemake를 실행 전 directory tree는 아래와 비슷한 형태여야한다. (Working Directory 이름은 본인이 설정)
        
        ```
        Working Directory
        |
        |
        └── scripts
        |	|  ref.py
        |	|  sample-sheet.py
        |
        └── workflow
        |	|  Snakefile
        |	|  config.yaml
        |	|  
        |	└── rules
        |		|  fastqc.smk
        |		|  trimPE.smk
        |		|  star.smk
        |		|  ...
        |
        └── data
        |	|  sample1_1.fastq.gz
        |	|  sample1_2.fastq.gz
        |	|  sample2_1.fastq.gz
        |	|  ...
        |
        └── genome
        	|  reference.fa
        	|  reference.gtf
        	|  ...
        ```

#### Configuration
- Configuration 설정
    - Snakefile 자체의 파라미터는 config 파일 위쪽 설정들을 수정
    - threads: 사용할 thread 수를 설정
        - 모든 툴이 이 설정을 따라 thread수를 정해 이용하게 되지만, snakemake의 cores 파라미터가 우선으로, 그에 따라 thread수도 조정이 될 수 있다.
    - stranded: stranded일 경우 True, unstranded인 경우 False로 설정
    - extension: raw 파일의 확장자
- Tools 설정
    - tools.yaml 파일에 사용할 tool을 True로 지정한다.
    - 기존에 있는 툴 외의 툴 사용시 https://github.com/bmi-rna-pipeline/snakemake-wrappers 에서 wrapper를 사용/수정/제작해서 rule을 만들 수 있다.

#### Snakemake 실행
- conda environment를 activate한다. Conda environment는 업데이트 될 수 있기 때문에 확인해준다: https://anaconda.org/snuhbmibi/bmipreproc
    ```bash
    mamba env create snuhbmibi/bmipreproc
    conda activate bmipreproc
    ```
 
 - Working directory에 cd가 되어있는 것을 확인 후 진행한다.
 - Snakemake 실행 전에 scripts 폴더의 파일들을 실행해준다.
    ```bash
    python ./scripts/ref.py
    python ./scripts/sample-sheet.py
    ```

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
- Bulk RNA-Seq 전처리의 흐름대로 실행된다고 보면 되지만, 필요한 파일이 존재하면 동시에 여러 rule이 진행될 수 있다. 순서는 개별 rule을 사용해서 바꿀 수 있고, 혹은 rule에 `priority: 1` 등 지정해줄 수 있다.

        # run fastqc rule independently
        snakemake fastqc --cores 2

        # run everything else
        snakemake --cores 2 --rerun-incomplete


#### Snakemake rules의 원리
- Snakemake는 각 rule의 output file들이 존재하지 않으면, 그 rule을 실행하여 output files가 만들어지도록 진행되는 과정이다.
- Snakemake는 각 rule의 실행에 필요한 input files가 존재해야 실행된다. 존재하지 않으면 input files가 나올 때까지 필요한 다른 rule들을 실행한다.
- Snakefile의 rule all의 input 파일들은 모든 rule들이 진행되면 생성될 output file들이다.

### Troubleshooting & Issues
- Snakemake 실행에 문제가 있으면, raw data와 genome reference 파일들을 (fasta, gtf/gff) 확인하고, 확장자와 형태가 맞는지 확인한다.
- Config 파일에 오타가 없고, 데이터에 맞도록 수정이 되어있음을 꼭 확인한다.
- 각 툴의 파라미터 설정에 오류가 있는 경우, 데이터와 파라미터가 맞지 않는 경우, 데이터에 문제가 있는 경우 등을 고려한다.
- Snakefile, config.yaml, 그리고 smk 파일의 코드에 오류가 있을 경우, GitHub 담당자에게 문의한다.
- 필요한 툴이 없는 경우, 직접 pull request를 하거나, new issue로 request를 한다.
