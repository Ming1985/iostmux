# iostmux - iOS Claude Code Session Viewer

## Overview

An iOS app that connects to Mac Studio via SSH (over Tailscale) to browse projects and interact with Claude Code tmux sessions. Optimized for reading Claude's text responses with minimal input — voice-first with gesture-activated keyboard fallback.

## Architecture

```
iOS App (SwiftUI)
├── ProjectListView — ls ~/Projects/, show tmux session status
├── SessionView — SwiftTerm terminal + output filter + voice input
└── SSH Connection — libssh2 over Tailscale to fixed IP

Mac Studio
└── tmux sessions managed by `ccc` script
```

## Pages

### ProjectListView

- On launch, SSH to Mac Studio (hardcoded Tailscale IP)
- Execute `ls ~/Projects/` to get project directory list
- Execute `tmux list-sessions -F '#{session_name}'` to get active sessions
- Display each project as a row: project name + green dot if tmux session exists
- Tap → navigate to SessionView

### SessionView

- SwiftTerm-based terminal view
- On enter: `tmux attach-session -t <project> 2>/dev/null || cd ~/Projects/<project> && ccc`
- **Output filter layer** intercepts SwiftTerm output stream:
  - Detects and hides tool call blocks (lines starting with `⏺`, file content dumps, diffs, progress indicators)
  - Passes through Claude's text responses and user prompts
  - Toggle button (top-right): compact mode / raw terminal mode
- **Voice input**: floating mic button, uses iOS Speech framework, sends recognized text to terminal stdin
- **Gesture keyboard**: swipe up from bottom edge to reveal, swipe down to dismiss
  - Compact layout: alphanumeric, common symbols, special keys (Tab, Ctrl+C, arrow keys, Esc)
  - Quick-access row: common slash commands (/commit, /help, yes, no)

## Output Filtering Rules (Compact Mode)

Lines to **hide**:
- Tool call headers: lines matching `⏺` followed by tool names (Read, Write, Edit, Bash, Grep, Glob, etc.)
- File content blocks: indented content between tool call header and next `⏺` or blank line
- Progress/status lines: spinner characters, "Running...", permission prompts
- Diff output: lines starting with `+`, `-`, `@@` in tool context

Lines to **show**:
- Claude's natural language responses (text paragraphs)
- User input prompts (`>` prefixed or after `❯`)
- Error messages and warnings
- Section headers from Claude's responses

Implementation: regex-based filter on terminal output buffer, applied before SwiftTerm rendering in compact mode. Raw mode bypasses filter entirely.

## Tech Stack

- **UI**: SwiftUI, iOS 17+
- **Terminal**: SwiftTerm (Swift package)
- **SSH**: libssh2 via SwiftTerm or NMSSH
- **Voice**: Speech framework (SFSpeechRecognizer)
- **Target**: iPhone, portrait primary

## Connection Details

- Host: hardcoded Tailscale IP (configurable later)
- Auth: SSH key (stored in iOS Keychain)
- User: `ming`
- Port: 22

## Non-Goals (v1)

- Multi-device support
- iPad/Mac Catalyst
- SSH key generation in-app (user copies key manually)
- File browsing or editing
- Notification on Claude completion
