# AXe CLI Reference

iOS Simulator automation via Apple's Accessibility APIs and HID.

## Installation

```bash
brew install cameroncooke/axe/axe
```

## Commands

### Simulator Management

```bash
axe list-simulators
```

### Touch & Gestures

```bash
# Tap at coordinates
axe tap -x 100 -y 200 --udid $UDID
axe tap -x 100 -y 200 --pre-delay 1.0 --post-delay 0.5 --udid $UDID

# Tap by accessibility element
axe tap --id "elementId" --udid $UDID
axe tap --label "Button Text" --udid $UDID

# Swipe
axe swipe --start-x 100 --start-y 300 --end-x 300 --end-y 100 --udid $UDID
axe swipe --start-x 50 --start-y 500 --end-x 350 --end-y 500 --duration 2.0 --delta 25 --udid $UDID

# Low-level touch control
axe touch -x 150 -y 250 --down --udid $UDID
axe touch -x 150 -y 250 --up --udid $UDID
axe touch -x 150 -y 250 --down --up --delay 1.0 --udid $UDID
```

### Gesture Presets

| Preset | Description |
|--------|-------------|
| `scroll-up` | Scroll up in center |
| `scroll-down` | Scroll down in center |
| `scroll-left` | Scroll left in center |
| `scroll-right` | Scroll right in center |
| `swipe-from-left-edge` | Back navigation |
| `swipe-from-right-edge` | Forward navigation |
| `swipe-from-top-edge` | Dismiss/close |
| `swipe-from-bottom-edge` | Open/reveal |

```bash
axe gesture scroll-up --udid $UDID
axe gesture swipe-from-left-edge --udid $UDID
axe gesture scroll-down --pre-delay 0.5 --post-delay 1.0 --udid $UDID

# Custom screen dimensions
axe gesture scroll-up --screen-width 430 --screen-height 932 --udid $UDID
```

### Text Input

```bash
# Direct text (use single quotes for special chars)
axe type 'Hello World!' --udid $UDID

# From stdin
echo "Complex text" | axe type --stdin --udid $UDID

# From file
axe type --file input.txt --udid $UDID
```

### Hardware Buttons

```bash
axe button home --udid $UDID
axe button lock --udid $UDID
axe button lock --duration 2.0 --udid $UDID
axe button siri --udid $UDID
axe button side-button --udid $UDID
axe button apple-pay --udid $UDID
```

### Keyboard Control

```bash
# Individual key by HID keycode
axe key 40 --udid $UDID                    # Enter
axe key 42 --duration 1.0 --udid $UDID     # Hold Backspace

# Key sequences
axe key-sequence --keycodes 11,8,15,15,18 --udid $UDID  # "hello"
```

### Screenshots

```bash
# Auto-generated filename
axe screenshot --udid $UDID

# Specific file
axe screenshot --output ~/Desktop/screenshot.png --udid $UDID

# Save to directory (auto-timestamps)
axe screenshot --output ~/Desktop/ --udid $UDID
```

### Video

```bash
# MJPEG stream
axe stream-video --udid $UDID --fps 10 --format mjpeg > stream.mjpeg

# Pipe to ffmpeg
axe stream-video --udid $UDID --fps 30 --format ffmpeg | \
  ffmpeg -f image2pipe -framerate 30 -i - -c:v libx264 -preset ultrafast output.mp4

# Record to MP4
axe record-video --udid $UDID --fps 15 --output recording.mp4
```

### Accessibility

```bash
# Full screen UI tree
axe describe-ui --udid $UDID

# Specific point
axe describe-ui --point 100,200 --udid $UDID
```

## Common Patterns

### Wait and tap

```bash
axe tap --label "Continue" --pre-delay 2.0 --udid $UDID
```

### Scroll to find element

```bash
for i in {1..5}; do
  axe describe-ui --udid $UDID | grep -q "Target Element" && break
  axe gesture scroll-down --udid $UDID
done
```

### Type with keyboard dismiss

```bash
axe type 'search query' --udid $UDID
axe key 40 --udid $UDID  # Enter to dismiss
```
