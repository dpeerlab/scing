version 1.0

task CellBender {

    input {
        String sampleName
        File features
        File barcodes
        File matrix
        Boolean cuda
        Int expectedCells
        Float fpr = 0.01
        Int epochs = 150
    }

    String dockerImage = "us.gcr.io/broad-dsde-methods/cellbender:0.2.0"
    Float inputSize = size(features, "GiB") + size(barcodes, "GiB") + size(matrix, "GiB")

    command <<<
        set -euo pipefail

        mkdir -p data/
        mv ~{features} data/
        mv ~{barcodes} data/
        mv ~{matrix} data/

        cellbender remove-background ~{if cuda then '--cuda' else ''} \
            --input data/ \
            --output ~{sampleName}.h5 \
            --expected-cells ~{expectedCells} \
            --fpr ~{fpr} \
            --epochs ~{epochs}

        find .
    >>>

    output {
        # full count matrix with background RNA removed.
        # this file contains all the original droplet barcodes.
        File outH5 = sampleName + ".h5"

        # filtered count matrix with background RNA removed.
        # this file contains only the droplets which were determined to have a > 50% posterior probability of containing cells.
        File outFilteredH5 = sampleName + "_filtered.h5"

        # csv file containing all the droplet barcodes which were determined to have a > 50% posterior probability of containing cells.
        File outCellBarcodes = sampleName + "_cell_barcodes.csv"

        # pdf file that provides a standard graphical summary of the inference procedure.
        File outPdf = sampleName + ".pdf"

        # log file
        File outLog = sampleName + ".log"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 10 else inputSize)) + " HDD"
        cpu: 4
        memory: "32 GB"
    }
}
