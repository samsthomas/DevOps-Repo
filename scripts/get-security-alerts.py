import requests

repo_owner = "samsthomas"
access_token = ""

HEADERS = {

    "Authorization": f"token {access_token}"
}

api_url = "https://api.github.com/"
url = f"{api_url}users/{repo_owner}/repos"

print(url)

#params = {"name": " "}

def get_branch_repos():
    response = requests.get(url, headers = HEADERS)
    data = response.json()

    repo_names = [x["name"] for x in data]

    branch_repos = ()

    for repo in repo_names:
        if "branch" in repo:
            branch_repos.append(repo)
        else:
            continue

    print (branch_repos)

get_branch_repos()

sec_url = f"{api_url}repos/{repo_owner}/Branch-Test-Repo-2/secret-scanning/alerts"


def get_branch_repos_alerts():
    response = requests.get(sec_url, headers = HEADERS)
    data = response.json()

    print(data)

get_branch_repos_alerts()



