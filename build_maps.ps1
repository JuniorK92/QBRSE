[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$WorldNames,

    [string]$MissionName = "QBRSE",
    [string]$OutputDirectory,
    [string]$ArmakePath,
    [string]$CfgConvertPath
)

$ErrorActionPreference = "Stop"
$baseDirectory = [System.IO.Path]::GetFullPath($PSScriptRoot)
$mapDisplayNames = @{
    Altis = "Altis"
    Stratis = "Stratis"
    Malden = "Malden"
    Tanoa = "Tanoa"
    Enoch = "Livonia"
    SefrouRamal = "Sefrou-Ramal"
}

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path (Split-Path $baseDirectory -Parent) "QBRSE-maps"
}
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
$sourcePrefix = $baseDirectory.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
if ($OutputDirectory.Equals($baseDirectory, [System.StringComparison]::OrdinalIgnoreCase) -or
    $OutputDirectory.StartsWith($sourcePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "OutputDirectory must be outside the mission source directory."
}

if ($MissionName -notmatch '^[A-Za-z0-9_-]+$') {
    throw "MissionName may contain only letters, numbers, underscores, and hyphens."
}

if ([string]::IsNullOrWhiteSpace($ArmakePath)) {
    $armakeCommand = Get-Command "armake_w64.exe" -ErrorAction SilentlyContinue
    if ($null -eq $armakeCommand) {
        throw "armake_w64.exe was not found. Pass its path with -ArmakePath or add it to PATH."
    }
    $ArmakePath = $armakeCommand.Source
}
elseif (-not (Test-Path -LiteralPath $ArmakePath -PathType Leaf)) {
    throw "armake_w64 executable not found: $ArmakePath"
}

if ([string]::IsNullOrWhiteSpace($CfgConvertPath)) {
    $cfgConvertCommand = Get-Command "CfgConvert.exe" -ErrorAction SilentlyContinue
    if ($null -ne $cfgConvertCommand) {
        $CfgConvertPath = $cfgConvertCommand.Source
    }
    else {
        $cfgConvertCandidates = @(
            (Join-Path $env:ProgramFiles "Arma 3 Tools\CfgConvert\CfgConvert.exe"),
            (Join-Path ${env:ProgramFiles(x86)} "Arma 3 Tools\CfgConvert\CfgConvert.exe"),
            "D:\SteamLibrary\steamapps\common\Arma 3 Tools\CfgConvert\CfgConvert.exe"
        )
        $CfgConvertPath = $cfgConvertCandidates |
            Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
            Select-Object -First 1
    }
    if ([string]::IsNullOrWhiteSpace($CfgConvertPath)) {
        throw "CfgConvert.exe was not found. Pass its path with -CfgConvertPath or add it to PATH."
    }
}
elseif (-not (Test-Path -LiteralPath $CfgConvertPath -PathType Leaf)) {
    throw "CfgConvert executable not found: $CfgConvertPath"
}

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$sourceItems = Get-ChildItem -LiteralPath $baseDirectory -Force |
    Where-Object { $_.Name -ne ".git" -and $_.Name -ne "build_maps.ps1" }

foreach ($worldName in $WorldNames) {
    $worldName = $worldName.Trim()
    if ($worldName -notmatch '^[A-Za-z0-9_]+$') {
        throw "Invalid worldName '$worldName'. Use letters, numbers, and underscores only."
    }
    $mapDisplayName = $mapDisplayNames[$worldName]
    if ([string]::IsNullOrWhiteSpace($mapDisplayName)) {
        $mapDisplayName = $worldName
    }

    $missionFolderName = "$MissionName.$worldName"
    $missionDirectory = Join-Path $OutputDirectory $missionFolderName
    New-Item -ItemType Directory -Path $missionDirectory -Force | Out-Null
    foreach ($item in $sourceItems) {
        Copy-Item -LiteralPath $item.FullName -Destination $missionDirectory -Recurse -Force
    }

    $descriptionPath = Join-Path $missionDirectory "description.ext"
    $description = [System.IO.File]::ReadAllText($descriptionPath)
    $settingsToUpdate = @(
        @{ Name = "onLoadName"; Value = "YoRah's BRSE - $mapDisplayName" },
        @{ Name = "onLoadMission"; Value = "YoRah's BRSE - $mapDisplayName" }
    )
    $missingSettings = New-Object System.Collections.Generic.List[string]
    foreach ($setting in $settingsToUpdate) {
        $pattern = "(?im)^\s*$($setting.Name)\s*=\s*[^;]*;"
        $replacement = "$($setting.Name) = `"$($setting.Value)`";"
        if ([regex]::IsMatch($description, $pattern)) {
            $description = [regex]::Replace($description, $pattern, $replacement)
        }
        else {
            $missingSettings.Add($replacement)
        }
    }
    if ($missingSettings.Count -gt 0) {
        $description = ($missingSettings -join [Environment]::NewLine) + [Environment]::NewLine + $description
    }
    [System.IO.File]::WriteAllText($descriptionPath, $description, [System.Text.UTF8Encoding]::new($false))

    $missionPath = Join-Path $missionDirectory "mission.sqm"
    $missionTextPath = Join-Path $missionDirectory "mission.sqm.txt"
    $missionBinaryPath = Join-Path $missionDirectory "mission.binarized.sqm"
    & $CfgConvertPath -txt -dst $missionTextPath $missionPath
    if ($LASTEXITCODE -ne 0) {
        throw "CfgConvert could not convert mission.sqm to text for $worldName."
    }
    $missionText = [System.IO.File]::ReadAllText($missionTextPath)
    $briefingPattern = '(?im)^(\s*briefingName\s*=\s*)"[^"]*"\s*;'
    $briefingMatches = [regex]::Matches($missionText, $briefingPattern)
    if ($briefingMatches.Count -lt 1) {
        throw "No briefingName found in mission.sqm for $worldName."
    }
    $briefingReplacement = '$1"' + "YoRah's BRSE - $mapDisplayName" + '";'
    $missionText = [regex]::Replace($missionText, $briefingPattern, $briefingReplacement, 1)
    [System.IO.File]::WriteAllText($missionTextPath, $missionText, [System.Text.UTF8Encoding]::new($false))
    & $CfgConvertPath -bin -dst $missionBinaryPath $missionTextPath
    if ($LASTEXITCODE -ne 0) {
        throw "CfgConvert could not convert the updated mission.sqm to binary for $worldName."
    }
    Move-Item -LiteralPath $missionBinaryPath -Destination $missionPath -Force
    Remove-Item -LiteralPath $missionTextPath -Force

    $pboPath = Join-Path $OutputDirectory "$missionFolderName.pbo"
    & $ArmakePath build -f -p $missionDirectory $pboPath
    if ($LASTEXITCODE -ne 0) {
        throw "armake_w64 failed for $worldName with exit code $LASTEXITCODE."
    }
    Write-Host "Built $pboPath"
}
