param(
    [string]$OutputDir = "bin"
)

$ErrorActionPreference = "Stop"
$repoRoot = $PSScriptRoot
$outputDirPath = $OutputDir
if (-not ([System.IO.Path]::IsPathRooted($OutputDir))) {
    $outputDirPath = Join-Path $repoRoot $OutputDir
}
$outputExe = Join-Path $outputDirPath "batcap.exe"

$csc = Join-Path $env:WINDIR "Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path $csc)) {
    $csc = Join-Path $env:WINDIR "Microsoft.NET\Framework\v4.0.30319\csc.exe"
}
if (-not (Test-Path $csc)) {
    Write-Host "csc.exe not found. Install .NET Framework 4.0 or later."
    exit 1
}

$sources = @(Get-ChildItem (Join-Path $repoRoot "src\*.cs") | ForEach-Object { $_.FullName })
if ($sources.Count -eq 0) {
    Write-Host "No source files found in src."
    exit 1
}

New-Item -ItemType Directory -Path $outputDirPath -Force | Out-Null

Write-Host "Building batcap..."
& $csc /nologo /optimize+ /reference:System.Management.dll /target:winexe /platform:anycpu "/out:$outputExe" $sources
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed."
    exit 1
}

Write-Host "Build succeeded: $outputExe"
exit 0
