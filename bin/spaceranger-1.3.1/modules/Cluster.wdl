version 1.0

task GetGraphCluster {

    input {
        String sampleName
        File secondaryAnalysis
    }

    parameter_meta {
        secondaryAnalysis: "tarball-gzipped secondary analysis from 10x Space Ranger"
    }

    Float inputSize = size(secondaryAnalysis, "GiB")

    # find the number of clusters
    command <<<
        set -euo pipefail

        tar xvzf ~{secondaryAnalysis}
    >>>

    output {
        # SAMPLE_NAME/outs/analysis/clustering/graphclust/clusters.csv
        File graphclust = sampleName + "/outs/analysis/clustering/graphclust/clusters.csv"
    }

    runtime {
        docker: "ubuntu:20.04"
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 5 else inputSize)) + " HDD"
        cpu: 1
        memory: "2 GB"
    }
}

task GetNumGraphClusters {

    input {
        File graphclust
    }

    parameter_meta {
        graphclust: "clusters.csv from 10x Space Ranger's graphclust"
    }

    # find the number of clusters
    command <<<
        set -euo pipefail

        python - << EOF
        import pandas as pd
        print(pd.read_csv("~{graphclust}").Cluster.max())
        EOF
    >>>

    output {
        Int numClusters = read_int(stdout())
    }

    runtime {
        docker: "jupyter/datascience-notebook:notebook-6.4.0"
        disks: "local-disk 10 HDD"
        cpu: 1
        memory: "4 GB"
    }
}
