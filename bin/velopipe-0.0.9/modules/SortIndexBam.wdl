version 1.0

task SortIndexBam {

    input {
        File inBam

        # docker-related
        String dockerRegistry         
    }

    String dockerImage = dockerRegistry + "/cromwell-samtools:1.9"
    Float inputSize = size(inBam, "GiB")
    Int numCores = 8

    String outBam = basename(inBam, ".bam") + ".sorted.bam"

    command <<<
        set -euo pipefail

        # sort by position
        samtools sort --threads ~{numCores} -o ~{outBam} ~{inBam}
        # index
        samtools index ~{outBam}
    >>>

    output {
        File outSortedBam = outBam
        File outSortedBai = outBam + ".bai"
    }

    # 2GB per core is not enough and will fail.
    runtime {
        docker: dockerImage
        # disks: "local-disk " + ceil(10 * (if inputSize < 5 then 1 else inputSize)) + " HDD"
        cpu: numCores
        memory: "64 GB"
        preemptible: 0
    }
}
