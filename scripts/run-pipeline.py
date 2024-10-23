import os
from azure.devops.connection import Connection
from azure.devops.credentials import BasicAuthentication
from azure.devops.v7_0.build.models import Build

# Azure DevOps organization URL
organization_url = "https://dev.azure.com/samsthomas"

# Personal Access Token (PAT)
personal_access_token = ""

# Create a connection to Azure DevOps
credentials = BasicAuthentication('', personal_access_token)
connection = Connection(base_url=organization_url, creds=credentials)

# Get a client (the "core" client provides access to projects, teams, etc.)
core_client = connection.clients.get_core_client()

# Get the build client
build_client = connection.clients.get_build_client()

# Define your project name
my_project = "Sams-DevOps-Project"

# Get the project
project = core_client.get_project(my_project)

if project.name == my_project:
    # Create a Build object
    build_parameters = Build(definition={"id": 1})
    
    # Queue the build
    build = build_client.queue_build(build=build_parameters, project=my_project)
    
    # Wait for the build to complete
    while True:
        build = build_client.get_build(project=my_project, build_id=build.id)
        if build.status == "completed":
            break
    
    # Check if the build was successful
    if build.result == "succeeded":
        print(f"Pipeline run for {my_project} was successful!")
    else:
        print(f"Pipeline run for {my_project} failed. Result: {build.result}")
else:
    print(f"Project {my_project} not found.")
