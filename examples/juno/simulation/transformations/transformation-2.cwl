#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow
id: transformation_2
label: Transformation 2
doc: |-
  Transformation 2: ElecSimulation-JUNO (elecsim_rec)

  Electronics simulation followed by reconstruction, in a single
  application (tut_elec2rec.py), over one detsim file per job (the JUNO
  prodsys uses a group size of 1 for this step).

  The options are set by `elecsim_rec-mode` (the prodsys
  "elecsim_rec-mode").

  This is a plain CWL run body: the DiracX-specific configuration lives in
  the hints of the workgraph step that runs it.

requirements:
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  input-data:
    doc: detsim file produced by transformation 1
    type:
      type: array
      items: [File, string]
  software-version:
    doc: JUNO release, relative to /cvmfs/juno.ihep.ac.cn
    type: string
  elecsim_rec-mode:
    doc: Further options for tut_elec2rec.py
    default: [--rate, '0.001', --enableWP, --enableWPDarkPulse, --no-evtrec]
    type: string[]

steps:
  elecsim_rec:
    run: ../tools/juno-run-app.cwl
    in:
      software-version: software-version
      application:
        default: tut_elec2rec.py
      n-of-events:
        default: -1
      input-data: input-data
      # As in run-elecsim_rec-ts.sh: detsim-<N>.root -> elecsim_rec-<N>.root,
      # with <N> also used as the seed
      seed:
        source: input-data
        valueFrom: |-
          ${
            var f = self[0];
            var name = typeof f === "string" ? f.split("/").pop() : f.basename;
            return parseInt(name.replace(/\D/g, ""), 10);
          }
      output:
        source: input-data
        valueFrom: |-
          ${
            var f = self[0];
            var name = typeof f === "string" ? f.split("/").pop() : f.basename;
            return name.replace("detsim", "elecsim_rec");
          }
      user-output:
        source: input-data
        valueFrom: |-
          ${
            var f = self[0];
            var name = typeof f === "string" ? f.split("/").pop() : f.basename;
            return name.replace("detsim", "elecsim_rec_user");
          }
      extra-args: elecsim_rec-mode
    out: [output-data, user-data, others]

outputs:
  rec-files:
    outputSource: elecsim_rec/output-data
    type: File[]
  user-files:
    outputSource: elecsim_rec/user-data
    type: File[]
  others:
    outputSource: elecsim_rec/others
    type: File[]
