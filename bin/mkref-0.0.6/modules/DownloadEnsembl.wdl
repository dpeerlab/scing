version 1.0

task DownloadEnsemblHuman {

    input {
        String genomeVersion
        String ensemblVersion
    }

    parameter_meta {
        genomeVersion: "e.g. 38 (as in GRCh38 or GRCm38"
        ensemblVersion: "e.g. 99 (as in Ensembl Release 99"
    }

    command <<<
        set -euo pipefail

        apt-get update -y
        apt-get install wget -y

        # curl -L -C - ftp://ftp.ensembl.org/pub/release-~{ensemblVersion}/fasta/homo_sapiens/dna/Homo_sapiens.GRCh~{genomeVersion}.dna.primary_assembly.fa.gz -o hg.fa.gz &
        # curl -L -C - ftp://ftp.ensembl.org/pub/release-~{ensemblVersion}/gtf/homo_sapiens/Homo_sapiens.GRCh~{genomeVersion}.~{ensemblVersion}.gtf.gz -o hg.gtf.gz &
        wget -O hg.fa.gz --quiet ftp://ftp.ensembl.org/pub/release-~{ensemblVersion}/fasta/homo_sapiens/dna/Homo_sapiens.GRCh~{genomeVersion}.dna.primary_assembly.fa.gz &
        wget -O hg.gtf.gz --quiet ftp://ftp.ensembl.org/pub/release-~{ensemblVersion}/gtf/homo_sapiens/Homo_sapiens.GRCh~{genomeVersion}.~{ensemblVersion}.gtf.gz &
        wait
    >>>

    output {
        File outFasta = "hg.fa.gz"
        File outGtf = "hg.gtf.gz"
    }

    runtime {
        docker: "ubuntu:20.04"
        disks: "local-disk 100 HDD"
        cpu: 1
        memory: "1 GB"
    }
}

task DownloadEnsemblMouse {

    input {
        String genomeVersion
        String ensemblVersion
    }

    command <<<
        set -euo pipefail

        apt-get update -y
        apt-get install wget -y

        # curl -L -C - ftp://ftp.ensembl.org/pub/release-~{ensemblVersion}/fasta/mus_musculus/dna/Mus_musculus.GRCm~{genomeVersion}.dna.primary_assembly.fa.gz -o mm.fa.gz &
        # curl -L -C - ftp://ftp.ensembl.org/pub/release-~{ensemblVersion}/gtf/mus_musculus/Mus_musculus.GRCm~{genomeVersion}.~{ensemblVersion}.gtf.gz -o mm.gtf.gz &
        wget -O mm.fa.gz --quiet ftp://ftp.ensembl.org/pub/release-~{ensemblVersion}/fasta/mus_musculus/dna/Mus_musculus.GRCm~{genomeVersion}.dna.primary_assembly.fa.gz &
        wget -O mm.gtf.gz --quiet ftp://ftp.ensembl.org/pub/release-~{ensemblVersion}/gtf/mus_musculus/Mus_musculus.GRCm~{genomeVersion}.~{ensemblVersion}.gtf.gz &
        wait
    >>>

    output {
        File outFasta = "mm.fa.gz"
        File outGtf = "mm.gtf.gz"
    }

    runtime {
        docker: "ubuntu:20.04"
        disks: "local-disk 100 HDD"
        cpu: 1
        memory: "1 GB"
    }
}
