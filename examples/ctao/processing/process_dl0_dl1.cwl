#!/usr/bin/env cwl-runner

%YAML 1.1
---
cwlVersion: v1.2
class: CommandLineTool
label: Process DL0 to DL1
doc: |
  Processes a single file from DL0 to DL1 using the ctapipe-process tool.
  (*DPPS-UC-130-1.2.1*)

requirements:
  InlineJavascriptRequirement: {}

inputs:
  camera_calibration_file:
    type: File?
    inputBinding:
      prefix: --HDF5MonitoringSource.input_files
  dl0:
    doc: |
      path to input file, which can be at any data level transformable to DL1
      that is supported by the installed ctapipe io plugins. I can also be a
      URL.
    type:
    - File
    - string
    inputBinding:
      prefix: --input
  dl1_filename:
    doc: name of the DL1 output file
    type: string
    inputBinding:
      prefix: --output
  processing_config:
    doc: |
      Sets the reconstruction parameters that apply to DL0 to DL1.
      See ``ctapipe-process --help-all`` for a list of all options, or the output
      of ``ctapipe-quickstart`` for sample configuration files.
    type: File?
    inputBinding:
      prefix: --config
  provenance_log_filename:
    doc: file in which to write the local ctapipe-process provenance.
    type: string
    default: ctapipe-process_dl0_dl1.provenance.log
    inputBinding:
      prefix: --provenance-log
  write_images:
    doc: If true, store DL1 images in the output file
    type: boolean
    default: true
    inputBinding:
      prefix: --DataWriter.write_dl1_images
      valueFrom: '$(self ? "True" : "False")'
  write_parameters:
    doc: If true, store DL1 image parameters in the output file
    type: boolean
    default: true
    inputBinding:
      prefix: --DataWriter.write_dl1_parameters
      valueFrom: '$(self ? "True" : "False")'

outputs:
  dl1:
    doc: HDF5 format output file.
    type: File
    outputBinding:
      glob: $(inputs.dl1_filename)
  provenance_log:
    doc: ctapipe format provenance log for this step.
    type: File
    outputBinding:
      glob: $(inputs.provenance_log_filename)

baseCommand: ctapipe-process
arguments:
- --DataWriter.write_dl2=False
- valueFrom: |-
    $(inputs.camera_calibration_file != null ? "--ProcessorTool.monitoring_source_list=HDF5MonitoringSource" : null)

hints:
  DockerRequirement:
    dockerPull: harbor.cta-observatory.org/dpps/datapipe:v0.3.3
