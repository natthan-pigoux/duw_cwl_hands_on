#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow
id: MC_MinBias_2025_W43_45_MagDown_nu1
label: MinBias 2025.W43.45 pp MagDown nu=1.0, no spillover (30000000)
doc: |-
  LHCb Run 3 simulation workgraph: minimum bias, 2025.W43.45 pp MagDown

  Metadata:
    Event Type: 30000000 (minimum bias)
    Sim Condition: Beam6800GeV-2025.W43.45-MagDown-Nu1.0-Pythia8
      (production uses Nu7.6-25ns; pileup reduced and spillover
      disabled here so the example runs in a few minutes)
    Simulation: Sim10h
    Based on: lhcb-simulation/mc-requests!2372 (Lb2Lmumu_run3)

  This workgraph contains 3 transformations:
    MCSimulation     — Gauss (transformations/transformation-1.cwl)
    MCReconstruction — Boole, HLT1 (transformations/transformation-2.cwl)
    MCMerge          — merge the HLT1 DSTs (transformations/transformation-3.cwl)

  It has no input data: the Seeds feeder issues one seed per MCSimulation
  job. The SIM and reconstructed files are intermediates (consumed but
  not declared as outputs); the merged files are the deliverable.

  The dirac: hints follow DX-ADR-007 and the draft dirac-1.0 hint schema
  (DIRACGrid/diracx#1042).

$namespaces:
  dirac: https://diracgrid.org/cwl#

requirements:
  InlineJavascriptRequirement: {}
  SubworkflowFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  MultipleInputFeatureRequirement: {}
  ResourceRequirement:
    coresMin: 1
    ramMin: 4096

hints:
  dirac:Workgraph:
    schema_version: '1.0'
    type: MCSimulation
    # Logs and summaries are captured to the output sandbox, outside the
    # dataflow: they never become declared outputs.
    output_sandbox: ['prodConf_*.json', 'summary*.xml', 'prmon*', '*.log']

inputs:
  events:
    doc: Seeds, issued until the requested number of events has been produced
    dirac:Feeder:
      name: Seeds
      args:
        target_events: 2
        events_per_seed: 2
    type: {type: array, items: [File, string]}
  output-prefix:
    doc: 'Output file prefix (format: PPPPPPPP_JJJJJJJJ where P=production-id,
      J=prod-job-id), injected per job at scheduling.'
    default: '00012345_00006789'
    type: string
  n-of-events:
    doc: Number of events each MCSimulation job generates (events_per_seed)
    default: 2
    type: int

steps:
  MCSimulation:
    label: MCSimulation
    doc: Gauss, one seed per job
    hints:
      dirac:Transformation:
        packer: {name: PerInput}
        actions:
          Finalizing: [{action: NoInputProcessedTwice}]
    run: transformations/transformation-1.cwl
    in:
      seed: events
      output-prefix: output-prefix
      n-of-events: n-of-events
    out: [sim-files]

  MCReconstruction:
    label: MCReconstruction
    doc: Boole and Moore HLT1 over groups of simulated files
    hints:
      dirac:Transformation:
        packer: {name: ByGroupSizeRun, args: {group_size: 3, keep_storage_together: true}}
        actions:
          Finalizing: [{action: NoInputProcessedTwice}]
    run: transformations/transformation-2.cwl
    in:
      input-data: MCSimulation/sim-files
      output-prefix: output-prefix
    out: [reco-files]

  MCMerge:
    label: MCMerge
    doc: Merge groups of reconstructed files into the deliverable
    hints:
      dirac:Transformation:
        packer: {name: ByGroupSizeRun, args: {group_size: 8, keep_storage_together: true}}
        actions:
          Finalizing: [{action: NoInputProcessedTwice}]
    run: transformations/transformation-3.cwl
    in:
      input-data: MCReconstruction/reco-files
      output-prefix: output-prefix
    out: [merged]

outputs:
  datasets:
    label: Merged MC datasets (HLT1.DST)
    outputSource: MCMerge/merged
    type: File[]
