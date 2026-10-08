cwlVersion: v1.2
class: CommandLineTool

inputs: []
outputs:
  output_data:
    type: File
    outputBinding:
      glob: "output_data*"

baseCommand: ["echo", "Testing Output Data"]
stdout: "output_data.txt"
hints:
  - class: dirac:ExecutionHooks
    hook_plugin: "QueryBasedPlugin"
    output_paths:
      output_data: "lfn:/ctao.dpps.test/tests/jobs/"
    output_se: ["TestSE"]

  - class: dirac:Scheduling
    sites: CTAO.CI.de
