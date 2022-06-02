#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import logging
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from typing import List

NAME = "bi-builder"
VERSION = "0.1"
PIGEN_REPO_URL = "https://github.com/RPi-Distro/pi-gen.git"
CONTAINER_NAME = "pigen_work"

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger("builder")


def run(*args, **kwargs):
    logger.debug(f"running {args=} -- {kwargs=}")
    return subprocess.run(*args, **kwargs)


@dataclass
class Defaults:
    pigen_version: str = "2022-04-04-raspios-bullseye"
    build_64b: bool = False
    dont_use_docker: bool = False

    src_dir: pathlib.Path = pathlib.Path(__file__).parent

    _build_dir: str = tempfile.mkdtemp(prefix="pigen")
    build_dir: pathlib.Path = None
    keep_build_dir: bool = False

    _output_dir: str = "."
    output_dir: pathlib.Path = None

    IMG_NAME: str = "offspot-base"
    LOCALE_DEFAULT: str = "en_US.UTF-8"
    TARGET_HOSTNAME: str = "offspot-base"
    KEYBOARD_KEYMAP: str = "us"
    KEYBOARD_LAYOUT = "English (US)"
    TIMEZONE_DEFAULT: str = "UTC"
    FIRST_USER_NAME: str = "user"
    FIRST_USER_PASS: str = "raspberry"
    ENABLE_SSH: bool = "0"
    PUBKEY_SSH_FIRST_USER: str = None
    PUBKEY_ONLY_SSH: str = "0"
    STAGE_LIST: str = "stage0 stage1 stage2"

    def __post_init__(self):
        self.output_dir = pathlib.Path(self._output_dir)
        self.build_dir = pathlib.Path(self._build_dir)

    @classmethod
    def pigen_vars(cls) -> List[str]:
        """list of our Default vars that are exported to pigen's config"""
        return list(
            filter(lambda item: item == item.upper(), cls.__dataclass_fields__.keys())
        )

    @property
    def use_docker(self):
        """whether we'll use docker to build"""
        return not self.dont_use_docker


class Builder:
    def __init__(self, conf):
        self.conf = conf

    def run(self):
        self.download_pigen()
        self.merge_tree()
        self.write_config()
        self.update_packages()
        self.build()

    def download_pigen(self):
        """clone requested version of Pi-gen"""
        if self.conf.build_dir.exists() and list(self.conf.build_dir.iterdir()):
            logger.warning(f"build-dir exists. reusing ({self.conf.build_dir}")
            return
        logger.info("Cloning Pi-gen")
        branch = "arm64" if self.conf.build_64b else self.conf.pigen_version
        run(
            [
                "git",
                "clone",
                "--depth",
                "1",
                "--branch",
                branch,
                PIGEN_REPO_URL,
                str(self.conf.build_dir),
            ],
            check=True,
        )

    def merge_tree(self):
        """copy files from our tree to pygen and apply our patches"""
        root = self.conf.src_dir / "tree"
        for fpath in root.rglob("*"):
            if fpath == root / "README.md" or not fpath.is_file():
                continue
            relpath = fpath.relative_to(root)
            dest = self.conf.build_dir / relpath
            if fpath.suffix == ".patch":
                dest = dest.with_name(re.sub(r".patch$", "", dest.name))
                logger.debug(f"patching {dest}")
                subprocess.run(["/usr/bin/env", "patch", dest, fpath], check=True)
            else:
                logger.debug(f"copying {relpath}")
                shutil.copyfile(fpath, dest, follow_symlinks=True)

    def write_config(self):
        """save main pi-gen config from our defaults and passed values"""
        logger.info("Writing config")
        with open(self.conf.build_dir / "config", "w") as fh:
            for key in self.conf.pigen_vars():
                value = getattr(self.conf, key)
                if value is not None:
                    fh.write(f'{key}="{value}"\n')
            fh.write(f"APT_ARCH=\"arm{'64' if self.conf.build_64b else 'hf'}\"\n")

    def update_packages(self):
        """rewrites stage2's packages file to add or remove those we requested to"""
        logger.info("Updating packages list")
        packages = set()
        fpath = self.conf.build_dir / "stage2" / "01-sys-tweaks" / "00-packages"
        with open(fpath, "r") as fh:
            for line in fh.readlines():
                for item in line.strip().split():
                    packages.add(item.strip())

        with open(self.conf.src_dir / "packages") as fh:
            for line in fh.readlines():
                line = line.strip()
                if line and line[0] in ("+", "-"):
                    for item in line[1:].strip().split():
                        if line[0] == "+":
                            packages.add(item)
                        if line[0] == "-":
                            try:
                                packages.remove(item)
                            except KeyError:
                                ...

        with open(fpath, "w") as fh:
            fh.write("\n".join(packages))

    def build(self):
        if self.conf.use_docker:
            self.build_docker()
        else:
            self.build_nodocker()

    def build_nodocker(self):
        logger.info("Starting build")
        subprocess.run(["./build.sh"], cwd=self.conf.build_dir)

    def build_docker(self):
        logger.info("Starting build using docker")
        subprocess.run(["./build-docker.sh"], cwd=self.conf.build_dir)

    def cleanup(self):
        if not subprocess.run(
            ["/usr/bin/env", "docker", "inspect", CONTAINER_NAME], capture_output=True
        ).returncode:
            logger.debug(f"Removing existing container {CONTAINER_NAME}")
            subprocess.run(["/usr/bin/env", "docker", "rm", "-v", "-f", CONTAINER_NAME])

        # remove build-dir (pigen clone)
        if self.conf.build_dir.exists() and not self.conf.keep_build_dir:
            shutil.rmtree(self.conf.build_dir)


def main():
    parser = argparse.ArgumentParser(
        prog=NAME,
        description="Pi-gen based image builder",
    )

    parser.add_argument(
        "--output",
        help="Output folder for image file",
        default=Defaults._output_dir,
        dest="_output_dir",
    )

    parser.add_argument(
        "--64b",
        help="Build a 64b image. Uses Pi-gen's arm64 branch.",
        default=Defaults.build_64b,
        dest="build_64b",
        action="store_true",
    )

    parser.add_argument(
        "--no-docker",
        help="Don't use docker to build. Additional depenendencies required",
        default=Defaults.dont_use_docker,
        dest="dont_use_docker",
        action="store_true",
    )

    for name in Defaults.pigen_vars():
        opt_name = name.lower().replace("_", "-")
        parser.add_argument(
            f"--{opt_name}",
            help=f"`{name}` environ for pi-gen. "
            f"Default: “{getattr(Defaults, name) or '-'}”",
            default=getattr(Defaults, name),
            dest=name,
        )

    parser.add_argument(
        "--build-dir",
        help="Directory to clone pi-gen into",
        default=Defaults._build_dir,
        dest="_build_dir",
    )

    parser.add_argument(
        "--keep",
        help="[dev] Keep build Directory",
        default=Defaults.keep_build_dir,
        dest="keep_build_dir",
        action="store_true",
    )

    parser.add_argument(
        "--version",
        help="Display builder script version and exit",
        action="version",
        version=f"{NAME} v{VERSION}",
    )

    builder = Builder(Defaults(**dict(parser.parse_args()._get_kwargs())))
    try:
        sys.exit(builder.run())
    except Exception as exc:
        logger.error(f"FAILED. An error occurred: {exc}")
        logger.exception(exc)
        raise SystemExit(1)
    finally:
        builder.cleanup()


if __name__ == "__main__":
    main()
