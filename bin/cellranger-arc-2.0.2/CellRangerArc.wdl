version 1.0

import "modules/Count.wdl" as Count

workflow CellRangerArc {

    input {
        String runID
        String gexFastqName
        String atacFastqName
        Array[File] gexFastqFiles
        Array[File] atacFastqFiles
        File referenceUrl

        # docker-related
        String dockerRegistry
    }

    call Count.Count {
        input:
            runID = runID,
            gexFastqName = gexFastqName,
            atacFastqName = atacFastqName,
            gexFastqFiles = gexFastqFiles,
            atacFastqFiles = atacFastqFiles,
            referenceUrl = referenceUrl,
            dockerRegistry = dockerRegistry
    }

    output {
        String outputs = Count.outputs

        File libraries = Count.libraries

        File webSummary = Count.webSummary
        File metricsSummary = Count.metricsSummary
        File gexPerMoleculeInfo = Count.gexPerMoleculeInfo

        File gexBam = Count.gexBam
        File gexBai = Count.gexBai

        File atacBam = Count.atacBam
        File atacBai = Count.atacBai

        File atacFragments = Count.atacFragments
        File atacFragmentsIndex = Count.atacFragmentsIndex

        Array[File] rawFeatureBCMatrix = Count.rawFeatureBCMatrix
        File rawFeatureBCMatrixH5 = Count.rawFeatureBCMatrixH5

        Array[File] filteredFeatureBCMatrix = Count.filteredFeatureBCMatrix
        File filteredFeatureBCMatrixH5 = Count.filteredFeatureBCMatrixH5

        File? secondaryAnalysis = Count.secondaryAnalysis

        File perBarcodeMetrics = Count.perBarcodeMetrics
        File peaks = Count.peaks
        File cutSites = Count.cutSites
        File peakAnnotation = Count.peakAnnotation

        File cloupe = Count.cloupe

        File pipestanceMeta = Count.pipestanceMeta
    }
}
