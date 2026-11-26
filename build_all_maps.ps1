$ErrorActionPreference = "Stop"
$salida = "D:\_dev\GitHub\QBRSE-maps"
$imagenes = Join-Path $PSScriptRoot "images"
$fileBank = "D:\SteamLibrary\steamapps\common\Arma 3 Tools\FileBank\FileBank.exe"
$mapas = @(
    @{ World = "Altis"; Image = "Altis.jpg" },
    @{ World = "Stratis"; Image = "Stratis.jpg" },
    @{ World = "Malden"; Image = "Malden.jpg" },
    @{ World = "Tanoa"; Image = "Tanoa.jpg" },
    @{ World = "Enoch"; Image = "Livonia.jpg" },
    @{ World = "SefrouRamal"; Image = "Sefrou-Ramal.jpg" }
)

if (-not (Test-Path -LiteralPath $salida -PathType Container)) {
    throw "No existe la carpeta de salida: $salida"
}
if (-not (Test-Path -LiteralPath $fileBank -PathType Leaf)) {
    throw "No se encontró FileBank.exe: $fileBank"
}
$imagenDefault = Join-Path $imagenes "Default.jpg"
if (-not (Test-Path -LiteralPath $imagenDefault -PathType Leaf)) {
    throw "No se encontró la imagen de respaldo: $imagenDefault"
}

Push-Location $salida
try {
    foreach ($mapa in $mapas) {
        $carpetaMision = Join-Path $salida "QBRSE.$($mapa.World)"
        if (-not (Test-Path -LiteralPath $carpetaMision -PathType Container)) {
            throw "No existe la carpeta de misión: $carpetaMision"
        }

        $imagenMapa = Join-Path $imagenes $mapa.Image
        if (-not (Test-Path -LiteralPath $imagenMapa -PathType Leaf)) {
            $imagenMapa = $imagenDefault
        }
        Copy-Item -LiteralPath $imagenMapa -Destination (Join-Path $carpetaMision "Start.jpg") -Force

        & $fileBank -dst $salida ".\\QBRSE.$($mapa.World)"
        if ($LASTEXITCODE -ne 0) {
            throw "Falló la compilación de QBRSE.$($mapa.World)"
        }
        Write-Host "Compilado QBRSE.$($mapa.World) con $([System.IO.Path]::GetFileName($imagenMapa))"
    }
}
finally {
    Pop-Location
}
