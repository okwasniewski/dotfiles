---
name: macos-automation
description: Automate macOS apps using CLI tools like AXe (iOS Simulator) and Peekaboo (macOS desktop). Use when asked to automate UI interactions, capture screenshots, or control apps programmatically.
---

# macOS Automation

Automate macOS and iOS Simulator interactions using AXe and Peekaboo CLI tools.

## Overview

Two complementary tools for UI automation:
- **AXe**: iOS Simulator automation via Accessibility APIs and HID
- **Peekaboo**: macOS desktop automation with screen capture and AI analysis

## When to Use

| Tool | Use Case |
|------|----------|
| AXe | iOS Simulator: taps, swipes, text input, button presses, screenshots |
| Peekaboo | macOS: app control, window management, menu clicks, screen capture |

## AXe Quick Reference

```bash
# List simulators
axe list-simulators

# Basic interactions
UDID="YOUR-SIMULATOR-UDID"
axe tap -x 100 -y 200 --udid $UDID
axe tap --label "Button Text" --udid $UDID
axe type 'Hello World!' --udid $UDID
axe swipe --start-x 100 --start-y 300 --end-x 300 --end-y 100 --udid $UDID

# Gesture presets
axe gesture scroll-up --udid $UDID
axe gesture swipe-from-left-edge --udid $UDID

# Hardware buttons
axe button home --udid $UDID
axe button lock --udid $UDID

# Screenshots
axe screenshot --udid $UDID
axe screenshot --output ~/Desktop/screen.png --udid $UDID

# Accessibility tree
axe describe-ui --udid $UDID
axe describe-ui --point 100,200 --udid $UDID

# Timing controls
axe tap -x 100 -y 200 --pre-delay 1.0 --post-delay 0.5 --udid $UDID
```

## Peekaboo Quick Reference

```bash
# Screenshot capture
peekaboo image --mode screen --retina --path ~/Desktop/screen.png
peekaboo image --mode window --app Safari --path ~/Desktop/safari.png

# UI inspection (returns element IDs)
peekaboo see --app Safari --json-output

# Click by element or label
peekaboo click --on "Reload this page" --snapshot "$SNAPSHOT"
peekaboo click --at 100,200

# Text input
peekaboo type --text "Hello World"
peekaboo hotkey cmd,shift,t

# App control
peekaboo app launch Safari
peekaboo app quit Safari
peekaboo app list

# Window management
peekaboo window list
peekaboo window focus --app Safari
peekaboo window move --app Safari --x 0 --y 0

# Menu interaction
peekaboo menu list --app Safari
peekaboo menu click --app Safari --path "File > New Window"

# Natural language automation
peekaboo "Open Notes and create a TODO list"
```

## Workflow: iOS Simulator Testing

1. Get simulator UDID: `axe list-simulators`
2. Inspect UI: `axe describe-ui --udid $UDID`
3. Interact by label or coordinates
4. Capture result: `axe screenshot --udid $UDID`

## Workflow: macOS App Automation

1. Capture and analyze: `peekaboo see --app AppName --json-output`
2. Extract element IDs from snapshot
3. Click/type using element references
4. Verify with another capture

## Best Practices

- **Prefer labels over coordinates** for maintainable automation
- **Use timing controls** (`--pre-delay`, `--post-delay`) for flaky interactions
- **Capture before clicking** to get accurate element positions
- **Check accessibility tree** when elements aren't clickable
- **Use gesture presets** instead of manual swipe coordinates

## Resources

- See `references/axe.md` for AXe command details
- See `references/peekaboo.md` for Peekaboo command details
