# Peekaboo CLI Reference

macOS automation with screen capture, UI inspection, and AI analysis.

## Installation

```bash
brew install steipete/tap/peekaboo
```

## Requirements

- macOS 15+ (Sequoia)
- Screen Recording permission
- Accessibility permission

## Commands

### Screen Capture

```bash
# Full screen (Retina)
peekaboo image --mode screen --retina --path ~/Desktop/screen.png

# Specific app window
peekaboo image --mode window --app Safari --path ~/Desktop/safari.png

# Menu bar
peekaboo image --mode menu --path ~/Desktop/menubar.png

# With AI analysis
peekaboo image --mode screen --analyze --path ~/Desktop/analyzed.png
```

### UI Inspection

```bash
# Capture and get element IDs
peekaboo see --app Safari --json-output

# Store snapshot ID for subsequent commands
SNAPSHOT=$(peekaboo see --app Safari --json-output | jq -r '.data.snapshot_id')
```

### Click Actions

```bash
# By element ID or label (requires snapshot)
peekaboo click --on "Reload this page" --snapshot "$SNAPSHOT"
peekaboo click --on "element-id-123" --snapshot "$SNAPSHOT"

# By coordinates
peekaboo click --at 100,200

# With wait
peekaboo click --on "Submit" --snapshot "$SNAPSHOT" --wait
```

### Text Input

```bash
peekaboo type --text "Hello World"
peekaboo type --text "search query" --clear  # Clear first
peekaboo type --text "slow typing" --delay-ms 50
```

### Keyboard

```bash
# Special keys
peekaboo press enter
peekaboo press escape
peekaboo press tab --repeat 3

# Hotkey combos
peekaboo hotkey cmd,c           # Copy
peekaboo hotkey cmd,v           # Paste
peekaboo hotkey cmd,shift,t     # Reopen tab
peekaboo hotkey cmd,alt,esc     # Force quit
```

### Scrolling

```bash
peekaboo scroll --direction up --ticks 5
peekaboo scroll --direction down --ticks 3
peekaboo scroll --on "element-id" --direction up
```

### Swipe & Drag

```bash
# Swipe gesture
peekaboo swipe --from 100,500 --to 100,200 --duration 0.5

# Drag and drop
peekaboo drag --from "source-element" --to "target-element"
peekaboo drag --from 100,100 --to 300,300
```

### App Control

```bash
peekaboo app list
peekaboo app launch Safari
peekaboo app quit Safari
peekaboo app relaunch Safari
peekaboo app switch Safari
```

### Window Management

```bash
peekaboo window list
peekaboo window focus --app Safari
peekaboo window move --app Safari --x 0 --y 0
peekaboo window resize --app Safari --width 1200 --height 800
peekaboo window set-bounds --app Safari --x 0 --y 0 --width 1200 --height 800
```

### Menu Interaction

```bash
# List menus
peekaboo menu list --app Safari
peekaboo menu list-all --app Safari

# Click menu items
peekaboo menu click --app Safari --path "File > New Window"
peekaboo menu click --app Safari --path "View > Reload Page"

# Menu bar extras (status bar)
peekaboo menubar list
peekaboo menubar click --name "Wi-Fi"
```

### Dock

```bash
peekaboo dock list
peekaboo dock launch Safari
peekaboo dock right-click Safari
peekaboo dock hide
peekaboo dock show
```

### Spaces (Mission Control)

```bash
peekaboo space list
peekaboo space switch --index 2
peekaboo space move-window --app Safari --to 2
```

### Dialog Handling

```bash
peekaboo dialog list
peekaboo dialog click "Save"
peekaboo dialog dismiss
peekaboo dialog input --text "filename.txt"
peekaboo dialog file --select ~/Documents/file.txt
```

### Permissions

```bash
peekaboo permissions status
peekaboo permissions grant
```

### Utilities

```bash
# Cursor positioning
peekaboo move --to 100,200
peekaboo move --to "element-id" --snapshot "$SNAPSHOT"

# Delays
peekaboo sleep --duration 1000  # milliseconds

# List available tools
peekaboo tools --json-output
```

## Natural Language Agent

```bash
# Single command
peekaboo "Open Safari and navigate to google.com"

# With specific model
peekaboo agent --model gpt-4 "Create a new note in Notes app"

# Dry run (show plan without executing)
peekaboo agent --dry-run "Close all Safari windows"

# Resume session
peekaboo agent --resume "Continue from where we left off"
```

## MCP Server Mode

```bash
# Start MCP server
peekaboo mcp serve

# Or via npx
npx -y @steipete/peekaboo
```

## Common Patterns

### Capture, analyze, click

```bash
SNAPSHOT=$(peekaboo see --app Safari --json-output | jq -r '.data.snapshot_id')
peekaboo click --on "Downloads" --snapshot "$SNAPSHOT"
```

### Menu navigation

```bash
peekaboo app switch Finder
peekaboo menu click --app Finder --path "File > New Folder"
peekaboo type --text "My Folder"
peekaboo press enter
```

### Window arrangement

```bash
peekaboo window set-bounds --app Safari --x 0 --y 0 --width 960 --height 1080
peekaboo window set-bounds --app "VS Code" --x 960 --y 0 --width 960 --height 1080
```
