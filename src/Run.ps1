param (
    [Parameter(Mandatory=$true)]
    [string]
    $PackageName,

    [Parameter(Mandatory=$false)]
    [string]
    $InstallCommand = "",

    [Parameter(Mandatory=$false)]
    [bool]
    $use_wsl = $true,

    [Parameter(Mandatory=$true)]
    [string]
    $ResultsDirectory
)

if ($use_wsl)
{
    $wsl_cmd = "wsl "
}
else
{
    $wsl_cmd = ""
}

# Copyright Linux Foundation and contributors. Licensed under the MIT license.

$RetryCount = 2

$IMAGE_TAG = "0.1.0"
$ResultsDirectory = "C:\dev\source\ossf\omega-tracer\ubuntu\22.04"

if (Test-Path -Type Container (Join-Path $ResultsDirectory $PackageName)) {
    Write-Host "Package [$PackageName] already analyzed."
    Exit 0
}

while ($RetryCount -gt 0)
{
    $CURRENT_DIRECTORY = (Get-Location).Path
    cd $ResultsDirectory
    $RESULTS_REPOSITORY_WSL = $(wsl pwd)
    cd $CURRENT_DIRECTORY

    cd "apt-mirror"
    $APT_MIRROR_PATH = $(wsl pwd)
    cd ..

    $wsl_cmd docker run --rm -it --mount type=bind,source=$APT_MIRROR_PATH,target=/opt/apt-mirror,readonly --mount type=bind,source=$RESULTS_REPOSITORY_WSL,target=/opt/export openssf/omega-tracer:$IMAGE_TAG $PackageName $InstallCommand
    $RESULT=$LASTEXITCODE
    if ($RESULT -eq 0) {
        Write-Output "Package successfully analyzed, results in $ResultsDirectory\$PackageName"
        break
    } elseif ($RESULT -eq 2) {
        Write-Output "No executables found for $PackageName"
        break
    } else {
        Write-Output "Analysis did not complete for $PackageName."
        Sleep 5
    }
    $RetryCount--
}
Write-Output "Operation Complete."
[Console]::Out.Flush()
