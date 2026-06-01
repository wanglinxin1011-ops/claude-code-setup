@echo off
title Claude Code Setup - 一键安装 Skills & Plugins
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ============================================
echo   Claude Code Setup - 一键安装
echo ============================================
echo.

:: 检查 claude 命令
where claude >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 找不到 claude 命令，请先安装 Claude Code CLI
    echo 安装方法: https://code.claude.com/docs/zh-CN/quickstart
    pause
    exit /b 1
)

:: 检查 git
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 找不到 git 命令，请先安装 Git
    echo 下载: https://git-scm.com/downloads/win
    pause
    exit /b 1
)

set CLAUDE_SKILLS_DIR=%USERPROFILE%\.claude\skills
set TMP_DIR=%TEMP%\claude-setup-tmp

echo [1/3] 安装 Marketplace 插件...
echo ----------------------------------------
for /f "usebackq tokens=*" %%p in ("%~dp0plugins.txt") do (
    if not "%%p"=="" (
        if not "%%p:~0,1"=="#" (
            echo   安装插件: %%p
            call claude plugin install %%p
        )
    )
)
echo.

echo [2/3] 安装第三方 Skills...
echo ----------------------------------------
:: 确保 skills 目录存在
if not exist "%CLAUDE_SKILLS_DIR%" mkdir "%CLAUDE_SKILLS_DIR%"

:: 读取 skills.txt 逐行处理
for /f "usebackq tokens=1,2,3" %%a in ("%~dp0skills.txt") do (
    if not "%%a"=="" (
        if not "%%a:~0,1"=="#" (
            set "REPO=%%a"
            set "SUB_DIR=%%b"
            set "TARGET=%%c"
            echo   安装 skill: !TARGET!
            echo   从: !REPO!

            :: 清理并重新克隆
            if exist "%TMP_DIR%" rmdir /s /q "%TMP_DIR%"
            git clone --depth 1 --filter=blob:none --sparse "%%a" "%TMP_DIR%" >nul 2>&1
            if !ERRORLEVEL! EQU 0 (
                cd "%TMP_DIR%"
                git sparse-checkout set "%%b" >nul 2>&1
                if exist "%TMP_DIR%\%%b" (
                    if exist "%CLAUDE_SKILLS_DIR%\%%c" rmdir /s /q "%CLAUDE_SKILLS_DIR%\%%c"
                    xcopy /e /i /q "%TMP_DIR%\%%b" "%CLAUDE_SKILLS_DIR%\%%c" >nul
                    echo   ✓ %%c 安装成功
                ) else (
                    echo   ✗ 子目录 %%b 未找到
                )
                rmdir /s /q "%TMP_DIR%"
            ) else (
                echo   ✗ 克隆失败，请检查网络连接
            )
        )
    )
)

echo.

echo [3/3] 清理临时文件...
if exist "%TMP_DIR%" rmdir /s /q "%TMP_DIR%"
echo.

echo ============================================
echo   安装完成！
echo   请重启 Claude Code 使所有插件生效。
echo ============================================
pause
