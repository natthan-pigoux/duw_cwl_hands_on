# LHCb Run 3 simulation as CWL

A Run 3 Monte Carlo production expressed as a CWL workgraph: minimum bias
events (event type `30000000`) generated, digitised and passed through
HLT1 with the 2025.W43.45 MagDown conditions, then merged.

The application steps are taken from the real MC request
`Lb2Lmumu_run3 2025.W43.45 pp MagDown`
([lhcb-simulation/mc-requests!2372](https://gitlab.cern.ch/lhcb-simulation/mc-requests/-/merge_requests/2372)).

It follows the same structure as the
[LHCb Analysis Production example](https://gitlab.cern.ch/roneil/lhcb-cwl-example),
but needs **no input data and no credentials**: the events are generated
from scratch, and the software and conditions come from CVMFS.

## Layout

```
minbias_2025_mc.cwl           Workgraph (outermost Workflow)
inputs.yaml
transformations/
  transformation-1.cwl        MCSimulation — Gauss (Sim10h)
  transformation-2.cwl        MCReconstruction — Boole → HLT1
  transformation-3.cwl        MCMerge — merge the HLT1 DSTs
tools/
  lb-ap-run-app.cwl           Common CommandLineTool shared by all steps
```

```
        ┌──────────────┐ sim-files ┌───────────────────────┐ reco-files ┌──────────┐
seeds → │ MCSimulation │ ────────▶ │ MCReconstruction      │ ─────────▶ │ MCMerge  │ → datasets
        │ Gauss        │           │ Boole → Moore HLT1    │            │ LHCb     │
        └──────────────┘           └───────────────────────┘            └──────────┘
```

The `dirac:` hints follow DX-ADR-007 and the draft `dirac-1.0` hint
schema ([DIRACGrid/diracx#1042](https://github.com/DIRACGrid/diracx/pull/1042)):

- **Workgraph** (`dirac:Workgraph`) — the DAG of transformations, with
  `schema_version`, its VO `type` (`MCSimulation`) and the
  `output_sandbox` patterns. There is no input data: the `events` input
  carries a `dirac:Feeder` naming the **Seeds** feeder, which issues one
  seed per MCSimulation job.
- **Transformations** (`dirac:Transformation` on each step) — the packer
  that groups inputs into jobs (one seed per job, then groups of 3 and 8
  files) and the finalizing checks. The run bodies under
  `transformations/` are plain CWL. MCReconstruction's is a two-step
  sub-workflow: the DIGI file never leaves the job.
- **Outputs** — only the merged files (`datasets`) are declared. The
  SIM and reconstructed files are consumed but not declared, which makes
  them intermediates. Logs and summaries are not dataflow: they go to the
  output sandbox through the `output_sandbox` patterns.
- **CommandLineTool** — `lb-ap-run-app` runs one LHCb application from a
  ProdConf JSON. The tool fills in the output prefix, number of events,
  input files and, for Gauss, the seed (used as the job number from which
  lb-prod-run derives the run number and first event number).

## Differences from production

To run in a few minutes, the example deviates from the real request:

- **Pileup** is reduced from ν = 7.6 to ν = 1.0, by overriding
  `Gauss().Luminosity` in the Gauss step's `gaudi_extra_options` (which
  are applied after the beam options file).
- **Spillover** is disabled: `Gauss/EnableSpillover-25ns.py` and
  `Boole/EnableSpillover.py` are not included, so only the main bunch
  crossing is simulated and digitised.
- **HLT2 is not run**: the chain stops after HLT1 (flagging mode, so
  every event is kept), and the HLT1 DSTs are merged.
- The output file type is `hlt1.dst` rather than the hashed
  `HLT1_FILTERED_<hash>.DST`, and only one job runs per transformation.

## Running

Needs an x86_64 EL9 machine with CVMFS (e.g. lxplus, or `lblhcbpr20`):

```bash
source /cvmfs/lhcb.cern.ch/lib/LbEnv
cwltool --outdir /tmp/lhcb_mc_output \
    examples/lhcb/simulation/minbias_2025_mc.cwl \
    examples/lhcb/simulation/inputs.yaml
```

`LbEnv` provides both `cwltool` and `lb-ap-run-app`. `inputs.yaml`
supplies the seed by hand, since there is no feeder locally. Seeds are
positive integers.

Because logs go to the output sandbox rather than through the dataflow,
`cwltool` only copies the merged DST to the output directory. To keep
the logs of every step when running locally, add `--leave-tmpdir`, or run
a single transformation's file directly: its run body still exposes them
as the `others` output.

## Things to try

- Change `n-of-events` in `inputs.yaml`.
- Change the seed in `inputs.yaml` and check in the Gauss log that the
  run number and seeds change.
- Run several Gauss jobs with `scatter` over a list of seeds and feed all
  the SIM files to the merge — this is what the transformations do on the
  grid, with the packers deciding the grouping.
