version 1.0

import "FastaToGtf.wdl" as FastaToGtf
import "CreateFullGtf.wdl" as CreateFullGtf
import "GenomeForIgv.wdl" as GenomeForIgv
import "FilterBiotypes.wdl" as FilterBiotypes

workflow Transgenes {

    input {
        File genomeReferenceFasta
        File annotationGtf
        Array[File] customFastaFiles
        Array[String] ensembleIds
        String ensembleIdPrefix

        Array[String] biotypes

        # docker-related
        String dockerRegistry
    }

    # zip FASTA files and Ensemble IDs
    # pair.left = path to FASTA file
    # pair.right = path to Ensemble ID (only digits)
    Array[Pair[File, String]] fastaAndEnsembleIds = zip(customFastaFiles, ensembleIds)

    scatter (pair in fastaAndEnsembleIds) {

        call FastaToGtf.IndexFasta {
            input:
                fasta = pair.left,
                dockerRegistry = dockerRegistry
        }

        # G for gene, T for transcript
        call FastaToGtf.IndexToGtf {
            input:
                fastaIdx = IndexFasta.out,
                geneId = ensembleIdPrefix + "G" + pair.right,
                transcriptId = ensembleIdPrefix + "T" + pair.right,
                dockerRegistry = dockerRegistry
        }
    }

    call GenomeForIgv.ConcatenateFastas {
        input:
            genomeReferenceFasta = genomeReferenceFasta,
            customFastaFiles = customFastaFiles,
            dockerRegistry = dockerRegistry
    }

    call GenomeForIgv.IndexCompressedFasta {
        input:
            compressedFasta = ConcatenateFastas.outBgzip,
            dockerRegistry = dockerRegistry
    }

    call CreateFullGtf.CreateFullGtf {
        input:
            normalFullGtf = annotationGtf,
            customGtfs = IndexToGtf.out
    }

    # add `transgene` to the user supplied biotypes
    call FilterBiotypes.FilterBiotypes {
        input:
            biotypes = flatten([biotypes, ["transgene"]]),
            gtf = CreateFullGtf.out,
            dockerRegistry = dockerRegistry
    }

    output {
        File outFasta = ConcatenateFastas.out
        File outFastaBgzip = ConcatenateFastas.outBgzip
        File outFastaGzi = IndexCompressedFasta.outGzi
        File outFastaFai = IndexCompressedFasta.outFai
        File outGtf = CreateFullGtf.out
        File outFilterLog = FilterBiotypes.outLog
    }
}
