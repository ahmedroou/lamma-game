# Resize the generated artwork into native launcher assets. No package required.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$appRoot = Split-Path $PSScriptRoot -Parent
$artRoot = Join-Path $appRoot 'design_sources/app_icon'
$iconSource = [System.Drawing.Image]::FromFile((Join-Path $artRoot 'generated-icon.png'))
$foregroundSource = [System.Drawing.Image]::FromFile((Join-Path $artRoot 'generated-foreground.png'))

function Save-Icon([System.Drawing.Image]$Source, [int]$Size, [string]$RelativePath, [double]$Scale = 1, [bool]$Transparent = $false) {
    $destination = Join-Path $appRoot $RelativePath
    [System.IO.Directory]::CreateDirectory((Split-Path $destination -Parent)) | Out-Null
    $format = if ($Transparent) { [System.Drawing.Imaging.PixelFormat]::Format32bppArgb } else { [System.Drawing.Imaging.PixelFormat]::Format24bppRgb }
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, $format)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $attributes = [System.Drawing.Imaging.ImageAttributes]::new()
    try {
        if ($Transparent) { $graphics.Clear([System.Drawing.Color]::Transparent) }
        else { $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml('#101215')) }
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $attributes.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)
        $edge = [int][Math]::Round($Size * $Scale)
        $offset = [int][Math]::Round(($Size - $edge) / 2)
        $rect = [System.Drawing.Rectangle]::new($offset, $offset, $edge, $edge)
        $graphics.DrawImage($Source, $rect, 0, 0, $Source.Width, $Source.Height, [System.Drawing.GraphicsUnit]::Pixel, $attributes)
        $bitmap.Save($destination, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $attributes.Dispose(); $graphics.Dispose(); $bitmap.Dispose()
    }
}

try {
    Save-Icon $iconSource 1024 'design_sources/app_icon/lamma-icon-1024.png'
    Save-Icon $iconSource 512 'design_sources/app_icon/play-store-icon-512.png'
    foreach ($density in @(
        @{ Name = 'mdpi'; Legacy = 48; Adaptive = 108 },
        @{ Name = 'hdpi'; Legacy = 72; Adaptive = 162 },
        @{ Name = 'xhdpi'; Legacy = 96; Adaptive = 216 },
        @{ Name = 'xxhdpi'; Legacy = 144; Adaptive = 324 },
        @{ Name = 'xxxhdpi'; Legacy = 192; Adaptive = 432 }
    )) {
        $folder = "android/app/src/main/res/mipmap-$($density.Name)"
        Save-Icon $iconSource $density.Legacy "$folder/ic_launcher.png"
        # The generated emblem spans about 72% of its canvas. 0.80 keeps it
        # within Android's central 66dp safe area in a 108dp foreground layer.
        Save-Icon $foregroundSource $density.Adaptive "$folder/ic_launcher_foreground.png" 0.80 $true
    }
    $iosFolder = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    $catalog = Get-Content -LiteralPath (Join-Path $appRoot "$iosFolder/Contents.json") -Raw | ConvertFrom-Json
    foreach ($entry in $catalog.images) {
        $points = [double]::Parse(($entry.size -split 'x')[0], [System.Globalization.CultureInfo]::InvariantCulture)
        $multiplier = [double]::Parse(($entry.scale -replace 'x$', ''), [System.Globalization.CultureInfo]::InvariantCulture)
        Save-Icon $iconSource ([int][Math]::Round($points * $multiplier)) "$iosFolder/$($entry.filename)"
    }
    foreach ($size in @(192, 512)) {
        Save-Icon $iconSource $size "web/icons/Icon-$size.png"
        Save-Icon $foregroundSource $size "web/icons/Icon-maskable-$size.png" 0.90
    }
    Save-Icon $iconSource 180 'web/icons/apple-touch-icon.png'
    Save-Icon $iconSource 32 'web/favicon.png'
} finally {
    $iconSource.Dispose(); $foregroundSource.Dispose()
}
Write-Output 'Generated Android, iOS and web launcher assets.'
