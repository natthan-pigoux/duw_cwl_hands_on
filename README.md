# DIRAC User Workshop CWL Hands On

Material for DIRAC User Workshop CWL hands on session.

**Basic CWL examples**

[examples/basic](examples/basic) contains basic CWL CommandLineTools, Workflows and ExpressionTool examples.

**CTAO Examples**

[examples/ctao](examples/ctao) contains a CTAO DL0 to DL2 processing workflow example and its corresponding DiracX ADR hints, which can be visualized using the [Playground](https://diracx--1042.org.readthedocs.build/en/1042/playground/#doc=zrZRtb9s2EMff81Pc4A5Oili2BAQD9GbI4mVI4a5BUmwtUEA4SWeJC0WyJCXXyfLdB4ryU-IXC5A3hsU73sPvf8fRT9PWmmnO5ZRkB8VKTEwrJRnGfv568XEBcRSzyWTCipX4i4zlSqbQxVHCCoHWpvC3MvdLoVZMYE4ihRujCrIW5osZOAXzRcJKVaTwL4OtDSVwqVsHSy7Iey2NajY3LGk06AjmixhQlj4EqNbp1tmIMUPfW26oIelsygCupeCSPmCHtjBcu9udPYXHJwZw50hf-3S__9CGrG_huRMbweeaoOQGi_Q91Fw66FSBeSvQrIFbKGnJJZWQrwGhCyCohA93n_4EW9TUILgaHXDLRmAdFwJy4rKCkiyvvOvJ_MvkYn47mc1-OQOlSQK3tiV7moKrCToULVnISagVoCE2Ai5Ea51Bxzs6A6k8L4kiYr6-vvlQsJegMqhrfwRDOVm3UWscR7Nxb3FrTSnM0eGgBJdVbxhB4VBzTaCN6kiiLAiEqqyvBO5JO-ASCIsa_lH52A56gEVZ5uoHGHQ1mSGUq1GCM9iREJ6A765Eh35KzsAqf7AGSR0ZyKlQDUGBDoWqWhpClCR4RwZzQTbqz0LCbEgYGp3A-H20KzgSqhrvDP0XY_2gBVhiFu718-inzVcVZpBLWCrToAPbaq2MC1IPVKI9eldchCoD-yuikkyICyCx8YCvby8uvd9laGswoqnsxhHge0tmvfsE-Hh5iY1GXskUbm4_zc_3bJY7SmGBNyga3DvXaBwvBKVQYXNgeSDJXZ1CMts79P1mgjq_p_PFjDHweg-DkBVKLnm1h6jHs3OA4ND6gVQ9rw2fyeD0nNOvjLFhc4MA8YEA8aEAmxGsy-X5oMYx7iHgnWpNQakXNXMqK0U8LUXcJ0kOkiRvkiQOSZJpKZJAbRi6TKgqe9nY4Rq9qo3D2MeSPW_w9cm27TxLxqwjvVmWoaCQbPvk7Eb_s0FpA0L_zmznTGNxTyaFx7ANv63_MKrVdMcf6CwsATxW_iiz_IFSiGdPT_1lvg3iV9X_bD_jzAvYB9zm6V_MK6OaFN6dhDWPSjGLcrS9Z2RICyzoZPotsrxxJL5FD9a9m57BOCpFHNXn49PTIdzLPXh51LuaVm5NmafkIxUrseG8eZrCNPp_LwTd8X8jtq9DGx_ZmmBJ_jfl-CjlAHUDOHkTwLHndBxwchzwfw).


**LHCb Examples**

[examples/lhcb/simulation](examples/lhcb/simulation) contains an LHCb Run 3 minimum bias simulation workgraph (Gauss → Boole → HLT1 → Merge) based on a real MC request. It needs no input data or credentials, only CVMFS.

## Running the CWL examples

All examples can be ran using `cwltool`:

```bash
cwltool examples/basic/hello_world/hello_world.cwl
```

or with `pixi`:

```bash
pixi run cwltool examples/basic/hello_world/hello_world.cwl
```
**Basic Examples**

All [basic examples](examples/basic) can be executed directly.

**CTAO Workflows Examples**

See [README](examples/ctao/processing/README.md)
