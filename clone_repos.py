import requests
import os
import subprocess

# Enter your GitHub username here
username = "rishavnandi"

# API endpoint to get repositories
url = f"https://api.github.com/users/{username}/repos"

# Make a GET request to the GitHub API
response = requests.get(url)

# Check if the request was successful
if response.status_code == 200:
    repos = response.json()

    # Iterate over each repository
    for repo in repos:
        repo_name = repo["name"]
        repo_url = repo["clone_url"]

        # Clone the repository using git clone command
        subprocess.run(["git", "clone", repo_url, repo_name])

        print(f"Cloned repository: {repo_name}")
else:
    print("Failed to retrieve repositories.")
