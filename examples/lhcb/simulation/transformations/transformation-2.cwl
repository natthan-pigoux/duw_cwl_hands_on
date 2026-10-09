#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow
id: transformation_2
label: Transformation 2
doc: |-
  Transformation 2: MCReconstruction

  Two application steps chained inside a single job:
    2. Boole  - digitisation (Digi17c, without spillover)
    3. Moore  - HLT1 (flagging mode: all events are kept)

  Unlike the other transformations this run body is a multi-step
  Workflow: the intermediate DIGI file never leaves the job.

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
    doc: SIM files produced by transformation 1
    type:
      type: array
      items: [File, string]

steps:
  Digi17c_2025_W43_45_NoSpillover:
    run: ../tools/lb-ap-run-app.cwl
    in:
      output-prefix:
        source: output-prefix
        valueFrom: $(self)_2
      input-data: input-data
      step-index:
        default: 2
      output-data-glob:
        default: ['*.[dD][iI][gG][iI]']
      prod-conf:
        default: |-
          {
            "spec_version": 1,
            "application": {
              "name": "Boole",
              "version": "v47r0p1",
              "binary_tag": "x86_64_v2-el9-gcc13+detdesc-opt",
              "data_pkgs": [
                "AppConfig.v3r471"
              ]
            },
            "options": {
              "files": [
                "$APPCONFIGOPTS/Boole/Default.py",
                "$APPCONFIGOPTS/Boole/Boole-Upgrade-Baseline-20200616.py",
                "$APPCONFIGOPTS/Boole/Upgrade-RichMaPMT-NoSpilloverDigi.py",
                "$APPCONFIGOPTS/Boole/Boole-Upgrade-IntegratedLumi-0fb.py",
                "$APPCONFIGOPTS/Boole/Run3-VP-NoSpillOver.py",
                "$APPCONFIGOPTS/Persistency/BasketSize-10.py",
                "$APPCONFIGOPTS/Boole/MuonLowE-Bkg-G4.py",
                "$APPCONFIGOPTS/Persistency/Compression-ZSTD-1.py"
              ]
            },
            "db_tags": {
              "dddb_tag": "2025-v00.03",
              "conddb_tag": "sim10-2025.W43.45-v00.00-md100"
            },
            "input": {},
            "output": {
              "types": [
                "digi"
              ]
            }
          }
    out: [output-data, others]

  HLT1_2025_W43_45:
    run: ../tools/lb-ap-run-app.cwl
    in:
      output-prefix:
        source: output-prefix
        valueFrom: $(self)_3
      input-data: Digi17c_2025_W43_45_NoSpillover/output-data
      step-index:
        default: 3
      output-data-glob:
        default: ['*.[hH][lL][tT]1.[dD][sS][tT]']
      prod-conf:
        default: |-
          {
            "spec_version": 1,
            "application": {
              "name": "Moore",
              "version": "v57r14p3",
              "binary_tag": "x86_64_v2-el9-gcc13+detdesc-opt",
              "data_pkgs": []
            },
            "options": {
              "entrypoint": "Moore.production:hlt1",
              "extra_options": {
                "data_type": "Upgrade",
                "input_type": "ROOT",
                "simulation": true,
                "compression": {
                  "level": 1,
                  "algorithm": "ZSTD",
                  "max_buffer_size": 1048576
                },
                "output_type": "ROOT",
                "root_ioalg_name": "RootIOAlgExt",
                "root_ioalg_opts": {
                  "IgnorePaths": ["/Event/DAQ"],
                  "StoreOldFSRs": true
                },
                "input_raw_format": 0.5
              },
              "extra_args": [
                "--",
                "--sequence=hlt1_pp_forward_then_matching_and_downstream_with_parkf_1200kHz_M23_M41",
                "--merge-fsrs",
                "--flagging"
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
  reco-files:
    outputSource: HLT1_2025_W43_45/output-data
    type: File[]
  others:
    outputSource:
    - Digi17c_2025_W43_45_NoSpillover/others
    - HLT1_2025_W43_45/others
    linkMerge: merge_flattened
    type: File[]
