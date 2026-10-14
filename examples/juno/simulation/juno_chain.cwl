#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow
id: JUNO_Chain_e+_1.398MeV
label: JUNO Chain, e+ 1.398 MeV at the detector centre
doc: |-
  JUNO simulation workgraph: detsim -> elecsim_rec

  Metadata:
    Process: Chain
    Tag: e+_1.398MeV (tagParser (.*)_(.*)MeV -> particle e+, momentum 1.398)
    Software: J26.6.0 (el9_amd64_gcc11)
    Based on: the [Chain] example of ihepdirac-juno-make-productions
      (IHEPDIRAC/TransformationSystem/scripts/ihepdirac_juno_make_productions.py)

  This workgraph contains 2 transformations:
    MCSimulation-JUNO   — detsim (transformations/transformation-1.cwl)
    ElecSimulation-JUNO — elecsim_rec (transformations/transformation-2.cwl)

  It has no input data: the Seeds feeder issues one seed per detsim job.
  ihepdirac-juno-make-productions creates one such workgraph per tag.

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
    # The application logs go to the output sandbox, as in the JUNO prodsys
    output_sandbox: ['app.out', 'app.err']

inputs:
  events:
    doc: Seeds, one per detsim job (prodsys `seed` + job ID, for `njobs` jobs)
    dirac:Feeder:
      name: Seeds
      args:
        target_events: 20
        events_per_seed: 2
    type: {type: array, items: [File, string]}
  n-of-events:
    doc: Number of events each detsim job simulates (prodsys `evtmax`)
    default: 2
    type: int
  software-version:
    doc: JUNO release, relative to /cvmfs/juno.ihep.ac.cn (prodsys
      `softwareVersion`)
    default: el9_amd64_gcc11/Release/J26.6.0
    type: string
  detsim-mode:
    doc: What detsim simulates (prodsys `detsim-mode`, with the tag
      parameters filled in)
    default: [gun, --particles, e+, --momentums, '1.398', --positions, '0', '0', '0']
    type: string[]
  elecsim_rec-mode:
    doc: Options for elecsim_rec (prodsys `elecsim_rec-mode`)
    default: [--rate, '0.001', --enableWP, --enableWPDarkPulse, --no-evtrec]
    type: string[]

steps:
  MCSimulation:
    label: MCSimulation-JUNO
    doc: detsim, one seed per job
    hints:
      dirac:Transformation:
        packer: {name: PerInput}
        actions:
          Finalizing: [{action: NoInputProcessedTwice}]
    run: transformations/transformation-1.cwl
    in:
      seed: events
      n-of-events: n-of-events
      software-version: software-version
      detsim-mode: detsim-mode
    out: [detsim-files, user-files]

  ElecSimulation:
    label: ElecSimulation-JUNO
    doc: elecsim_rec, one detsim file per job
    hints:
      dirac:Transformation:
        packer: {name: PerInput}
        actions:
          Finalizing: [{action: NoInputProcessedTwice}]
    run: transformations/transformation-2.cwl
    in:
      input-data: MCSimulation/detsim-files
      software-version: software-version
      elecsim_rec-mode: elecsim_rec-mode
    out: [rec-files, user-files]

outputs:
  detsim:
    label: detsim files (kept, as with prodsys moveType = detsim)
    outputSource: MCSimulation/detsim-files
    type: File[]
  elecsim_rec:
    label: elecsim_rec files
    outputSource: ElecSimulation/rec-files
    type: File[]
  user:
    label: User (analysis) files of both steps
    outputSource: [MCSimulation/user-files, ElecSimulation/user-files]
    linkMerge: merge_flattened
    type: File[]
