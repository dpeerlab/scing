version 1.0

task Count {

    input {
        String sampleName
        String fastqName
        Array[File] inputFastq
        String referenceUrl

        File heImage
        # File? darkImage
        # File? colorizedImage

        String slideSerialNumber
        String areaId

        Boolean reorientImages

        # docker-related
        String dockerRegistry
    }

    parameter_meta {
        heImage: "Brightfield tissue H&E image in .jpg or .tiff format."
    }

    String spaceRangerVersion = "1.3.1"
    String dockerImage = dockerRegistry + "/cromwell-spaceranger:" + spaceRangerVersion
    Float inputSize = size(inputFastq, "GiB") + size(heImage, "GiB")

    # ~{sampleName} : the top-level output directory containing pipeline metadata
    # ~{sampleName}/outs/ : contains the final pipeline output files.
    String outBase = sampleName + "/outs"

    command <<<
        set -euo pipefail

        export MRO_DISK_SPACE_CHECK=disable

        # download reference
        curl -L --silent -o reference.tgz ~{referenceUrl}
        ref_dir="$(basename ~{referenceUrl} .tar.gz)"
        mkdir -p ${ref_dir}
        tar xvzf reference.tgz -C ${ref_dir} --strip-components=1
        chmod -R +r ${ref_dir}
        rm -rf reference.tgz

        # path to input fastq files
        path_input=`dirname ~{inputFastq[0]}`

        # run pipeline
        spaceranger count \
            --id=~{sampleName} \
            --transcriptome=${ref_dir}/ \
            --fastqs=${path_input} \
            --sample=~{fastqName} \
            --image=~{heImage} \
            --slide=~{slideSerialNumber} \
            --area=~{areaId} ~{true='--reorient-images' false='' reorientImages}

        if [ $? -eq 0 ]
        then
            tar cvzf spatial.tgz ~{outBase}/spatial/*

            tar cvzf filtered_feature_bc_matrix.tgz ~{outBase}/filtered_feature_bc_matrix/*

            tar cvzf raw_feature_bc_matrix.tgz ~{outBase}/raw_feature_bc_matrix/*

            tar cvzf analysis.tgz ~{outBase}/analysis/*
        fi
    >>>

    output {

        # - Run summary HTML:                         /opt/sample345/outs/web_summary.html
        File webSummary = outBase + "/web_summary.html"

        # - Outputs of spatial pipeline:              /opt/sample345/outs/spatial
        File spatial = "spatial.tgz"

        # - Run summary CSV:                          /opt/sample345/outs/metrics_summary.csv
        File metricsSummary = outBase + "/metrics_summary.csv"

        # - BAM:                                      /opt/sample345/outs/possorted_genome_bam.bam
        File bam = outBase + "/possorted_genome_bam.bam"

        # - BAM index:                                /opt/sample345/outs/possorted_genome_bam.bam.bai
        File bai = outBase + "/possorted_genome_bam.bam.bai"

        # - Filtered feature-barcode matrices MEX:    /opt/sample345/outs/filtered_feature_bc_matrix
        File filteredFeatureBarcodeMatrix = "filtered_feature_bc_matrix.tgz"

        # - Filtered feature-barcode matrices HDF5:   /opt/sample345/outs/filtered_feature_bc_matrix.h5
        File filteredFeatureBarcodeMatrixH5 = outBase + "/filtered_feature_bc_matrix.h5"

        # - Unfiltered feature-barcode matrices MEX:  /opt/sample345/outs/raw_feature_bc_matrix
        File rawFeatureBarcodeMatrix = "raw_feature_bc_matrix.tgz"

        # - Unfiltered feature-barcode matrices HDF5: /opt/sample345/outs/raw_feature_bc_matrix.h5
        File rawFeatureBarcodeMatrixH5 = outBase + "/raw_feature_bc_matrix.h5"

        # - Secondary analysis output CSV:            /opt/sample345/outs/analysis
        File analysis = "analysis.tgz"

        # - Per-molecule read information:            /opt/sample345/outs/molecule_info.h5
        File perMoleculeInfo = outBase + "/molecule_info.h5"

        # - Loupe Browser file:                       /opt/sample345/outs/cloupe.cloupe
        File loupe = outBase + "/cloupe.cloupe"

        # - Spatial Enrichment using Moran I file:    /opt/sample345/outs/spatial_enrichment.csv
        File spatialEnrichment = outBase + "/spatial_enrichment.csv"

        # pipestance metadata
        File pipestanceMeta = sampleName + "/" + sampleName + ".mri.tgz"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 50 else inputSize)) + " HDD"
        cpu: 32
        memory: "128 GB"
    }
}
