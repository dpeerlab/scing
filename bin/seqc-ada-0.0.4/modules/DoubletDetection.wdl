version 1.0

task DoubletDetection {

    input {
        String sampleName
        File countMatrixH5ad
        Float voterThreshold = 0.5

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/seqc-basic-analysis:0.0.11"
    Int nThreads = 8
    Float inputSize = size(countMatrixH5ad, "GiB")

    command <<<
        set -euo pipefail

        source activate workspace

        papermill \
            /opt/doublet-detection.ipynb doublet-detection.ipynb \
            --parameters path_h5ad ~{countMatrixH5ad} \
            --parameters path_out . \
            --parameters n_jobs ~{nThreads} \
            --parameters voter_thresh ~{voterThreshold} \
            --parameters sample_name ~{sampleName} \
            --stdout-file doublet-detection.stdout.txt \
            --log-output
            
    >>>

    output {
        File doublets = sampleName + ".doublets.pickle"
        File doubletScore = sampleName + ".doublet-score.pickle"
        File notebook = "doublet-detection.ipynb"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk 10 HDD"
        cpu: nThreads
        memory: "32 GB"
    }
}
