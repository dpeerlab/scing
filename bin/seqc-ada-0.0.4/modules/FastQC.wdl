version 1.0

task FastQC {

    input {
        File fastqFile

        # docker-related
        String dockerRegistry        
    }

    Int numCores = 4
    String dockerImage = dockerRegistry + "/cromwell-fastqc:0.11.9"
    Float inputSize = size(fastqFile, "GiB")
    String sampleName = basename(fastqFile, ".fastq.gz") 

    command <<<
        set -euo pipefail

        fastqc -o . ~{fastqFile}
    >>>

    output {
        File outHtml = sampleName + "_fastqc.html"
        File outZip = sampleName + "_fastqc.zip"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "16 GB"
    }
}
