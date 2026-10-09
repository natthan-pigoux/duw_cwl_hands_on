import subprocess as sp
import tempfile
from pathlib import Path
import yaml
from ctapipe.utils import get_dataset_path


def create_multiple_dl1():
    input_file = get_dataset_path("gamma_prod5.simtel.zst")
        # create to dl1 files with different obs_ids, merge checks for
        # same subarray and different obs-ids, but we do not have two test files
        # that are small and similar
    inputs = {
        "input_files": [],
        "output_filename": "merged.dl1.h5",
    }
    tmp_path = tempfile.mkdtemp()
    for obs_id in (1, 2):
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
    create_multiple_dl1()