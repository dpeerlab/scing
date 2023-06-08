version 1.0

task ToAnnData {

    input {
        String sampleName
        File denseMatrix
        File sparseBarcodes
        File sparseGenes
        File sparseMoleculeCounts
        File sparseReadCounts

        Int memoryGB

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/seqc-basic-analysis:0.0.11"
    Float inputSize = size(denseMatrix, "GiB") + size(sparseBarcodes, "GiB") + size(sparseGenes, "GiB") + size(sparseMoleculeCounts, "GiB")  + size(sparseReadCounts, "GiB")

    command <<<
        set -euo pipefail

        mkdir -p data
        mv ~{denseMatrix} data/
        mv ~{sparseBarcodes} data/
        mv ~{sparseGenes} data/
        mv ~{sparseMoleculeCounts} data/
        mv ~{sparseReadCounts} data/

        papermill \
            /opt/to-adata.ipynb to-adata.ipynb \
            --parameters path_data data \
            --parameters path_out . \
            --parameters sample_name ~{sampleName} \
            --stdout-file to-adata.stdout.txt \
            --log-output
    >>>

    output {
        File filteredH5ad = sampleName + ".filtered.h5ad"
        File rawH5ad = sampleName + ".raw.h5ad"
        File notebookStdout = "to-adata.stdout.txt"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk 10 HDD"
        cpu: 1
        memory: memoryGB + " GB"
    }
}
