#this script is used to get all the repositories for a github org

$pat = "$env:GITHUB_PAT"
$owner = "samsthomas"
$url = "https://api.github.com/users/$owner/repos"

Write-Host $url

$headers = @{
    Authorization = "token $pat"
    Accept = "application/vnd.github.v3+json"
    'X-GitHub-Api-Version' = "2022-11-28"
}

$response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

Write-Host "Repositories: $($response | Select-Object -ExpandProperty name)"

Write-Host "Checking for Branch Repos"
$repos = $response | Select-Object -ExpandProperty name

foreach ($repo in $repos) {
        if ($repo -like "*Branch*") {
        $BranchRepo = $repo
        Write-Host "Branch Repository: $BranchRepo"
    }
}

