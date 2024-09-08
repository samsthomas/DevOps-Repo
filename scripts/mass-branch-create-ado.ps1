#script to create a new branch in all repositories for a ado project

Add-Type -AssemblyName System.Web

#variables 

$pat = "$env:ADO_PAT"
$organization = "https://dev.azure.com/samsthomas"
$project = [System.Web.HttpUtility]::UrlEncode("Sams DevOps Project")

$Repositories = @("ADO-Test-Repo-1", "ADO-Test-Repo-2")

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))

$headers = @{
    Authorization=("Basic {0}" -f $base64AuthInfo)
}

$SourceBranch = "refs/heads/main"
$NewBranch = "feature/test-release-branch"

foreach ($repo in $Repositories) {
    $repoUrl = "$organization/$project/_apis/git/repositories/$([System.Web.HttpUtility]::UrlEncode($repo))?api-version=7.0"
    $repoDetails = Invoke-RestMethod -Uri $repoUrl -Method Get -Headers $headers
    $repoId = $repoDetails.id
    $defaultBranch = $repoDetails.defaultBranch.Replace("refs/heads/", "")

    # Get the SHA of the default branch
    $branchUrl = "$organization/$project/_apis/git/repositories/$repoId/refs?filter=heads/$defaultBranch&api-version=7.0"
    $branchDetails = Invoke-RestMethod -Uri $branchUrl -Method Get -Headers $headers
    $defaultBranchSha = $branchDetails.value[0].objectId

    $createBranchUrl = "$organization/$project/_apis/git/repositories/$repoId/refs?api-version=7.0"
    $body = @{
        name = "refs/heads/$NewBranch"
        oldObjectId = "0000000000000000000000000000000000000000"
        newObjectId = $defaultBranchSha
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $createBranchUrl -Method Post -Headers $headers -Body $body -ContentType "application/json"
    Write-Host "Created branch $NewBranch in repository $repo"
}


