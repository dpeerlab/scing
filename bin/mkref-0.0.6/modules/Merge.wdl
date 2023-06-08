version 1.0

task Merge {

    input {
        Array[File] files
        String extension
    }

    parameter_meta {
        extension: "e.g. gtf or fasta"
    }

    Float inputSize = size(files, "GiB")

    command <<<
        set -euo pipefail

        cat ~{sep=" " files} > merged.~{extension}
    >>>

    output {
        File outMergedFile = "merged." + extension
    }

    runtime {
        docker: "ubuntu:20.04"
        disks: "local-disk " + ceil(10 * (if inputSize < 1 then 5 else inputSize)) + " HDD"
        cpu: 1
        memory: "1 GB"
    }
}
