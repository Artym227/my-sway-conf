#!/bin/bash

# Пути
REPO_DIR="$HOME/my-sway-conf"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/config_backup_$(date +%Y%m%d_%H%M%S)"

# Список папок для копирования
dots=("sway" "waybar" "wofi" "gtk-3.0" "gtk-4.0")

echo "--- Starting config installation ---"

# 1. Бэкап старых конфигов
echo "1. Creating backups in $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
for item in "${dots[@]}"; do
    if [ -d "$CONFIG_DIR/$item" ]; then
        cp -r "$CONFIG_DIR/$item" "$BACKUP_DIR/"
    fi
done
[ -f "$HOME/.config/kdeglobals" ] && cp "$HOME/.config/kdeglobals" "$BACKUP_DIR/"

# 2. Копирование новых конфигов
echo "2. Copying new config in  $CONFIG_DIR..."
for item in "${dots[@]}"; do
    mkdir -p "$CONFIG_DIR/$item"
    cp -r "$REPO_DIR/$item/"* "$CONFIG_DIR/$item/"
done
cp "$REPO_DIR/kdeglobals" "$CONFIG_DIR/" 2>/dev/null || echo "File kdeglobals not found. Skipping..."

# 3. Настройка .bashrc (Экспорты для темной темы)
echo "3. Checking variables in .bashrc..."
EXPORTS=(
    'export QT_QPA_PLATFORMTHEME=gtk3'
    'export QT_WAYLAND_DISABLE_WINDOWDECORATION=1'
    'export MOZ_ENABLE_WAYLAND=1'
)

for line in "${EXPORTS[@]}"; do
    if ! grep -Fxq "$line" "$HOME/.bashrc"; then
        echo "$line" >> "$HOME/.bashrc"
        echo "Added: $line"
    else
        echo "Already: $line"
    fi
done

# Список нужных программ
apps=("pasystray" "pavucontrol" "font-awesome-fonts")

echo "Checking dependecies..."
for app in "${apps[@]}"; do
    if ! rpm -q $app &>/dev/null; then
        echo "Устанавливаю $app..."
        sudo dnf install -y $app
    fi
done

echo "--- All right! Re run terminal or enter: source ~/.bashrc ---"
