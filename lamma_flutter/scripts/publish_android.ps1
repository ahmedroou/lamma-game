param(
    [string]$NotesPath = 'RELEASE_NOTES.md',
    [string]$FlutterPath = 'C:\Users\Admin\.cache\flutter-celebrations-sdk\bin\flutter.bat',
    [string]$JavaHome = 'C:\Users\Admin\.cache\haseela-build\ms-java\jdk-21.0.12.1+1',
    [string]$AndroidSdk = 'C:\Users\Admin\.cache\haseela-build\android-sdk'
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$originalLocation = Get-Location
function Run-Native([string]$program, [string[]]$arguments) {
    & $program @arguments
    if ($LASTEXITCODE -ne 0) { throw "Failed: $program" }
}
try {
    Set-Location -LiteralPath $projectRoot
    $versionMatch = [regex]::Match((Get-Content pubspec.yaml -Raw), '(?m)^version:\s*(\d+\.\d+\.\d+)\+([1-9]\d*)\s*$')
    if (-not $versionMatch.Success) { throw 'Use VERSION+BUILD in pubspec.yaml.' }
    $versionName = $versionMatch.Groups[1].Value
    $buildNumber = $versionMatch.Groups[2].Value
    $tag = "v$versionName+$buildNumber"
    $repo = 'ahmedroou/lamma-game'
    $notesFile = (Resolve-Path -LiteralPath $NotesPath).Path
    if (-not (Test-Path android/key.properties)) { throw 'Missing permanent release signing configuration.' }
    $env:JAVA_HOME = $JavaHome
    $env:ANDROID_HOME = $AndroidSdk
    $trackedChanges = & git status --porcelain --untracked-files=no
    if ($LASTEXITCODE -ne 0 -or $trackedChanges) { throw 'Commit reviewed source changes before publishing.' }
    $sourceCommit = (& git rev-parse HEAD).Trim()
    Run-Native 'git' @('push','origin','HEAD')
    $existing = & gh api "repos/$repo/releases" --jq '.[].tag_name'
    if ($LASTEXITCODE -ne 0) { throw 'Could not list releases.' }
    if ($existing -contains $tag) { throw 'This tag already exists; increase BUILD. Never replace a published APK.' }
    Run-Native $FlutterPath @('build','apk','--release')
    $apkSource = Join-Path $projectRoot 'build/app/outputs/flutter-apk/app-release.apk'
    $buildTools = Join-Path $AndroidSdk 'build-tools/36.0.0'
    Run-Native (Join-Path $buildTools 'apksigner.bat') @('verify','--verbose',$apkSource)
    $badging = & (Join-Path $buildTools 'aapt.exe') dump badging $apkSource
    if ($LASTEXITCODE -ne 0 -or -not ($badging[0] -match "name='com.lamma.lamma' versionCode='$buildNumber' versionName='$versionName'")) { throw 'APK package or version differs from release source.' }
    $outputDir = Join-Path $projectRoot 'release_artifacts'
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    $apk = Join-Path $outputDir 'lamma-android.apk'
    Copy-Item -LiteralPath $apkSource -Destination $apk
    $digest = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash.ToLowerInvariant()
    [System.IO.File]::WriteAllText((Join-Path $outputDir 'lamma-android.apk.sha256'), "$digest  lamma-android.apk`n", [System.Text.UTF8Encoding]::new($false))
    # Public metadata is fetched directly, without consuming anonymous API quota.
    $encodedTag = [uri]::EscapeDataString($tag)
    $manifest = @{
        tag_name = $tag; draft = $false; prerelease = $false
        body = [System.IO.File]::ReadAllText($notesFile)
        assets = @(@{
            name = 'lamma-android.apk'; state = 'uploaded'
            browser_download_url = "https://github.com/$repo/releases/download/$encodedTag/lamma-android.apk"
            digest = "sha256:$digest"; size = (Get-Item -LiteralPath $apk).Length
        })
    }
    $manifestPath = Join-Path $outputDir 'update.json'
    [System.IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 6), [System.Text.UTF8Encoding]::new($false))
    Run-Native 'gh' @('release','create',$tag,'--repo',$repo,'--target',$sourceCommit,'--draft','--title',"لَمّة $versionName ($buildNumber)",'--notes-file',$notesFile)
    Run-Native 'gh' @('release','upload',$tag,$apk,(Join-Path $outputDir 'lamma-android.apk.sha256'),$manifestPath,'--repo',$repo)
    # Tag lookup excludes unpublished drafts. Find our draft in the
    # authenticated list, then verify its uploaded assets before publication.
    $releaseList = & gh api "repos/$repo/releases" | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) { throw 'Could not verify draft assets.' }
    $matchingReleases = @($releaseList | Where-Object tag_name -eq $tag)
    if ($matchingReleases.Count -ne 1 -or -not $matchingReleases[0].draft) { throw 'Expected exactly one draft release.' }
    $remote = $matchingReleases[0]
    $asset = @($remote.assets | Where-Object name -eq 'lamma-android.apk')
    if ($asset.Count -ne 1 -or $asset[0].digest -ne "sha256:$digest" -or $asset[0].size -ne (Get-Item -LiteralPath $apk).Length) { throw 'Release asset integrity mismatch; draft was not published.' }
    $manifestAsset = @($remote.assets | Where-Object name -eq 'update.json')
    $manifestDigest = (Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($manifestAsset.Count -ne 1 -or $manifestAsset[0].digest -ne "sha256:$manifestDigest") { throw 'Update manifest integrity mismatch; draft was not published.' }
    Run-Native 'gh' @('release','edit',$tag,'--repo',$repo,'--draft=false','--latest')
    Write-Output "Published: https://github.com/$repo/releases/download/$tag/lamma-android.apk"
} finally { Set-Location -LiteralPath $originalLocation }
