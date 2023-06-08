version 1.0

import "modules/Count.wdl" as Count

workflow CellRangerATAC {

    input {
        String sampleName
        String fastqNames
        Array[File] fastqFiles
        Map[String, String] referenceGenome
        String? chemistry

        # docker-related
        String dockerRegistry
    }

    call Count.Count {
        input:
            sampleName = sampleName,
            fastqNames = fastqNames,
            fastqFiles = fastqFiles,
            referenceGenome = referenceGenome,
            chemistry = chemistry,
            dockerRegistry = dockerRegistry
    }

    output {
        File bam = Count.bam
        File bai = Count.bai
        File summaryJson = Count.summaryJson
        File summaryCsv = Count.summaryCsv
        File summaryHtml = Count.summaryHtml
        File perBarcodeMetrics = Count.perBarcodeMetrics

        File peaks = Count.peaks
        File? secondaryAnalysis = Count.secondaryAnalysis

        Array[File] rawPeakBCMatrix = Count.rawPeakBCMatrix
        File rawPeakBCMatrixH5 = Count.rawPeakBCMatrixH5

        Array[File] filteredPeakBCMatrix = Count.filteredPeakBCMatrix
        File filteredPeakBCMatrixH5 = Count.filteredPeakBCMatrixH5

        Array[File] filteredTFBCMatrix = Count.filteredTFBCMatrix
        File filteredTFBCMatrixH5 = Count.filteredTFBCMatrixH5

        File cloupe = Count.cloupe

        File fragments = Count.fragments
        File fragmentsIndex = Count.fragmentsIndex

        File peakAnnotation = Count.peakAnnotation
        File peakMotifMapping = Count.peakMotifMapping

        File pipestanceMeta = Count.pipestanceMeta
    }
}
