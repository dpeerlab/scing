version 1.0

task GenerateIndex {

    input {
        File genomeReferenceFasta
        Array[File] customFasta
        File annotationGtf
        Int sjdbOverhang
        String starVersion

        # docker-related
        String dockerRegistry
    }

    parameter_meta {
        starVersion: "e.g. 2.5.3a, 2.7.6a"
    }

    String dockerImage = dockerRegistry + "/cromwell-star:" + starVersion
    Float inputSize = size(genomeReferenceFasta, "GiB") + size(annotationGtf, "GiB") + size(customFasta, "GiB")

    # m5.12xlarge = 45
    Int numCores = 15

    String outputDir = "out"

    command <<<
        set -euo pipefail

        mkdir -p ~{outputDir}

        STAR \
            --runMode genomeGenerate \
            --genomeDir ~{outputDir} \
            --genomeFastaFiles ~{genomeReferenceFasta} ~{sep=" " customFasta} \
            --sjdbGTFfile ~{annotationGtf} \
            --sjdbOverhang ~{sjdbOverhang} \
            --runThreadN ~{numCores}


        # to make it SEQC compatible
        cp ~{annotationGtf} out/annotations.gtf
    >>>

    output {
        Array[File] outFiles = glob(outputDir + "/*")
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(30 * (if inputSize < 1 then 1 else inputSize)) + " HDD"
        cpu: numCores
        memory: "100 GB"
        preemptible: 0
    }
}
