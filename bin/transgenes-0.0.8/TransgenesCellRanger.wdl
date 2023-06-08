version 1.0

import "modules/Transgenes.wdl" as Transgenes
import "modules/CellRanger.wdl" as CellRanger

workflow TransgenesCellRanger {

    input {
        String referenceName
        File genomeReferenceFasta
        File annotationGtf
        Array[File] customFastaFiles
        Array[String] ensembleIds
        String ensembleIdPrefix
        Array[String] biotypes

        String cellRangerVersion

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

    call CellRanger.mkref {
        input:
            referenceName = referenceName,
            fasta = Transgenes.outFasta,
            gtf = Transgenes.outGtf,
            cellRangerVersion = cellRangerVersion,
            dockerRegistry = dockerRegistry
    }

    output {
        File outReferencePackage = mkref.outReferencePackage
        File outFastaBgzip = Transgenes.outFastaBgzip
        File outFastaGzi = Transgenes.outFastaGzi
        File outFastaFai = Transgenes.outFastaFai
        File outFilterLog = Transgenes.outFilterLog
    }
}
