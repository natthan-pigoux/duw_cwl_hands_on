# JUNO simulation as CWL

A JUNO Monte Carlo production expressed as a CWL workgraph: positrons
of 1.398 MeV fired from the centre of the detector, simulated (detsim),
then put through electronics simulation and reconstruction
(elecsim_rec), with the J26.6.0 release.

It is the `[Chain]` example of the JUNO production system,
`ihepdirac-juno-make-productions --example`, translated to CWL. The
production system is part of IHEPDIRAC
(`IHEPDIRAC/TransformationSystem/scripts/ihepdirac_juno_make_productions.py`),
and the job scripts it runs are on CVMFS in
`/cvmfs/dcomputing.ihep.ac.cn/frontend/prodsys/scripts/`.

## Layout

```
juno_chain.cwl                Workgraph (outermost Workflow)
inputs.yaml
transformations/
  transformation-1.cwl        MCSimulation-JUNO   — detsim
  transformation-2.cwl        ElecSimulation-JUNO — elecsim_rec
tools/
  juno-run-app.cwl            Common CommandLineTool shared by all steps
```

```
        ┌──────────────┐ detsim ┌─────────────────────┐
seeds → │ MCSimulation │ ─────▶ │ ElecSimulation      │ → elecsim_rec
        │ detsim       │   │    │ elecsim_rec         │
        └──────────────┘   │    └─────────────────────┘
                           └──────────────────────────→ detsim
```

## From the JUNO production system to CWL

`ihepdirac-juno-make-productions` reads an ini file and, for each
**tag** (e.g. `e+_1.398MeV`), creates one DIRAC transformation per step
in `workflow`. Every job of every transformation runs the same
`bootstrap.sh`, which downloads and runs `run-<step>-ts.sh`. That script
sets up the JUNO release from CVMFS and calls one steering script from
`$TUTORIALROOT/share`. Here:

| JUNO prodsys | CWL |
|---|---|
| one production per tag | one workgraph (`juno_chain.cwl`); the tag's parameters are filled into `detsim-mode` |
| `bootstrap.sh` → `run-<step>-ts.sh` | `tools/juno-run-app.cwl`, one CommandLineTool for every step |
| a transformation per step in `workflow` | a workgraph step with a `dirac:Transformation` hint |
| detsim: `MaxNumberOfTasks = njobs`, seed = `seed` + job ID | `events` with the **Seeds** feeder, `PerInput` packer |
| later steps: DFC metadata query on the previous `transID`, group size 1 | dataflow from the previous step, `PerInput` packer |
| `<step>-mode` | `detsim-mode`, `elecsim_rec-mode` |
| `softwareVersion`, `evtmax` | `software-version`, `n-of-events` |
| `dirac-add-files.py` (upload to an SE and register in the DFC) | declared workgraph outputs |
| output sandbox `app.out`, `app.err` | `output_sandbox` in the `dirac:Workgraph` hint |
| `moveType` (Replication transformations) | not part of the dataflow: data management, left out |

## The CommandLineTool

`juno-run-app` can run any JUNO job. It sets up the release
(`software-version`) and runs `application`, a steering script in
`$TUTORIALROOT/share`, or `executable`, any other program. It adds
`--evtmax`, `--seed`, `--input` (once per input file), `--output` and
`--user-output` from its inputs, then appends `extra-args`. The prodsys
`<step>-mode` goes in `extra-args`, so generator sub-commands such as
`gun ...` or `hepevt ...` stay last. Literal `$TUTORIALROOT` and
`$JUNOTOP` in `application`, `executable` and `extra-args` are expanded
after setup, as `run-rawrec-ts.sh` does. Files in `auxiliary-files` are
placed in the working directory, so `extra-args` can name them.

The prodsys steps map to these applications:

| prodsys step | `application` |
|---|---|
| detsim | `tut_detsim.py` |
| elecsim | `tut_det2elec.py` |
| elecsim_rec | `tut_elec2rec.py` |
| calib (without elecsim) | `tut_det2calib.py` |
| rec | `tut_calib2rec.py` |
| rawrec | `tut_rtraw2rec.py` |

For example, to reconstruct a raw data file:

```yaml
software-version: el9_amd64_gcc11/Release/J26.6.0
application: tut_rtraw2rec.py
n-of-events: 100
input-data: [{class: File, path: RUN.1234.JUNODAQ.Physics.ds-2.global_trigger.20250306.001.rtraw}]
output: RUN.1234.JUNODAQ.Physics.ds-2.global_trigger.20250306.001.esd
extra-args: [--global-tag, MixedPhase_J25.4, --method, qctr]
```

Reconstruction, elecsim_rec included, reads the conditions database
through Frontier, so the tool declares `NetworkAccess` (without it,
`cwltool` runs the container with no network). The production jobs for
real data also set `FRONTIER_SERVER` and the site's proxies, as
`run-rawrec-ts.sh` does; the default server is enough for this example.

Some prodsys steps run a `<step>-preScripts` first, typically a
generator writing the events that detsim then reads. In CWL that is a
step of its own in the same transformation: run the generator with
`executable`, collect its file with `output-data-glob`, and pass it to
detsim in `auxiliary-files`:

```yaml
steps:
  generate:
    run: ../tools/juno-run-app.cwl
    in:
      software-version: software-version
      executable: {default: Muon.exe}
      extra-args:
        source: seed
        valueFrom: |-
          $(["-seed", self[0], "-o", "Muon.txt", "-n", "2", "-v", "Rock", "-mult", "1",
             "-music_dir", "$JUNOTOP/data/Generator/Muon/data"])
      output-data-glob: {default: [Muon.txt]}
    out: [output-data]
  detsim:
    run: ../tools/juno-run-app.cwl
    in:
      auxiliary-files: generate/output-data
      extra-args: {default: [--no-gdml, hepevt, --exe, Muon, --file, Muon.txt]}
      # ... as in transformation-1.cwl
```

The tool has a `DockerRequirement` hint for the JUNO EL9 image on
CVMFS, `/cvmfs/juno.ihep.ac.cn/singularity/juno-el9`, an unpacked
Apptainer sandbox. It provides libraries such as `libnsl.so.3` that the
release needs but some EL9 hosts lack.

## Differences from production

- The example runs one job per transformation, with 2 events, so it
  finishes in a few minutes. The production example runs 10 jobs per
  tag, for 3 tags.
- `userOutput` is on, so the user files are kept and declared as an
  output.
- detsim is run with `--no-gdml`, as `run-detsim-ts.sh` does.

## Running

Run it on lxplus:

```bash
export APPTAINER_BINDPATH=/cvmfs
cwltool --singularity --outdir /tmp/juno_output \
    examples/juno/simulation/juno_chain.cwl \
    examples/juno/simulation/inputs.yaml
```

`inputs.yaml` supplies the seed by hand, since there is no feeder
locally. `--singularity` runs the steps in the JUNO EL9 image, and
`APPTAINER_BINDPATH` makes CVMFS visible inside it. If `apptainer` is
not on your `PATH`, it is on CVMFS:

```bash
export PATH=/cvmfs/oasis.opensciencegrid.org/mis/apptainer/current/bin:$PATH
```

On a host that already has everything the release needs, use
`--no-container` instead of `--singularity`.

Each step takes a few minutes, longer on the first run while CVMFS fills
its cache.

`cwltool` copies the detsim, elecsim_rec and user files to the output
directory. The application logs go to the output sandbox, so they are
not copied: add `--leave-tmpdir` to keep them, or run a single
transformation's file directly, which exposes them as the `others`
output.

## Things to try

- Change the particle or momentum in `detsim-mode`, as another tag would.
- Change the seed in `inputs.yaml`.
- Run elecsim and rec as two steps (`tut_det2elec.py`, then
  `tut_elec2rec.py`) instead of elecsim_rec.
- Run several detsim jobs with `scatter` over a list of seeds.
