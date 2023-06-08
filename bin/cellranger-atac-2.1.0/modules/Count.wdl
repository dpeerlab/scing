version 1.0

task Count {

    input {
        String sampleName
        String fastqNames
        Array[File] fastqFiles
        Map[String, String] referenceGenome
        String? chemistry

        # docker-related
        String dockerRegistry
    }

    String cellRangerAtacVersion = "2.1.0"
    String dockerImage = dockerRegistry + "/cromwell-cellranger-atac:" + cellRangerAtacVersion
    Float inputSize = size(fastqFiles, "GiB")

    # ~{sampleName} : the top-level output directory containing pipeline metadata
    # ~{sampleName}/outs/ : contains the final pipeline output files.
    String outBase = sampleName + "/outs"

    command <<<
        set -euo pipefail

        export MRO_DISK_SPACE_CHECK=disable

        path_input=`dirname ~{fastqFiles[0]}`

        echo ${path_input}

        # download reference package
        echo "*** Downloading Reference Package ***"
        curl -L --silent -o reference.tgz ~{referenceGenome["location"]}
        mkdir -p reference
        tar xvzf reference.tgz -C reference --strip-components=1
        chmod -R +r reference
        rm -rf reference.tgz

        # run pipeline
        cellranger-atac count \
            --id=~{sampleName} \
            --reference=./reference/ \
            --fastqs=${path_input} \
            --sample=~{fastqNames} ~{if defined(chemistry) then "--chemistry " + chemistry else ""}

        # targz the analysis folder and pipestance metadata if successful
        if [ $? -eq 0 ]
        then
            tar czf ~{outBase}/analysis.tgz ~{outBase}/analysis/*
        fi
    >>>

    output {

        File bam = outBase + "/possorted_bam.bam"
        File bai = outBase + "/possorted_bam.bam.bai"
        File summaryJson = outBase + "/summary.json"
        File summaryCsv = outBase + "/summary.csv"
        File summaryHtml = outBase + "/web_summary.html"
        File perBarcodeMetrics = outBase + "/singlecell.csv"

        File peaks = outBase + "/peaks.bed"
        File? secondaryAnalysis = outBase + "/analysis.tgz"

        Array[File] rawPeakBCMatrix = glob(outBase + "/raw_peak_bc_matrix/*")
        File rawPeakBCMatrixH5 = outBase + "/raw_peak_bc_matrix.h5"

        Array[File] filteredPeakBCMatrix = glob(outBase + "/filtered_peak_bc_matrix/*")
        File filteredPeakBCMatrixH5 = outBase + "/filtered_peak_bc_matrix.h5"

        Array[File] filteredTFBCMatrix = glob(outBase + "/filtered_tf_bc_matrix/*")
        File filteredTFBCMatrixH5 = outBase + "/filtered_tf_bc_matrix.h5"

        File cloupe = outBase + "/cloupe.cloupe"

        File fragments = outBase + "/fragments.tsv.gz"
        File fragmentsIndex = outBase + "/fragments.tsv.gz.tbi"

        File peakAnnotation = outBase + "/peak_annotation.tsv"
        File peakMotifMapping = outBase + "/peak_motif_mapping.bed"

        File pipestanceMeta = sampleName + "/" + sampleName + ".mri.tgz"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 50 else inputSize)) + " HDD"
        cpu: 24
        memory: "160 GB"
    }
}
