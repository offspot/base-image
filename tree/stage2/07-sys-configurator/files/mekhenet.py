"""mekhenet - simple HTTP API to pass command from services to host via socket

curl --unix-socket /run/offspot/mekhenet.sock http://host/service-is-enabled/ssh
"""

import subprocess
from pathlib import Path
from typing import Annotated

from fastapi import FastAPI
from fastapi import Path as FastAPIPath

allowed_toggle_actions = ("enable", "disable")
allowed_services = ("ssh",)
systemctl_path = Path("/usr/bin/systemctl")

app = FastAPI()


@app.get("/reboot/{after_seconds}")
async def request_host_reboot(
    after_seconds: Annotated[
        int, FastAPIPath(title="Nb. of seconds after which to reboot")
    ],
):
    reboot = subprocess.run(
        [
            str(systemctl_path),
            "reboot",
            "--when",
            f"+{after_seconds!s}s",
        ],
        check=False,
    )
    return {"success": reboot.returncode == 0}


@app.get("/toggle-service/{action}/{name}")
async def request_service_toggle(
    action: Annotated[str, FastAPIPath(title="Action to use (enable/disable)")],
    name: Annotated[str, FastAPIPath(title="Name of service to toggle")],
):
    if action not in allowed_toggle_actions:
        return {
            "success": False,
            "details": f"Forbidden action. Only {', '.join(allowed_toggle_actions)}",
        }
    if name not in allowed_services:
        return {
            "success": False,
            "details": "Forbidden service.",
        }
    toggle = subprocess.run(
        [str(systemctl_path), action, name],
        check=False,
    )
    return {"success": toggle.returncode == 0}


@app.get("/service-is-enabled/{name}")
async def request_service_enabled(
    name: Annotated[str, FastAPIPath(title="Name of service to query")],
):
    if name not in allowed_services:
        return {
            "success": False,
            "details": "Forbidden service.",
        }
    toggle = subprocess.run(
        [str(systemctl_path), "is-enabled", name],
        text=True,
        capture_output=True,
        check=False,
    )
    if toggle.stdout.strip() in ("enabled", "disabled"):
        return {"success": True, "enabled": toggle.stdout.strip() == "enabled"}

    return {"success": False, "details": toggle.stdout.splitlines()[0].strip()}
