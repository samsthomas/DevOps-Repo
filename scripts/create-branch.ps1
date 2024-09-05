#This script is used to create a new branch in a selection of repositories
try {
    Write-Host "Script started"
    
    # Your existing script here
    
} catch {
    Write-Host "An error occurred:"
    Write-Host $_.Exception.Message
    Write-Host $_.ScriptStackTrace
    exit 1
}

Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"

$pat = "$env:GitHub_Token"
$owner = "samsthomas"

Write-Host "Accessing repo: https://github.com/$owner/$repo"

$headers = @{
    Authorization = "token $pat"
    Accept = "application/vnd.github.v3+json"
}
Write-Host "Headers keys: $($headers.Keys -join ', ')"

#repo we are looking at

$repo = "DevOps-Repo"

#branches we are looking at and looking to create
$branch = "feature/test-branch-creation"
$baseBranch = "main"
$newBranch = "feature/create-branch"

Write-Host "Script started"

# Add these lines right after any variable declarations
Write-Host "Owner: $owner"
Write-Host "Repo: $repo"
Write-Host "Base Branch: $baseBranch"
Write-Host "New Branch: $newBranch"

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


