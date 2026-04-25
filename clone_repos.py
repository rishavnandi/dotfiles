#!/usr/bin/env python3
"""
Clone all GitHub repositories for a user.
Assumes gh CLI is authenticated and SSH keys are set up.
"""

import argparse
import json
import shutil
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path


def check_deps():
    """Ensure required tools are installed."""
    for cmd in ["gh", "git"]:
        if not shutil.which(cmd):
            print(f"Error: '{cmd}' not found in PATH")
            sys.exit(1)


def run(cmd: list, check: bool = True) -> subprocess.CompletedProcess:
    """Run a command and return the result."""
    result = subprocess.run(cmd, capture_output=True, text=True)
    if check and result.returncode != 0:
        print(f"Error: {' '.join(cmd)}\n{result.stderr.strip()}")
        sys.exit(1)
    return result


def get_repos() -> list:
    """List all repos (including private) via gh CLI."""
    print("Fetching repositories...")
    output = run([
        "gh", "repo", "list",
        "--json", "name,sshUrl",
        "--limit", "9999",
    ]).stdout.strip()
    repos = json.loads(output)
    print(f"Found {len(repos)} repositories")
    return repos


def clone_repo(repo: dict, dest_dir: Path) -> tuple:
    """Clone a single repo via SSH."""
    name = repo["name"]
    path = dest_dir / name

    if path.exists():
        return (name, "skip", "already exists")

    result = run(
        ["git", "clone", repo["sshUrl"], str(path)],
        check=False,
    )

    if result.returncode == 0:
        return (name, "ok", "")
    return (name, "fail", result.stderr.strip())


def main():
    check_deps()

    parser = argparse.ArgumentParser(description="Clone all GitHub repositories")
    parser.add_argument(
        "-d", "--directory",
        default=".",
        help="Destination directory (default: current directory)",
    )
    parser.add_argument(
        "-j", "--jobs",
        type=int,
        default=4,
        help="Number of parallel clones (default: 4)",
    )
    args = parser.parse_args()

    dest = Path(args.directory).resolve()
    dest.mkdir(parents=True, exist_ok=True)
    print(f"Cloning to: {dest}\n")

    repos = get_repos()
    if not repos:
        print("No repositories found")
        return

    print(f"Cloning {len(repos)} repos with {args.jobs} parallel jobs...\n")

    success = skip = fail = 0

    with ThreadPoolExecutor(max_workers=args.jobs) as executor:
        futures = {
            executor.submit(clone_repo, repo, dest): repo
            for repo in repos
        }
        for future in as_completed(futures):
            name, status, msg = future.result()
            if status == "ok":
                print(f"✓ {name}")
                success += 1
            elif status == "skip":
                print(f"⊘ {name}: {msg}")
                skip += 1
            else:
                print(f"✗ {name}: {msg}")
                fail += 1

    print(f"\nDone: {success} cloned, {skip} skipped, {fail} failed")


if __name__ == "__main__":
    main()
