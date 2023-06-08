version 1.0

task scCB2 {

    input {
        String sampleName
        File sparseBarcodes
        File sparseGenes
        File sparseMoleculeCounts

        # docker-related
        String dockerRegistry
    }

    Float inputSize = size(sparseBarcodes, "GiB") + size(sparseGenes, "GiB") + size(sparseMoleculeCounts, "GiB")

    String dockerImage = dockerRegistry + "/sccb2:1.2.0"

    command <<<
        set -euo pipefail

        # input
        mkdir -p data
        mv ~{sparseBarcodes} data/
        mv ~{sparseGenes} data/
        mv ~{sparseMoleculeCounts} data/

        # output
        mkdir -p outs

        # run scCB2
        # arg1: sample name
        # arg2: path in
        # arg3: path out
        Rscript /opt/process-seqc-mtx.R \
            ~{sampleName} data/ outs/

        find .
    >>>

    output {
        File realCells = "./outs/" + sampleName + "_realdrops.csv"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 10 else inputSize)) + " HDD"
        cpu: 1
        memory: "32 GB"
    }
}