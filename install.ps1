#Requires -Version 5.0
param()

$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Claude Code Setup - 一键安装" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 检查 claude
if (-not (Get-Command "claude" -ErrorAction SilentlyContinue)) {
    Write-Host "[错误] 找不到 claude 命令，请先安装 Claude Code CLI" -ForegroundColor Red
    Write-Host "安装方法: https://code.claude.com/docs/zh-CN/quickstart"
    Read-Host "按 Enter 退出"
    exit 1
}

# 检查 git
if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Host "[错误] 找不到 git 命令，请先安装 Git" -ForegroundColor Red
    Write-Host "下载: https://git-scm.com/downloads/win"
    Read-Host "按 Enter 退出"
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeSkillsDir = "$env:USERPROFILE\.claude\skills"
$TempDir = "$env:TEMP\claude-setup-tmp"

# [1] 安装 marketplace 插件
Write-Host "[1/3] 安装 Marketplace 插件..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor DarkGray
Get-Content "$ScriptDir\plugins.txt" | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("#")) {
        Write-Host "  安装插件: $line"
        & claude plugin install $line 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ $line 安装成功" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $line 安装失败" -ForegroundColor Red
        }
    }
}
Write-Host ""

# [2] 安装第三方 skills
Write-Host "[2/3] 安装第三方 Skills..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor DarkGray

if (-not (Test-Path $ClaudeSkillsDir)) {
    New-Item -ItemType Directory -Path $ClaudeSkillsDir -Force | Out-Null
}

Get-Content "$ScriptDir\skills.txt" | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("#")) {
        $parts = $line -split '\s+'
        $repo = $parts[0]
        $subDir = $parts[1]
        $target = $parts[2]

        Write-Host "  安装 skill: $target"
        Write-Host "  来自: $repo ($subDir)"

        # 清理并克隆
        if (Test-Path $TempDir) { Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue }

        try {
            & git clone --depth 1 --filter=blob:none --sparse $repo $TempDir 2>&1 | Out-Null
            Push-Location $TempDir
            & git sparse-checkout set $subDir 2>&1 | Out-Null
            Pop-Location

            $sourcePath = Join-Path $TempDir $subDir
            $targetPath = Join-Path $ClaudeSkillsDir $target

            if (Test-Path $sourcePath) {
                if (Test-Path $targetPath) { Remove-Item -Recurse -Force $targetPath }
                Copy-Item -Recurse $sourcePath $targetPath
                Write-Host "  ✓ $target 安装成功" -ForegroundColor Green
            } else {
                Write-Host "  ✗ 子目录 $subDir 未找到" -ForegroundColor Red
            }
            Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
        } catch {
            Write-Host "  ✗ 克隆失败: $_" -ForegroundColor Red
        }
    }
}
Write-Host ""

# [3] 清理
Write-Host "[3/3] 清理临时文件..." -ForegroundColor Green
if (Test-Path $TempDir) { Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue }
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  安装完成！请重启 Claude Code 使插件生效。" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Read-Host "按 Enter 退出"
