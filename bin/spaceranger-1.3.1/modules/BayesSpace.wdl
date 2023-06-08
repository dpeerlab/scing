version 1.0

task BayesSpace {

    input {
        String sampleName
        File spatial
        File filteredFeatureBarcodeMatrix
        Int numClusters
        Int numHvg
        Int numPca

        # docker-related
        String dockerRegistry
    }

    parameter_meta {
        sampleName: "sample name supplised to Space Ranger via --id"
        spatial: "tarball-gzipped outputs of spatial pipeline"
        filteredFeatureBarcodeMatrix: "tarball-gzipped filtered feature-barcode matrix with the output subdirectories retained"
    }

    String dockerImage = dockerRegistry + "/bayes-space:1.2.0"
    Float inputSize = size(spatial, "GiB") + size(filteredFeatureBarcodeMatrix, "GiB")

    String pathOut = "./bayes-space-outs"

    command <<<
        set -euo pipefail

        # should be like this after uncompressed
        #
        # AdultMouseBrain/
        # └── outs
        #     ├── filtered_feature_bc_matrix
        #     │   ├── barcodes.tsv.gz
        #     │   ├── features.tsv.gz
        #     │   └── matrix.mtx.gz
        #     └── spatial
        #         ├── aligned_fiducials.jpg
        #         ├── detected_tissue_image.jpg
        #         ├── scalefactors_json.json
        #         ├── tissue_hires_image.png
        #         ├── tissue_lowres_image.png
        #         └── tissue_positions_list.csv
        tar xvzf ~{spatial}
        tar xvzf ~{filteredFeatureBarcodeMatrix}

        path_matrix="~{sampleName}/outs/"

        # Visium datasets processed with Space Ranger can be loaded directly via the readVisium() function.
        # This function takes only the path to the Space Ranger output directory
        # (containing the spatial/ and filtered_feature_bc_matrix/ subdirectories) and returns a SingleCellExperiment.
        # https://edward130603.github.io/BayesSpace/articles/BayesSpace.html#preparing-your-experiment-for-bayesspace-1
        mkdir -p ~{pathOut}

        Rscript /opt/process.R ${path_matrix} ~{pathOut} ~{numHvg} ~{numPca} ~{numClusters} Visium
    >>>

    output {
        File knee = pathOut + "/knee.png"
        File cluster = pathOut + "/cluster.png"
        File clusterEnhanced = pathOut+ "/cluster-enhanced.png"
        File adata = pathOut + "/spatial.h5ad"
        File csvEnhanced = pathOut + "/spatial-enhanced.csv"
        File rds = pathOut + "/spatial.rds"
        File rdsEnhanced = pathOut + "/spatial-enhanced.rds"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 5 else inputSize)) + " HDD"
        cpu: 16
        memory: "32 GB"
    }
}
