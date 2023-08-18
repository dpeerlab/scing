version 1.0

import "modules/Flex.wdl" as Flex
import "modules/GetSize.wdl" as GetSize

workflow CellRangerFlex {

    input {
        String sampleName
        File csv

        Int numCores = 16
        Int memory = 128

        String dockerRegistry
    }

    call GetSize.GetSize {
        input:
            csv = csv,
            dockerRegistry = dockerRegistry,
    }

    call Flex.Flex {
        input:
            sampleName = sampleName,
            csv = csv,

            inputSize = GetSize.inputSize,
            numCores = numCores,
            memory = memory,

            dockerRegistry = dockerRegistry,
    }

    output {
        String outputs = Flex.outputs
    }
}
