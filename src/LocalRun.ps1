param (
    [Parameter(Mandatory=$true)]
    [string]
    $PackageName
)

.\Run.ps1 $PackageName -use_wsl $true -ResultsDirectory C:\dev\source\ossf\omega-tracer\ubuntu\22.04 -AptMirrorPath C:\dev\source\ossf\linux-runtime-dependency-analyzer\apt-mirror