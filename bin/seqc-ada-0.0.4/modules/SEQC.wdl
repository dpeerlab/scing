version 1.0

task SEQC {

    input {
        String version
        String assay
        String index
        String barcodeFiles
        Array[File] fastqGenomic
        Array[File] fastqBarcode
        String starArguments
        String outputPrefix
        String email

        String filterMode
        Int? maxInsertSize
        String? extraParameters

        Float inputSize = 250
        Int numCores = 4
        Int memoryGB = 100

        # docker-related
        String dockerRegistry
    }

    parameter_meta {
        version: { help: "must be 0.2.10 or higher" }
        filterMode : { help: "either scRNA-seq or snRNA-seq" }
        maxInsertSize : { help: "for snRNA-seq, 2304700 for hg38, 4434881 for mm38" }
        extraParameters: { help: "e.g. --no-filter-low-coverage --no-filter-mitochondrial-rna"}
    }

    String dockerImage = dockerRegistry + "/cromwell-seqc:" + version

    command <<<
        set -euo pipefail

        # aggregate all the genomic fastq files into a single directory
        mkdir -p fastq-genomic
        mv -v ~{sep=' ' fastqGenomic} ./fastq-genomic/

        # aggregate all the barcode fastq files into a single directory
        mkdir -p fastq-barcode
        mv -v ~{sep=' ' fastqBarcode} ./fastq-barcode/

        # `--local` still requires AWS region to be speicifed
        # set dummy region
        export AWS_DEFAULT_REGION=us-east-1

        # set max number of workers for UMI correction task
        export SEQC_MAX_WORKERS=~{numCores}

        # run locally and do not terminate
        SEQC run ~{assay} \
            --index ~{index} \
            --barcode-files ~{barcodeFiles} \
            --genomic-fastq ./fastq-genomic/ \
            --barcode-fastq ./fastq-barcode/ \
            --filter-mode ~{filterMode} ~{if defined(maxInsertSize) then '--max-insert-size ' + maxInsertSize else ''} \
            --min-poly-t 0 ~{if defined(extraParameters) then extraParameters else ''} \
            --star-args ~{starArguments} \
            --output-prefix ~{outputPrefix} \
            --email ~{email} \
            --local --no-terminate

        # hack: optional output doesn't seem to be supported
        if [ ! -r "~{outputPrefix}_umi-correction.csv.gz" ]
        then
            touch "~{outputPrefix}_umi-correction.csv.gz"
        fi

        find .
    >>>

    output {
        File alignedBam = outputPrefix + "_Aligned.out.bam"
        File mergedFastq = outputPrefix + "_merged.fastq.gz"

        File denseMatrix = outputPrefix + "_dense.csv"

        File sparseBarcodes = outputPrefix + "_sparse_counts_barcodes.csv"
        File sparseGenes = outputPrefix + "_sparse_counts_genes.csv"
        File sparseMoleculeCounts = outputPrefix + "_sparse_molecule_counts.mtx"
        File sparseReadCounts = outputPrefix + "_sparse_read_counts.mtx"

        Array[File] rawFeatureBCMatrix = glob("raw_feature_bc_matrix/*")

        File h5 = outputPrefix + ".h5"

        File miniSummaryPdf = outputPrefix + "_mini_summary.pdf"
        File miniSummaryJson = outputPrefix + "_mini_summary.json"
        File alignmentSummary = outputPrefix + "_alignment_summary.txt"
        File summary = outputPrefix + "_summary.tar.gz"

        Array[File] mast = glob(outputPrefix + "_cluster_*_mast_input.csv")
        File deGeneList = outputPrefix + "_de_gene_list.txt"

        File preCorrectionReadArray = "pre-correction-ra.pickle"
        File cbCorrection = outputPrefix + "_cb-correction.csv.gz"
        File umiCorrection = outputPrefix + "_umi-correction.csv.gz"

        File daskReport = "dask-report.html"
        File? log = outputPrefix + "_seqc_log.txt"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: memoryGB + "GB"
        preemptible: 0
    }
}
