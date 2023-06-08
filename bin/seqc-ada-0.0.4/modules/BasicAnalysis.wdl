version 1.0

task BasicAnalysis {

    input {
        String sampleName
        File pathRawAdata
        File pathFilteredAdata

        String templateNotebook = "basic-analysis-v1b.ipynb"
        String ribosomeGeneList = "RB_genes_human_including_GM_genes.txt"
        Int numCpus = 4
        Int memoryGB

        # docker-related
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/seqc-basic-analysis:0.0.11"
    Float inputSize = size(pathRawAdata, "GiB") + size(pathFilteredAdata, "GiB")

    String path_outdir = "outputs"

    command <<<
        set -euo pipefail

        source activate workspace

        # create a output directory
        mkdir -p ~{path_outdir}

        # notes:
        # set --cwd /opt because /opt has ribosomal gene list and external .py dependencies (e.g. get_optimal_k.py)
        # but --cwd doesn't apply to the source & target notebook

        # version 1
        papermill \
            /opt/~{templateNotebook} ~{sampleName}_basic-analysis.ipynb \
            --cwd /opt \
            --parameters sample_name ~{sampleName} \
            --parameters path_raw_adata ~{pathRawAdata} \
            --parameters path_filtered_adata ~{pathFilteredAdata} \
            --parameters path_outdir $(pwd)/~{path_outdir} \
            --parameters path_rb_gene_list ~{ribosomeGeneList} \
            --parameters n_workers ~{numCpus} \
            --stdout-file $(pwd)/~{path_outdir}/~{sampleName}_basic-analysis.stdout.txt \
            --log-output

    >>>

    output {
        File notebook = sampleName + "_basic-analysis.ipynb"
        File notebookStdout = path_outdir + "/" + sampleName + "_basic-analysis.stdout.txt"
        File normalizedH5ad = path_outdir + "/" + sampleName + "_normalized.h5ad"
    }

    runtime {
        docker: dockerImage
        disks: "local-disk " + ceil(2 * (if inputSize < 1 then 10 else inputSize)) + " HDD"
        cpu: numCpus
        memory: (if memoryGB < 4 then 4 else memoryGB)  + " GB"
    }
}
