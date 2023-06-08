version 1.0

task ConcatenateFastas {

    input {
        File genomeReferenceFasta
        Array[File] customFastaFiles

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/htslib:1.9"
    Float inputSize = size(genomeReferenceFasta, "GiB") + size(customFastaFiles, "GiB")
    Int numCores = 4

    String outName = "customGenome.fa"

    command <<<
        set -euo pipefail

        # concatenate
        cat ~{genomeReferenceFasta} ~{sep=" " customFastaFiles} > ~{outName}

        # comrpess
        bgzip \
            --threads ~{numCores} \
            --index \
            --index-name ~{outName}.gz.gzi \
            --stdout ~{outName} > ~{outName}.gz
    >>>

    output {
        File out = outName
        File outBgzip = outName + ".gz"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "16 GB"
        preemptible: 0
    }
}

task IndexCompressedFasta {

    input {
        File compressedFasta

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/cromwell-samtools:1.9"
    Float inputSize = size(compressedFasta, "GiB")
    Int numCores = 1

    String baseName = basename(compressedFasta, ".fa.gz")

    command <<<
        set -euo pipefail

        # workaround to make it easy for Cromwell to pick up .fa.fai
        # i.e. work from the current directory where Cromwell put you in
        cp ~{compressedFasta} ~{baseName}.fa.gz
        samtools faidx ~{baseName}.fa.gz
    >>>

    output {
        File outGzi = baseName + ".fa.gz.gzi"
        File outFai = baseName + ".fa.gz.fai"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "8 GB"
        preemptible: 0
    }
}
