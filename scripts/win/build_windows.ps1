param(
  [string]$QtDir="",           # e.g. C:\Qt\6.7.2\msvc2022_64
  [string]$VSYear="2022",      # Visual Studio version: 2019 or 2022
  [string]$Config="Release",
  [switch]$DownloadFFmpeg      # if specified, download ffmpeg portable zip
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Resolve-Path (Join-Path $here "..\..")
$build = Join-Path $root "build"
$dist  = Join-Path $root "dist"
$exeRel = Join-Path $build "$Config\quickcut.exe"

function Find-Qt {
  param([string]$QtDirParam)
  if ($QtDirParam -ne "") { return $QtDirParam }
  $common = @("C:\Qt", "$env:USERPROFILE\Qt")
  foreach ($base in $common) {
    if (Test-Path $base) {
      $candidates = Get-ChildItem -Path $base -Directory -Recurse -Depth 2 |
        Where-Object { $_.Name -match "msvc(2019|2022)_64" }
      if ($candidates) {
        # pick the newest version
        $sorted = $candidates | Sort-Object FullName -Descending
        return $sorted[0].FullName
      }
    }
  }
  throw "未找到 Qt 目录，请用 -QtDir 指定（例如 C:\Qt\6.7.2\msvc2022_64）"
}

function Ensure-Tool {
  param([string]$Name,[string]$TestCmd)
  Write-Host "检查 $Name ..."
  try {
    & cmd /c "$TestCmd" | Out-Null
  } catch {
    throw "未找到 $Name，请先安装。"
  }
}

# Ensure required tools
Ensure-Tool "CMake" "cmake --version"
Ensure-Tool "FFmpeg (可选，若 -DownloadFFmpeg 则会自动下载)" "cmd /c exit 0"

$QtDir = Find-Qt -QtDirParam $QtDir
$windeploy = Join-Path $QtDir "bin\windeployqt.exe"
if (!(Test-Path $windeploy)) { throw "未找到 windeployqt: $windeploy" }

# Configure & Build with MSBuild generator
Write-Host "== 配置 CMake =="
if (!(Test-Path $build)) { New-Item -ItemType Directory -Path $build | Out-Null }
pushd $build
& cmake -G "Visual Studio 17 $VSYear" -A x64 -DCMAKE_PREFIX_PATH="$QtDir" -DCMAKE_BUILD_TYPE=$Config ..
if ($LASTEXITCODE -ne 0) { throw "CMake 配置失败" }

Write-Host "== 编译 =="+$Config
& cmake --build . --config $Config -j
if ($LASTEXITCODE -ne 0) { throw "编译失败" }
popd

# Deploy Qt runtime
if (Test-Path $dist) { Remove-Item -Recurse -Force $dist }
New-Item -ItemType Directory -Path $dist | Out-Null
$deployDir = Join-Path $dist "QuickCut"
New-Item -ItemType Directory -Path $deployDir | Out-Null

Copy-Item $exeRel $deployDir
& "$windeploy" --release --compiler-runtime (Join-Path $deployDir "quickcut.exe")
if ($LASTEXITCODE -ne 0) { throw "windeployqt 失败" }

# FFmpeg
if ($DownloadFFmpeg.IsPresent) {
  Write-Host "== 下载 FFmpeg 便携包 =="
  $ffurl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-essentials.zip"
  $zip = Join-Path $dist "ffmpeg.zip"
  Invoke-WebRequest -Uri $ffurl -OutFile $zip
  Expand-Archive -Path $zip -DestinationPath $dist -Force
  Remove-Item $zip -Force
  $ffdir = Get-ChildItem -Path $dist -Directory | Where-Object { $_.Name -like "ffmpeg*" } | Select-Object -First 1
  if ($null -ne $ffdir) {
    $bin = Join-Path $ffdir.FullName "bin"
    Copy-Item (Join-Path $bin "ffmpeg.exe") $deployDir -Force
    Copy-Item (Join-Path $bin "ffprobe.exe") $deployDir -Force
  }
}

# Zip portable
$zipOut = Join-Path $dist "QuickCut_Windows_Portable.zip"
if (Test-Path $zipOut) { Remove-Item $zipOut -Force }
Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
[System.IO.Compression.ZipFile]::CreateFromDirectory($deployDir, $zipOut)

Write-Host ""
Write-Host "✅ 完成！便携版已生成：$zipOut"
Write-Host "   解压后双击 quickcut.exe 即可运行。"