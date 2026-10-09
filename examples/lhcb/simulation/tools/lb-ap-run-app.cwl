#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool
id: lb-ap-run-app
label: Run an LHCb application step with lb-ap-run-app

doc: |-
  Common runner for one LHCb application step.

  The static application configuration is supplied via `prod-conf` and
  completed at runtime: the output file prefix, the XML summary file name
  (derived from the application name), the number of events, the
  simulation seeds and the resolved list of input files are filled in
  before the configuration is written to prodConf_<N>.json and executed
  with `lb-ap-run-app` (provided by LbEnv on CVMFS).

inputs:
  prod-conf:
    doc: |-
      Static part of the ProdConf configuration (application, options,
      db_tags, input/output settings) as a JSON string. Runtime fields are
      filled in by this tool. Passed as a string rather than a structured
      value so the CWL document loader does not URI-resolve fields named
      'name' inside it.
    type: string
  step-index:
    doc: 1-based index of this step within the job; used to name the
      generated prodConf_<N>.json file.
    type: int
  output-prefix:
    doc: 'Output file prefix (format: PPPPPPPP_JJJJJJJJ_N where
      P=production-id, J=prod-job-id, N=step-index).'
    type: string
  n-of-events:
    doc: Number of events to process (-1 for all events in the input).
    type: int
    default: -1
  input-data:
    doc: Input data files, either as staged Files or as URLs. Omitted for
      steps that generate events from scratch (Gauss).
    type:
    - 'null'
    - type: array
      items: [File, string]
  output-data-glob:
    doc: Glob pattern(s) matching the data files produced by the application.
    type: string[]

outputs:
  output-data:
    doc: Data files produced by the application.
    type: File[]
    outputBinding:
      glob: $(inputs["output-data-glob"])
  others:
    doc: Configuration files, XML summaries, prmon output and logs.
    type: File[]
    outputBinding:
      glob:
      - prodConf_*.json
      - prodConf_*.py
      - summary*.xml
      - prmon*
      - '*.log'

requirements:
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
    - entryname: prodConf_$(inputs["step-index"]).json
      entry: |-
        ${
          var conf = JSON.parse(inputs["prod-conf"]);
          var prefix = inputs["output-prefix"];
          conf["output"]["prefix"] = prefix;
          conf["input"]["xml_summary_file"] =
            "summary" + conf["application"]["name"].replace(/\//g, "") +
            "_" + prefix + ".xml";
          conf["input"]["n_of_events"] = inputs["n-of-events"];
          if (conf["input"]["seeds"]) {
            // Gauss derives its random seeds (run number and first event
            // number) from the production and job IDs in the prefix.
            var ids = prefix.split("_");
            conf["input"]["seeds"]["production_id"] = parseInt(ids[0], 10);
            conf["input"]["seeds"]["prod_job_id"] = parseInt(ids[1], 10);
          }
          if (inputs["input-data"]) {
            conf["input"]["files"] = inputs["input-data"].map(function (f) {
              return typeof f === "string" ? f : f.path;
            });
          }
          return JSON.stringify(conf, null, 2);
        }

baseCommand: [lb-ap-run-app]
arguments:
- prodConf_$(inputs["step-index"]).json
