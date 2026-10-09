"""Shared functions."""

from ctapipe.utils import get_dataset_path


def download_dataset(dataset: str):
    """Download dataset from CTAO Minio."""
    return get_dataset_path(dataset)
