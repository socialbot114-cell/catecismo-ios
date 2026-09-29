#!/usr/bin/env python3
"""Choose an installed iOS simulator and expose its UDID to GitHub Actions."""

import json
import os
import subprocess
import sys


def main() -> None:
    inventory = json.loads(
        subprocess.check_output(
            ["xcrun", "simctl", "list", "devices", "available", "--json"],
            text=True,
        )
    )
    family = os.environ.get("SIMULATOR_FAMILY", "iPhone")
    preferred = os.environ.get("PREFERRED_SIMULATOR", "iPhone 16")
    candidates = []

    for runtime, devices in inventory["devices"].items():
        if not runtime.startswith("com.apple.CoreSimulator.SimRuntime.iOS-"):
            continue
        version = tuple(int(part) for part in runtime.split(".iOS-", 1)[1].split("-"))
        for device in devices:
            if family in device["name"]:
                candidates.append((version, device["name"] == preferred, device))

    if not candidates:
        sys.exit(f"No available {family} simulator found")

    _, _, selected = max(candidates, key=lambda candidate: (candidate[0], candidate[1]))
    with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as output:
        output.write(f"udid={selected['udid']}\n")
        output.write(f"name={selected['name']}\n")
    print(f"Selected {selected['name']} ({selected['udid']})")


if __name__ == "__main__":
    main()
