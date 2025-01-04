import requests
import json
from datetime import datetime
import os


repo_owner = "samsthomas"
access_token = ""

HEADERS = {"Authorization": f"Bearer {os.environ.get('GITHUB_TOKEN')}"}

api_url = "https://api.github.com/"
url = f"{api_url}users/{repo_owner}/repos"



def send_teams_message(webhook_url, alerts):
    # Basic message card structure for Teams
    message = {
        "@type": "MessageCard",
        "@context": "http://schema.org/extensions",
        "title": "Security Alerts Found",
        "text": f"Found {len(alerts)} security alert(s)",
        "sections": []
    }

    for alert in alerts:
        alert_section = {
            "activityTitle": f"Alert #{alert.get("number", "N/A")}",
            "facts": [
                {"name": "Type", "value": alert.get('secret_type_display_name', 'N/A')},
                {"name": "State", "value": alert.get('state', 'N/A')},
                {"name": "File", "value": alert.get('location', {}).get('path', 'N/A')},
                {"name": "Created", "value": alert.get('created_at', 'N/A')},
            ],
            # Add clickable link to view the alert in GitHub
            "potentialAction": [
                {
                    "@type": "OpenUri",
                    "name": "View Alert",
                    "targets": [
                        {"os": "default", "uri": alert.get('html_url', '')}
                    ]
                }
            ]
        }
        message["sections"].append(alert_section)  # Add this section to the message
    
    try:
        response = requests.post(
            webhook_url,
            json=message,
            headers={"Content-Type": "application/json"}
        )
        response.raise_for_status()
        print("Successfully sent message to Teams")
    except Exception as e:
        print(f"Failed to send message to Teams: {str(e)}")





sec_url = f"{api_url}repos/{repo_owner}/Branch-Test-Repo/secret-scanning/alerts"


def get_branch_repos_alerts():
    # Get alerts from GitHub API

    response = requests.get(sec_url, headers=HEADERS)
    alerts = response.json()
    
    # Track total number of alerts

    alert_count = len(alerts)
    print(f"\nTotal alerts found: {alert_count}")
    
    if not alerts:
        print("No security alerts found.")
        return
    
    # Process and display each alert

    for alert in alerts:
        
        print("\n=== Secret Scanning Alert ===")
        print(f"Alert Number: #{alert.get('number', 'N/A')}")
        print(f"State: {alert.get('state', 'N/A')}")
        print(f"Secret Type: {alert.get('secret_type_display_name', 'N/A')}")
        
        
        location = alert.get('location', {})
        print(f"File: {location.get('path', 'N/A')}")
        
        
        print(f"Commit SHA: {alert.get('most_recent_commit', 'N/A')}")
        print(f"HTML URL: {alert.get('html_url', 'N/A')}")
        
        
        print(f"Created: {alert.get('created_at', 'N/A')}")
        if alert.get('resolved_at'):
            print(f"Resolved: {alert.get('resolved_at')}")
            print(f"Resolution: {alert.get('resolution')}")
        
        print("="*50)
    
    # Send to Teams if we have alerts
    if alerts:
        webhook_url = os.environ.get('TEAMS_WEBHOOK_URL')
        if webhook_url:
            print("\nSending alerts to Teams...")
            send_teams_message(webhook_url, alerts)
        else:
            print("\nWarning: No Teams webhook URL provided. Skipping Teams notification.")
            print("Set the TEAMS_WEBHOOK_URL environment variable to enable Teams notifications.")

get_branch_repos_alerts()



