param(
  [string]$GoExe = "go",
  [string]$Out = "android/app/libs/tailproxy.aar",
  [string]$GoMobileVersion = "v0.0.0-20260410095206-2cfb76559b7b"
)

$ErrorActionPreference = "Stop"
function Invoke-Native {
  param(
    [string]$FilePath,
    [string[]]$Arguments
  )
  & $FilePath @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "$FilePath failed with exit code $LASTEXITCODE"
  }
}

$root = Split-Path -Parent $PSScriptRoot
$tailproxy = Join-Path $root "tailproxy"
$outPath = [System.IO.Path]::GetFullPath((Join-Path $root $Out))
$outDir = Split-Path -Parent $outPath
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$goPath = Join-Path $tailproxy ".gopath"
New-Item -ItemType Directory -Force -Path $goPath | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $tailproxy ".gocache") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $tailproxy ".gomodcache") | Out-Null

$env:GOPATH = $goPath
$env:GOCACHE = Join-Path $tailproxy ".gocache"
$env:GOMODCACHE = Join-Path $tailproxy ".gomodcache"

$goParent = Split-Path -Parent $GoExe -ErrorAction SilentlyContinue
if ($goParent) {
  $env:PATH = "$goParent;$env:PATH"
}
$gopath = & $GoExe env GOPATH
$goBin = Join-Path $gopath "bin"
$env:PATH = "$goBin;$env:PATH"
$gomobile = Join-Path $gopath "bin/gomobile.exe"
if (-not (Test-Path -LiteralPath $gomobile)) {
  Invoke-Native $GoExe @(
    "install",
    "golang.org/x/mobile/cmd/gomobile@$GoMobileVersion"
  )
}

Invoke-Native $gomobile @("init")
Push-Location $tailproxy
try {
  Invoke-Native $gomobile @(
    "bind",
    "-target=android",
    "-androidapi=23",
    "-javapkg=top.gabrlie.orbita",
    "-o=$outPath",
    "."
  )
} finally {
  Pop-Location
}
