import argparse
import json
import os
import subprocess
import urllib.request

parser = argparse.ArgumentParser(description="Clone all repositories of an user on GitHub.")
parser.add_argument("user", help="GitHub username")
args = parser.parse_args()

repos = []


def get(url, page):
	isLast = True
	try:
		for repo in json.loads(urllib.request.urlopen(url + "?page=" + str(page)).read().decode("utf-8")):
			isLast = False
			if not os.path.isdir(repo["name"]) or len(os.listdir(repo["name"])) == 0:
				repos.append(repo["clone_url"])
	except Exception:
		raise Exception("RATE LIMIT")
	if not isLast:
		get(url, page + 1)


get(f"https://api.github.com/users/{args.user}/repos?per_page=100", 1)
print(f"Cloning {len(repos)} repositories...")

for repo in repos:
	subprocess.Popen(f"git clone " + repo, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
