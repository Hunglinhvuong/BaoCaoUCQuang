#!/usr/bin/env bash
# ============================================================
# Cài đặt Fiber Rescue Bot làm systemd service trên Linux.
#
# Dùng:
#   sudo ./deploy/install.sh [thư_mục_cài_đặt]
#
# Mặc định thư mục cài đặt: /opt/fiber_rescue
# Biến môi trường SERVICE_USER (tuỳ chọn): user chạy bot,
# mặc định là user gọi sudo (hoặc $USER nếu chạy trực tiếp bằng root).
# ============================================================
set -euo pipefail

INSTALL_DIR="${1:-/opt/fiber_rescue}"
SERVICE_USER="${SERVICE_USER:-${SUDO_USER:-$USER}}"
SERVICE_NAME="fiber-rescue-bot"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $EUID -ne 0 ]]; then
    echo "❌ Cần chạy bằng sudo/root (để tạo systemd service)."
    echo "   Ví dụ: sudo ./deploy/install.sh"
    exit 1
fi

if ! id "$SERVICE_USER" >/dev/null 2>&1; then
    echo "❌ User '$SERVICE_USER' không tồn tại. Tạo trước hoặc chỉ định SERVICE_USER=<user_có_sẵn>."
    exit 1
fi

echo "▶ Nguồn code:      $SOURCE_DIR"
echo "▶ Cài đặt vào:     $INSTALL_DIR"
echo "▶ Chạy bằng user:  $SERVICE_USER"
echo ""

command -v python3 >/dev/null 2>&1 || { echo "❌ Chưa cài python3."; exit 1; }
PY_VERSION="$(python3 -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')"
PY_MAJOR="$(python3 -c 'import sys; print(sys.version_info[0])')"
PY_MINOR="$(python3 -c 'import sys; print(sys.version_info[1])')"
echo "▶ Python version:  $PY_VERSION"
if [[ "$PY_MAJOR" -lt 3 || ( "$PY_MAJOR" -eq 3 && "$PY_MINOR" -lt 10 ) ]]; then
    echo "❌ Cần Python >= 3.10 (đang có $PY_VERSION)."
    exit 1
fi

command -v rsync >/dev/null 2>&1 || { echo "❌ Chưa cài rsync (sudo apt install rsync)."; exit 1; }

echo "▶ Copy code vào $INSTALL_DIR ..."
mkdir -p "$INSTALL_DIR"
rsync -a --delete \
    --exclude 'venv' \
    --exclude '__pycache__' \
    --exclude '*.pyc' \
    --exclude '.git' \
    --exclude 'storage/photos/*' \
    --exclude 'storage/*.pickle' \
    --exclude '.env' \
    "$SOURCE_DIR/" "$INSTALL_DIR/"

mkdir -p "$INSTALL_DIR/storage/photos"
chown -R "$SERVICE_USER":"$SERVICE_USER" "$INSTALL_DIR"

echo "▶ Tạo virtualenv & cài dependencies ..."
sudo -u "$SERVICE_USER" python3 -m venv "$INSTALL_DIR/venv"
sudo -u "$SERVICE_USER" "$INSTALL_DIR/venv/bin/pip" install --upgrade pip -q
sudo -u "$SERVICE_USER" "$INSTALL_DIR/venv/bin/pip" install -r "$INSTALL_DIR/requirements.txt" -q

if [[ ! -f "$INSTALL_DIR/.env" ]]; then
    cp "$INSTALL_DIR/.env.example" "$INSTALL_DIR/.env"
    chown "$SERVICE_USER":"$SERVICE_USER" "$INSTALL_DIR/.env"
    chmod 600 "$INSTALL_DIR/.env"
    NEW_ENV=1
else
    NEW_ENV=0
fi

echo "▶ Tạo systemd service ..."
sed \
    -e "s|__INSTALL_DIR__|$INSTALL_DIR|g" \
    -e "s|__SERVICE_USER__|$SERVICE_USER|g" \
    "$SOURCE_DIR/deploy/${SERVICE_NAME}.service.template" > "/etc/systemd/system/${SERVICE_NAME}.service"

systemctl daemon-reload
systemctl enable "$SERVICE_NAME" >/dev/null

echo ""
echo "✅ Cài đặt xong."
if [[ "$NEW_ENV" -eq 1 ]]; then
    echo "   1. Sửa cấu hình:  sudo nano $INSTALL_DIR/.env"
else
    echo "   1. (.env đã tồn tại sẵn, giữ nguyên) — kiểm tra lại nếu cần: sudo nano $INSTALL_DIR/.env"
fi
echo "   2. Tạo database (nếu chưa có): psql -d <db> -f $INSTALL_DIR/database/schema.sql"
echo "   3. Khởi động:     sudo systemctl start $SERVICE_NAME"
echo "   4. Xem trạng thái: sudo systemctl status $SERVICE_NAME"
echo "   5. Xem log:        sudo journalctl -u $SERVICE_NAME -f"
