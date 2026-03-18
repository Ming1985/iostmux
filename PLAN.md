# Plan: iostmux

## 技术栈
- SwiftUI (iOS 17+)
- SwiftTerm (终端模拟器)
- SwiftSH (libssh2 SSH 客户端)
- Speech framework (语音识别)
- BackgroundTasks framework (后台检测)

## 架构设计
- SwiftUI 前端 + SwiftTerm UIKit 桥接
- SSHService 封装所有 SSH 操作（命令执行 + 交互 shell）
- 输出过滤状态机（SHOW/TOOL_BLOCK）处理 ANSI 终端流
- 双缓冲渲染：raw terminal 始终存在，compact view 叠加显示

## 实施计划
详见 `docs/superpowers/plans/2026-03-18-iostmux-implementation.md`（12 个 task）
