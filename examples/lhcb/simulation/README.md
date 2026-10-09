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
         ┌──────────┐  SIM  ┌───────────────────────┐ HLT1.DST ┌──────────┐
(none) → │ 1. Gauss │ ────▶ │ 2. Boole → Moore HLT1 │ ───────▶ │ 3. Merge │ → HLT1.DST
         └──────────┘       └───────────────────────┘          └──────────┘
```

- **Workgraph** — the DAG of transformations. Unlike the Analysis
  Production example it has no `input-data`/`dirac:Feeder`: the first
  transformation creates the events.
- **Transformations** — one file per transformation. Transformation 2 is
  a two-step sub-workflow: the DIGI file is intermediate and stays inside
  the job, as it does in production.
- **CommandLineTool** — `lb-ap-run-app` runs one LHCb application from a
  ProdConf JSON. The tool fills in the output prefix, number of events,
  input files and, for Gauss, the random seeds (derived from the
  production and job IDs in `output-prefix`).

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

`LbEnv` provides both `cwltool` and `lb-ap-run-app`.

## Things to try

- Change `n-of-events` in `inputs.yaml`.
- Change the job ID in `output-prefix` and check in the Gauss log that
  the run number and seeds change.
- Run several Gauss jobs with `scatter` over a list of output prefixes
  and feed all the SIM files to the merge — this is what the
  transformations do on the grid.
