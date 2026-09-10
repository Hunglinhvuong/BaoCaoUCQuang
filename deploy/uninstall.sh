#!/usr/bin/env bash
# ============================================================
# Gỡ cài đặt Fiber Rescue Bot (dừng + xoá systemd service).
#
# Dùng:
#   sudo ./deploy/uninstall.sh [thư_mục_cài_đặt]
# ============================================================
set -euo pipefail

INSTALL_DIR="${1:-/opt/fiber_rescue}"
SERVICE_NAME="fiber-rescue-bot"

if [[ $EUID -ne 0 ]]; then
    echo "❌ Cần chạy bằng sudo/root."
    exit 1
fi

echo "▶ Dừng & vô hiệu hoá service ..."
systemctl stop "$SERVICE_NAME" 2>/dev/null || true
systemctl disable "$SERVICE_NAME" 2>/dev/null || true
rm -f "/etc/systemd/system/${SERVICE_NAME}.service"
systemctl daemon-reload

if [[ -d "$INSTALL_DIR" ]]; then
    read -rp "Xoá luôn thư mục cài đặt $INSTALL_DIR (kể cả ảnh đã lưu trong storage/photos)? [y/N] " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        rm -rf "$INSTALL_DIR"
        echo "✅ Đã xoá $INSTALL_DIR."
    else
        echo "Giữ lại $INSTALL_DIR (chỉ gỡ service)."
    fi
fi

echo "✅ Đã gỡ cài đặt $SERVICE_NAME."
