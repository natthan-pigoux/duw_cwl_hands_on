#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow
id: transformation_3
label: Transformation 3
doc: |-
  Transformation 3: MCMerge

  Merges the HLT1 DSTs produced by Transformation 2 into the final
  HLT1.DST, combining the generator-level FSRs (--merge-genfsr) so the
  generator statistics of all input jobs are kept.

  This is a plain CWL run body: the DiracX-specific configuration lives in
  the hints of the workgraph step that runs it.

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  output-prefix:
    doc: 'Output file prefix (format: PPPPPPPP_JJJJJJJJ where P=production-id,
      J=prod-job-id)'
    default: '00012345_00006789'
    type: string
  input-data:
    doc: HLT1 DST files produced by transformation 2
    type:
      type: array
      items: [File, string]

steps:
  Merge_HLT1_DST:
    run: ../tools/lb-ap-run-app.cwl
    in:
      output-prefix:
        source: output-prefix
        valueFrom: $(self)_4
      input-data: input-data
      step-index:
        default: 4
      output-data-glob:
        default: ['*.[hH][lL][tT]1.[dD][sS][tT]']
      prod-conf:
        default: |-
          {
            "spec_version": 1,
            "application": {
              "name": "LHCb",
              "version": "v59r5",
              "data_pkgs": [
                "AppConfig.v3r471"
              ]
            },
            "options": {
              "entrypoint": "GaudiConf.mergeDST:dst",
              "extra_options": {
                "data_type": "Upgrade",
                "write_fsr": true,
                "input_type": "ROOT",
                "simulation": true,
                "compression": {
                  "level": 4,
                  "algorithm": "LZMA",
                  "max_buffer_size": 1048576
                },
                "output_type": "ROOT",
                "root_ioalg_name": "RootIOAlgExt",
                "root_ioalg_opts": {
                  "IgnorePaths": ["/Event/DAQ/RawEvent/moved/aside"],
                  "StoreOldFSRs": true
                },
                "input_raw_format": 0.5
              },
              "extra_args": [
                "--",
                "--merge-genfsr"
              ]
            },
            "db_tags": {
              "dddb_tag": "2025-v00.03",
              "conddb_tag": "sim10-2025.W43.45-v00.00-md100"
            },
            "input": {},
            "output": {
              "types": [
                "hlt1.dst"
              ]
            }
          }
    out: [output-data, others]

outputs:
  merged:
    outputSource: Merge_HLT1_DST/output-data
    type: File[]
  others:
    outputSource:
    - Merge_HLT1_DST/others
    linkMerge: merge_flattened
    type: File[]
