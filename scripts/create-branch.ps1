#This script is used to create a new branch in a selection of repositories

$pat = "$GitHub_Token"
$owner = "samsthomas"

$headers = @{"Authorization" = "token $pat"}

#repo we are looking at

$repo = "DevOps-Repo"

#branches we are looking at and looking to create
$branch = "feature/test-branch-creation"
$baseBranch = "main"
$newBranch = "feature/create-branch"


#get the sha of the base branch
$uri = "https://api.github.com/repos/$owner/$repo/git/refs/heads/$baseBranch"
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