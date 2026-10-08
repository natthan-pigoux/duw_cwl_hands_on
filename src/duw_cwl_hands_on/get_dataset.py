from ctapipe.utils import get_dataset_path

URL = "https://minio-cta.zeuthen.desy.de/dpps-testdata-public/data/datapipe-test-data/"

if "__main__" == __name__:
    dataset_path = get_dataset_path("gamma_prod6_preliminary.simtel.zst")
    print(f"Dataset downloaded in {dataset_path}")