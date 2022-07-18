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
    $ResultsDirectory,

    [Parameter(Mandatory=$false)]
    [string]
    $AptMirrorPath
)

# Copyright Linux Foundation and contributors. Licensed under the MIT license.

if ($use_wsl) {
    $DOCKER_CMD = "wsl"
    $DOCKER_ARG = "docker"
} else {
    $DOCKER_CMD = "docker"
    $DOCKER_ARG = ""
}

$RetryCount = 2

$IMAGE_TAG = "latest"

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

    if ($AptMirrorPath) {
        cd $AptMirrorPath
        $APT_MIRROR_PATH = $(wsl pwd)
        cd $CURRENT_DIRECTORY

        & $DOCKER_CMD $DOCKER_ARG run --rm -it --mount type=bind,source=$APT_MIRROR_PATH,target=/opt/apt-mirror,readonly --mount type=bind,source=$RESULTS_REPOSITORY_WSL,target=/opt/export openssf/omega-tracer:$IMAGE_TAG $PackageName $InstallCommand
    } else {
        $APT_MIRROR_ARG = ""
        & $DOCKER_CMD $DOCKER_ARG run --rm -it --mount type=bind,source=$RESULTS_REPOSITORY_WSL,target=/opt/export openssf/omega-tracer:$IMAGE_TAG $PackageName $InstallCommand
    }

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
