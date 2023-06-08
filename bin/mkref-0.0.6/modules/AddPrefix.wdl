version 1.0

task AddPrefixGtf {

    input {
        String prefix
        File gzippedGtf
    }

    parameter_meta {
        prefix: "e.g. HUMAN or MOUSE"
    }

    Float inputSize = size(gzippedGtf, "GiB")

    command <<<
        set -euo pipefail

        gtf=`basename ~{gzippedGtf} .gz`
        gunzip -c ~{gzippedGtf} > ${gtf}

        awk -v org="~{prefix}" '!/^#!/ {$0=org"_"$0; print}' ${gtf} > ~{prefix}.gtf
    >>>

    output {
        File outPrefixedGtf = prefix + ".gtf"
    }

    runtime {
        docker: "ubuntu:20.04"
        disks: "local-disk " + ceil(10 * (if inputSize < 1 then 5 else inputSize)) + " HDD"
        cpu: 1
        memory: "1 GB"
    }
}

task AddPrefixFasta {

    input {
        String prefix
        File gzippedFasta
    }

    Float inputSize = size(gzippedFasta, "GiB")

    command <<<
        set -euo pipefail

        fasta=`basename ~{gzippedFasta} .gz`
        gunzip -c ~{gzippedFasta} > ${fasta}

        awk -v org="~{prefix}" '/^>/{sub(/^>/, ">"org"_"); print;next;}{print}' ${fasta} > ~{prefix}.fasta
    >>>

    output {
        File outPrefixedFasta = prefix + ".fasta"
    }

    runtime {
        docker: "ubuntu:20.04"
        disks: "local-disk " + ceil(10 * (if inputSize < 1 then 5 else inputSize)) + " HDD"
        cpu: 1
        memory: "1 GB"
    }
}
