version 1.0

import "modules/ReformatFragments.wdl" as ReformatFragments
import "modules/TabixfyFragments.wdl" as TabixfyFragments
import "modules/Preprocess.wdl" as Preprocess
import "modules/ConstructAnnData.wdl" as ConstructAnnData

# ArchR Stand Alone (starting from fragments file)
workflow ArchRSA {

    input {
        Array[File] fragmentsFiles
        Array[File] fragmentsIndexFiles
        Array[String] sampleNames
        String genome

        Boolean reformatFragments

        # ArchR unstable with multiprocessing
        Int numCores

        # docker-related
        String dockerRegistry
    }

    # reformat fragments only if requested
    if (reformatFragments) {
        scatter (fragments in fragmentsFiles) {
            call ReformatFragments.ReformatFragments {
                input:
                    fragments = fragments,
                    numCores = numCores,
                    dockerRegistry = dockerRegistry
            }
            call TabixfyFragments.TabixfyFragments {
                input:
                    fragments = ReformatFragments.out,
                    dockerRegistry = dockerRegistry
            }
        }
    }

    Array[File] finalFragments = select_first([ReformatFragments.out, fragmentsFiles])
    Array[File] finalFragmentsIndex = select_first([TabixfyFragments.out, fragmentsIndexFiles])

    call Preprocess.Run {
        input:
            fragmentsFiles = finalFragments,
            fragmentsIndexFiles = finalFragmentsIndex,
            sampleNames = sampleNames,
            genome = genome,
            numCores = numCores,
            dockerRegistry = dockerRegistry
    }

    call ConstructAnnData.ConstructAnnData {
        input:
            exports = Run.exports,
            dockerRegistry = dockerRegistry
    }

    output {
        Array[File] outLogs = Run.logFiles
        Array[File] outQC = Run.qcFiles
        Array[File] outArrow0 = Run.arrowFiles0
        File outProject = Run.projectOutputs
        File outAdata = ConstructAnnData.adata
        File? outFileList = Run.fileList
    }
}
