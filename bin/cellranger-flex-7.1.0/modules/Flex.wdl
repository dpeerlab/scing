version 1.0

task Flex {

    input {
        String sampleName
        File csv

        Float inputSize
        Int numCores = 16
        Int memory = 128

        String dockerRegistry
    }

    String cellRangerVersion = "7.1.0"
    String dockerImage = dockerRegistry + "/cromwell-cellranger:" + cellRangerVersion

    Int localMemory = floor(memory * 0.9)
    String outBase = sampleName + "/outs"

    command <<<
        set -euo pipefail

        export MRO_DISK_SPACE_CHECK=disable

        cellranger multi \
            --id=~{sampleName} \
            --csv=~{csv} 
    >>>

    output {
        String outputs = outBase
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 50 else inputSize)) + " HDD"
        cpu: numCores
        memory: memory + " GB"
    }
}
