---
name: ios-simulator
description: Automate iOS Simulator using AXe CLI. Use after implementing features to verify they work correctly via UI automation.
---

# iOS Simulator Automation

Automate iOS Simulator interactions using AXe CLI for testing implemented features.

## Philosophy

Implementation without verification is incomplete. After building a feature, use
AXe to interact with the simulator and confirm the feature works as expected.
This closes the loop between coding and testing.

## Installation

```bash
brew install cameroncooke/axe/axe
```

## Workflow: Verify Implementation

1. Get simulator UDID: `axe list-simulators`
2. Inspect UI: `axe describe-ui --udid $UDID`
3. Interact with the feature you just built
4. Capture result: `axe screenshot --udid $UDID`

## Quick Reference

```bash
# List simulators
axe list-simulators

# Store UDID
UDID="YOUR-SIMULATOR-UDID"

# Inspect UI tree
axe describe-ui --udid $UDID
axe describe-ui --point 100,200 --udid $UDID

# Tap interactions
axe tap -x 100 -y 200 --udid $UDID
axe tap --label "Button Text" --udid $UDID
axe tap --id "elementId" --udid $UDID

# Text input
axe type 'Hello World!' --udid $UDID

# Swipe
axe swipe --start-x 100 --start-y 300 --end-x 300 --end-y 100 --udid $UDID

# Gesture presets
axe gesture scroll-up --udid $UDID
axe gesture scroll-down --udid $UDID
axe gesture swipe-from-left-edge --udid $UDID

# Hardware buttons
axe button home --udid $UDID
axe button lock --udid $UDID

# Screenshots
axe screenshot --udid $UDID
axe screenshot --output ~/Desktop/screen.png --udid $UDID

# Timing controls
axe tap -x 100 -y 200 --pre-delay 1.0 --post-delay 0.5 --udid $UDID
```

## Best Practices

- **Prefer labels over coordinates** for maintainable automation
- **Use timing controls** (`--pre-delay`, `--post-delay`) for async operations
- **Check accessibility tree** when elements aren't found
- **Use gesture presets** instead of manual swipe coordinates
- **Take screenshots** to verify visual state after interactions

## Resources

- See `references/axe.md` for full AXe command reference
