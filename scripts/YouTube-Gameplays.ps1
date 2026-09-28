param(
    [ValidateSet('Find', 'Download')][string]$Action = 'Find',
    [string[]]$Game = @(),
    [int]$Candidates = 5,
    [ValidateRange(240,2160)][int]$MaxHeight = 720,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$downloader = Join-Path $projectRoot 'tools\yt-dlp.exe'
$sourcePath = Join-Path $projectRoot 'catalog\sources.json'
$exampleSourcePath = Join-Path $projectRoot 'catalog\sources.example.json'
if (!(Test-Path -LiteralPath $sourcePath) -and (Test-Path -LiteralPath $exampleSourcePath)) {
    Copy-Item -LiteralPath $exampleSourcePath -Destination $sourcePath
}
$games = @(Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'catalog\games.json') | ConvertFrom-Json)
if ($Game.Count) { $games = @($games | Where-Object { $_.slug -in $Game }) }
if (!$games.Count) { throw "Jogo desconhecido: $Game" }
if (!(Test-Path -LiteralPath $downloader)) {
    New-Item -ItemType Directory -Path (Split-Path $downloader) -Force | Out-Null
    Invoke-WebRequest 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe' -OutFile $downloader
}
$baseArgs = @('--ignore-config', '--no-playlist', '--js-runtimes', 'node', '--socket-timeout', '20', '--retries', '2')
$sources = @()
$failedCount = 0
if (Test-Path -LiteralPath $sourcePath) { $sources = @(Get-Content -Raw -LiteralPath $sourcePath | ConvertFrom-Json) }
$titlePatterns = @{
    'warpath-jurassic-park' = 'warpath'
    'ridge-racer-type-4' = 'ridge racer.*(type.?4|r4)|r4.*ridge'
    'legend-of-mana' = 'legend.*mana'
    'tekken-3' = 'tekken\s*3'
    'gran-turismo-2' = 'gran\s*turismo\s*2'
    'resident-evil-3-nemesis' = 'resident\s*evil\s*3'
    'breath-of-fire-iv' = 'breath.*fire.*(iv|4)'
    'alone-in-the-dark-new-nightmare' = 'alone.*dark.*new nightmare'
    'crash-bandicoot-3-warped' = 'crash.*(warped|bandicoot.*3)'
    'final-fantasy-ix' = 'final fantasy.*(ix|9)'
    'dino-crisis' = 'dino\s*crisis(?!\s*2)'
    'castlevania-symphony-of-the-night' = 'castlevania.*symphony'
    'chrono-cross' = 'chrono\s*cross'
    'street-fighter-alpha-3' = 'street fighter.*alpha\s*3'
    'alien-resurrection' = 'alien.*resurrection'
    'metal-gear-solid' = 'metal gear solid(?!\s*[2345])'
    'legend-of-dragoon' = 'legend.*dragoon'
    'bloody-roar-2' = 'bloody roar.*2'
}

function Save-Sources {
    ConvertTo-Json -InputObject @($script:sources) -Depth 8 | Set-Content -LiteralPath $script:sourcePath -Encoding utf8
}

function Save-Download($Source) {
    $statusPath = Join-Path $script:projectRoot "catalog\$($Source.slug).download-status.json"
    $Source | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $statusPath -Encoding utf8
}

function Get-Score($Entry) {
    $title = [string]$Entry.title
    $score = 0
    if ($title -match '(?i)longplay|full game|walkthrough') { $score += 4 }
    if ($title -match '(?i)no commentary|sem coment') { $score += 4 }
    if ($title -match '(?i)PS1|PSX|PlayStation(?!\s*[2345])') { $score += 4 }
    if ([string]$Entry.channel -match '^(World[- ]of[- ]Longplays|LongplayArchive)$') { $score += 5 }
    if ($title -match '(?i)remaster|remake|reignited|review|retrospective|comparison|top\s*\d') { $score -= 25 }
    if ($Entry.duration -and $Entry.duration -lt 600) { $score -= 10 }
    return $score
}

foreach ($item in $games) {
    $logPath = Join-Path $projectRoot "catalog\$($item.slug).$($Action.ToLower()).log"
    try {
        if ($Action -eq 'Find') {
            Write-Host "BUSCANDO: $($item.game)"
            $searchArgs = $baseArgs + @('--flat-playlist', '--dump-single-json', "ytsearch${Candidates}:$($item.query)")
            $raw = (& $downloader @searchArgs 2> $logPath | Out-String)
            if ($LASTEXITCODE -ne 0) { throw "Falha na busca; consulte $logPath" }
            $search = $raw | ConvertFrom-Json
            $raw | Set-Content -LiteralPath (Join-Path $projectRoot "catalog\$($item.slug).candidates.json") -Encoding utf8
            $entries = @($search.entries | Where-Object { $_.id -match '^[A-Za-z0-9_-]{11}$' -and $_.title -match $titlePatterns[$item.slug] -and $_.title -notmatch '(?i)remaster|remake|reignited' })
            if (!$entries.Count) { throw 'A busca nao retornou videos com o nome do jogo. Ajuste a consulta.' }
            $chosen = $entries | Sort-Object @{ Expression = { Get-Score $_ }; Descending = $true } | Select-Object -First 1
            $source = [pscustomobject]@{
                slug = $item.slug; game = $item.game; id = $chosen.id
                url = "https://www.youtube.com/watch?v=$($chosen.id)"
                title = $chosen.title; channel = $chosen.channel; query = $item.query
                sourceDuration = $chosen.duration; start = $item.start; duration = $item.duration
                selection = 'automatic-title-ranking'; visuallyReviewed = $false
                file = ''; downloaded = $false; error = ''
            }
            $sources = @($sources | Where-Object slug -ne $item.slug) + @($source)
            Save-Sources
            Write-Host "FONTE: $($chosen.title) [$($chosen.id)]"
            continue
        }

        $source = $sources | Where-Object slug -eq $item.slug | Select-Object -First 1
        if (!$source) { throw 'Fonte ausente. Execute primeiro -Action Find.' }
        if ($source.id -notmatch '^[A-Za-z0-9_-]{11}$') { throw 'ID de video invalido.' }
        $source.url = "https://www.youtube.com/watch?v=$($source.id)"
        $savedStatusPath = Join-Path $projectRoot "catalog\$($item.slug).download-status.json"
        if (Test-Path -LiteralPath $savedStatusPath) {
            $savedStatus = Get-Content -Raw -LiteralPath $savedStatusPath | ConvertFrom-Json
            if ($savedStatus.id -eq $source.id -and $savedStatus.start -eq $source.start -and $savedStatus.duration -eq $source.duration) { $source = $savedStatus }
        }
        $targetDir = Join-Path $projectRoot "gameplays\$($item.slug)"
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        $targetFile = Join-Path $targetDir "$($item.slug)__$($source.id)__$([int]$source.start).mp4"
        if (!$Force -and $source.downloaded -and (Test-Path -LiteralPath $targetFile)) {
            Write-Host "JA BAIXADO: $($item.game)"
            continue
        }
        $ffmpeg = (Get-Command ffmpeg.exe -ErrorAction Stop).Source
        $metadataPath = Join-Path $projectRoot "catalog\$($item.slug).info.json"
        $metaArgs = $baseArgs + @('--skip-download', '--dump-single-json', $source.url)
        $raw = (& $downloader @metaArgs 2> $logPath | Out-String)
        if ($LASTEXITCODE -ne 0) { throw "Falha ao consultar formatos; consulte $logPath" }
        $info = $raw | ConvertFrom-Json
        $raw | Set-Content -LiteralPath $metadataPath -Encoding utf8
        $source.title = $info.title
        $source.channel = $info.channel
        $source.sourceDuration = $info.duration
        if ($source.start + $source.duration -gt $info.duration) { throw 'O trecho ultrapassa a duracao da fonte. Ajuste sources.json.' }
        $range = "*$($source.start)-$($source.start + $source.duration)"
        Write-Host "BAIXANDO: $($item.game) [$range]"
        $selectors = @(
            "bv[height<=$MaxHeight][vcodec^=avc1]+ba[ext=m4a]/b[height<=$MaxHeight][ext=mp4]/b[height<=$MaxHeight]",
            "bv[protocol=m3u8_native][height<=$MaxHeight][vcodec^=avc1]+ba[protocol=m3u8_native]"
        )
        $complete = $false
        foreach ($selector in $selectors) {
            $downloadArgs = $baseArgs + @(
                '--ffmpeg-location', $ffmpeg, '--download-sections', $range, '-f', $selector,
                '--merge-output-format', 'mp4', '--no-progress', '--force-overwrites', '-o', $targetFile, $source.url
            )
            & $downloader @downloadArgs *> $logPath
            if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $targetFile)) {
                $probeRaw = (& (Get-Command ffprobe.exe).Source -v error -show_entries 'format=duration:stream=codec_type' -of json $targetFile | Out-String)
                if ($LASTEXITCODE -eq 0) {
                    $probe = $probeRaw | ConvertFrom-Json
                    $length = [double]::Parse($probe.format.duration, [Globalization.CultureInfo]::InvariantCulture)
                    $complete = $length -ge ($source.duration - 2) -and @($probe.streams | Where-Object codec_type -eq 'video').Count -gt 0
                    if ($complete) { break }
                }
            }
            Write-Host "Tentando outro formato publico para $($item.game)..."
        }
        if (!$complete) { throw "Download falhou ou ficou incompleto; consulte $logPath" }
        $source.file = $targetFile
        $source.downloaded = $true
        $source.error = ''
        Save-Download $source
        Write-Host "SALVO: $targetFile"
    }
    catch {
        $failedCount++
        Write-Warning "$($item.game): $($_.Exception.Message)"
        $failedSource = $sources | Where-Object slug -eq $item.slug | Select-Object -First 1
        if ($failedSource) { $failedSource.error = $_.Exception.Message; Save-Download $failedSource }
    }
}

if ($Action -eq 'Find') { $sources | Select-Object game, channel, url | Format-Table -AutoSize }
if ($failedCount) { exit 1 }
