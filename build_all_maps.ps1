$salida = "D:\_dev\GitHub\QBRSE-maps"
$fileBank = "D:\SteamLibrary\steamapps\common\Arma 3 Tools\FileBank\FileBank.exe"

Push-Location $salida
try {
    "Altis", "Stratis", "Malden", "Tanoa", "Enoch", "SefrouRamal" | ForEach-Object {
        & $fileBank -dst $salida ".\QBRSE.$_"
        if ($LASTEXITCODE -ne 0) {
            throw "Falló la compilación de QBRSE.$_"
        }
    }
}
finally {
    Pop-Location
}
