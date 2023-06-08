version 1.0

workflow MAST {

    input {
        File h5ad
        String clusterObsName = "Clusters"

        # docker-related
        String dockerRegistry
    }

    call PrepareMAST {
        input:
            h5ad = h5ad,
            clusterObsName = clusterObsName,
            dockerRegistry = dockerRegistry
    }

    scatter (dataframe in PrepareMAST.dataframes) {

        call PairwiseDiffExp {
            input:
                dataframe = dataframe,
                dockerRegistry = dockerRegistry
        }
    }

    output {
        Array[File] out = PairwiseDiffExp.out
    }
}

task PrepareMAST {

    input {
        File h5ad
        String clusterObsName = "Clusters"

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/mast:0.0.1"
    Float inputSize = size(h5ad, "GiB")

    command <<<
        set -euo pipefail

        # this first generates
        # df.0.RDS, df.0.rest.RDS
        # df.1.RDS, df.1.rest.RDS
        # ...
        # then, each pair will be compressed to
        # df.0.tgz
        # df.1.tgz
        # ...
        papermill \
            /opt/prepare-MAST.ipynb tmp.ipynb \
            --parameters path_h5ad ~{h5ad} \
            --parameters cluster_obs_name ~{clusterObsName}
    >>>

    output {
        Array[File] dataframes = glob("df.*.tgz")
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 10 else inputSize)) + " HDD"
        cpu: 1
        memory: "32 GB"
    }
}

task PairwiseDiffExp {

    input {
        File dataframe

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/mast:0.0.1"
    Float inputSize = size(dataframe, "GiB")

    command <<<
        set -euo pipefail

        # extract:
        # df.7.RDS
        # df.7.rest.RDS
        tar xvzf ~{dataframe}

        # get cluster number from the input filename
        cluster_num=`python -c "fn='~{dataframe}'; print(fn.split('.')[1])"`
        outfile="MAST-cluster-${cluster_num}-vs-rest.csv"

        # generate the output in the current directory (must end with a trailing slash)
        Rscript \
            /opt/pairwise-diffexp.R \
            ${cluster_num} \
            ${outfile}

        # compress
        gzip ${outfile}
    >>>

    output {
        File out = glob("MAST-cluster-*.csv.gz")[0]
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 10 else inputSize)) + " HDD"
        cpu: 1
        memory: "32 GB"
    }
}
