version 1.0

task ReformatFragments {

    input {
        File fragments
        Int numCores

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/archr:0.9.x-snapshot-20200922b"
    Float inputSize = size(fragments, "GiB")
    String outFilename = basename(fragments, ".tsv.gz") + "-Reformat.tsv.gz"

    # IN:  "./dp-lab-home/ea2690/AMLATAC/BM_08022017/fragments.tsv.gz"
    # OUT: "./dp-lab-home/ea2690/AMLATAC/BM_08022017/fragments-Reformat.tsv.gz"

    command <<<
        set -euo pipefail

        Rscript /opt/reformat.R ~{fragments} ~{numCores}

        mv `dirname ~{fragments}`/~{outFilename} .
    >>>

    output {
        File out = outFilename
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 10 else inputSize)) + " HDD"
        cpu: numCores
        memory: "32 GB"
    }
}
