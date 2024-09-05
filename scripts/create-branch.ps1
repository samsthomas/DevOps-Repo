#This script is used to create a new branch in a selection of repositories
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Host "GITHUB_PAT is set: $([bool]$env:GITHUB_PAT)"
Write-Host "GITHUB_PAT length: $($env:GITHUB_PAT.Length)"

try {
    Write-Host "Script started"

    $owner = "samsthomas"
    $repo = "DevOps-Repo"
    $baseBranch = "main"
    $newBranch = "feature/create-branch"

    Write-Host "Owner: $owner"
    Write-Host "Repo: $repo"
    Write-Host "Base Branch: $baseBranch"
    Write-Host "New Branch: $newBranch"

    Write-Host "Accessing repo: https://github.com/$owner/$repo"

    $headers = @{
        Authorization = "token $env:GITHUB_PAT"
        Accept = "application/vnd.github.v3+json"
    }
    Write-Host "Headers keys: $($headers.Keys -join ', ')"

    #added simpler api call to get user details
    $userUri = "https://api.github.com/user"
    $user = Invoke-RestMethod -Uri $userUri -Headers $headers
    Write-Host "Authenticated as: $($user.login)"

    #get the sha of the base branch
    $uri = "https://api.github.com/repos/$owner/$repo/git/refs/heads/$baseBranch"
    Write-Host "Accessing URI: $uri"
    $baseBranchRef = Invoke-RestMethod -Uri $uri -Headers $headers
    $baseBranchSha = $baseBranchRef.object.sha

    #create the branch
    $uri = "https://api.github.com/repos/$owner/$repo/git/refs"
    $body = @{
        ref = "refs/heads/$newBranch"
        sha = $baseBranchSha
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -ContentType "application/json" -Body $body

    Write-Host "Branch $newBranch created"

} catch {
    Write-Error "An error occurred:"
    Write-Error $_.Exception.Message
    Write-Error $_.ScriptStackTrace
    exit 1
}


