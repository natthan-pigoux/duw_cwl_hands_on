"""CLI to download dataset from CTAO Minio and create CWL input file."""
import tempfile
from pathlib import Path

import typer
import yaml

from duw_cwl_hands_on.cli.utils import download_dataset

app = typer.Typer()


@app.command()
def main(input_path: str = typer.Option(
        default=None,
        help="CWL input file path.",
    ),
):
    """Create input for DL0 to DL2 CWL Workflow."""
    dataset_path = download_dataset("gamma_prod6_preliminary.simtel.zst")
    typer.echo(f"Dataset downloaded in {dataset_path}")
    tmp_path = tempfile.mkdtemp()
    if not input_path:
        input_path = Path(tmp_path) / "input_dl0_dl2.yaml"
    else:
        input_path = Path(input_path)
    inputs = {
        "dl0": {"class": "File", "path": str(dataset_path)},
    }
    with input_path.open("w") as f:
        yaml.dump(inputs, f)
    typer.echo(f"Input file created at {input_path}")