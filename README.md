# Hermes Android

Hermes Agent on Android — APK builds + Termux setup scripts.

## Quick Install

### Option 1: APK (recommended)

Download and install the latest APK:

**[⬇️ Download hermes-0.17.0-android-debug.apk](https://github.com/SouthpawIN/hermes-android/raw/main/hermes-0.17.0-android-debug.apk)**

You'll need to enable "Install from unknown sources" in your phone's settings.

### Option 2: Termux (full agent control)

1. Install [Termux](https://f-droid.org/en/packages/com.termux/) from F-Droid
2. Run:
```bash
curl -fsSL https://raw.githubusercontent.com/SouthpawIN/hermes-android/main/setup-termux.sh | bash
```

This gives you: SSH access, ADB daemon, Hermes CLI, and the gateway running on your phone.

## What you get

| Method | Chat | Gateway | Agent Tools | SSH |
|--------|------|---------|-------------|-----|
| **APK** | ✅ React UI | Connects to remote | Via gateway | ❌ |
| **Termux** | ✅ CLI | ✅ Full | ✅ Full | ✅ |

## Architecture

The APK is the Hermes Desktop React renderer (Vite + React + Tailwind) wrapped in Capacitor for Android. It connects to a Hermes gateway via WebSocket — either on your local machine, or running in Termux on the same phone.

```
Phone (APK) ──WS──▶ Hermes Gateway ──HTTP──▶ LLM Provider
Phone (Termux) ──▶ hermes gateway run ──▶ Same stack, full CLI
```

## Connecting to your gateway

On first launch, the app needs to know where your Hermes gateway is running:

- **Same WiFi**: `http://192.168.x.x:8642`
- **Tailscale**: `http://100.x.x.x:8642`
- **Termux on same phone**: `http://localhost:8642`

## Building from source

```bash
cd apps/desktop
npm install --workspace apps/desktop
npm run build
npx cap sync android
cd android && ./gradlew assembleDebug
```

APK output: `android/app/build/outputs/apk/debug/app-debug.apk`

## TOWARDS SELF-IMPROVEMENT
