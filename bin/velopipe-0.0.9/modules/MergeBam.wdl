version 1.0

task MergeBam {

    input {
        Array[File] chunks
        String fileName
    }

    parameter_meta {
        chunks: "list of chunked BAM files to be merged"
        fileName: "name of the merged BAM filename"
    }

    String dockerImage = "broadinstitute/gatk:4.1.8.0"
    Float inputSize = size(chunks, "GiB")

    command <<<
        set -euo pipefail

        gatk MergeSamFiles \
            -I ~{sep=' -I ' chunks} \
            -O ~{fileName} \
            --CREATE_INDEX true \
            --USE_THREADING true
    >>>

    output {
        File outBam = fileName
        File outBai = basename(fileName, ".bam") + ".bai"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk " + ceil(10 * (if inputSize < 1 then 5 else inputSize)) + " HDD"
        cpu: 16
        memory: "32 GB"
        preemptible: 0
    }
}
