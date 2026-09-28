$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$games = @(Get-Content -Raw (Join-Path $projectRoot 'catalog\games.json') | ConvertFrom-Json)
$ffprobe = (Get-Command ffprobe.exe).Source
$ffmpeg = (Get-Command ffmpeg.exe).Source
$previewDir = Join-Path $projectRoot 'previews'
New-Item -ItemType Directory -Path $previewDir -Force | Out-Null
$catalog = @()

foreach ($game in $games) {
    $statusPath = Join-Path $projectRoot "catalog\$($game.slug).download-status.json"
    if (!(Test-Path -LiteralPath $statusPath)) { continue }
    $source = Get-Content -Raw -LiteralPath $statusPath | ConvertFrom-Json
    if (!$source.downloaded -or !(Test-Path -LiteralPath $source.file)) { continue }
    $probeRaw = (& $ffprobe -v error -show_entries 'format=duration:stream=codec_name,codec_type,width,height,avg_frame_rate' -of json $source.file | Out-String)
    if ($LASTEXITCODE -ne 0) { throw "Arquivo invalido: $($source.file)" }
    $probe = $probeRaw | ConvertFrom-Json
    $video = $probe.streams | Where-Object codec_type -eq 'video' | Select-Object -First 1
    $audio = $probe.streams | Where-Object codec_type -eq 'audio' | Select-Object -First 1
    $length = [double]::Parse($probe.format.duration, [Globalization.CultureInfo]::InvariantCulture)
    if (!$video -or !$audio -or $length -lt ($source.duration - 2)) { throw "Video/audio incompleto: $($source.file)" }
    foreach ($second in @(20,60,100)) {
        $imagePath = Join-Path $previewDir "$($game.slug)-$second.jpg"
        & $ffmpeg -y -v error -ss $second -i $source.file -frames:v 1 -vf 'scale=320:240:force_original_aspect_ratio=decrease,pad=320:240:(ow-iw)/2:(oh-ih)/2' $imagePath
        if ($LASTEXITCODE -ne 0) { throw "Falha ao extrair imagem: $($game.game)" }
    }
    $catalog += [pscustomobject]@{
        slug = $game.slug; game = $game.game; src = $source.file
        sourceUrl = $source.url; sourceTitle = $source.title; channel = $source.channel
        sourceStartSeconds = $source.start; requestedDurationSeconds = $source.duration
        durationSeconds = $length; durationInFrames30fps = [int][Math]::Floor($length * 30)
        width = $video.width; height = $video.height; sourceFrameRate = $video.avg_frame_rate
        videoCodec = $video.codec_name; audioCodec = $audio.codec_name
        poster = Join-Path $previewDir "$($game.slug)-60.jpg"
        visuallyReviewed = $source.visuallyReviewed
        visualReviewMethod = $source.visualReviewMethod; reviewNotes = $source.reviewNotes
        sourceNotes = $source.sourceNotes
    }
}

ConvertTo-Json -InputObject $catalog -Depth 8 | Set-Content -LiteralPath (Join-Path $projectRoot 'catalog\gameplays.json') -Encoding utf8
Add-Type -AssemblyName System.Drawing
$font = [Drawing.Font]::new('Segoe UI', 16, [Drawing.FontStyle]::Regular, [Drawing.GraphicsUnit]::Pixel)
$brush = [Drawing.SolidBrush]::new([Drawing.Color]::White)
for ($first = 0; $first -lt $catalog.Count; $first += 6) {
    $count = [Math]::Min(6, $catalog.Count - $first)
    $bitmap = [Drawing.Bitmap]::new(960, $count * 285)
    $graphics = [Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([Drawing.Color]::FromArgb(22,22,22))
    for ($row = 0; $row -lt $count; $row++) {
        $entry = $catalog[$first + $row]
        $y = $row * 285
        $graphics.DrawString("$($entry.game) | $($entry.channel) | frames em 20s / 60s / 100s", $font, $brush, 10, $y + 9)
        $column = 0
        foreach ($second in @(20,60,100)) {
            $frame = [Drawing.Image]::FromFile((Join-Path $previewDir "$($entry.slug)-$second.jpg"))
            $graphics.DrawImage($frame, $column * 320, $y + 40, 320, 240)
            $frame.Dispose()
            $column++
        }
    }
    $sheetPath = Join-Path $previewDir ('gameplay-sheet-{0:D2}.jpg' -f ([int]($first / 6) + 1))
    $bitmap.Save($sheetPath, [Drawing.Imaging.ImageFormat]::Jpeg)
    $graphics.Dispose(); $bitmap.Dispose()
}
$font.Dispose(); $brush.Dispose()
Write-Host "Catalogo verificado: $($catalog.Count)/$($games.Count) jogos."
$catalog | Select-Object game,durationSeconds,width,height,videoCodec,audioCodec | Format-Table -AutoSize
