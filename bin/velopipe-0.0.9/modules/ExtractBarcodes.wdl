version 1.0

task ExtractBarcodes {

    input {
        File filteredBarcodes

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/seqc-utils:0.5.2"
    Float inputSize = size(filteredBarcodes, "GiB")

    command <<<
        set -euo pipefail

        # get the error-corrected barcodes from the counts matrix
        python3 /opt/extract_barcodes.py \
            --input ~{filteredBarcodes} \
            --outdir results
    >>>

    output {
        File outFilteredBarcodesACGT = "results/barcodes.acgt.txt"
        File outFilteredBarcodes1234 = "results/barcodes.1234.txt"
        File outLog = "extract_barcodes.log"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk " + ceil(10 * (if inputSize < 1 then 5 else inputSize)) + " HDD"
        cpu: 1
        memory: "16 GB"
        preemptible: 0
    }
}
