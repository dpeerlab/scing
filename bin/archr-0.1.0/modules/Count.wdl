version 1.0

task Count {

    input {
        String sampleName
        String fastqNames
        Array[File] fastqFiles
        Map[String, String] referenceGenome

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

        # download reference
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
            --sample=~{fastqNames}

        # targz the analysis folder and pipestance metadata if successful
        if [ $? -eq 0 ]
        then
            tar czf ~{outBase}/analysis.tgz ~{outBase}/analysis/*
            tar czf ~{outBase}/pipestanceMeta.tgz ~{sampleName}/_*
        fi
    >>>

    output {
        File outBam = outBase + "/possorted_bam.bam"
        File outBai = outBase + "/possorted_bam.bam.bai"

        File outSummaryJson = outBase + "/summary.json"
        File outSummaryCsv = outBase + "/summary.csv"
        File outSummaryHtml = outBase + "/web_summary.html"
        File outPerBarcodeMetrics = outBase + "/singlecell.csv"

        File outPeaks = outBase + "/peaks.bed"
        File? outAnalysis = outBase + "/analysis.tgz"

        Array[File] outRawPeakBCMtx = glob(outBase + "/raw_peak_bc_matrix/*")
        File outRawPeakBCMtxHdf5 = outBase + "/raw_peak_bc_matrix.h5"

        Array[File] outFilteredPeakBCMtx = glob(outBase + "/filtered_peak_bc_matrix/*")
        File outFilteredPeakBCMtxHdf5 = outBase + "/filtered_peak_bc_matrix.h5"

        Array[File] outFilteredTFBCMtx = glob(outBase + "/filtered_tf_bc_matrix/*")
        File outFilteredTFBCMtxHdf5 = outBase + "/filtered_tf_bc_matrix.h5"

        File outLoupe = outBase + "/cloupe.cloupe"

        File outFragments = outBase + "/fragments.tsv.gz"
        File outFragmentsIndex = outBase + "/fragments.tsv.gz.tbi"

        File outPeakAnnotation = outBase + "/peak_annotation.tsv"
        File outPeakMotifMapping = outBase + "/peak_motif_mapping.bed"

        File outPipestanceMeta = outBase + "/pipestanceMeta.tgz"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 50 else inputSize)) + " HDD"
        cpu: 24
        memory: "160 GB"
    }
}
