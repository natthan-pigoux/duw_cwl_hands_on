#!/usr/bin/env cwl-runner

%YAML 1.1
---
cwlVersion: v1.2
class: CommandLineTool
label: Merge Event Files
doc: |
  Merge multiple ctapipe output files into a single output file using ctapipe-merge.
  (DPPS-UC-130-1.8)

inputs:
  config:
    doc: The configuration file for ctapipe-merge
    type: File?
    inputBinding:
      prefix: --config
      position: 2
  input_files:
    doc: |
      Paths to ctapipe files to be merged into output_filename
    type: File[]
    inputBinding:
      position: 5
  output_filename:
    doc: name of the output filename
    type: string
    inputBinding:
      prefix: --output
      position: 1
  provenance_log_filename:
    doc: file in which to write the local provenance.
    type: string
    default: ctapipe-merge.provenance.log
    inputBinding:
      prefix: --provenance-log
      position: 4

outputs:
  merged_output:
    doc: output file.
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
  provenance_log:
    doc: ctapipe format provenance log for this step.
    type: File
    outputBinding:
      glob: $(inputs.provenance_log_filename)

baseCommand:
- ctapipe-merge
- --log-level=INFO

hints:
  DockerRequirement:
    dockerPull: harbor.cta-observatory.org/dpps/datapipe:v0.3.3-rc1-2-gb8d0cdd
