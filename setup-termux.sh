#!/data/data/com.termux/files/usr/bin/bash
# Hermes Agent Phone Setup — run this in Termux on your Android device
# Sets up: Termux API, Android tools, Hermes CLI, SSH access, ADB daemon

set -e

echo "🔧 Hermes Agent Phone Setup"
echo "============================"

# 1. Update Termux packages
echo "📦 Updating Termux packages..."
pkg update -y && pkg upgrade -y

# 2. Install core tools
echo "📦 Installing core tools..."
pkg install -y openssh termux-api termux-services android-tools ncurses-utils git python python-pip

# 3. Set up SSH daemon (auto-start)
echo "🔑 Setting up SSH daemon..."
ssh-keygen -A 2>/dev/null || true
# Start sshd via Termux services
sv-enable sshd 2>/dev/null || true
sv start sshd 2>/dev/null || true
echo "SSH daemon running on port 8022"

# 4. Set up ADB daemon (wireless debugging)
echo "📱 Setting up ADB daemon..."
adb start-server 2>/dev/null || true
# Enable ADB over TCP on port 5555
setprop service.adb.tcp.port 5555 2>/dev/null || true
echo "ADB daemon starting..."

# 5. Install Hermes Agent
echo "🤖 Installing Hermes Agent..."
pip install hermes-agent 2>/dev/null || {
    # Fallback: install from source
    cd ~
    git clone https://github.com/NousResearch/hermes-agent.git .hermes/hermes-agent 2>/dev/null || true
    cd .hermes/hermes-agent
    pip install -e . 2>/dev/null || echo "⚠️  Install hermes-agent manually: pip install hermes-agent"
}

# 6. Create hermes config directory
mkdir -p ~/.hermes/profiles

# 7. Set up PATH for hermes
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.hermes/hermes-agent:$PATH"' >> ~/.bashrc

# 8. Install the Hermes APK (if downloaded)
echo "📱 Installing Hermes Desktop APK..."
if [ -f /storage/emulated/0/Download/hermes.apk ]; then
    am install -r /storage/emulated/0/Download/hermes.apk 2>/dev/null || \
    echo "⚠️  Install APK manually: Open Files → Downloads → hermes.apk"
else
    echo "⚠️  APK not found in Downloads. Download from:"
    echo "   https://github.com/SouthpawIN/hermes-android/raw/main/hermes-0.17.0-android-debug.apk"
fi

# 9. Create a Hermes gateway launcher script
cat > ~/hermes-gateway.sh << 'GATEWAY'
#!/data/data/com.termux/files/usr/bin/bash
# Start Hermes gateway on the phone
# Connects to the local Hermes instance or a remote gateway
export HERMES_HOME="$HOME/.hermes"
if [ -n "$1" ]; then
    # Remote gateway URL provided
    echo "Connecting to remote gateway: $1"
    hermes gateway run --remote "$1"
else
    hermes gateway run
fi
GATEWAY
chmod +x ~/hermes-gateway.sh

# 10. Print connection info
echo ""
echo "✅ Setup complete!"
echo "=================="
echo ""
echo "📱 Phone SSH:   ssh -p 8022 $(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 || echo '<your-phone-ip>')"
echo "🤖 Hermes CLI:  hermes"
echo "🌐 Gateway:     ~/hermes-gateway.sh [remote-url]"
echo "📱 APK:         Install from Downloads or https://github.com/SouthpawIN/hermes-android"
echo ""
echo "Tailscale users: your phone's Tailscale IP is in the Tailscale app"
