#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow
id: transformation_1
label: Transformation 1
doc: |-
  Transformation 1: MCSimulation-JUNO (detsim)

  Simulates events in the JUNO detector with tut_detsim.py. There is no
  input data: each job generates its own events from the seed it is
  given (one seed per job, issued by the workgraph's Seeds feeder). In
  the JUNO prodsys this seed is `seed` + the DIRAC job ID.

  What is simulated is set by `detsim-mode` (the prodsys "detsim-mode"):
  by default a particle gun.

  This is a plain CWL run body: the DiracX-specific configuration lives in
  the hints of the workgraph step that runs it.

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  seed:
    doc: The seed for this job, as issued by the Seeds feeder (one per job)
    type:
      type: array
      items: [File, string]
  n-of-events:
    doc: Number of events to simulate
    default: 2
    type: int
  software-version:
    doc: JUNO release, relative to /cvmfs/juno.ihep.ac.cn
    type: string
  detsim-mode:
    doc: Arguments selecting what to simulate (generator and its options)
    default: [gun, --particles, e+, --momentums, '1.398', --positions, '0', '0', '0']
    type: string[]

steps:
  detsim:
    run: ../tools/juno-run-app.cwl
    in:
      software-version: software-version
      application:
        default: tut_detsim.py
      n-of-events: n-of-events
      seed:
        source: seed
        valueFrom: $(parseInt(self[0], 10))
      output:
        source: seed
        valueFrom: detsim-$(self[0]).root
      user-output:
        source: seed
        valueFrom: detsim_user-$(self[0]).root
      extra-args:
        source: detsim-mode
        # --no-gdml must come before the generator sub-command
        valueFrom: $(["--no-gdml"].concat(self))
    out: [output-data, user-data, others]

outputs:
  detsim-files:
    outputSource: detsim/output-data
    type: File[]
  user-files:
    outputSource: detsim/user-data
    type: File[]
  others:
    outputSource: detsim/others
    type: File[]
