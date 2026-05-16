param(
    [string] $OutputDir = "assets/images"
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$size = 1024
$outputPath = Join-Path (Get-Location) $OutputDir
New-Item -ItemType Directory -Force -Path $outputPath | Out-Null

function New-RoundedRectPath([float] $x, [float] $y, [float] $w, [float] $h, [float] $r) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function New-RoundPen([System.Drawing.Color] $color, [float] $width) {
    $pen = [System.Drawing.Pen]::new($color, $width)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    return $pen
}

function New-IconCanvas([bool] $withBackground) {
    $icon = [System.Drawing.Bitmap]::new($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($icon)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    if ($withBackground) {
        $bg = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
            [System.Drawing.Rectangle]::new(0, 0, $size, $size),
            [System.Drawing.Color]::FromArgb(255, 5, 18, 21),
            [System.Drawing.Color]::FromArgb(255, 9, 9, 15),
            135.0
        )
        $g.FillRectangle($bg, 0, 0, $size, $size)
        $bg.Dispose()
    }

    return @{ Icon = $icon; Graphics = $g }
}

function Draw-TerminalTile($graphics) {
    $shadowPath = New-RoundedRectPath 214 214 596 596 128
    $shadowBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(118, 0, 0, 0))
    $graphics.TranslateTransform(0, 20)
    $graphics.FillPath($shadowBrush, $shadowPath)
    $graphics.ResetTransform()
    $shadowBrush.Dispose()
    $shadowPath.Dispose()

    $panelPath = New-RoundedRectPath 214 204 596 596 128
    $panelFill = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.Rectangle]::new(214, 204, 596, 596),
        [System.Drawing.Color]::FromArgb(255, 9, 34, 37),
        [System.Drawing.Color]::FromArgb(255, 5, 13, 19),
        90.0
    )
    $graphics.FillPath($panelFill, $panelPath)
    $panelFill.Dispose()

    $panelPen = New-RoundPen ([System.Drawing.Color]::FromArgb(245, 238, 255, 250)) 20
    $graphics.DrawPath($panelPen, $panelPath)
    $panelPen.Dispose()

    $divider = New-RoundPen ([System.Drawing.Color]::FromArgb(82, 238, 255, 250)) 9
    $graphics.DrawLine($divider, 282, 356, 742, 356)
    $divider.Dispose()

    $dotBrush1 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 85, 245, 137))
    $dotBrush2 = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 252, 170, 82))
    $graphics.FillEllipse($dotBrush1, 310, 294, 40, 40)
    $graphics.FillEllipse($dotBrush2, 372, 294, 40, 40)
    $dotBrush1.Dispose()
    $dotBrush2.Dispose()

    $promptPen = New-RoundPen ([System.Drawing.Color]::FromArgb(255, 242, 255, 252)) 68
    $graphics.DrawLine($promptPen, 360, 456, 458, 512)
    $graphics.DrawLine($promptPen, 458, 512, 360, 568)
    $promptPen.Dispose()

    $cursorPen = New-RoundPen ([System.Drawing.Color]::FromArgb(255, 82, 246, 227)) 58
    $graphics.DrawLine($cursorPen, 536, 568, 704, 568)
    $cursorPen.Dispose()
    $panelPath.Dispose()
}

$full = New-IconCanvas $true
Draw-TerminalTile $full.Graphics
$fullPath = Join-Path $outputPath "orbita_icon.png"
$full.Icon.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
$full.Graphics.Dispose()
$full.Icon.Dispose()

$foreground = New-IconCanvas $false
Draw-TerminalTile $foreground.Graphics
$foregroundPath = Join-Path $outputPath "orbita_icon_foreground.png"
$foreground.Icon.Save($foregroundPath, [System.Drawing.Imaging.ImageFormat]::Png)
$foreground.Graphics.Dispose()
$foreground.Icon.Dispose()

Write-Output "Wrote $fullPath ($size x $size)"
Write-Output "Wrote $foregroundPath ($size x $size)"
