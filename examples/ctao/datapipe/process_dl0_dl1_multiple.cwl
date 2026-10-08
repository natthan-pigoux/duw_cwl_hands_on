#!/usr/bin/env cwl-runner

%YAML 1.1
---
cwlVersion: v1.2
class: Workflow
doc: |
  Process multiple dl0 files using process_dl0_dl1 and then merge
  the individual result files into one common output file using
  the merge tool.
  This is useful for processing simulation files in DIRAC as processing
  a single file per DIRAC job would result in very many, very short
  jobs that are not ideal for the workflow management system.

requirements:
  ScatterFeatureRequirement: {}

inputs:
  input_files: File[]
  output_filename: string
  processing_config: File?

outputs:
  intermediate_provenance_log:
    type: File[]
    outputSource: process_dl0_to_dl1/provenance_log
  merge_provenance_log:
    type: File
    outputSource: merge/provenance_log
  merged_output:
    type: File
    outputSource: merge/merged_output

steps:
  filenames:
    in:
      input_file: input_files
    scatter: input_file
    run: ./internal/output_names.cwl
    out:
    - output_filename
    - provenance_log_filename
  merge:
    in:
      input_files: process_dl0_to_dl1/dl1
      output_filename: output_filename
    run: merge.cwl
    out:
    - merged_output
    - provenance_log
  process_dl0_to_dl1:
    in:
      dl0: input_files
      dl1_filename: filenames/output_filename
      processing_config: processing_config
      provenance_log_filename: filenames/provenance_log_filename
    scatter:
    - dl0
    - dl1_filename
    - provenance_log_filename
    scatterMethod: dotproduct
    run: process_dl0_dl1.cwl
    out:
    - dl1
    - provenance_log
