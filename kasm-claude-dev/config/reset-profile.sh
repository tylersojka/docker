#!/bin/bash

# Reset Kasm home directory to factory defaults
DIALOG=$(which zenity 2>/dev/null)

confirm() {
    if [ -n "$DIALOG" ]; then
        zenity --question \
            --title="Reset Profile" \
            --text="This will DELETE all your personal data and restore the default profile.\n\nThis includes:\n• Projects in claude-workspace\n• API keys and configs\n• Browser data and bookmarks\n• Shell history\n• SSH keys\n• Everything in your home directory\n\nThis cannot be undone. Continue?" \
            --width=400 \
            --ok-label="Reset Everything" \
            --cancel-label="Cancel"
        return $?
    else
        echo "⚠️  WARNING: This will DELETE all personal data and restore defaults."
        echo "This cannot be undone."
        read -p "Type 'RESET' to confirm: " answer
        [ "$answer" = "RESET" ] && return 0 || return 1
    fi
}

notify() {
    if [ -n "$DIALOG" ]; then
        zenity --info --title="Profile Reset" --text="$1" --width=300
    else
        echo "$1"
    fi
}

error() {
    if [ -n "$DIALOG" ]; then
        zenity --error --title="Reset Failed" --text="$1" --width=300
    else
        echo "ERROR: $1"
    fi
}

if ! confirm; then
    exit 0
fi

DEFAULT_PROFILE="/home/kasm-default-profile"

if [ ! -d "$DEFAULT_PROFILE" ]; then
    error "Default profile not found at $DEFAULT_PROFILE.\nCannot reset."
    exit 1
fi

# Remove everything in home except the reset script itself
cd /home/kasm-user || exit 1

# Delete all files and directories (hidden and visible)
find /home/kasm-user -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null

# Copy defaults back from the template profile
cp -a ${DEFAULT_PROFILE}/. /home/kasm-user/

# Fix ownership
chown -R 1000:1000 /home/kasm-user/

notify "Profile has been reset to defaults.\n\nPlease close this session and start a new one for all changes to take effect."