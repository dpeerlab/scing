version 1.0

task ConstructAnnData {

    input {
        File exports

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/archr2adata:0.0.3"

    command <<<
        set -euo pipefail

        tar xvzf ~{exports}

        python /opt/archr2adata.py --data outs2
    >>>

    output {
        File adata = "outs2/preprocessed.h5ad"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk 100 HDD"
        cpu: 1
        memory: "64 GB"
    }
}
