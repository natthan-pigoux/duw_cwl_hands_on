#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow
id: transformation_1
label: Transformation 1
doc: |-
  Transformation 1: MCSimulation

  Generates and simulates minimum bias events (event type 30000000) with
  Gauss (Sim10h). There is no input data: each job generates its own
  events from the seed it is given (one seed per job, issued by the
  workgraph's Seeds feeder).

  To keep the example fast, the configuration differs from production in
  two ways:
    * the pileup is reduced from nu=7.6 to nu=1.0 by overriding
      Gauss().Luminosity in gaudi_extra_options, which runs after the
      beam options file;
    * spillover is disabled ($APPCONFIGOPTS/Gauss/EnableSpillover-25ns.py
      is not included), so only the main bunch crossing is simulated.

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
  seed:
    doc: The seed for this job, as issued by the Seeds feeder (one per job)
    type:
      type: array
      items: [File, string]
  n-of-events:
    doc: Number of events to generate
    default: 2
    type: int

steps:
  Sim10h_2025_W43_45_MagDown_nu1:
    run: ../tools/lb-ap-run-app.cwl
    in:
      output-prefix:
        source: output-prefix
        valueFrom: $(self)_1
      n-of-events: n-of-events
      seed:
        source: seed
        valueFrom: $(self[0])
      step-index:
        default: 1
      output-data-glob:
        default: ['*.[sS][iI][mM]']
      prod-conf:
        default: |-
          {
            "spec_version": 1,
            "application": {
              "name": "Gauss",
              "version": "v57r1",
              "binary_tag": "x86_64_v3-el9-gcc13-opt",
              "data_pkgs": [
                "AppConfig.v3r471",
                "Gen/DecFiles.v32r50"
              ]
            },
            "options": {
              "files": [
                "$APPCONFIGOPTS/Gauss/Beam6800GeV-md100-2025.W43.45-nu7.6.py",
                "$APPCONFIGOPTS/Gauss/Run3-detector.py",
                "$APPCONFIGOPTS/Gauss/DataType-2025.py",
                "$DECFILESROOT/options/30000000.py",
                "$LBPYTHIA8ROOT/options/Pythia8.py",
                "$APPCONFIGOPTS/Gauss/G4PL_FTFP_BERT_EmOpt2.py",
                "$APPCONFIGOPTS/Persistency/BasketSize-10.py",
                "$APPCONFIGOPTS/Persistency/Compression-ZSTD-1.py"
              ],
              "gaudi_extra_options": "from Configurables import Gauss\nfrom GaudiKernel import SystemOfUnits\n# nu = 1.0 instead of 7.6: scale the luminosity per bunch by 1.0/7.6\nGauss().Luminosity = 0.835 * (10**30) * 1.0 / 7.6 / (SystemOfUnits.cm2 * SystemOfUnits.s)\n"
            },
            "db_tags": {
              "dddb_tag": "2025-v00.03",
              "conddb_tag": "sim10-2025.W43.45-v00.00-md100"
            },
            "input": {
              "files": [],
              "seeds": {
                "production_id": 0,
                "prod_job_id": 0
              }
            },
            "output": {
              "types": [
                "sim"
              ]
            }
          }
    out: [output-data, others]

outputs:
  sim-files:
    outputSource: Sim10h_2025_W43_45_MagDown_nu1/output-data
    type: File[]
  others:
    outputSource:
    - Sim10h_2025_W43_45_MagDown_nu1/others
    linkMerge: merge_flattened
    type: File[]
