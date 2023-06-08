version 1.0

task RunTutorial {

    input {
        File tutorialCode
        String outputDir

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/archr:0.9.x-snapshot-20200922b"

    command {
        set -euo pipefail

        Rscript ~{tutorialCode}

        find .

        find . > filelist-all.txt
    }

    output {
        Array[File] logFiles = glob("ArchRLogs/*.log")
        Array[File] qcFiles = glob("QualityControl/*/*")
        Array[File] arrowFiles0 = glob("*.arrow") # original arrow files
        Array[File] arrowFiles = glob(outputDir + "/ArrowFiles/*.arrow")
        Array[File] lsiFiles = glob(outputDir + "/IterativeLSI/*")
        Array[File] embeddingFiles = glob(outputDir + "/Embeddings/*")
        Array[File] plotFiles = glob(outputDir + "/Plots/*")
        File projectFile = outputDir + "/Save-ArchR-Project.rds"
        File? fileList = "filelist-all.txt"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk 100 HDD"
        cpu: 16
        memory: "64 GB"
    }
}

task Run {

    input {
        Array[File] fragmentsFiles
        Array[File] fragmentsIndexFiles
        Array[String] sampleNames
        String genome
        Int numCores
        String outputDir = "outs"

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/archr:0.9.x-snapshot-20200922b"

    command <<<
        set -euo pipefail

        # generate input-files.txt and sample-names.txt
        echo "~{sep='\n' fragmentsFiles}" > input-files.txt
        echo "~{sep='\n' sampleNames}" > sample-names.txt

        # refresh the fragments tabix index files
        for file in ~{sep=' ' fragmentsIndexFiles}
        do
            touch ${file}
        done

        # run md5 checksum
        for file in ~{sep=' ' fragmentsFiles}
        do
            md5sum ${file}
        done

        # preprocess
        Rscript /opt/preprocess.R input-files.txt sample-names.txt ~{genome} ~{numCores}

        # tar-gzip outs
        tar cvzf outs.tgz outs/*
        tar cvzf exports.tgz outs2/*

        # generate file list
        find . > filelist-all.txt

        # check number of arrow files generated
        count=`find ~{outputDir}/ArrowFiles -name "*.arrow" | wc -l`
        if [ $count -eq ~{length(sampleNames)} ]
        then
            exit 0 # ok
        else
            exit 1 # fail
        fi
    >>>

    output {
        Array[File] logFiles = glob("ArchRLogs/*.log")
        Array[File] qcFiles = glob("QualityControl/*/*")
        Array[File] arrowFiles0 = glob("*.arrow") # original arrow files
        # Array[File] arrowFiles = glob(outputDir + "/ArrowFiles/*.arrow")
        # Array[File] lsiFiles = glob(outputDir + "/IterativeLSI/*")
        # Array[File] embeddingFiles = glob(outputDir + "/Embeddings/*")
        # Array[File] plotFiles = glob(outputDir + "/Plots/*")
        # File projectFile = outputDir + "/Save-ArchR-Project.rds"
        File projectOutputs = "outs.tgz"
        File exports = "exports.tgz"
        File? fileList = "filelist-all.txt"
    }

    runtime {
        docker: dockerImage
        # disks: "local-disk 100 HDD"
        cpu: numCores
        memory: "100 GB"
    }
}
