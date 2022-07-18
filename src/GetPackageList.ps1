param (
    [Parameter(Mandatory=$false)]
    [bool]
    $use_wsl = $true
)

# Copyright Linux Foundation and contributors. Licensed under the MIT license.

$IMAGE_TAG = "latest"

if ($use_wsl) {
    $DOCKER_CMD = "wsl"
    $DOCKER_ARG = "docker"
} else {
    $DOCKER_CMD = "docker"
    $DOCKER_ARG = ""
}

& $DOCKER_CMD $DOCKER_ARG run --rm -it --entrypoint /usr/bin/get-package-list.sh openssf/omega-tracer:$IMAGE_TAG > package-list

Write-Output "Package list written to package-list"
