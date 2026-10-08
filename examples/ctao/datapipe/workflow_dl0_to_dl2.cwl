#!/usr/bin/env cwl-runner

%YAML 1.1
---
cwlVersion: v1.2
class: Workflow
label: Process DL0 to DL2
doc: |
  Process an input file to from DL0 to separate DL1 and DL2 outputs.

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  dl0:
    doc: DL0 data file in format supported by ctapipe.
    type: File
  processing_config:
    doc: data processing configuration for ctapipe-process.
    type: File?

outputs:
  dl1:
    doc: DL1 data file in ctapipe hdf5 format
    type: File
    outputSource: dl0_to_dl1/dl1
  dl2:
    doc: DL2 data file in ctapipe hdf5 format
    type: File
    outputSource: dl1_to_dl2/dl2

steps:
  dl0_to_dl1:
    in:
      dl0: dl0
      dl1_filename:
        valueFrom: $(inputs.dl0.basename.replace(/\.simtel\.zst$/, '.dl1.h5'))
      processing_config: processing_config
    run: process_dl0_dl1.cwl
    out:
    - dl1
    - provenance_log
  dl1_to_dl2:
    in:
      dl1: dl0_to_dl1/dl1
      dl2_filename:
        valueFrom: $(inputs.dl1.basename.replace(/\.dl1.h5$/, '.dl2.h5'))
      processing_config: processing_config
    run: process_dl1_dl2.cwl
    out:
    - dl2
    - provenance_log
