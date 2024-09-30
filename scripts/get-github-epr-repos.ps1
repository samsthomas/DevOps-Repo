#this script is used to get all the repositories for a github org

$pat = "$env:GITHUB_PAT"
$owner = "samsthomas"
$url = "https://api.github.com/orgs/$owner/repos"

$headers = @{
    Authorization = "token $pat"
    Accept = "application/vnd.github.v3+json"
    'X-GitHub-Api-Version' = "2022-11-28"
}

$response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

Write-Host "Repositories: $($response)"


