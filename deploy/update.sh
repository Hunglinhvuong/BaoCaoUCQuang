#!/usr/bin/env bash
# ============================================================
# Cập nhật code cho Fiber Rescue Bot đã cài đặt (deploy/install.sh)
# và restart lại systemd service. KHÔNG đụng tới file .env.
#
# Dùng:
#   sudo ./deploy/update.sh [thư_mục_cài_đặt]
# ============================================================
set -euo pipefail

INSTALL_DIR="${1:-/opt/fiber_rescue}"
SERVICE_NAME="fiber-rescue-bot"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $EUID -ne 0 ]]; then
    echo "❌ Cần chạy bằng sudo/root."
    exit 1
fi

if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "❌ Chưa thấy $INSTALL_DIR. Chạy deploy/install.sh trước."
    exit 1
fi

SERVICE_USER="$(stat -c '%U' "$INSTALL_DIR")"
echo "▶ Cập nhật code vào $INSTALL_DIR (user: $SERVICE_USER) ..."

rsync -a \
    --exclude 'venv' \
    --exclude '__pycache__' \
    --exclude '*.pyc' \
    --exclude '.git' \
    --exclude 'storage/photos/*' \
    --exclude 'storage/*.pickle' \
    --exclude '.env' \
    "$SOURCE_DIR/" "$INSTALL_DIR/"

chown -R "$SERVICE_USER":"$SERVICE_USER" "$INSTALL_DIR"

echo "▶ Cài lại dependencies (nếu requirements.txt thay đổi) ..."
sudo -u "$SERVICE_USER" "$INSTALL_DIR/venv/bin/pip" install -r "$INSTALL_DIR/requirements.txt" -q

echo "▶ Restart service ..."
systemctl restart "$SERVICE_NAME"

echo "✅ Đã cập nhật & restart $SERVICE_NAME."
echo "   Xem log: sudo journalctl -u $SERVICE_NAME -f"
