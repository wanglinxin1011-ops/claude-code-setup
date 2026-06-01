# Claude Code Setup — 跨设备同步

一键安装 Claude Code 的 Skills 和 Plugins，换电脑只需一条命令。

## 使用方法

### Windows (推荐用 PowerShell)

```powershell
.\install.ps1
```

或者双击 `install.bat`。

### macOS / Linux

```bash
chmod +x install.sh
./install.sh
```

## 包含内容

### Marketplace Plugins
| 插件 | 来源 |
|------|------|
| Superpowers | obra/superpowers |
| Code Review | anthropics/claude-plugins-official |
| Code Simplifier | anthropics/claude-plugins-official |
| Ralph Loop | anthropics/claude-plugins-official |
| Skill Creator | anthropics/claude-plugins-official |

### Third-party Skills
| Skill | 来源 |
|-------|------|
| PPTX | anthropics/skills |
| Planning with Files | OthmanAdi/planning-with-files |
| UI UX Pro Max | nextlevelbuilder/ui-ux-pro-max-skill |
| Banner Design | nextlevelbuilder/ui-ux-pro-max-skill |
| Brand | nextlevelbuilder/ui-ux-pro-max-skill |
| Design | nextlevelbuilder/ui-ux-pro-max-skill |
| Design System | nextlevelbuilder/ui-ux-pro-max-skill |
| Slides | nextlevelbuilder/ui-ux-pro-max-skill |
| UI Styling | nextlevelbuilder/ui-ux-pro-max-skill |

> 注：`pdf`、`docx`、`xlsx`、`webapp-testing`、`mcp-builder`、`frontend-design` 等标准技能由 Claude Code 自动内置，无需手动安装。

## 文件说明

| 文件 | 用途 |
|------|------|
| `plugins.txt` | Marketplace 插件清单 |
| `skills.txt` | 第三方 Skill 清单（仓库+子目录+目标名） |
| `install.ps1` | Windows PowerShell 安装脚本 |
| `install.bat` | Windows 批处理安装脚本 |
| `install.sh` | macOS/Linux 安装脚本 |

## 新增 Skill

在 `skills.txt` 末尾添加一行：

```
https://github.com/user/repo.git  path/to/skill  skill-name
```

## 新增 Plugin

在 `plugins.txt` 末尾添加插件名，确保 marketplace 中存在即可。