version 1.0

task TabixfyFragments {

    input {
        File fragments

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/htslib:1.9"
    Float inputSize = size(fragments, "GiB")
    String outFilename = basename(fragments) + ".tbi"

    # IN:  "./dp-lab-gwf-core/cromwell-execution/ReformatFragments/ccce2137-e492-4bb4-8481-6a0eeeee2281/call-ReformatFragments/fragments-Reformat.tsv.gz"
    # OUT: "./dp-lab-gwf-core/cromwell-execution/ReformatFragments/ccce2137-e492-4bb4-8481-6a0eeeee2281/call-ReformatFragments/fragments-Reformat.tsv.gz.tbi"

    command <<<
        set -euo pipefail

        tabix -p bed ~{fragments}

        mv `dirname ~{fragments}`/~{outFilename} .
    >>>

    output {
        File out = outFilename
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(5 * (if inputSize < 1 then 10 else inputSize)) + " HDD"
        cpu: 2
        memory: "16 GB"
    }
}
