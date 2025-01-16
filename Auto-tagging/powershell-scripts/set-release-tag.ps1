function getLatestVersionByMajor ($Major) {
    $listOfReleases = git tag -l 
    Write-Host "All tags: $($listOfReleases)"

    $versions = $listOfReleases | Where-Object {$_ -match "^Release-$Major\.[0-9]+-Latest$" } | Foreach-Object {
        if($_ -match "^Release-$Major\.([0-9]+)-Latest$") {
            [PSCustomObject]@{
                Major = $Major
                Minor = [int]$matches[1]
                FullTag = $_
            }
        }
    }

    $latestVersion = $versions | Sort-Object -Property Minor -Descending | Select-Object -First 1

    if ($latestVersion) {
        return $latestVersion
    }
    return $null
}

$versioningJsonPath = './Auto-tagging/version.json'

function testIfTagPresent ($tag) {
    $listOfReleases = git tag -l 
    $result = $listOfReleases | Where-Object { $_ -match "^$tag$"} | Select-Object -First 1
    if ($result.count -eq 1){
        return $true
    }
    else {
        return $false
    }
}

try {
    $versionInfo = Get-Content -Raw -Path $versioningJsonPath | ConvertFrom-Json
    if ([string]::IsNullOrEmpty($versionInfo.major) -or [string]::IsNullOrEmpty($versionInfo.minor)) {
        throw
    }
}
catch {
    throw "version info missing in the file '$($versioningJsonPath)'. Error : $($_.Exception.Message)"
}

Write-Host "Raw version info: $($versionInfo | ConvertTo-Json)"
Write-Host "Major version: $($versionInfo.major)"
Write-Host "Minor version: $($versionInfo.minor)"

$latestVersion = getLatestVersionByMajor $versionInfo.major

$latestMajorTag = "Release-$($versionInfo.major).$($versionInfo.minor)-Latest"

if (testIfTagPresent $latestMajorTag){
    Write-Host "Removing Tag $latestMajorTag"
    git tag -d $latestMajorTag
}

Write-Host "Tagging new commit as $latestMajorTag"
git tag -f $latestMajorTag

git push --tags --force





