param(
    [string]$InnoSetupCompiler
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$RootDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$FfmpegVersionUrl = "https://www.gyan.dev/ffmpeg/builds/release-version"
$RunnerOutput = Join-Path $RootDir "build\windows\x64\runner\Release"
$BuildDirectory = Join-Path $RootDir "build\windows-installer"
$DownloadDirectory = Join-Path $BuildDirectory "downloads"
$FfmpegArchive = Join-Path $DownloadDirectory "ffmpeg-essentials.zip"
$ExtractDirectory = Join-Path $BuildDirectory "ffmpeg-extracted"
$StagingDirectory = Join-Path $BuildDirectory "AIOconvert"
$OutputDirectory = Join-Path $RootDir "dist"
$InstallerDefinition = Join-Path $PSScriptRoot "windows-installer.iss"
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

if ($InnoSetupCompiler) {
    $CompilerCommand = Get-Command $InnoSetupCompiler -ErrorAction SilentlyContinue
    if (-not $CompilerCommand) {
        throw "Inno Setup compiler was not found: $InnoSetupCompiler"
    }
    $CompilerPath = $CompilerCommand.Source
}
else {
    $CompilerCommand = Get-Command ISCC.exe -ErrorAction SilentlyContinue
    $CompilerPath = if ($CompilerCommand) { $CompilerCommand.Source } else { $null }
    if (-not $CompilerPath) {
        $CompilerCandidates = @(
            (Join-Path ${env:ProgramFiles(x86)} "Inno Setup 6\ISCC.exe"),
            (Join-Path $env:ProgramFiles "Inno Setup 6\ISCC.exe")
        )
        $CompilerPath = $CompilerCandidates |
            Where-Object { Test-Path $_ } |
            Select-Object -First 1
    }
    if (-not $CompilerPath) {
        throw "Inno Setup 6 was not found. Install it or pass -InnoSetupCompiler with the path to ISCC.exe."
    }
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
    & flutter build windows --release
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter Windows release build failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}

if (-not (Test-Path (Join-Path $RunnerOutput "AIOconvert.exe"))) {
    throw "Windows release output was not found at $RunnerOutput."
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
$CompilerArguments = @(
    "/DAppVersion=$AppVersion"
    "/DStagingDir=$StagingDirectory"
    "/DOutputDir=$OutputDirectory"
    "/DProjectDir=$RootDir"
    $InstallerDefinition
)
& $CompilerPath @CompilerArguments
if ($LASTEXITCODE -ne 0) {
    throw "Inno Setup compilation failed with exit code $LASTEXITCODE."
}

$InstallerPath = Join-Path $OutputDirectory "AIOconvert-$AppVersion-windows-x64-setup.exe"
if (-not (Test-Path $InstallerPath)) {
    throw "Installer output was not found at $InstallerPath."
}
Write-Host "Created Windows installer: $InstallerPath"
Write-Host "Bundled gyan.dev FFmpeg Essentials version: $FfmpegVersion (SHA-256 verified)"