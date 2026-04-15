# CarKeyboard — Claude Context

## Project
Floating on-screen keyboard for macOS, designed for touchscreen car setups.
Provides a draggable, always-on-top soft keyboard so the CX101 touchscreen can input text without a physical keyboard.
Repo: KreativConsultingServicesAIbuilt/CarKeyboard

## Hardware / Environment
- macOS 13+ (Ventura or later)
- CX101 touchscreen display at 1280×800 (car dashboard setup)
- Swift Package executable — built and run via terminal or LaunchAgent

## Architecture
- `Sources/FloatingKeyboard/` — Swift Package executable (macOS 13+)
  - Links against `Cocoa` and `Carbon` frameworks
  - `NSPanel`-based floating window (always-on-top, non-activating)
  - Touch-friendly key sizing optimized for the 1280×800 display
- `scripts/` — helper scripts (build, install, etc.)
- `.github/` — GitHub Actions CI

## Current Status (last updated: 2026-04-15)
- Core floating keyboard implementation in place
- Linked with Cocoa + Carbon for key event injection
- No LaunchAgent wired in yet — manual launch only

## Next Steps / Known Issues
- Wire up as LaunchAgent so it auto-starts with the dashboard
- Test key event injection works in all target apps (Safari, terminal)
- Adjust key layout and sizing for fat-finger touch use at 1280×800
- Consider an auto-hide trigger (e.g. hide when a text field loses focus)

## Key File Locations
- `Sources/FloatingKeyboard/` — all Swift source
- `Package.swift` — Swift Package definition
- `scripts/` — build/install helpers
