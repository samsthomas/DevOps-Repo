function getLatestVersionByMajor ($Major) {
    $listOfReleases = git tag -l 

    $versions = $listOfReleases | Where-Object {$_ -match "^Release-$Major.[0-9]+.[0-9]+$" } | Foreach-Object {[System.Version]::new($_.Substring(9))}
    $ver = $versions | Sort-Object -Descending | Select-Object -First 1
    return $ver
     
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

$latestReleaseVersion = getLatestVersionByMajor $versionInfo.major

# Write-Host "Raw version info: $($versionInfo | ConvertTo-Json)"
# Write-Host "Major version: $($versionInfo.major)"

$majorVersion = $($versionInfo.major)

Write-Host "Latest release version $($majorVersion)"

#check if there is an existing tag
# if ($null -eq $latestReleaseVersion){
#     throw "cant find tag"
# }

#Remove tag if it is present 

$latestMajorTag = "Release-$($majorVersion)-latest"
if (testIfTagPresent $latestMajorTag){
    Write-Host "Removing Tag $latestMajorTag"
    git tag -d $latestMajorTag
}

Write-Host "Tagging new commit as $latestMajorTag"
git tag -f $latestMajorTag

git push --tags --force













# $prevTagVersion = @{
#     Major = ""; Minor = ""; Patch = ""
# }

# $newTagVersion = @{
#     Major = ""; Minor = ""; Patch = ""
# }

# try 