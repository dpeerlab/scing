version 1.0

task TagBam {

    input {
        File whitelist
        File inBam
        File inBai
        String outBam

        # docker-related
        String dockerRegistry
    }

    # .bai should be localized so that tag_bam.py can pick it up
    # otherwise, pysam.fetch will error out (called on bamfile without index)

    String dockerImage = dockerRegistry + "/seqc-utils:0.4.3"
    Float inputSize = size(whitelist, "GiB") + size(inBam, "GiB")

    command <<<
        set -euo pipefail

        # the index file is older than the data file
        touch ~{inBai}

        python3 /opt/tag_bam.py \
            --bam-in ~{inBam} \
            --bam-out ~{outBam} \
            --whitelist ~{whitelist}
    >>>

    output {
        File outTaggedBam = outBam
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk " + ceil(10 * (if inputSize < 1 then 5 else inputSize)) + " HDD"
        cpu: 4
        memory: "256 GB"
        preemptible: 0
    }
}
