version 1.0

task Vdj {

    input {
        String sampleName
        String fastqNames
        Array[File] inputFastq
        File referenceUrl
        String chain = "auto"

        # docker-related
        String dockerRegistry
    }

    String cellRangerVersion = "6.1.2"
    String referenceVersion = "5.0.0"

    String dockerImage = dockerRegistry + "/cromwell-cellranger:" + cellRangerVersion
    Float inputSize = size(inputFastq, "GiB")

    # ~{sampleName} : the top-level output directory containing pipeline metadata
    # ~{sampleName}/outs/ : contains the final pipeline output files.
    String outBase = sampleName + "/outs"

    command <<<
        set -euo pipefail

        export MRO_DISK_SPACE_CHECK=disable

        # copy reference
        cp ~{referenceUrl} reference.tgz
        mkdir -p reference
        tar xvzf reference.tgz -C reference --strip-components=1
        chmod -R +r reference
        rm -rf reference.tgz

        path_input=`dirname ~{inputFastq[0]}`

        # run pipeline
        cellranger vdj \
            --id=~{sampleName} \
            --sample ~{fastqNames} \
            --reference ./reference/ \
            --fastqs=${path_input} \
            --chain ~{chain}

        find ./~{sampleName}

        tar cvzf vdj_reference.tgz ~{outBase}/vdj_reference/*
    >>>

    output {
        File outputs = outBase
        Array[File] annotationFiles = glob(outBase + "/*_annotations.*")
        Array[File] fastaFiles = glob(outBase + "/*.fasta*")
        Array[File] fastqFiles = glob(outBase + "/*.fastq")
        Array[File] bamFiles = glob(outBase + "/*.bam*")
        File cellBarcodes = outBase + "/cell_barcodes.json"
        File vloupe = outBase + "/vloupe.vloupe"
        File webSummary = outBase + "/web_summary.html"
        File metricsSummary = outBase + "/metrics_summary.csv"
        File clonotypes = outBase + "/clonotypes.csv"
        File airr = outBase + "/airr_rearrangement.tsv"
        File allContigProtoBuf = outBase + "/vdj_contig_info.pb"
        File vdjReference = "vdj_reference.tgz"

        File pipestanceMeta = sampleName + "/" + sampleName + ".mri.tgz"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk 1500 SSD"
        cpu: 16
        memory: "128 GB"
    }
}
