#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool
id: juno-run-app
label: Run a JUNO offline application step

doc: |-
  Common runner for one JUNO offline (junosw) step.

  This is the CWL equivalent of the JUNO production system's
  bootstrap.sh -> run-<app>-ts.sh scripts
  (/cvmfs/dcomputing.ihep.ac.cn/frontend/prodsys/scripts/): it sets up a
  JUNO release from CVMFS and runs one application, by default one of the
  steering scripts under $TUTORIALROOT/share:

    detsim       tut_detsim.py
    elecsim      tut_det2elec.py
    elecsim_rec  tut_elec2rec.py
    calib        tut_det2calib.py
    rec          tut_calib2rec.py
    rawrec       tut_rtraw2rec.py
    ...

  The tool only adds the arguments that come from the dataflow (number of
  events, seed, input and output files). Everything that defines the
  physics (the prodsys "<step>-mode", e.g. a particle gun or a generator
  and its options) goes in `extra-args`, and is appended after them.
  Literal $TUTORIALROOT and $JUNOTOP in `application`, `executable` and
  `extra-args` are replaced with their values once the release is set up.

  The DockerRequirement hint points at the JUNO EL9 image, an unpacked
  Apptainer sandbox on CVMFS. Run with `cwltool --singularity` on hosts
  whose OS lacks libraries the release needs (e.g. libnsl.so.3), or with
  `--no-container` on hosts that have them.

inputs:
  cvmfs-repo:
    doc: JUNO CVMFS repository.
    type: string
    default: /cvmfs/juno.ihep.ac.cn
  software-version:
    doc: Release path relative to `cvmfs-repo`, e.g.
      el9_amd64_gcc11/Release/J26.6.0. setup.sh is sourced from there.
    type: string
  application:
    doc: Steering script to run with python. A bare name is looked up in
      $TUTORIALROOT/share; a path is used as is. Ignored if `executable`
      is set.
    type: string?
  executable:
    doc: Run this program instead of a python steering script (e.g. a
      generator).
    type: string?
  n-of-events:
    doc: Number of events to process (--evtmax; -1 for all events in the
      input).
    type: int?
  seed:
    doc: Random seed (--seed). In production this is the prodsys `seed`
      plus the DIRAC job ID.
    type: int?
  input-data:
    doc: Input files, each passed with --input. Either staged Files or
      URLs/LFNs read remotely.
    type:
    - 'null'
    - type: array
      items: [File, string]
  output:
    doc: Name of the main output file (--output).
    type: string?
  user-output:
    doc: Name of the user (analysis) output file (--user-output).
    type: string?
  extra-args:
    doc: Further arguments, appended after the ones above (the prodsys
      "<step>-mode"). Sub-commands such as `gun ...` or `hepevt ...` must
      come last, so they belong here.
    type: string[]
    default: []
  auxiliary-files:
    doc: Files placed in the working directory before the application
      runs, e.g. the event file of a generator run as an earlier step
      (what the prodsys "<step>-preScripts" produce in the same job).
    type: File[]
    default: []
  output-data-glob:
    doc: Glob pattern(s) matching the data files produced by the step.
      Defaults to the `output` file.
    type: string[]?
  user-data-glob:
    doc: Glob pattern(s) matching the user files produced by the step.
      Defaults to the `user-output` file.
    type: string[]?

outputs:
  output-data:
    doc: Data files produced by the application.
    type: File[]
    outputBinding:
      glob: |-
        ${
          if (inputs["output-data-glob"]) return inputs["output-data-glob"];
          return inputs.output ? [inputs.output] : [];
        }
  user-data:
    doc: User (analysis) files produced by the application.
    type: File[]
    outputBinding:
      glob: |-
        ${
          if (inputs["user-data-glob"]) return inputs["user-data-glob"];
          return inputs["user-output"] ? [inputs["user-output"]] : [];
        }
  others:
    doc: Logs of the application.
    type: File[]
    outputBinding:
      glob: [app.out, app.err]

requirements:
  InlineJavascriptRequirement: {}
  # Reconstruction reads conditions from the JUNO Frontier database
  NetworkAccess:
    networkAccess: true
  InitialWorkDirRequirement:
    listing:
    # Inputs produced by an earlier step (e.g. a generator's event file),
    # placed in the working directory so that extra-args can name them.
    - $(inputs["auxiliary-files"])
    # The release must be set up in the same shell as the application, so
    # the step runs through this script. (In CWL, \$( and \${ escape the
    # shell's own $( and ${.)
    - entryname: juno-run-app.sh
      entry: |-
        #!/bin/bash
        source "$JUNO_CVMFS_REPO/$JUNO_SOFTWARE_VERSION/setup.sh" > setup.log 2>&1 \
            || { cat setup.log >&2; exit 1; }

        # Replace literal $TUTORIALROOT and $JUNOTOP, known only after setup
        expand() {
            local a=\${1//'$TUTORIALROOT'/$TUTORIALROOT}
            printf '%s\n' "\${a//'$JUNOTOP'/$JUNOTOP}"
        }

        args=()
        for a in "$@"; do args+=("\$(expand "$a")"); done

        if [ -n "$JUNO_EXECUTABLE" ]; then
            cmd=("\$(expand "$JUNO_EXECUTABLE")")
        else
            app=\$(expand "$JUNO_APPLICATION")
            [[ "$app" == */* ]] || app="$TUTORIALROOT/share/$app"
            cmd=(python "$app")
        fi

        echo "Running: \${cmd[*]} \${args[*]}"
        "\${cmd[@]}" "\${args[@]}" > app.out 2> app.err
        status=$?
        [ $status -eq 0 ] || tail -n 50 app.err >&2
        exit $status
  EnvVarRequirement:
    envDef:
      JUNO_CVMFS_REPO: $(inputs["cvmfs-repo"])
      JUNO_SOFTWARE_VERSION: $(inputs["software-version"])
      JUNO_APPLICATION: $(inputs.application || "")
      JUNO_EXECUTABLE: $(inputs.executable || "")

hints:
  DockerRequirement:
    dockerImageId: /cvmfs/juno.ihep.ac.cn/singularity/juno-el9

baseCommand: [bash, juno-run-app.sh]
arguments:
- valueFrom: |-
    ${
      var args = [];
      if (inputs["n-of-events"] !== null) args.push("--evtmax", String(inputs["n-of-events"]));
      if (inputs.seed !== null) args.push("--seed", String(inputs.seed));
      (inputs["input-data"] || []).forEach(function (f) {
        args.push("--input", typeof f === "string" ? f : f.path);
      });
      if (inputs.output) args.push("--output", inputs.output);
      if (inputs["user-output"]) args.push("--user-output", inputs["user-output"]);
      return args.concat(inputs["extra-args"]);
    }
