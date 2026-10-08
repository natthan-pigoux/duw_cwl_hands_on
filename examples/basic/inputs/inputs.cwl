cwlVersion: v1.2
class: CommandLineTool

inputs:
  input_file:
    type: File[]
    default: ["input.txt"]
    inputBinding:
      position: 1

outputs:
  output_file:
    type: File
    outputBinding:
      glob: "output*"

baseCommand: ["cp"]

hints:
  - class: dirac:ExecutionHooks
    hook_plugin: "QueryBasedPlugin"
    output_sandbox: ["output_file"]
    output_se: ["TestSE"]

  - class: dirac:Scheduling
    sites: CTAO.CI.de
