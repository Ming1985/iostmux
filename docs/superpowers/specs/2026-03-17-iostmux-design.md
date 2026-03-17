# iostmux - iOS Claude Code Session Viewer

## Overview

An iOS app that connects to Mac Studio via SSH (over Tailscale) to browse projects and interact with Claude Code tmux sessions. Optimized for reading Claude's text responses with minimal input — voice-first with gesture-activated keyboard fallback.

## Architecture

```
iOS App (SwiftUI)
├── ProjectListView — ls ~/Projects/, show tmux session status
├── SessionView — SwiftTerm terminal + output filter + voice input
└── SSHService — Citadel (SwiftNIO SSH) over Tailscale to fixed IP

Mac Studio
└── tmux sessions managed by `ccc` script
    (ccc = ~/workspace/scripts/ccc, creates tmux session named after
     project directory and launches `claude --dangerously-skip-permissions`)
```

## Pages

### ProjectListView

- On launch, SSH to Mac Studio (hardcoded Tailscale IP)
- Execute `ls ~/Projects/` to get project directory list
- Execute `tmux list-sessions -F '#{session_name}'` to get active sessions
- Display each project as a row: project name + green dot if tmux session exists
- Pull-to-refresh to update list
- Tap → navigate to SessionView

### SessionView

- SwiftTerm-based terminal view
- On enter: `tmux attach-session -t <project> 2>/dev/null || (cd ~/Projects/<project> && ccc)`
- On navigate-back: detach from tmux (`tmux detach`), close SSH channel
- **Output filter layer**: dual-buffer approach — SwiftTerm always receives the full stream (preserving raw buffer); a parallel filter produces a cleaned view for compact mode. Toggle switches which buffer is rendered.
- Toggle button (top-right): compact mode / raw terminal mode
- **Voice input**: floating mic button, tap-to-speak, Chinese + English auto-detect via iOS Speech framework, sends recognized text to terminal stdin on completion
- **Gesture keyboard**: swipe up from bottom edge to reveal, swipe down to dismiss
  - Compact layout: alphanumeric, common symbols, special keys (Tab, Ctrl+C, arrow keys, Esc)
  - Special keys send correct terminal escape sequences (e.g., arrow up = `\x1b[A`)
  - Quick-access row: common slash commands (/commit, /help, yes, no)

## Output Filtering (Compact Mode)

### Strategy

Terminal output is ANSI-encoded. The filter operates as a **state machine** on ANSI-stripped text, maintaining parser state to track whether current output is inside a tool block.

### States

- **SHOW** (default): render lines to compact view
- **TOOL_BLOCK**: suppress lines until state exits back to SHOW

### Transitions

- SHOW → TOOL_BLOCK: line contains `⏺` (after ANSI stripping) followed by a tool name keyword (Read, Write, Edit, Bash, Grep, Glob, Agent, etc.)
- TOOL_BLOCK → SHOW: next line containing `⏺` that is NOT a tool call (i.e., Claude's response marker), or a user prompt line (`❯`/`>`)

### Lines always shown (regardless of state)

- User prompt lines (containing `❯` or `>` prefix)
- Error/warning lines
- Claude's natural language text (lines in SHOW state)
- Cost/token summary lines (informational)

### Lines always hidden in compact mode

- Permission prompts (`Allow X? [Y/n]`)
- Spinner/progress indicators
- `Ctrl+C to interrupt` hints

### ANSI handling

Strip ANSI escape codes (`\x1b\[[0-9;]*[A-Za-z]`) before pattern matching. The compact view renders plain text with basic markdown-style formatting. Raw mode shows full ANSI terminal.

## Tech Stack

- **UI**: SwiftUI, iOS 17+
- **Terminal**: SwiftTerm (Swift package, provides TerminalView + terminal emulation)
- **SSH**: Citadel (orlandos-nl/Citadel, Swift-native, built on SwiftNIO SSH)
- **SSH-to-SwiftTerm bridge**: custom layer that pipes Citadel SSH channel bytes into SwiftTerm's terminal emulator input
- **Voice**: Speech framework (SFSpeechRecognizer), tap-to-speak
- **Target**: iPhone, portrait only (landscape blocked)

## Connection Details

- Host: hardcoded Tailscale IP (configurable later)
- Auth: SSH key pair
- User: `ming`
- Port: 22

### First-Run Key Setup

1. App detects no SSH key in Keychain on first launch
2. Prompts user to paste private key (from clipboard) or import from Files.app
3. Stores in iOS Keychain
4. User must manually add the public key to Mac Studio's `~/.ssh/authorized_keys`

### Reconnection

- On SSH disconnect: show banner "Connection lost", auto-retry 3 times with 2s interval
- If all retries fail: show "Reconnect" button
- tmux sessions survive disconnects (server-side), so re-attach picks up where left off

## Known Limitations (v1)

- Assumes one tmux window, one pane per session. Multi-pane layouts not handled.
- Scrollback buffer unbounded — may need limits if memory becomes an issue.
- Output filter is heuristic-based; edge cases in Claude Code output format changes may require filter updates.
- No landscape, no iPad.

## Non-Goals (v1)

- Multi-device support
- iPad/Mac Catalyst
- SSH key generation in-app
- File browsing or editing
- Notification on Claude completion
