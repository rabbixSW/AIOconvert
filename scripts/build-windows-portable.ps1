param(
    [ValidateSet("release", "debug")]
    [string]$Mode = "release"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$RootDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$FfmpegVersionUrl = "https://www.gyan.dev/ffmpeg/builds/release-version"
$BuildConfiguration = if ($Mode -eq "release") { "Release" } else { "Debug" }
$RunnerOutput = Join-Path $RootDir "build\windows\x64\runner\$BuildConfiguration"
$BuildDirectory = Join-Path $RootDir "build\windows-portable"
$DownloadDirectory = Join-Path $BuildDirectory "downloads"
$FfmpegArchive = Join-Path $DownloadDirectory "ffmpeg-essentials.zip"
$ExtractDirectory = Join-Path $BuildDirectory "ffmpeg-extracted"
$StagingDirectory = Join-Path $BuildDirectory "AIOconvert"
$OutputDirectory = Join-Path $RootDir "dist"
$VersionLine = Get-Content (Join-Path $RootDir "pubspec.yaml") |
    Where-Object { $_ -match '^version:' } |
    Select-Object -First 1
$AppVersion = if ($VersionLine -match '^version:\s*([^+ ]+)') { $Matches[1] } else { $null }

if (-not $AppVersion) {
    throw "Could not read the app version from pubspec.yaml."
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Flutter was not found on PATH. Install Flutter and reopen PowerShell."
}

$FfmpegVersion = (Invoke-RestMethod -Uri $FfmpegVersionUrl).Trim()
if ($FfmpegVersion -notmatch '^\d+(\.\d+)+$') {
    throw "Unexpected FFmpeg version returned by gyan.dev: $FfmpegVersion"
}
$FfmpegArchiveName = "ffmpeg-$FfmpegVersion-essentials_build.zip"
$FfmpegArchiveUrl = "https://www.gyan.dev/ffmpeg/builds/packages/$FfmpegArchiveName"
$FfmpegChecksumUrl = "$FfmpegArchiveUrl.sha256"

New-Item -ItemType Directory -Force -Path $DownloadDirectory | Out-Null
Invoke-WebRequest -Uri $FfmpegArchiveUrl -OutFile $FfmpegArchive
$ExpectedHash = (Invoke-RestMethod -Uri $FfmpegChecksumUrl).Trim().Split()[0].ToLowerInvariant()
$ActualHash = (Get-FileHash -Path $FfmpegArchive -Algorithm SHA256).Hash.ToLowerInvariant()
if ($ActualHash -ne $ExpectedHash) {
    throw "FFmpeg archive checksum mismatch. Expected $ExpectedHash but received $ActualHash."
}

if (Test-Path $ExtractDirectory) {
    Remove-Item -Path $ExtractDirectory -Recurse -Force
}
Expand-Archive -Path $FfmpegArchive -DestinationPath $ExtractDirectory -Force
$FfmpegExe = Get-ChildItem -Path $ExtractDirectory -Filter ffmpeg.exe -Recurse | Select-Object -First 1
$FfprobeExe = Get-ChildItem -Path $ExtractDirectory -Filter ffprobe.exe -Recurse | Select-Object -First 1
if (-not $FfmpegExe -or -not $FfprobeExe) {
    throw "The verified FFmpeg archive did not contain ffmpeg.exe and ffprobe.exe."
}

Push-Location $RootDir
try {
    & flutter build windows "--$Mode"
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter Windows $Mode build failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}

if (-not (Test-Path (Join-Path $RunnerOutput "AIOconvert.exe"))) {
    throw "Windows build output was not found at $RunnerOutput."
}

if (Test-Path $StagingDirectory) {
    Remove-Item -Path $StagingDirectory -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $StagingDirectory | Out-Null
Copy-Item -Path (Join-Path $RunnerOutput "*") -Destination $StagingDirectory -Recurse -Force
Copy-Item -Path $FfmpegExe.FullName -Destination (Join-Path $StagingDirectory "ffmpeg.exe")
Copy-Item -Path $FfprobeExe.FullName -Destination (Join-Path $StagingDirectory "ffprobe.exe")
$FfmpegLicense = Get-ChildItem -Path $ExtractDirectory -Filter "LICENSE*" -Recurse |
    Select-Object -First 1
if ($FfmpegLicense) {
    Copy-Item -Path $FfmpegLicense.FullName -Destination $StagingDirectory
}
@"
AIOconvert includes FFmpeg $FfmpegVersion from gyan.dev's FFmpeg Essentials build.
These FFmpeg binaries are licensed under GPLv3.

Build source and license information:
https://www.gyan.dev/ffmpeg/builds/
https://ffmpeg.org/legal.html
"@ | Set-Content -Path (Join-Path $StagingDirectory "FFmpeg-NOTICE.txt") -Encoding utf8

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$OutputArchive = Join-Path $OutputDirectory "AIOconvert-$AppVersion-windows-x64-portable.zip"
if (Test-Path $OutputArchive) {
    Remove-Item -Path $OutputArchive -Force
}
Compress-Archive -Path (Join-Path $StagingDirectory "*") -DestinationPath $OutputArchive

Write-Host "Created portable package: $OutputArchive"
Write-Host "Bundled gyan.dev FFmpeg essentials version: $FfmpegVersion (SHA-256 verified)"
