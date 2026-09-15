#!/usr/bin/env bash
# ============================================================
# Cài đặt Fiber Rescue (bot Telegram + dashboard Streamlit) làm
# systemd service NGAY TẠI thư mục gốc dự án (không copy sang thư
# mục khác). Bot và dashboard dùng chung 1 virtualenv (venv/).
#
# Dùng:
#   sudo ./deploy/install.sh
# ============================================================
set -euo pipefail

SERVICE_NAME="fiber_rescue"
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE_USER="${SERVICE_USER:-${SUDO_USER:-${USER:-$(id -un)}}}"

if [[ $EUID -ne 0 ]]; then
    echo "❌ Cần chạy bằng sudo/root (để tạo systemd service)."
    echo "   Ví dụ: sudo ./deploy/install.sh"
    exit 1
fi

if ! id "$SERVICE_USER" >/dev/null 2>&1; then
    echo "❌ User '$SERVICE_USER' không tồn tại. Tạo trước hoặc chỉ định SERVICE_USER=<user_có_sẵn>."
    exit 1
fi

echo "▶ Thư mục dự án:   $INSTALL_DIR"
echo "▶ Chạy bằng user:  $SERVICE_USER"
echo "▶ Tên service:     $SERVICE_NAME"
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

mkdir -p "$INSTALL_DIR/storage/photos"
chown -R "$SERVICE_USER":"$SERVICE_USER" "$INSTALL_DIR"

echo "▶ Tạo virtualenv dùng chung cho bot + dashboard ..."
sudo -u "$SERVICE_USER" python3 -m venv "$INSTALL_DIR/venv"
sudo -u "$SERVICE_USER" "$INSTALL_DIR/venv/bin/pip" install --upgrade pip -q
sudo -u "$SERVICE_USER" "$INSTALL_DIR/venv/bin/pip" install \
    -r "$INSTALL_DIR/requirements.txt" \
    -r "$INSTALL_DIR/requirements-dashboard.txt" -q

if [[ ! -f "$INSTALL_DIR/.env" ]]; then
    cp "$INSTALL_DIR/.env.example" "$INSTALL_DIR/.env"
    chown "$SERVICE_USER":"$SERVICE_USER" "$INSTALL_DIR/.env"
    chmod 600 "$INSTALL_DIR/.env"
    NEW_ENV=1
else
    NEW_ENV=0
fi

chmod +x "$INSTALL_DIR/deploy/run.sh"

echo "▶ Tạo systemd service ..."
sed \
    -e "s|__INSTALL_DIR__|$INSTALL_DIR|g" \
    -e "s|__SERVICE_USER__|$SERVICE_USER|g" \
    "$INSTALL_DIR/deploy/${SERVICE_NAME}.service.template" > "/etc/systemd/system/${SERVICE_NAME}.service"

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
echo "   3. Khởi động:      sudo systemctl start $SERVICE_NAME"
echo "   4. Xem trạng thái: sudo systemctl status $SERVICE_NAME"
echo "   5. Xem log:        sudo journalctl -u $SERVICE_NAME -f"
echo "   6. Dashboard mặc định chạy ở cổng 8501 (đổi bằng DASHBOARD_PORT trong .env nếu cần)"
