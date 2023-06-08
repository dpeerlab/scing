version 1.0

task SortByBarcode {

    input {
        File inBam

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/cromwell-samtools:1.9"
    Float inputSize = size(inBam, "GiB")
    Int numCores = 8

    String outBam = "cellsorted_" + basename(inBam)

    command <<<
        set -euo pipefail

        # only sort by CB (cellular barcode), no index
        # because chromosome blocks not continuous
        samtools sort \
            --threads ~{numCores} \
            -t CB \
            -O BAM \
            -o ~{outBam} \
            ~{inBam}

        # samtools sort \
        #     -l 7 \
        #     -m 6G \
        #     --threads ~{numCores} \
        #     -t CB \
        #     -O BAM \
        #     -o ~{outBam} \
        #     ~{inBam}
    >>>

    output {
        File outSortedBam = outBam
    }

    # 2GB per core is not enough and will fail.
    runtime {
        docker: dockerImage
        # disks: "local-disk " + ceil(10 * (if inputSize < 1 then 5 else inputSize)) + " HDD"
        cpu: numCores
        memory: "64 GB"
        preemptible: 0
    }
}
