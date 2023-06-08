version 1.0

task MergeFastq {

    input {
        # set from workflow
        Array[File] uriFastq
        String sampleName
        String readName
        String dockerRegistry
    }

    Int numFastq = length(uriFastq)
    String dockerImage = dockerRegistry + "/cromwell-seqc:0.2.11"
    Int numCores = 2
    Float inputSize = size(uriFastq, "GiB")

    command <<<
        set -euo pipefail

        filenames="~{sep=" " uriFastq}"

        echo "${filenames}"

        path_out="~{sampleName}_~{readName}.fastq"

        echo "${path_out}"

        if [ ~{numFastq} -eq 1 ]
        then
            # single file, no need to merge
            cp ${filenames} ${path_out}.gz
        else
            # gunzip and concatenate
            for filename in $filenames
            do
                echo "$filename > ${path_out}"
                gunzip -c ${filename} >> ${path_out}
            done

            # gzip
            gzip ${path_out}
        fi
    >>>

    output {
        File out = sampleName + "_" + readName + ".fastq.gz"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk " + ceil(5 * (if inputSize < 1 then 1 else inputSize )) + " HDD"
        cpu: numCores
        memory: "8 GB"
    }
}
