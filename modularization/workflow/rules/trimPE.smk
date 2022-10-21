rule trimpe:
    input:
        r1 = "data/{sample}_1.{ext}",
        r2 = "data/{sample}_2.{ext}"
    output:
        r1 = "trimmed/{sample}_1.{ext}",
        r2 = "trimmed/{sample}_2.{ext}",
        r1_unpaired = "trimmed/{sample}_1.se.{ext}",
        r2_unpaired = "trimmed/{sample}_2.se.{ext}"
    log:
        "trimmed/log/{sample}.{ext}.log"
    params:
        # list of trimmers (see manual)
        trimmer=["TRAILING:3"],
        # optional parameters
        extra="",
        compression_level="-9"
    threads: config['threads']
    wrapper:
        "master/bio/trimmomatic/pe"