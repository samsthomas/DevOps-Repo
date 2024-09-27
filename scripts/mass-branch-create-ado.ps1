#script to create a new branch in all repositories for a ado project

Add-Type -AssemblyName System.Web

#defining variables

$Repositories = @("ADO-Test-Repo-1", "ADO-Test-Repo-2")
$newBranch = "test-branch-1"
$baseBranch = "main"

$organization = "Sams-DevOps-Project"
$project = "Sams-DevOps-Project"
$pat = "personalAccessToken"

$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$pat"))

#setting headers
$headers = @{ Authorization = "Basic $base64AuthInfo" }

#for loop to iterate through each repository and create a new branch
foreach ($repo in $Repositories) {
    # Get ID of the base branch
    $url = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repo/refs?filter=heads/$baseBranch&api-version=7.1"
    $baseBranchResponse = Invoke-RestMethod -Uri $url -ContentType "application/json" -headers $headers -Method GET

    # Create a new branch
    $url = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repo/refs?api-version=7.1"
    $body = ConvertTo-Json @(
        @{
            name = "refs/heads/$newBranch"
            newObjectId = $baseBranchResponse.value.objectId
            oldObjectId = "0000000000000000000000000000000000000000"
        }
    )


    $response = Invoke-RestMethod -Uri $url -ContentType "application/json" -Body $body -headers $headers -Method POST

}








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


