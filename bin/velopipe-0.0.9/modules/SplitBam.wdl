version 1.0

task SplitBam {

    input {
        File inBam
        Int numOfChunks
    }

    String dockerImage = "broadinstitute/gatk:4.1.8.0"
    Float inputSize = size(inBam, "GiB")
    String outputDir = "chunks"
    command <<<
        set -euo pipefail

        mkdir -p ~{outputDir}

        gatk SplitSamByNumberOfReads \
            --INPUT ~{inBam} \
            --OUTPUT ~{outputDir} \
            --SPLIT_TO_N_FILES ~{numOfChunks} \
            --CREATE_INDEX true \
            --VERBOSITY DEBUG

        # for some reason if SplitSamByNumberOfReads didn't generate .bai
        # count=`find ~{outputDir} -name *.bai | wc -l`
        # if [ $count -eq 0 ]
        # then
        #     for bam in `find ~{outputDir} -name "*.bam"`
        #     do
        #         gatk SortSam \
        #             --INPUT ${bam} \
        #             --OUTPUT ~{outputDir}/`basename ${bam} .bam`.sorted.bam \
        #             --SORT_ORDER coordinate \
        #             --CREATE_INDEX &
        #     done

        #     wait
        # fi

        find ~{outputDir}
        find .
    >>>

    output {
        Array[File] outBam = glob(outputDir + "/*.bam")
        Array[File] outBai = glob(outputDir + "/*.bai")
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk " + ceil(10 * (if inputSize < 1 then 5 else inputSize)) + " HDD"
        cpu: 16
        memory: "32 GB"
        preemptible: 0
    }
}
