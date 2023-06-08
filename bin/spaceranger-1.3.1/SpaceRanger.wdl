version 1.0

import "modules/Count.wdl" as Count

workflow SpaceRanger {

    input {
        String sampleName
        String fastqName
        Array[File] inputFastq
        String referenceUrl

        File heImage

        String slideSerialNumber
        String areaId

        Boolean reorientImages

        # docker-related
        String dockerRegistry
    }

    call Count.Count {
        input:
            sampleName = sampleName,
            fastqName = fastqName,
            inputFastq = inputFastq,
            referenceUrl = referenceUrl,
            heImage = heImage,
            slideSerialNumber = slideSerialNumber,
            areaId = areaId,
            reorientImages = reorientImages,
            dockerRegistry = dockerRegistry
    }

    output {
        File webSummary = Count.webSummary
        File spatial = Count.spatial
        File metricsSummary = Count.metricsSummary
        File bam = Count.bam
        File bai = Count.bai
        File filteredFeatureBarcodeMatrix = Count.filteredFeatureBarcodeMatrix
        File filteredFeatureBarcodeMatrixH5 = Count.filteredFeatureBarcodeMatrixH5
        File rawFeatureBarcodeMatrix = Count.rawFeatureBarcodeMatrix
        File rawFeatureBarcodeMatrixH5 = Count.rawFeatureBarcodeMatrixH5
        File analysis = Count.analysis
        File perMoleculeInfo = Count.perMoleculeInfo
        File loupe = Count.loupe
        File spatialEnrichment = Count.spatialEnrichment
        File pipestanceMeta = Count.pipestanceMeta
    }
}
