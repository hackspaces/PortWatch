# PortWatch

macOS menu bar app showing applications listening on TCP ports.

## Quick Start for Agents

Run these checks before installing:

```bash
# Check macOS version (needs 14.0+)
sw_vers -productVersion

# Check if XcodeGen is installed
which xcodegen || echo "Install with: brew install xcodegen"

# Check if Xcode CLI tools are available
xcode-select -p
```

## Install Steps

```bash
# 1. Generate the Xcode project
xcodegen generate

# 2. Build the app
xcodebuild -scheme PortWatch -configuration Release build

# 3. Copy to Applications
cp -r ~/Library/Developer/Xcode/DerivedData/PortWatch-*/Build/Products/Release/PortWatch.app /Applications/

# 4. Launch
open /Applications/PortWatch.app
```

## Project Structure

```
PortWatch/
├── project.yml          # XcodeGen config
├── PortWatch/
│   ├── Info.plist       # App config (LSUIElement=true for menu bar)
│   ├── PortWatch.entitlements
│   ├── PortWatchApp.swift
│   ├── AppDelegate.swift
│   ├── Models/
│   │   └── PortInfo.swift
│   ├── Services/
│   │   └── PortScanner.swift
│   └── Views/
│       └── MenuView.swift
```

## Tech Stack

- Swift 5.9, SwiftUI, AppKit
- macOS 14.0+ (Sonoma)
- Uses `lsof -iTCP -sTCP:LISTEN` for port detection
- App Sandbox disabled (required for lsof)

## Verify It Works

After launching, check the menu bar for the network icon with port count. Click to see apps and their ports.
