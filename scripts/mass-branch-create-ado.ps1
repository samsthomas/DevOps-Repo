#script to create a new branch in all repositories for a ado project

#variables 

$pat = "$env:ADO_PAT"
$organization = "https://dev.azure.com/samsthomas"
$project = "Sams%20DevOps%20Project"

$Repositories = @("ADO-Test-Repo-1", "ADO-Test-Repo-2")

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))

$headers = @{
    Authorization=("Basic {0}" -f $base64AuthInfo)
}

$SourceBranch = "refs/heads/main"
$NewBranch = "feature/test-release-branch"

foreach ($repo in $Repositories) {
    $repoUrl = "$organization/$project/_apis/git/repositories/$repo?api-version=7.0"
    $repoDetails = Invoke-RestMethod -Uri $repoUrl -Method Get -Headers $headers
    $repoId = $repoDetails.id

    $createBranchUrl = "$organization/$project/_apis/git/repositories/$repoId/refs?api-version=7.0"
    $body = @{
        name = "refs/heads/$NewBranch"
        oldObjectId = $SourceBranch
        newObjectId = $NewBranch
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $createBranchUrl -Method Post -Headers $headers -Body $body

}


