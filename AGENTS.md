# iostmux — iOS Claude Code Session Viewer

## 项目概述
iOS app，通过 SSH（Tailscale）连接 Mac Studio，浏览 ~/Projects/ 目录列表，接入 Claude Code tmux session，过滤工具调用只显示文字回复，支持语音输入和手势键盘。

## 项目路径
- 根目录: ~/Projects/iostmux
- 源代码: ~/Projects/iostmux/iostmux/ (Xcode 项目内)
- 文档: ~/Projects/iostmux/docs/
- 设计文档: ~/Projects/iostmux/docs/superpowers/specs/
- 实施计划: ~/Projects/iostmux/docs/superpowers/plans/

## 技术栈
- SwiftUI (iOS 17+, iPhone only, portrait)
- SwiftTerm (SPM, 终端模拟器)
- SwiftSH (SPM, libssh2 SSH wrapper)
- Speech framework (语音识别)
- BackgroundTasks framework (后台轮询)

## 环境依赖
- Xcode 16+
- iOS 17+ 真机（SSH + 语音需要真机测试）
- Mac Studio 上需要: tmux, ccc 脚本 (~/workspace/scripts/ccc)
- Tailscale VPN 连接

## 代码结构
```
iostmux/
├── iostmuxApp.swift          — App 入口, 后台任务注册
├── Config.swift              — SSH 配置（硬编码 IP/user/port）
├── Models/Project.swift      — 项目数据模型
├── Services/
│   ├── SSHService.swift      — SSH 连接管理
│   ├── OutputFilter.swift    — 输出过滤状态机
│   └── BackgroundMonitor.swift — 后台空闲检测
├── Views/
│   ├── ProjectListView.swift     — 项目列表
│   ├── SessionView.swift         — 终端会话容器
│   ├── TerminalViewWrapper.swift — SwiftTerm UIViewRepresentable
│   ├── GestureKeyboardView.swift — 手势键盘
│   └── VoiceInputButton.swift    — 语音输入按钮
```

## 开发约定
- SSH 库: SwiftSH（不用 Citadel，后者不支持交互式 shell）
- 终端桥接: SwiftTerm TerminalView 通过 UIViewRepresentable 包装
- 输出过滤: ANSI 转义码先 strip 再做模式匹配

### [evolve] 标签规则
- 来自 evolve-engine 建议的任务/idea 必须带 `[evolve]` 标签

## GTD 流程
本项目由 `/project-new` 创建，所有开发工作都必须纳入 GTD 流程：
- 开始前：确认工作对应 PROJECT.md 中的哪个任务
- 完成后：更新 PROJECT.md + 写日志 + `python3 ~/workspace/scripts/gtd_dashboard.py` + `~/workspace/scripts/gtd_git_commit.sh ~/Projects/iostmux "提交信息"`
