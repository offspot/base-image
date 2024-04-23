#!/usr/bin/env python3

import json
import logging
import os
import pathlib
import subprocess
import sys
import tarfile

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger("docker-loader")

images_root = pathlib.Path(os.getenv("IMAGES_ROOT", "/data/images"))
engine = os.getenv("DOCKER_ENGINE", "balena-engine")

errors: int = 0

logger.info(f"Looking for docker images in {images_root}")
for fpath in images_root.glob("*.tar"):
    logger.info(f"{fpath.name} FOUND")
    with tarfile.open(fpath, "r:") as tar:
        try:
            manifest = json.loads(tar.extractfile("manifest.json").read())
            name = manifest[0]["RepoTags"][0]
        except Exception as exc:
            errors += 1
            logger.error(f">> Unable to identify as valid tar image ({exc}). Skipping.")
            logger.exception(exc)
            continue
        logger.info(f">> Loading {name}…")
        dl = subprocess.run(
            ["/usr/bin/env", engine, "load", "--input", fpath], check=True
        )
        if dl.returncode == 0:
            logger.info(f">> Successfuly loaded {name}. Removing {fpath.name}")
            try:
                fpath.unlink()
            except Exception as exc:
                logger.warning(f"Failed to remove tar file at {fpath}: {exc}")
            continue
        errors += 1
        logger.error(f"Unable to load {name} into docker")

sys.exit(errors)
