param(
    [Parameter(Mandatory=$false)]
    [bool]
    $force = $false,

    [Parameter(Mandatory=$false)]
    [bool]
    $use_wsl = $true
)

if ($use_wsl)
{
    $wsl_cmd = "wsl "
}
else
{
    $wsl_cmd = ""
}

try
{
    $version = (Select-String -Path Dockerfile -Pattern 'LABEL Version="(.*)"').Matches.Groups[1].Value

    if ($force) {
        $wsl_cmd docker build -t openssf/omega-tracer:$version . -f Dockerfile --build-arg CACHEBUST=$(date -Format o)
    } else {
        $wsl_cmd docker build -t openssf/omega-tracer:$version . -f Dockerfile
    }
    $wsl_cmd docker tag openssf/omega-tracer:$version openssf/omega-tracer:latest
}
catch
{
    Write-Host "Error running build."
}
