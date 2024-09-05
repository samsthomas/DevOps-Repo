Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"

$repositoryNames = @("Branch-Test-Repo", "Branch-Test-Repo-2", "Branch-Test-Repo-3")
$pat = "$env:GITHUB_PAT"
$owner = "samsthomas"


#branches we are looking at and looking at
$newBranch = "feature/test-release-branch"
$baseBranch = "main"

# Add these lines right after any variable declarations
Write-Host "Owner: $owner"
Write-Host "Base Branch: $baseBranch"
Write-Host "New Branch: $newBranch"

$headers = @{
    Authorization = "token $pat"
    Accept = "application/vnd.github.v3+json"
}


foreach ($repositoryName in $repositoryNames) {
    
    $uri = "https://api.github.com/repos/$owner/$repositoryNames/git/refs/heads/$baseBranch"
    $baseBranchRef = Invoke-RestMethod -Uri $uri -Headers $headers
    $baseBranchSha = $baseBranchRef.object.sha

    #Create the branch
    $uri = "https://api.github.com/repos/$owner/$repositoryName/git/refs"
    $body = @{
        ref = "refs/heads/$newBranch"
        sha = $baseBranchSha
    } | ConvertTo-Json

    Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -ContentType "application/json" -Body $body

    Write-Host "Branch $newBranch has been created on $repositoryName"
    
    
}