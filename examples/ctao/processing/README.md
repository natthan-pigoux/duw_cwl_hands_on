# CTAO DL0 to DL2 Processing as CWL

A simplified workflow to process DL0/Event files from an Observation Block to DL1 and DL2 using the ``ctapipe-process`` tool. 

The input data used for this example is downloaded from public test dataset from CTAO Minio. 


The [CTAO DL0 to DL2 workflow example](examples/ctao/processing/workflow_dl0_to_dl2.cwl) needs an input data file which can be downloaded using the pixi task:
```bash
pixi run create-dl0-dl2-input
```
Then you must adapt the [input_dl0_dl2.yaml](examples/ctao/processing/input_dl0_dl2.yaml) and run the workflow:
```bash
pixi run cwltool --outdir=/tmp/cwl_output examples/ctao/processing/workflow_dl0_to_dl2.cwl /tmp/tmpeam81tot/input_dl0_dl2.yaml
```

The [DL0 to DL1 multiple](examples/ctao/processing/process_dl0_dl1_multiple.cwl) needs first to generate multiple input files:
```bash
pixi run create-multi-dl1-input
```
Once the input file generated, simply run:
```bash
pixi run cwltool --outdir=/tmp/cwl_output examples/ctao/processing/process_dl0_dl1_multiple.cwl input_mutliple.yaml
```
