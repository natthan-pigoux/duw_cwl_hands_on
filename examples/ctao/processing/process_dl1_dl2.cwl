#!/usr/bin/env cwl-runner

%YAML 1.1
---
cwlVersion: v1.2
class: CommandLineTool
label: Process DL1 to DL2
doc: |
  Processes a single file from DL1 to DL2 using the ``ctapipe-process`` tool.
  (*DPPS-UC-130-1.2.2*). Minimally, Hillas-style geometry reconstruction is
  performed, but energy, gammaness, mono reconstruction may be included by using
  an appropriate data processing configuration.

inputs:
  dl1:
    doc: |
      path to input file, which can be at any data level transformable to DL2
      that is supported by the installed ctapipe io plugins. I can also be a
      URL.
    type:
    - File
    - string
    inputBinding:
      prefix: --input
  dl2_filename:
    doc: name of the DL2 output file
    type: string
    inputBinding:
      prefix: --output
  processing_config:
    doc: |
      Sets the reconstruction parameters that apply to DL1 to DL2.
      See ``ctapipe-process --help-all`` for a list of all options, or the output
      of ``ctapipe-quickstart`` for sample configuration files.
    type: File?
    inputBinding:
      prefix: --config
  provenance_log_filename:
    doc: file in which to write the local ctapipe-process provenance.
    type: string
    default: ctapipe-process_dl1_dl2.provenance.log
    inputBinding:
      prefix: --provenance-log

outputs:
  dl2:
    doc: HDF5 format output file.
    type: File
    outputBinding:
      glob: $(inputs.dl2_filename)
  provenance_log:
    doc: ctapipe format provenance log for this step.
    type: File
    outputBinding:
      glob: $(inputs.provenance_log_filename)

baseCommand:
- ctapipe-process
- --DataWriter.write_dl1_parameters=False
- --DataWriter.write_dl1_images=False
- --DataWriter.write_dl2=True

hints:
  DockerRequirement:
    dockerPull: harbor.cta-observatory.org/dpps/datapipe:v0.3.3
