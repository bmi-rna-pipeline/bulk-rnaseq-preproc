# RNA-Seq Pre-Processing Snakemake Pipeline
## RNA-Seq data pre-processing Snakemake Pipeline for BMI Lab, SNUH

### Snakemake 기본 설명

#### Quick Snakemake Guide
1. Working directory에 data, genome, config 폴더를 만든다.
    - genome 폴더: reference genome의 fasta 파일과 gtf/gff 파일이 존재해야함
    - data 폴더: raw 파일이 존재해야함
2. Snakemake가 설치된 conda environment를 activate한다.
3. github에서 snakemake관련 파일을 받는다.
4. tools.yaml에 사용할 툴을 지정하고, params.yaml에서 파라미터와 threads, strandedness, PE/SE 설정을 한다.
5. Snakemake 실행 전에 scripts 폴더의 파일들을 실행해준다.
6. Snakemake를 실행한다.
        ```bash
        # dry run
        snakemake -n
        
        # run snakemake
        snakemake --cores 4
        ```

#### Checklist
1. raw 파일과 reference genome 파일이 형식에 맞는 것을 확인.
    - raw files: 
        - PE일 경우 {sample ID}\_1 {sample ID}\_2 형식.
        - SE의 경우 {sample ID}\_se 형식.
        - 확장자: .fastq, .fq, .fastq.gz 또는 .fq.gz 형식.
    - reference genome:
        - fasta 파일: .fasta 또는 .fa 형식.
        - annotation: .gtf, .gff 또는 .gff3 형식.
        - scripts/ref.py 실행후 파일명이 변경될 경우 파일명을 도로 수정하면 안됨.
2. script 실행 후 config 폴더에 csv 파일이 두개가 생긴 것을 확인.
    - samples.csv: raw 파일의 샘플명, read, 파일 경로등 저장되어있는 파일
    - genome.csv: reference genome 파일에 대한 정보
2. tools.yaml과 params.yaml 파일 내용 확인.

#### Getting Started
1. Environment Setup
    - 이미지로 도커 컨테이너를 만들어준다. 사용하는 서버에 snuhbmi/preproc 이미지가 없으면 docker pull을 먼저 해준다.
    
        ```bash
        docker pull snuhbmi/preproc
        docker run -it --memory="512G" --cpus=128 --name [본인이름_컨테이너명] snuhbmi/preproc
        ```
    - conda environment를 activate한다. Conda environment는 업데이트 될 수 있기 때문에 확인해준다: https://anaconda.org/snuhbmibi/bmipreproc
        ```bash
        # when creating new environment
        mamba env create snuhbmibi/bmipreproc
        # activate environment
        conda activate bmipreproc
        ```
2. Snakemake directory
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
        |	|  sample_se.fastq.gz
        |	|  ...
        |
        └── config
        |	|  
        |	|  samples.csv
        |	|  genome.csv
        |
        └── genome
        	|  reference.fa
        	|  reference.gtf
        	|  ...
        ```
