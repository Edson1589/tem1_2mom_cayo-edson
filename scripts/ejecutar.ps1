param([switch]$SoloConsultas)

$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$utf8 = New-Object System.Text.UTF8Encoding($false)
[Console]::OutputEncoding = $utf8
New-Item -ItemType Directory -Force -Path data, resultados, evidencias/logs | Out-Null

function Invoke-Docker {
    param([string[]]$DockerArgs)
    & docker.exe @DockerArgs
    if ($LASTEXITCODE -ne 0) { throw "Docker fallo: $($DockerArgs -join ' ')" }
}

if (-not $SoloConsultas) {
    $source = Join-Path (Get-Location) 'Sample - Superstore.csv'
    $bytes = [IO.File]::ReadAllBytes($source)
    try {
        $strictUtf8 = New-Object System.Text.UTF8Encoding($false, $true)
        $text = $strictUtf8.GetString($bytes)
    } catch [System.Text.DecoderFallbackException] {
        $text = [Text.Encoding]::GetEncoding(1252).GetString($bytes)
    }
    $rows = @($text | ConvertFrom-Csv)
    # Autocomprobacion del archivo entregado antes de sobrescribir la carga propia.
    if ($rows.Count -ne 9994 -or @($rows[0].PSObject.Properties).Count -ne 21) {
        throw 'El CSV debe tener 9994 filas y 21 columnas. Revisa el archivo de entrada.'
    }
    if ($rows[1].'Product Name' -ne 'Hon Deluxe Fabric Upholstered Stacking Chairs, Rounded Back') {
        throw 'La lectura de las comas entre comillas no coincide con el archivo original.'
    }
    $dataWithoutHeader = $text.Substring($text.IndexOf("`n") + 1)
    [IO.File]::WriteAllText((Join-Path (Get-Location) 'data/data_edson_cayo.csv'), $dataWithoutHeader, $utf8)
    $manifest = "Fecha: $(Get-Date -Format o)`nFilas CSV: $($rows.Count)`nColumnas: 21`nSHA256 original: $((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash)`n"
    [IO.File]::WriteAllText((Join-Path (Get-Location) 'evidencias/logs/entrada.txt'), $manifest, $utf8)
    Invoke-Docker -DockerArgs @('compose','cp','data/data_edson_cayo.csv','namenode:/tmp/data_edson_cayo.csv')
    Invoke-Docker -DockerArgs @('compose','exec','-T','namenode','hdfs','dfs','-mkdir','-p','/user/hive/superstore_edson/raw')
    Invoke-Docker -DockerArgs @('compose','exec','-T','namenode','hdfs','dfs','-put','-f','/tmp/data_edson_cayo.csv','/user/hive/superstore_edson/raw/data_edson_cayo.csv')
}
Invoke-Docker -DockerArgs @('compose','cp','scripts/.','hive-server:/tmp/superstore_edson_scripts')

$files = @(Get-ChildItem scripts -Filter '*.hql' | Sort-Object Name)
if ($SoloConsultas) { $files = @($files | Where-Object { $_.Name -notlike '01_*' }) }
$measurements = @()
foreach ($file in $files) {
    Write-Host "Ejecutando $($file.Name)..."
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $output = Join-Path (Get-Location) "resultados/$($file.BaseName).tsv"
    $log = Join-Path (Get-Location) "evidencias/logs/$($file.BaseName).log"
    # Beeline escribe diagnosticos en stderr incluso al completar correctamente.
    $ErrorActionPreference = 'Continue'
    & docker.exe compose exec -T hive-server beeline `
        -u jdbc:hive2://localhost:10000/default -n hive `
        --force=false --silent=false --showHeader=true --outputformat=tsv2 `
        -f "/tmp/superstore_edson_scripts/$($file.Name)" 2> $log |
        Set-Content -Encoding UTF8 -LiteralPath $output
    $exitCode = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    $timer.Stop()
    if ($exitCode -ne 0 -or (Select-String -LiteralPath $log -Pattern 'Error:|FAILED:|Exception:' -Quiet)) {
        throw "Fallo en $($file.Name). Revisa $log."
    }
    $measurements += [pscustomobject]@{
        script=$file.Name; segundos=[Math]::Round($timer.Elapsed.TotalSeconds,2); estado='OK'
    }
    $measurements | Export-Csv -NoTypeInformation -Encoding UTF8 resultados/tiempos.csv
}
Write-Host 'Finalizado. Resultados TSV en resultados/ y registros reales en evidencias/logs/.'
