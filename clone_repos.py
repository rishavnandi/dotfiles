#!/usr/bin/env python3
"""
GitHub Repository Cloner
Clones all repositories for a given GitHub user with enhanced features.
"""

import argparse
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from typing import List, Dict

try:
    import requests
except ImportError:
    print("Error: 'requests' library not found. Install it with: pip install requests")
    sys.exit(1)


def parse_arguments() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Clone all GitHub repositories for a given user"
    )
    parser.add_argument(
        "username",
        nargs="?",
        default="rishavnandi",
        help="GitHub username (default: rishavnandi)"
    )
    parser.add_argument(
        "-d", "--directory",
        default=".",
        help="Destination directory for cloned repos (default: current directory)"
    )
    parser.add_argument(
        "-j", "--jobs",
        type=int,
        default=4,
        help="Number of parallel clone operations (default: 4)"
    )
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        help="Skip repositories that already exist locally"
    )
    parser.add_argument(
        "--ssh",
        action="store_true",
        help="Use SSH URLs instead of HTTPS for cloning"
    )
    parser.add_argument(
        "--token",
        help="GitHub personal access token (for private repos or higher rate limits)"
    )
    return parser.parse_args()


def get_all_repos(username: str, token: str = None) -> List[Dict]:
    """
    Fetch all repositories for a given username with pagination support.
    
    Args:
        username: GitHub username
        token: Optional GitHub personal access token
        
    Returns:
        List of repository dictionaries
    """
    headers = {}
    if token:
        headers["Authorization"] = f"token {token}"
    
    repos = []
    page = 1
    per_page = 100
    
    print(f"Fetching repositories for user: {username}")
    
    while True:
        url = f"https://api.github.com/users/{username}/repos"
        params = {"page": page, "per_page": per_page, "sort": "updated"}
        
        try:
            response = requests.get(url, headers=headers, params=params, timeout=10)
            response.raise_for_status()
        except requests.exceptions.RequestException as e:
            print(f"Error fetching repositories: {e}", file=sys.stderr)
            if hasattr(e, 'response') and e.response is not None:
                print(f"Response: {e.response.text}", file=sys.stderr)
            sys.exit(1)
        
        page_repos = response.json()
        
        if not page_repos:
            break
        
        repos.extend(page_repos)
        print(f"Fetched page {page} ({len(page_repos)} repos)")
        
        # Check if there are more pages
        if len(page_repos) < per_page:
            break
        
        page += 1
    
    print(f"Total repositories found: {len(repos)}")
    return repos


def clone_repository(repo: Dict, dest_dir: Path, use_ssh: bool, skip_existing: bool) -> tuple:
    """
    Clone a single repository.
    
    Args:
        repo: Repository dictionary from GitHub API
        dest_dir: Destination directory
        use_ssh: Use SSH URL instead of HTTPS
        skip_existing: Skip if repository already exists
        
    Returns:
        Tuple of (repo_name, success, message)
    """
    repo_name = repo["name"]
    repo_path = dest_dir / repo_name
    
    # Check if repository already exists
    if repo_path.exists():
        if skip_existing:
            return (repo_name, True, "Already exists (skipped)")
        else:
            return (repo_name, False, "Already exists (use --skip-existing to skip)")
    
    # Choose clone URL
    clone_url = repo["ssh_url"] if use_ssh else repo["clone_url"]
    
    try:
        result = subprocess.run(
            ["git", "clone", clone_url, str(repo_path)],
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout
        )
        
        if result.returncode == 0:
            return (repo_name, True, "Cloned successfully")
        else:
            return (repo_name, False, f"Clone failed: {result.stderr}")
    
    except subprocess.TimeoutExpired:
        return (repo_name, False, "Clone timeout (>5 minutes)")
    except Exception as e:
        return (repo_name, False, f"Error: {str(e)}")


def main():
    """Main execution function."""
    args = parse_arguments()
    
    # Check if git is available
    try:
        subprocess.run(["git", "--version"], capture_output=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Error: git is not installed or not in PATH", file=sys.stderr)
        sys.exit(1)
    
    # Create destination directory if it doesn't exist
    dest_dir = Path(args.directory).resolve()
    dest_dir.mkdir(parents=True, exist_ok=True)
    print(f"Cloning to: {dest_dir}\n")
    
    # Fetch repositories
    repos = get_all_repos(args.username, args.token)
    
    if not repos:
        print("No repositories found!")
        return
    
    # Clone repositories in parallel
    print(f"\nCloning {len(repos)} repositories using {args.jobs} parallel jobs...\n")
    
    success_count = 0
    skip_count = 0
    fail_count = 0
    
    with ThreadPoolExecutor(max_workers=args.jobs) as executor:
        # Submit all clone tasks
        future_to_repo = {
            executor.submit(clone_repository, repo, dest_dir, args.ssh, args.skip_existing): repo
            for repo in repos
        }
        
        # Process completed tasks
        for future in as_completed(future_to_repo):
            repo_name, success, message = future.result()
            
            if success:
                if "skipped" in message.lower():
                    print(f"⊘ {repo_name}: {message}")
                    skip_count += 1
                else:
                    print(f"✓ {repo_name}: {message}")
                    success_count += 1
            else:
                print(f"✗ {repo_name}: {message}")
                fail_count += 1
    
    # Print summary
    print("\n" + "="*50)
    print("SUMMARY")
    print("="*50)
    print(f"Successfully cloned: {success_count}")
    print(f"Skipped (existing): {skip_count}")
    print(f"Failed: {fail_count}")
    print(f"Total: {len(repos)}")


if __name__ == "__main__":
    main()
