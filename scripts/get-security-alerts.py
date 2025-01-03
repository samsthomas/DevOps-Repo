import requests

repo_owner = "samsthomas"
access_token = ""

HEADERS = {

    "Authorization": f"token {access_token}"
}

api_url = "https://api.github.com/"
url = f"{api_url}users/{repo_owner}/repos"

# print(url)

#params = {"name": " "}

# def get_branch_repos():
#     response = requests.get(url, headers = HEADERS)
#     data = response.json()

#     repo_names = [x["name"] for x in data]

#     branch_repos = ()

#     for repo in repo_names:
#         if "branch" in repo:
#             branch_repos.append(repo)
#         else:
#             continue

#     print (branch_repos)

# get_branch_repos()


sec_url = f"{api_url}repos/{repo_owner}/Branch-Test-Repo/secret-scanning/alerts"


def get_branch_repos_alerts():
    response = requests.get(sec_url, headers=HEADERS)
    data = response.json()
    
    alert_count = len(data)
    print(f"##vso[task.setvariable variable=ALERT_COUNT]{alert_count}")
    
    if not data:
        print("No secret scanning alerts found.")
        return
    
    # Format alert details for Teams message
    alert_details = []
    for alert in data:
        alert_text = (
            f"**Alert #{alert.get('number', 'N/A')}**\n"
            f"- Type: {alert.get('secret_type_display_name', 'N/A')}\n"
            f"- State: {alert.get('state', 'N/A')}\n"
            f"- File: {alert.get('location', {}).get('path', 'N/A')}\n"
            f"- Created: {alert.get('created_at', 'N/A')}\n"
            f"- Link: {alert.get('html_url', 'N/A')}\n"
        )
        alert_details.append(alert_text)
    
    formatted_details = "\n\n".join(alert_details)
    print(f"##vso[task.setvariable variable=ALERT_DETAILS]{formatted_details}")
    
    for alert in data:
        print("\n=== Secret Scanning Alert ===")
        # Basic Info
        print(f"Alert Number: #{alert.get('number', 'N/A')}")
        print(f"State: {alert.get('state', 'N/A')}")
        print(f"Secret Type: {alert.get('secret_type_display_name', 'N/A')}")
        
        # Location Details
        location = alert.get('location', {})
        print(f"File: {location.get('path', 'N/A')}")
        
        # Commit Information
        print(f"Commit SHA: {alert.get('most_recent_commit', 'N/A')}")
        print(f"HTML URL: {alert.get('html_url', 'N/A')}")
        
        # Timestamps
        print(f"Created: {alert.get('created_at', 'N/A')}")
        if alert.get('resolved_at'):
            print(f"Resolved: {alert.get('resolved_at')}")
            print(f"Resolution: {alert.get('resolution')}")
        
        print("="*50)

get_branch_repos_alerts()



