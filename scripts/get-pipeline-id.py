import os
from azure.devops.connection import Connection
from msrest.authentication import BasicAuthentication

# Azure DevOps organization URL
organization_url = "https://dev.azure.com/samsthomas"

# Personal Access Token (PAT)
personal_access_token = ""

# Create a connection to Azure DevOps
credentials = BasicAuthentication('', personal_access_token)
connection = Connection(base_url=organization_url, creds=credentials)

# Get a client (the "core" client provides access to projects, teams, etc.)
core_client = connection.clients.get_core_client()

# Get the first page of projects
projects = core_client.get_projects()

# Get the build client
build_client = connection.clients.get_build_client()

# Iterate through projects and list pipelines
for project in projects:
    print(f"Project: {project.name}")
    
    # Get pipelines for the project
    pipelines = build_client.get_definitions(project=project.id)
    
    for pipeline in pipelines:
        print(f"  Pipeline Name: {pipeline.name}")
        print(f"  Pipeline ID: {pipeline.id}")
    
    print()  # Add a blank line between projects
