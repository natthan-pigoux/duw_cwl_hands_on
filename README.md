# DIRAC User Workshop CWL Hands On

Material for DIRAC User Workshop CWL hands on session.

This is based on the [CWL documentation](https://www.commonwl.org/user_guide/).

# CWL Overview

## Basic CommandLineTool and Workflow

- [data-generation.cwl](examples/basic/basic_workflow/data-generation.cwl): [CommandLineTool](https://www.commonwl.org/user_guide/topics/command-line-tool.html#command-line-tool) to generate random data.

- [gaussian-fit.cwl](examples/basic/basic_workflow/gaussian-fit.cwl): [CommandLineTool](https://www.commonwl.org/user_guide/topics/command-line-tool.html#command-line-tool) to run a gaussian"fit" on data files.

- [gaussian-fit-workflow.cwl](examples/basic/basic_workflow/gaussian-fit-workflow.cwl): a two steps [Workflow](https://www.commonwl.org/user_guide/topics/workflows.html#workflows) running the two above CLT.

### Running the CWL examples

All examples can be ran using [cwltool](https://github.com/common-workflow-language/cwltool#install):

with [pixi](https://pixi.prefix.dev/latest/installation/):

```bash
pixi run cwltool examples/basic/hello_world/hello_world.cwl
```

or directly calling `cwltool`:

```bash
cwltool examples/basic/hello_world/hello_world.cwl
```

## Running Containers

To run an executable from a container, one can use the `hints`:
```yaml
hints:
  DockerRequirement:
    dockerPull: /path/to/my/container:latest
```
`dockerPull` will check if the image already exists locally or pull the image.

Try it with the [container_example.cwl](examples/basic/hello_world/container_example.cwl).

## Expressions

If you need to manipulate input parameters, include the requirement `InlineJavascriptRequirement` and then anywhere a parameter reference is legal you can provide a fragment of Javascript that will be evaluated by the CWL runner.

Example:
`TEL001_SDH000_20260613T004600_SBID0000024422_OBSID0000024422_TEL_MUON_CHUNK000.fits.fz` 
```yaml
output_filename:
        # this transforms the name by dropping SDH and CHUNK parts, which should now be merged.
        valueFrom: |
          ${
            var newname = inputs.input_files[0].basename;
            var parts = newname.split("_");

            var filtered = parts.filter(function(part) {
                return !part.startsWith("SDH")
                    && !part.startsWith("CHUNK")
                    && !part.startsWith("TEL")
                    && !part.startsWith("SBID")
            });
            filtered = filtered.slice(0,-1);
            return filtered.join("_") + ".dl1.h5";
           }
```

**ExpressionTool**

An [expression tool](https://www.commonwl.org/user_guide/topics/expression-tool.html#expression-tool) is a type of Process that can be run by itself or as a Workflow step. It executes a pure JavaScript expression. It is meant to be used as a way to isolate complex JavaScript expressions that need to operate on input data and produce some result as output.

As example see [generate_names.cwl](examples/basic/scatter_workflow/generate_names.cwl).

## Scatter Workflow

[This feature](https://www.commonwl.org/user_guide/topics/workflows.html#scattering-steps) tells the runner that you wish to run a tool or workflow multiple times over a list of inputs. It requires the requirement:
```yaml
requirements:
  ScatterFeatureRequirement: {}
```

The `scatter` feature provides functions similar to those of the DIRAC Transformation System however it cannot be used to describe or orchestrate transformations in a workgraph, though it can be used *inside* a transformation.

## Experiments Examples

**CTAO Examples**

[examples/ctao](examples/ctao/processing/README.md) contains a simplified CTAO DL0 to DL2 processing workflow example and its corresponding DiracX ADR hints, which can be visualized using the [Playground](https://diracx--1042.org.readthedocs.build/en/1042/playground/#doc=zrZRtb9s2EMff81Pc4A5Oili2BAQD9GbI4mVI4a5BUmwtUEA4SWeJC0WyJCXXyfLdB4ryU-IXC5A3hsU73sPvf8fRT9PWmmnO5ZRkB8VKTEwrJRnGfv568XEBcRSzyWTCipX4i4zlSqbQxVHCCoHWpvC3MvdLoVZMYE4ihRujCrIW5osZOAXzRcJKVaTwL4OtDSVwqVsHSy7Iey2NajY3LGk06AjmixhQlj4EqNbp1tmIMUPfW26oIelsygCupeCSPmCHtjBcu9udPYXHJwZw50hf-3S__9CGrG_huRMbweeaoOQGi_Q91Fw66FSBeSvQrIFbKGnJJZWQrwGhCyCohA93n_4EW9TUILgaHXDLRmAdFwJy4rKCkiyvvOvJ_MvkYn47mc1-OQOlSQK3tiV7moKrCToULVnISagVoCE2Ai5Ea51Bxzs6A6k8L4kiYr6-vvlQsJegMqhrfwRDOVm3UWscR7Nxb3FrTSnM0eGgBJdVbxhB4VBzTaCN6kiiLAiEqqyvBO5JO-ASCIsa_lH52A56gEVZ5uoHGHQ1mSGUq1GCM9iREJ6A765Eh35KzsAqf7AGSR0ZyKlQDUGBDoWqWhpClCR4RwZzQTbqz0LCbEgYGp3A-H20KzgSqhrvDP0XY_2gBVhiFu718-inzVcVZpBLWCrToAPbaq2MC1IPVKI9eldchCoD-yuikkyICyCx8YCvby8uvd9laGswoqnsxhHge0tmvfsE-Hh5iY1GXskUbm4_zc_3bJY7SmGBNyga3DvXaBwvBKVQYXNgeSDJXZ1CMts79P1mgjq_p_PFjDHweg-DkBVKLnm1h6jHs3OA4ND6gVQ9rw2fyeD0nNOvjLFhc4MA8YEA8aEAmxGsy-X5oMYx7iHgnWpNQakXNXMqK0U8LUXcJ0kOkiRvkiQOSZJpKZJAbRi6TKgqe9nY4Rq9qo3D2MeSPW_w9cm27TxLxqwjvVmWoaCQbPvk7Eb_s0FpA0L_zmznTGNxTyaFx7ANv63_MKrVdMcf6CwsATxW_iiz_IFSiGdPT_1lvg3iV9X_bD_jzAvYB9zm6V_MK6OaFN6dhDWPSjGLcrS9Z2RICyzoZPotsrxxJL5FD9a9m57BOCpFHNXn49PTIdzLPXh51LuaVm5NmafkIxUrseG8eZrCNPp_LwTd8X8jtq9DGx_ZmmBJ_jfl-CjlAHUDOHkTwLHndBxwchzwfw).


**LHCb Examples**

[examples/lhcb/simulation](examples/lhcb/simulation/README.md) contains an LHCb Run 3 minimum bias simulation workgraph (Gauss → Boole → HLT1 → Merge) based on a real MC request. It needs no input data or credentials, only CVMFS.
