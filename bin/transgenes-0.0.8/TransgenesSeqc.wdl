version 1.0

import "modules/Transgenes.wdl" as Transgenes
import "modules/STAR.wdl" as STAR

workflow TransgenesSeqc {

    input {
        String referenceName
        File genomeReferenceFasta
        File annotationGtf
        Array[File] customFastaFiles
        Array[String] ensembleIds
        String ensembleIdPrefix
        Array[String] biotypes

        Int sjdbOverhang = 101
        String starVersion

        # docker-related
        String dockerRegistry
    }

    call Transgenes.Transgenes {
        input:
            genomeReferenceFasta = genomeReferenceFasta,
            annotationGtf = annotationGtf,
            customFastaFiles = customFastaFiles,
            ensembleIds = ensembleIds,
            ensembleIdPrefix = ensembleIdPrefix,
            biotypes = biotypes,
            dockerRegistry = dockerRegistry
    }

    call STAR.GenerateIndex {
        input:
            genomeReferenceFasta = genomeReferenceFasta,
            customFasta = customFastaFiles,
            annotationGtf = Transgenes.outGtf,
            sjdbOverhang = sjdbOverhang,
            starVersion = starVersion,
            dockerRegistry = dockerRegistry
    }

    output {
        Array[File] outStarFiles = GenerateIndex.outFiles
        File outFastaBgzip = Transgenes.outFastaBgzip
        File outFastaGzi = Transgenes.outFastaGzi
        File outFastaFai = Transgenes.outFastaFai
        File outFilterLog = Transgenes.outFilterLog
    }
}
