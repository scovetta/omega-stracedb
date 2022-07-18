param(
    [Parameter(Mandatory=$false)]
    [bool]
    $force = $false,

    [Parameter(Mandatory=$false)]
    [bool]
    $use_wsl = $true
)

if ($use_wsl) {
    $DOCKER_CMD = "wsl"
    $DOCKER_ARG = "docker"
} else {
    $DOCKER_CMD = "docker"
    $DOCKER_ARG = ""
}

try
{
    $version = (Select-String -Path Dockerfile -Pattern 'LABEL Version="(.*)"').Matches.Groups[1].Value

    & $DOCKER_CMD $DOCKER_ARG build -t openssf/omega-tracer:$version . -f Dockerfile
    & $DOCKER_CMD $DOCKER_ARG tag openssf/omega-tracer:$version openssf/omega-tracer:latest
}
catch
{
    Write-Host "Error running build."
}
