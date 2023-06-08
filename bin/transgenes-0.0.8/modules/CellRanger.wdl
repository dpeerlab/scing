version 1.0

task mkref {

    input {
        String referenceName
        File fasta
        File gtf
        String cellRangerVersion

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/cromwell-cellranger:" + cellRangerVersion
    Float inputSize = size(fasta, "GiB") + size(gtf, "GiB")
    Int numCores = 15
    Int memoryGB = 100

    command <<<
        set -euo pipefail

        cellranger mkref \
            --genome=~{referenceName} \
            --fasta=~{fasta} \
            --genes=~{gtf} \
            --nthreads=~{numCores} \
            --memgb=~{memoryGB}

        tar cvzf ~{referenceName}.tar.gz ~{referenceName}
    >>>

    output {
        File outReferencePackage = referenceName + ".tar.gz"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 5 else inputSize )) + " HDD"
        cpu: numCores + 1
        memory: memoryGB + " GB"
    }
}
