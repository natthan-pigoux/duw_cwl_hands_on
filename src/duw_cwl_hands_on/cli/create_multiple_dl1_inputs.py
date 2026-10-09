"""Generate DL1 files and create the CWL input file."""

import subprocess as sp
import tempfile
from pathlib import Path

import typer
import yaml

from duw_cwl_hands_on.cli.utils import download_dataset

app = typer.Typer()


@app.command()
def main(
    dataset: str = "gamma_prod5.simtel.zst",
    output_filename: str = "merged.dl1.h5",
    nb_obs: int = 2,
    input_path: str = typer.Option(
        default=None,
        help="CWL input file path.",
    ),
):
    """Generate DL1 files and create the CWL input file."""
    input_file = download_dataset(dataset)
    # create to dl1 files with different obs_ids, merge checks for
    # same subarray and different obs-ids, but we do not have two test files
    # that are small and similar
    inputs = {
        "input_files": [],
        "output_filename": output_filename,
    }
    tmp_path = tempfile.mkdtemp()
    for obs_id in (i for i in range(nb_obs)):
        output_path = f"{tmp_path}/gamma_{obs_id}.dl1_img.h5"
        print(f"Creating data at {output_path}")
        sp.run(
            [
                "ctapipe-process",
                f"--input={input_file}",
                f"--output={output_path}",
                f"--SimTelEventSource.override_obs_id={obs_id}",
                "--write-images",
                "--no-write-parameters",
            ],
            check=True,
        )
        inputs["input_files"].append({"class": "File", "path": str(output_path)})

    inputs_path = Path(tmp_path) / "input_mutliple.yaml"
    with inputs_path.open("w") as f:
        yaml.dump(inputs, f)
    print(f"Input file created at {inputs_path}")


if "__main__" == __name__:
    app()
