# PortWatch

A macOS menu bar app that displays applications listening on TCP ports.

## Features

- Shows count of apps with open ports in the menu bar
- Groups ports by application
- Color-coded icons by service type (Node.js, Python, Redis, etc.)
- Auto-refreshes every 5 seconds
- Click any app to see its ports

## Requirements

- macOS 14.0 (Sonoma) or later
- App Sandbox must be disabled (uses `lsof` command)

## Building

1. Install XcodeGen: `brew install xcodegen`
2. Generate project: `xcodegen generate`
3. Open `PortWatch.xcodeproj` in Xcode
4. Build and run

## How It Works

Uses `lsof -iTCP -sTCP:LISTEN` to detect applications with open TCP ports, parses the output, and displays them in a clean menu bar interface.

## License

MIT
