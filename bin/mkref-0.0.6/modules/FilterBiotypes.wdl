version 1.0

task FilterBiotypes {

    input {
        Array[String] biotypes
        File gtf

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/gtf-utils:0.0.6"
    Float inputSize = size(gtf, "GiB")

    command <<<
        set -euo pipefail

        python3 /opt/filter_biotypes.py \
            --in ~{gtf} \
            --out annotations.gtf \
            --biotypes ~{sep=" " biotypes}
    >>>

    output {
        File outGtf = "annotations.gtf"
        File outLog = "filter_biotypes.log"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(10 * (if inputSize < 1 then 5 else inputSize)) + " HDD"
        cpu: 4
        memory: "64 GB"
    }
}
