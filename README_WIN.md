# QuickCut Windows 便携版一键打包

**目标**：在你的 Windows 机器上，一键生成一个可直接运行的文件夹（双击 `quickcut.exe` 即用）。

## 方式 A：PowerShell 脚本（推荐）
前提：已安装 **Visual Studio 2022 Build Tools**（含 C++）与 **Qt 6 (msvc_64)**。

```powershell
# 以 PowerShell 打开 scripts\win 目录：
cd scripts\win

# 运行并自动打包（会尝试下载 FFmpeg）
.\build_windows.ps1 -QtDir "C:\Qt\6.7.2\msvc2022_64" -DownloadFFmpeg

# 完成后：dist\QuickCut_Windows_Portable.zip
# 解压后双击 quickcut.exe 即可。
```

## 方式 B：批处理（最少参数）
```bat
# 在仓库根目录
scripts\win\build_win.bat C:\Qt\6.7.2\msvc2022_64
# 生成便携目录在 dist\QuickCut
```

> 如果你未安装 Qt：请用 Qt 官方安装器安装 Desktop 版（MSVC 64-bit），组件包含 Widgets、Multimedia、MultimediaWidgets。