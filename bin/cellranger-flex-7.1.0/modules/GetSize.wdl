version 1.0

task GetSize
{
    input {
        File csv
        String dockerRegistry
    }

    String dockerImage = dockerRegistry + "/cromwell-pigz:2.4"

    # Input looks like this:
    # [gene-expression]
    # reference,{reference_url}
    # probe-set,{probe_set_url}
    # 
    # [libraries
    # fastq_id,fastqs,feature_types
    # {fastq_id},{fastqs},{feature_types}
    # {fastq_id},{fastqs},{feature_types}

    command <<<
        fastq_paths=$(grep ".fastq.gz" ${csv} | cut -d, -f2 | tr '\n' ' ')
        fastq_size=$(du -c ${fastq_paths} --block-size=1G | grep total | cut -f1)
        echo ${fastq_size}
    >>>
    
    output {
        Int inputSize = read_int(stdout())
    }

    runtime {
        docker: dockerImage
        disks: "local-disk 100 HDD"
        cpu: 4
        memory: "8 GB"
    }
}