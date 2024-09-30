#script to create a new branch in all repositories for a ado project


#param for the new branch name being passed in

param(
    [Parameter(Mandatory=$true)]
    [string]$newBranch
)

#defining variables

$Repositories = @("ADO-Test-Repo-1", "ADO-Test-Repo-2") #for ado as there are very few repos left, this can potentially be left as a list like this
$baseBranch = "main"

$organization = "samsthomas"
$project = "Sams-DevOps-Project"
$pat = "$env:ADO_PAT"

$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$pat"))

#setting headers
$headers = @{ Authorization = "Basic $base64AuthInfo" }

#for loop to iterate through each repository and create a new branch
foreach ($repo in $Repositories) {
    Write-Host "Checking repository: $repo"
    
    # Get ID of the base branch
    $url = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repo/refs?filter=heads/$baseBranch&api-version=7.1"
    try {
        $baseBranchResponse = Invoke-RestMethod -Uri $url -Headers $headers -Method GET
        $baseBranchId = $baseBranchResponse.value.objectId
        Write-Host "  Found base branch '$baseBranch'"
    } catch {
        Write-Host "  Error: Unable to find base branch '$baseBranch' in repository $repo"
        Write-Host "  StatusCode: $($_.Exception.Response.StatusCode.value__)"
        Write-Host "  StatusDescription: $($_.Exception.Response.StatusDescription)"
        continue
    }

    # Check if the new branch already exists
    $checkBranchUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repo/refs?filter=heads/$newBranch&api-version=7.1"
    $existingBranch = Invoke-RestMethod -Uri $checkBranchUrl -Headers $headers -Method GET

    if ($existingBranch.value) {
        Write-Host "  Branch '$newBranch' already exists in repository $repo. Skipping creation."
        continue
    }

    # Create a new branch
    $url = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repo/refs?api-version=7.1"
    $body = ConvertTo-Json @(
        @{
            name = "refs/heads/$newBranch"
            newObjectId = $baseBranchId
            oldObjectId = "0000000000000000000000000000000000000000"
        }
    )

    try {
        Invoke-RestMethod -Uri $url -ContentType "application/json" -Body $body -Headers $headers -Method POST
        Write-Host "  Successfully created branch '$newBranch' in repository $repo"
        Write-Host "  New branch details:"
        Write-Host "    Name: $($newBranch)"
    } catch {
        Write-Host "  Error: Failed to create branch '$newBranch' in repository $repo"
        Write-Host "  StatusCode: $($_.Exception.Response.StatusCode.value__)"
        Write-Host "  StatusDescription: $($_.Exception.Response.StatusDescription)"
        Write-Host "  ResponseBody: $($_.ErrorDetails.Message)"
    }

    Write-Host ""  # Add a blank line for better readability between repositories
}

Write-Host "Branch creation process completed."



# $pat = "$env:ADO_PAT"
# $organization = "https://dev.azure.com/samsthomas"
# $project = [System.Web.HttpUtility]::UrlEncode("Sams DevOps Project")

# $Repositories = @("ADO-Test-Repo-1", "ADO-Test-Repo-2")

# $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))

# $headers = @{
#     Authorization=("Basic {0}" -f $base64AuthInfo)
# }

# $defaultBranch = "refs/heads/main"
# $NewBranch = "feature/test-release-branch"




# foreach ($repo in $Repositories) {
#     $repoUrl = "$organization/$project/_apis/git/repositories/$([System.Web.HttpUtility]::UrlEncode($repo))?api-version=7.0"
#     Write-Host "Attempting to access: $repoUrl"
#     $repoDetails = Invoke-RestMethod -Uri $repoUrl -Method Get -Headers $headers
#     $repoId = $repoDetails.id
#     $defaultBranch = $repoDetails.defaultBranch.Replace("refs/heads/", "")

#     # Get the SHA of the default branch
#     $branchUrl = "$organization/$project/_apis/git/repositories/$repoId/refs?filter=heads/$defaultBranch&api-version=7.0"
#     $branchDetails = Invoke-RestMethod -Uri $branchUrl -Method Get -Headers $headers
#     $defaultBranchSha = $branchDetails.value[0].objectId

#     $createBranchUrl = "$organization/$project/_apis/git/repositories/$repoId/refs?api-version=7.0"
#     $body = @{
#         name = "refs/heads/$NewBranch"
#         oldObjectId = "0000000000000000000000000000000000000000"
#         newObjectId = $defaultBranchSha
#     } | ConvertTo-Json

#     Invoke-RestMethod -Uri $createBranchUrl -Method Post -Headers $headers -Body $body -ContentType "application/json"
#     Write-Host "Created branch $NewBranch in repository $repo"
# }


