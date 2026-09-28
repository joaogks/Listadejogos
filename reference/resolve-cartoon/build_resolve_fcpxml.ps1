param(
  [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$ProjectRoot = [IO.Path]::GetFullPath($ProjectRoot)
$EpisodeDir = Join-Path $ProjectRoot 'episodes'
$OutputDir = Join-Path $ProjectRoot 'outputs'
$SharedAssetsDir = Join-Path $OutputDir 'resolve-assets'
$Ffprobe = 'C:\Users\joao\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-9.0.2-full_build\bin\ffprobe.exe'

if (!(Test-Path -LiteralPath $Ffprobe)) {
  $found = Get-Command ffprobe.exe -ErrorAction SilentlyContinue
  if ($found) { $Ffprobe = $found.Source }
}
if (!(Test-Path -LiteralPath $Ffprobe)) { throw 'ffprobe.exe was not found.' }

function ConvertTo-FcpxmlTime([long]$Frames) {
  return "${Frames}/30s"
}

function Escape-Xml([string]$Value) {
  return [Security.SecurityElement]::Escape($Value)
}

function Get-Probe([string]$Path) {
  $json = (& $Ffprobe -v error -show_entries 'format=duration:stream=codec_type,width,height,avg_frame_rate,sample_rate,channels' -of json $Path | Out-String)
  if ($LASTEXITCODE -ne 0) { throw "ffprobe failed for: $Path" }
  return ($json | ConvertFrom-Json)
}

function New-TextBrush([int]$Alpha = 245, [int]$R = 244, [int]$G = 241, [int]$B = 232) {
  return [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb($Alpha, $R, $G, $B))
}

function Draw-Owl([System.Drawing.Graphics]$Graphics, [single]$X, [single]$Y, [single]$Size, [int]$Alpha = 245) {
  $s = $Size / 100.0
  $cream = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb($Alpha, 239, 236, 226))
  $black = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb($Alpha, 12, 12, 12))
  $white = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb($Alpha, 250, 248, 239))
  $line = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb($Alpha, 12, 12, 12), [Math]::Max(2.0, $Size * 0.045))
  $line.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
  $point = { param([single]$px, [single]$py) [System.Drawing.PointF]::new($X + ($px * $s), $Y + ($py * $s)) }

  $Graphics.FillPolygon($black, [System.Drawing.PointF[]]@((& $point 16 34), (& $point 13 5), (& $point 39 27)))
  $Graphics.FillPolygon($black, [System.Drawing.PointF[]]@((& $point 61 27), (& $point 87 5), (& $point 84 35)))
  $Graphics.FillEllipse($cream, $X + 12*$s, $Y + 19*$s, 76*$s, 70*$s)
  $Graphics.DrawEllipse($line, $X + 12*$s, $Y + 19*$s, 76*$s, 70*$s)
  $Graphics.FillEllipse($white, $X + 24*$s, $Y + 34*$s, 25*$s, 25*$s)
  $Graphics.FillEllipse($white, $X + 51*$s, $Y + 34*$s, 25*$s, 25*$s)
  $Graphics.DrawEllipse($line, $X + 24*$s, $Y + 34*$s, 25*$s, 25*$s)
  $Graphics.DrawEllipse($line, $X + 51*$s, $Y + 34*$s, 25*$s, 25*$s)
  $Graphics.FillEllipse($black, $X + 34*$s, $Y + 42*$s, 7*$s, 9*$s)
  $Graphics.FillEllipse($black, $X + 60*$s, $Y + 42*$s, 7*$s, 9*$s)
  $Graphics.FillPolygon($black, [System.Drawing.PointF[]]@((& $point 50 55), (& $point 43 64), (& $point 57 64)))
  $Graphics.FillPolygon($black, [System.Drawing.PointF[]]@((& $point 38 76), (& $point 50 69), (& $point 62 76), (& $point 50 86)))

  $line.Dispose(); $cream.Dispose(); $black.Dispose(); $white.Dispose()
}

function New-OpeningCard([string]$Path, $Plan) {
  $bitmap = [System.Drawing.Bitmap]::new(1920, 1080, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bitmap)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.Clear([System.Drawing.Color]::FromArgb(9, 9, 9))
  $main = New-TextBrush
  $muted = New-TextBrush 205 188 183 170
  $border = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(85, 244, 241, 232), 2)
  $g.DrawRectangle($border, 28, 28, 1864, 1024)
  Draw-Owl $g 72 57 76

  $smallFont = [System.Drawing.Font]::new('Georgia', 25, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $titleFont = [System.Drawing.Font]::new('Georgia', 43, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $g.DrawString("TONIGHT'S PROGRAM", $smallFont, $muted, 180, 60)
  $g.DrawString([string]$Plan.title, $titleFont, $main, 180, 99)

  $numFont = [System.Drawing.Font]::new('Georgia', 30, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $rowFont = [System.Drawing.Font]::new('Georgia', 30, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $y = 229
  $rowGap = 64
  for ($i = 0; $i -lt $Plan.episodes.Count; $i++) {
    $g.DrawString(('{0:D2}' -f ($i + 1)), $numFont, $muted, 92, $y)
    $g.DrawString([string]$Plan.episodes[$i].title, $rowFont, $main, 158, $y)
    $y += $rowGap
  }

  $smallFont.Dispose(); $titleFont.Dispose(); $numFont.Dispose(); $rowFont.Dispose()
  $main.Dispose(); $muted.Dispose(); $border.Dispose(); $g.Dispose()
  $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png); $bitmap.Dispose()
}

function New-EpisodeCard([string]$Path, $Plan, $Episode, [int]$Index) {
  $bitmap = [System.Drawing.Bitmap]::new(1920, 1080, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bitmap)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.Clear([System.Drawing.Color]::FromArgb(9, 9, 9))
  $main = New-TextBrush
  $muted = New-TextBrush 205 188 183 170
  $border = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(85, 244, 241, 232), 2)
  $format = [System.Drawing.StringFormat]::new()
  $format.Alignment = [System.Drawing.StringAlignment]::Center
  $g.DrawRectangle($border, 28, 28, 1864, 1024)

  $titleFont = [System.Drawing.Font]::new('Georgia', 31, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $g.DrawString([string]$Plan.title, $titleFont, $muted, [System.Drawing.RectangleF]::new(110, 72, 1700, 58), $format)
  Draw-Owl $g 860 230 200

  $episodeFont = [System.Drawing.Font]::new('Georgia', 27, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $g.DrawString(('EPISODE {0:D2} / {1:D2}' -f $Index, $Plan.episodes.Count), $episodeFont, $muted, [System.Drawing.RectangleF]::new(110, 485, 1700, 50), $format)

  $size = 66
  do {
    $episodeFont.Dispose()
    $episodeFont = [System.Drawing.Font]::new('Georgia', $size, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $measured = $g.MeasureString([string]$Episode.title, $episodeFont)
    $size -= 2
  } while ($measured.Width -gt 1580 -and $size -gt 36)
  $g.DrawString([string]$Episode.title, $episodeFont, $main, [System.Drawing.RectangleF]::new(130, 565, 1660, 250), $format)

  $titleFont.Dispose(); $episodeFont.Dispose(); $main.Dispose(); $muted.Dispose(); $border.Dispose(); $format.Dispose(); $g.Dispose()
  $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png); $bitmap.Dispose()
}

function New-FilmTreatment([string]$Path) {
  $bitmap = [System.Drawing.Bitmap]::new(1920, 1080, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bitmap)
  $g.Clear([System.Drawing.Color]::Transparent)
  $random = [System.Random]::new(240924)
  $top = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.Rectangle]::new(0, 0, 1920, 180), [System.Drawing.Color]::FromArgb(95, 0, 0, 0), [System.Drawing.Color]::FromArgb(0, 0, 0, 0), [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
  $bottom = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.Rectangle]::new(0, 900, 1920, 180), [System.Drawing.Color]::FromArgb(0, 0, 0, 0), [System.Drawing.Color]::FromArgb(95, 0, 0, 0), [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
  $left = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.Rectangle]::new(0, 0, 150, 1080), [System.Drawing.Color]::FromArgb(105, 0, 0, 0), [System.Drawing.Color]::FromArgb(0, 0, 0, 0), [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal)
  $right = [System.Drawing.Drawing2D.LinearGradientBrush]::new([System.Drawing.Rectangle]::new(1770, 0, 150, 1080), [System.Drawing.Color]::FromArgb(0, 0, 0, 0), [System.Drawing.Color]::FromArgb(105, 0, 0, 0), [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal)
  $g.FillRectangle($top, 0, 0, 1920, 180)
  $g.FillRectangle($bottom, 0, 900, 1920, 180)
  $g.FillRectangle($left, 0, 0, 150, 1080)
  $g.FillRectangle($right, 1770, 0, 150, 1080)
  for ($i = 0; $i -lt 1600; $i++) {
    $alpha = $random.Next(7, 20)
    $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb($alpha, 242, 237, 220))
    $g.FillRectangle($brush, $random.Next(0, 1920), $random.Next(0, 1080), $random.Next(1, 3), $random.Next(1, 3))
    $brush.Dispose()
  }
  $scratch = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(19, 244, 241, 232), 1)
  for ($i = 0; $i -lt 7; $i++) {
    $x = $random.Next(70, 1850)
    $y = $random.Next(0, 1070)
    $g.DrawLine($scratch, $x, $y, $x + $random.Next(-2, 3), [Math]::Min(1079, $y + $random.Next(18, 90)))
  }
  $top.Dispose(); $bottom.Dispose(); $left.Dispose(); $right.Dispose(); $scratch.Dispose(); $g.Dispose()
  $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png); $bitmap.Dispose()
}

function New-OwlWatermark([string]$Path) {
  $bitmap = [System.Drawing.Bitmap]::new(1920, 1080, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bitmap)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::Transparent)
  Draw-Owl $g 1747 897 118 205
  $g.Dispose(); $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png); $bitmap.Dispose()
}

function New-BlackFrame([string]$Path) {
  $bitmap = [System.Drawing.Bitmap]::new(1920, 1080, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bitmap)
  $g.Clear([System.Drawing.Color]::Black)
  $g.Dispose(); $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png); $bitmap.Dispose()
}

function New-Element([System.Xml.XmlDocument]$Document, [System.Xml.XmlNode]$Parent, [string]$Name, [hashtable]$Attributes = @{}) {
  $element = $Document.CreateElement($Name)
  foreach ($key in $Attributes.Keys) { $element.SetAttribute($key, [string]$Attributes[$key]) }
  [void]$Parent.AppendChild($element)
  return $element
}

function Add-BlendFade([System.Xml.XmlDocument]$Document, [System.Xml.XmlNode]$Clip, [long]$FadeIn, [long]$FadeOut, [double]$Base = 1.0) {
  $blend = New-Element $Document $Clip 'adjust-blend' @{ amount = ([string]$Base) }
  if ($FadeIn -gt 0 -or $FadeOut -gt 0) {
    $param = New-Element $Document $blend 'param' @{ name = 'amount'; value = ([string]$Base) }
    if ($FadeIn -gt 0) { [void](New-Element $Document $param 'fadeIn' @{ duration = (ConvertTo-FcpxmlTime $FadeIn); type = 'linear' }) }
    if ($FadeOut -gt 0) { [void](New-Element $Document $param 'fadeOut' @{ duration = (ConvertTo-FcpxmlTime $FadeOut); type = 'linear' }) }
  }
}

function Add-VolumeFade([System.Xml.XmlDocument]$Document, [System.Xml.XmlNode]$Clip, [double]$Gain, [long]$FadeIn, [long]$FadeOut) {
  $gainDb = if ($Gain -le 0) { '-96dB' } else { [string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0:0.####}dB', (20 * [Math]::Log10($Gain))) }
  $adjust = New-Element $Document $Clip 'adjust-volume' @{ amount = $gainDb }
  if ($FadeIn -gt 0 -or $FadeOut -gt 0) {
    $param = New-Element $Document $adjust 'param' @{ name = 'amount'; value = $gainDb }
    if ($FadeIn -gt 0) { [void](New-Element $Document $param 'fadeIn' @{ duration = (ConvertTo-FcpxmlTime $FadeIn); type = 'linear' }) }
    if ($FadeOut -gt 0) { [void](New-Element $Document $param 'fadeOut' @{ duration = (ConvertTo-FcpxmlTime $FadeOut); type = 'linear' }) }
  }
}

function Get-SourceRef([System.Xml.XmlDocument]$Document, [System.Xml.XmlNode]$Resources, [string]$Path, [hashtable]$ResourceIds, [hashtable]$ProbeCache, [ref]$NextId, [string]$Kind) {
  $fullPath = [IO.Path]::GetFullPath($Path)
  if (!(Test-Path -LiteralPath $fullPath)) { throw "Missing media asset: $fullPath" }
  if ($ResourceIds.ContainsKey($fullPath)) { return $ResourceIds[$fullPath] }
  if (!$ProbeCache.ContainsKey($fullPath)) { $ProbeCache[$fullPath] = Get-Probe $fullPath }
  $probe = $ProbeCache[$fullPath]
  $id = 'r' + $NextId.Value
  $NextId.Value++
  $name = [IO.Path]::GetFileName($fullPath)
  $attrs = @{ id = $id; name = $name; start = '0s' }
  $video = @($probe.streams | Where-Object codec_type -eq 'video' | Select-Object -First 1)
  $audio = @($probe.streams | Where-Object codec_type -eq 'audio' | Select-Object -First 1)

  if ($Kind -eq 'still') {
    $attrs.hasVideo = '1'; $attrs.hasAudio = '0'; $attrs.format = 'r1'; $attrs.videoSources = '1'; $attrs.duration = '1/30s'
  } elseif ($Kind -eq 'audio') {
    $attrs.hasVideo = '0'; $attrs.hasAudio = '1'; $attrs.audioSources = '1'
    if ($audio.Count -gt 0) {
      if ($audio[0].channels) { $attrs.audioChannels = [string]$audio[0].channels }
      switch ([string]$audio[0].sample_rate) {
        '32000' { $attrs.audioRate = '32k' }
        '44100' { $attrs.audioRate = '44.1k' }
        '48000' { $attrs.audioRate = '48k' }
        '88200' { $attrs.audioRate = '88.2k' }
        '96000' { $attrs.audioRate = '96k' }
        '176400' { $attrs.audioRate = '176.4k' }
        '192000' { $attrs.audioRate = '192k' }
      }
    }
  } else {
    if ($video.Count -eq 0) { throw "Expected video media, found none: $fullPath" }
    $attrs.hasVideo = '1'; $attrs.videoSources = '1'; $attrs.duration = (ConvertTo-FcpxmlTime ([long][Math]::Ceiling([double]$probe.format.duration * 30)))
    if ($audio.Count -gt 0) {
      $attrs.hasAudio = '1'; $attrs.audioSources = '1'
      if ($audio[0].channels) { $attrs.audioChannels = [string]$audio[0].channels }
      switch ([string]$audio[0].sample_rate) {
        '32000' { $attrs.audioRate = '32k' }
        '44100' { $attrs.audioRate = '44.1k' }
        '48000' { $attrs.audioRate = '48k' }
        '88200' { $attrs.audioRate = '88.2k' }
        '96000' { $attrs.audioRate = '96k' }
        '176400' { $attrs.audioRate = '176.4k' }
        '192000' { $attrs.audioRate = '192k' }
      }
    } else { $attrs.hasAudio = '0' }
  }

  # For stills, the source duration is short; the timeline clip supplies the hold length.
  $asset = New-Element $Document $Resources 'asset' $attrs
  $uri = ([System.Uri]$fullPath).AbsoluteUri
  [void](New-Element $Document $asset 'media-rep' @{ kind = 'original-media'; src = $uri })
  $ResourceIds[$fullPath] = $id
  return $id
}

function Get-EffectiveTrackPlan($Plan, [string]$BasePath, [hashtable]$ProbeCache) {
  $positioned = @()
  foreach ($track in $Plan.music) {
    $path = [IO.Path]::GetFullPath((Join-Path (Join-Path $BasePath 'public') ([string]$track.src).Replace('/', '\')))
    if (!$ProbeCache.ContainsKey($path)) { $ProbeCache[$path] = Get-Probe $path }
    $actualFrames = [long][Math]::Ceiling(([double]$ProbeCache[$path].format.duration * 30) - 0.0000001)
    $duration = [Math]::Max([long]$track.durationInFrames, $actualFrames)
    $previous = if ($positioned.Count) { $positioned[$positioned.Count - 1] } else { $null }
    $from = if (!$previous) { 0L } elseif ($null -ne $track.PSObject.Properties['fromFrame']) { [long]$track.fromFrame } else { $previous.fromFrame + $previous.durationInFrames - [Math]::Min(45, [Math]::Min($previous.durationInFrames, $duration)) }
    $positioned += [pscustomobject]@{ source = $track; fullPath = $path; fromFrame = $from; durationInFrames = $duration; gain = [double]$track.gain }
  }

  for ($i = 0; $i -lt $positioned.Count; $i++) {
    $previous = if ($i -gt 0) { $positioned[$i - 1] } else { $null }
    $next = if ($i + 1 -lt $positioned.Count) { $positioned[$i + 1] } else { $null }
    $before = if ($previous) { [Math]::Max(0, [Math]::Min($positioned[$i].durationInFrames, $previous.fromFrame + $previous.durationInFrames - $positioned[$i].fromFrame)) } else { 0 }
    $after = if ($next) { [Math]::Max(0, [Math]::Min($positioned[$i].durationInFrames, $positioned[$i].fromFrame + $positioned[$i].durationInFrames - $next.fromFrame)) } else { 0 }
    $positioned[$i] | Add-Member -NotePropertyName fadeInFrames -NotePropertyValue ([long]$before) -Force
    $positioned[$i] | Add-Member -NotePropertyName fadeOutFrames -NotePropertyValue ([long]$after) -Force
  }
  return ,$positioned
}

function New-Timeline([string]$PlanPath, [hashtable]$SharedRefs, [hashtable]$SharedProbeCache) {
  $plan = Get-Content -LiteralPath $PlanPath -Raw -Encoding UTF8 | ConvertFrom-Json
  $slug = [IO.Path]::GetFileNameWithoutExtension($PlanPath)
  $resolveDir = Join-Path (Join-Path $OutputDir $slug) 'resolve'
  $cardsDir = Join-Path $resolveDir 'assets'
  [void](New-Item -ItemType Directory -Force -Path $cardsDir)

  # Keep the episode lineup brief; music and picture both start at frame zero.
  $requestedOpeningFrames = if ($null -ne $plan.PSObject.Properties['openingListFrames']) { [long]$plan.openingListFrames } else { 150L }
  $openingFrames = [Math]::Min(150L, [Math]::Max(1L, $requestedOpeningFrames))
  $introFrames = [long]$plan.episodeIntroFrames
  $endingFadeFrames = [long]$plan.endingFadeFrames
  $tracks = Get-EffectiveTrackPlan $plan $ProjectRoot $SharedProbeCache
  $musicFrames = 0L
  foreach ($track in $tracks) { $musicFrames = [Math]::Max($musicFrames, $track.fromFrame + $track.durationInFrames) }
  $minimumMusicFrames = if ($null -ne $plan.PSObject.Properties['minimumMusicDurationInFrames']) { [long]$plan.minimumMusicDurationInFrames } else { 0L }
  if ($minimumMusicFrames -gt 0 -and $musicFrames -lt $minimumMusicFrames) {
    throw "The complete music mix for $slug is below its configured minimum. Add complete tracks; do not shorten them."
  }
  $visualFrames = 0L
  foreach ($episode in $plan.episodes) { $visualFrames += $introFrames + [long]$episode.durationInFrames }
  $programFrames = [Math]::Min($visualFrames, [Math]::Max(0L, $musicFrames - $openingFrames))
  $totalFrames = $openingFrames + $programFrames
  if ($musicFrames -le $openingFrames -or $totalFrames -lt $musicFrames) {
    throw "Not enough cartoon footage to cover every complete music track after the opening: $slug"
  }

  $openingPath = Join-Path $cardsDir 'opening-program.png'
  New-OpeningCard $openingPath $plan
  $episodeCardPaths = @()
  for ($i = 0; $i -lt $plan.episodes.Count; $i++) {
    $cardPath = Join-Path $cardsDir ('episode-{0:D2}.png' -f ($i + 1))
    New-EpisodeCard $cardPath $plan $plan.episodes[$i] ($i + 1)
    $episodeCardPaths += $cardPath
  }

  $doc = [System.Xml.XmlDocument]::new()
  $doc.PreserveWhitespace = $false
  [void]$doc.AppendChild($doc.CreateDocumentType('fcpxml', $null, $null, $null))
  $root = New-Element $doc $doc 'fcpxml' @{ version = '1.9' }
  $resources = New-Element $doc $root 'resources' @{}
  [void](New-Element $doc $resources 'format' @{ id = 'r1'; name = 'FFVideoFormat1080p30'; width = '1920'; height = '1080'; frameDuration = '1/30s' })
  $resourceIds = @{}
  $probeCache = @{}
  foreach ($key in $SharedProbeCache.Keys) { $probeCache[$key] = $SharedProbeCache[$key] }
  $nextId = 2

  $openingRef = Get-SourceRef $doc $resources $openingPath $resourceIds $probeCache ([ref]$nextId) 'still'
  $filmRef = Get-SourceRef $doc $resources $SharedRefs.film $resourceIds $probeCache ([ref]$nextId) 'still'
  $owlRef = Get-SourceRef $doc $resources $SharedRefs.owl $resourceIds $probeCache ([ref]$nextId) 'still'
  $blackRef = Get-SourceRef $doc $resources $SharedRefs.black $resourceIds $probeCache ([ref]$nextId) 'still'
  $episodeRefs = @()
  foreach ($episode in $plan.episodes) {
    $mediaPath = Join-Path (Join-Path $ProjectRoot 'production-public') ([string]$episode.src).Replace('/', '\')
    $episodeRefs += Get-SourceRef $doc $resources $mediaPath $resourceIds $probeCache ([ref]$nextId) 'video'
  }
  $trackRefs = @()
  foreach ($track in $tracks) { $trackRefs += Get-SourceRef $doc $resources $track.fullPath $resourceIds $probeCache ([ref]$nextId) 'audio' }

  $event = New-Element $doc $root 'event' @{ name = 'Cartoon Jazz' }
  $project = New-Element $doc $event 'project' @{ name = [string]$plan.title }
  $sequence = New-Element $doc $project 'sequence' @{ format = 'r1'; duration = (ConvertTo-FcpxmlTime $totalFrames); tcStart = '0s'; tcFormat = 'NDF'; audioLayout = 'stereo'; audioRate = '48k' }
  $spine = New-Element $doc $sequence 'spine' @{}
  $gap = New-Element $doc $spine 'gap' @{ name = 'Black primary timeline'; duration = (ConvertTo-FcpxmlTime $totalFrames) }
  $items = [System.Collections.Generic.List[object]]::new()

  $items.Add([pscustomobject]@{ offset = 0L; lane = 1; type = 'opening'; ref = $openingRef; duration = $openingFrames; name = 'Episode list'; source = $openingPath; fadeIn = 24L; fadeOut = 0L })
  $visualCursor = 0L
  for ($i = 0; $i -lt $plan.episodes.Count; $i++) {
    if ($visualCursor -ge $programFrames) { break }
    $episode = $plan.episodes[$i]
    $thisIntro = [Math]::Min($introFrames, $programFrames - $visualCursor)
    if ($thisIntro -gt 0) {
      $items.Add([pscustomobject]@{ offset = $openingFrames + $visualCursor; lane = 1; type = 'still'; ref = (Get-SourceRef $doc $resources $episodeCardPaths[$i] $resourceIds $probeCache ([ref]$nextId) 'still'); duration = $thisIntro; name = ('Episode {0:D2} title card' -f ($i + 1)); source = $episodeCardPaths[$i]; fadeIn = [Math]::Min(18, $thisIntro); fadeOut = [Math]::Min(18, $thisIntro) })
    }
    $visualCursor += $thisIntro
    if ($thisIntro -lt $introFrames -or $visualCursor -ge $programFrames) { break }
    $clipFrames = [Math]::Min([long]$episode.durationInFrames, $programFrames - $visualCursor)
    if ($clipFrames -gt 0) {
      $clipOffset = $openingFrames + $visualCursor
      $fadeOut = if ($visualCursor + $clipFrames -lt $programFrames) { [Math]::Min(18, $clipFrames) } else { 0L }
      $items.Add([pscustomobject]@{ offset = $clipOffset; lane = 1; type = 'video'; ref = $episodeRefs[$i]; duration = $clipFrames; name = [string]$episode.title; source = [string]$episode.src; start = [long]$episode.trimBefore; fadeIn = [Math]::Min(18, $clipFrames); fadeOut = $fadeOut })
      $owlFadeOut = if ($visualCursor + $clipFrames -lt $programFrames) { [Math]::Min(18, $clipFrames) } else { [Math]::Min($endingFadeFrames, $clipFrames) }
      $items.Add([pscustomobject]@{ offset = $clipOffset; lane = 3; type = 'owl'; ref = $owlRef; duration = $clipFrames; name = 'Owl watermark'; source = $SharedRefs.owl; fadeIn = [Math]::Min(18, $clipFrames); fadeOut = $owlFadeOut })
    }
    $visualCursor += $clipFrames
  }

  $items.Add([pscustomobject]@{ offset = 0L; lane = 2; type = 'overlay'; ref = $filmRef; duration = $totalFrames; name = 'Film grain and vignette'; source = $SharedRefs.film; fadeIn = 0L; fadeOut = 0L })
  foreach ($i in 0..($tracks.Count - 1)) {
    $track = $tracks[$i]
    $fadeOut = $track.fadeOutFrames
    if ($i -eq $tracks.Count - 1) { $fadeOut = [Math]::Min($endingFadeFrames, $track.durationInFrames) }
    $items.Add([pscustomobject]@{ offset = $track.fromFrame; lane = if (($i % 2) -eq 0) { -1 } else { -2 }; type = 'audio'; ref = $trackRefs[$i]; duration = $track.durationInFrames; name = [IO.Path]::GetFileName($track.fullPath); source = $track.fullPath; start = [long]$track.source.trimBefore; fadeIn = $track.fadeInFrames; fadeOut = $fadeOut; gain = $track.gain })
  }
  $items.Add([pscustomobject]@{ offset = $totalFrames - $endingFadeFrames; lane = 4; type = 'black'; ref = $blackRef; duration = $endingFadeFrames; name = 'Synchronized fade to black'; source = $SharedRefs.black; fadeIn = $endingFadeFrames; fadeOut = 0L })

  foreach ($item in ($items | Sort-Object offset, lane)) {
    $clipStart = if ($item.PSObject.Properties['start']) { ConvertTo-FcpxmlTime ([long]$item.start) } else { '0s' }
    $clipAttrs = @{ name = [string]$item.name; ref = [string]$item.ref; offset = (ConvertTo-FcpxmlTime ([long]$item.offset)); lane = [string]$item.lane; start = $clipStart; duration = (ConvertTo-FcpxmlTime ([long]$item.duration)) }
    if ($item.type -eq 'video') { $clipAttrs.srcEnable = 'video' }
    if ($item.type -eq 'audio') { $clipAttrs.srcEnable = 'audio' }
    $clip = New-Element $doc $gap 'asset-clip' $clipAttrs
    if ($item.type -eq 'video') { [void](New-Element $doc $clip 'adjust-conform' @{ type = 'fit' }) }
    if ($item.type -in @('opening', 'still', 'video', 'black')) {
      $base = if ($item.type -eq 'black') { 1.0 } else { 1.0 }
      Add-BlendFade $doc $clip ([long]$item.fadeIn) ([long]$item.fadeOut) $base
    }
    if ($item.type -eq 'audio') { Add-VolumeFade $doc $clip ([double]$item.gain) ([long]$item.fadeIn) ([long]$item.fadeOut) }
  }

  $settings = [System.Xml.XmlWriterSettings]::new()
  $settings.Encoding = [System.Text.UTF8Encoding]::new($false)
  $settings.Indent = $true
  $settings.IndentChars = '  '
  $settings.NewLineChars = "`n"
  $xmlPath = Join-Path $resolveDir ($slug + '.fcpxml')
  $writer = [System.Xml.XmlWriter]::Create($xmlPath, $settings)
  $doc.Save($writer); $writer.Dispose()

  $manifest = [ordered]@{
    slug = $slug
    title = [string]$plan.title
    timeline = [IO.Path]::GetFullPath($xmlPath)
    fps = 30
    width = 1920
    height = 1080
    durationInFrames = $totalFrames
    durationSeconds = [Math]::Round($totalFrames / 30.0, 3)
    minimumMusicDurationInFrames = $minimumMusicFrames
    songsComplete = $true
    songCount = $tracks.Count
    songs = @($tracks | ForEach-Object { [ordered]@{ title = $_.source.id; file = $_.fullPath; plannedFrames = [long]$_.source.durationInFrames; timelineFrames = [long]$_.durationInFrames; offsetFrames = [long]$_.fromFrame } })
    episodes = @($plan.episodes | ForEach-Object { [ordered]@{ title = $_.title; source = (Join-Path (Join-Path $ProjectRoot 'production-public') ([string]$_.src).Replace('/', '\')) } })
    note = 'Intermediate FCPXML 1.9 with local media paths; consumed by prepare_resolve_api.py and not imported in this Resolve installation.'
  }
  $manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $resolveDir 'timeline-manifest.json') -Encoding UTF8

  return [pscustomobject]@{ slug = $slug; title = [string]$plan.title; xml = $xmlPath; frames = $totalFrames; minutes = [Math]::Round($totalFrames / 1800.0, 2); tracks = $tracks.Count; cartoons = $plan.episodes.Count }
}

[void](New-Item -ItemType Directory -Force -Path $SharedAssetsDir)
$sharedRefs = @{
  film = Join-Path $SharedAssetsDir 'film-treatment.png'
  owl = Join-Path $SharedAssetsDir 'owl-watermark.png'
  black = Join-Path $SharedAssetsDir 'black.png'
}
if (!(Test-Path -LiteralPath $sharedRefs.film)) { New-FilmTreatment $sharedRefs.film }
if (!(Test-Path -LiteralPath $sharedRefs.owl)) { New-OwlWatermark $sharedRefs.owl }
if (!(Test-Path -LiteralPath $sharedRefs.black)) { New-BlackFrame $sharedRefs.black }

$sharedProbeCache = @{}
$planFiles = @(Get-ChildItem -LiteralPath $EpisodeDir -File -Filter '*.json' | Where-Object Name -Match '^\d{2}-.*\.json$' | Sort-Object Name)
if ($planFiles.Count -ne 10) { throw "Expected 10 numbered episode plans, found $($planFiles.Count)." }
$result = foreach ($planFile in $planFiles) { New-Timeline $planFile.FullName $sharedRefs $sharedProbeCache }
$result | Format-Table -AutoSize
Write-Output "`nTimelines and title cards saved below outputs/<video>/resolve/."
