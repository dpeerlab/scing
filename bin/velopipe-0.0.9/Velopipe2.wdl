version 1.0

import "modules/ExtractBarcodes.wdl" as ExtractBarcodes
import "modules/SplitBam.wdl" as SplitBam
import "modules/SortIndexBam.wdl" as SortIndexBam
import "modules/TagBam2.wdl" as TagBam2
import "modules/MergeBam.wdl" as MergeBam
import "modules/SortByBarcode.wdl" as SortByBarcode
import "modules/Velocyto.wdl" as Velocyto

workflow Velopipe2 {

    input {
        String sampleName
        File bam
        Int numOfChunks = 20
        File cbCorrection
        File umiCorrection
        File filteredBarcodes
        File gtf
        File fullBarcodeWhitelist

        # docker-related
        String dockerRegistry
    }

    call ExtractBarcodes.ExtractBarcodes {
        input:
            filteredBarcodes = filteredBarcodes,
            dockerRegistry = dockerRegistry
    }

    call SplitBam.SplitBam {
        input:
            inBam = bam,
            numOfChunks = numOfChunks
    }

    scatter (bam in SplitBam.outBam) {
        call SortIndexBam.SortIndexBam {
            input:
                inBam = bam,
                dockerRegistry = dockerRegistry
        }
    }

    call TagBam2.TagBam2 {
        input:
            inBam = SortIndexBam.outSortedBam,
            inBai = SortIndexBam.outSortedBai,
            whitelist = fullBarcodeWhitelist,
            cbCorrection = cbCorrection,
            umiCorrection = umiCorrection,
            dockerRegistry = dockerRegistry
    }

    call MergeBam.MergeBam {
        input:
            chunks = TagBam2.outTaggedBam,
            fileName = sampleName + ".tagged.bam"
    }

    # if the file cellsorted_${ORIGINAL-BAM-NAME} exists,
    # the sorting procedure will be skipped and the file present will be used.
    call SortByBarcode.SortByBarcode as CBSortedTaggedBam {
        input:
            inBam = MergeBam.outBam,
            dockerRegistry = dockerRegistry
    }

    call Velocyto.Velocyto {
        input:
            bamCBSorted = CBSortedTaggedBam.outSortedBam,
            bamPosSorted = MergeBam.outBam,
            baiPosSorted = MergeBam.outBai,
            gtf = gtf,
            filteredBarcodeSet = ExtractBarcodes.outFilteredBarcodesACGT,
            dockerRegistry = dockerRegistry
    }

    output {
        File outCBSortedTaggedBam = CBSortedTaggedBam.outSortedBam
        File outPosSortedTaggedBam = MergeBam.outBam
        File outPosSortedTaggedBai = MergeBam.outBai
        File outLoom = Velocyto.outLoom
        File outTagBamLog = TagBam2.outLog
        File outTagBamStats = TagBam2.outStats
        File outVelocytoLog = Velocyto.outLog
    }
}
