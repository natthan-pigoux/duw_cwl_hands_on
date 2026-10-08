cwlVersion: v1.2
class: CommandLineTool

inputs: []
outputs:
  output_sb:
    type: File
    outputBinding:
      glob: "output_sb*"

baseCommand: ["echo", "Testing Output Sandbox"]
stdout: "output_sb.txt"

hints:
  - class: dirac:ExecutionHooks
    hook_plugin: "QueryBasedPlugin"
    output_sandbox: ["output_sb"]

  - class: dirac:Scheduling
    sites: CTAO.CI.de
