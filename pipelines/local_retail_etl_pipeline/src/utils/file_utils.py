"""
File system operations with safety checks.
"""

import os
from typing import List

def ensure_dir(path: str):
    """Create directory if it doesn't exist."""
    os.makedirs(path, exist_ok=True)


def list_files(directory: str, extension: str = ".json") -> List[str]:
    """List files with given extension."""

    return [
        os.path.join(directory, f)
        for f in os.listdir(directory)
        if f.endswith(extension)
    ]

# This can be extended to support cloud storage ("gs://", "s3://") using Hadoop connectors