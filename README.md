# Fiber Rescue Bot

Bot Telegram báo cáo ứng cứu sự cố cáp quang từ hiện trường, lưu PostgreSQL.

## Cài đặt

```bash
python -m venv venv
source venv/bin/activate       # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## Cấu hình

```bash
cp .env.example .env
# điền TELEGRAM_BOT_TOKEN và thông tin kết nối PostgreSQL
```

## Tạo database

```bash
createdb fiber_rescue
psql -d fiber_rescue -f database/schema.sql
```

Sau khi chạy schema, cần thêm dữ liệu vào các bảng `fiber_route`, `material`,
`material_rule` (vật tư theo cấu hình cable_type/fiber_count/repair_span_type)
để bot có dữ liệu để chọn.

## Chạy bot

```bash
python app.py
```

## Lệnh sử dụng

- `/start` — đăng ký (lần đầu, mặc định quyền **VIEWER**/chỉ xem) hoặc đăng nhập lại.
  Admin (trong `ADMIN_TELEGRAM_IDS`) sẽ nhận thông báo khi có người dùng mới.
- `/setrole <telegram_id> <ADMIN|MANAGER|FIELD|VIEWER>` — chỉ admin dùng để cấp quyền.
- `/bc` — bắt đầu báo cáo sự cố (yêu cầu quyền ADMIN/MANAGER/FIELD): chọn tuyến →
  chọn loại sự cố → chọn nguyên nhân → chọn đoạn khắc phục (UNDERGROUND/KV100...KV500) →
  chọn vật tư + số lượng → nhập mô tả → gửi GPS → gửi ảnh trước → gửi ảnh sau →
  xác nhận → lưu CSDL (tạo `incident`, `incident_material`, `incident_photo`,
  `incident_status_history` trong 1 transaction).
- `/kt` — tra cứu sự cố: chọn ngày → chọn mã sự cố → xem chi tiết + ảnh đã gửi
  (FIELD chỉ xem sự cố của chính mình; ADMIN/MANAGER/VIEWER xem toàn bộ).

## Triển khai trên máy Linux khác (systemd)

Copy nguyên thư mục project (hoặc git clone) sang máy đích, sau đó:

```bash
sudo ./deploy/install.sh                 # cài vào /opt/fiber_rescue (mặc định)
sudo ./deploy/install.sh /path/khac      # hoặc chỉ định thư mục khác
```

Script tự động: kiểm tra Python >= 3.10, copy code, tạo virtualenv, cài
`requirements.txt`, tạo `.env` từ mẫu (nếu chưa có), tạo + enable systemd
service `fiber-rescue-bot`.

Sau khi cài:
```bash
sudo nano /opt/fiber_rescue/.env                       # điền TELEGRAM_BOT_TOKEN, DB...
psql -d fiber_rescue -f /opt/fiber_rescue/database/schema.sql   # nếu DB chưa có
sudo systemctl start fiber-rescue-bot
sudo systemctl status fiber-rescue-bot
sudo journalctl -u fiber-rescue-bot -f                  # xem log realtime
```

Bot tự khởi động lại nếu crash (`Restart=always`) và tự chạy khi máy khởi động
lại (`systemctl enable`).

**Cập nhật code** (sau khi đã cài): copy code mới đè lên thư mục nguồn rồi chạy
```bash
sudo ./deploy/update.sh [thư_mục_cài_đặt]
```
(không đụng tới `.env`, chỉ đồng bộ code + cài lại dependencies + restart service).

**Gỡ cài đặt:**
```bash
sudo ./deploy/uninstall.sh [thư_mục_cài_đặt]
```

## Dashboard Streamlit

Dashboard đọc trực tiếp từ cùng PostgreSQL (kết nối đồng bộ riêng, không đụng
tới pool async của bot) và hiển thị ảnh trực tiếp từ URL Cloudinary.

```bash
python -m venv venv-dashboard        # có thể dùng chung venv với bot cũng được
source venv-dashboard/bin/activate
pip install -r requirements-dashboard.txt
streamlit run dashboard/app.py
```

Mặc định chạy ở `http://localhost:8501`. Cấu hình DB lấy chung từ file `.env`
(`DB_HOST`, `DB_NAME`...) — đảm bảo `.env` đã có sẵn ở thư mục gốc trước khi chạy.

**Các trang đã triển khai:**
- 📊 **Tổng quan** — KPI (tổng số, đang xử lý, hoàn tất, hôm nay, 7 ngày), biểu đồ
  sự cố theo ngày, nguyên nhân, top tuyến nhiều sự cố.
- 🗺️ **Bản đồ sự cố** — marker theo toạ độ GPS (màu theo trạng thái), click marker
  xem thông tin nhanh rồi mở chi tiết đầy đủ.
- 🚨 **Sự cố** — bảng lọc theo ngày/trạng thái/tuyến/loại/nguyên nhân/từ khoá,
  xuất Excel, click 1 dòng để xem chi tiết + ảnh trước/sau (dạng popup).

**Chưa triển khai** (theo yêu cầu, để ở bước sau): Phân tích, Vật tư, Tuyến cáp.

⚠️ Dashboard hiện **chưa có xác thực đăng nhập** — hiển thị ảnh hiện trường và
thông tin sự cố cho bất kỳ ai truy cập được URL. Nếu deploy ra ngoài mạng nội bộ,
cần đặt sau reverse proxy có auth (VD: Nginx + Basic Auth, hoặc Streamlit
`st.login` nếu dùng bản có hỗ trợ) trước khi public.

## Ghi chú

- **Ảnh trước/sau khắc phục**: máy chủ bot KHÔNG tải/lưu bytes ảnh. Luồng:
  Telegram (`file_id`) → `getFile` → URL file Telegram → gửi URL đó cho
  Cloudinary tự fetch (upload REST API, `file=<url>`) → nhận về
  `secure_url`/`public_id`/`asset_id`, lưu vào `incident_photo.cloudinary_url` /
  `cloudinary_public_id` / `cloudinary_asset_id`. Cần cấu hình
  `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET` trong
  `.env` (và `CLOUDINARY_PROXY` nếu máy chủ ra internet qua proxy).
  `/kt` (Telegram) gửi lại ảnh qua `telegram_file_id` (không qua Cloudinary);
  Streamlit nhúng thẳng `cloudinary_url` — trình duyệt người xem tự tải ảnh từ
  Cloudinary, dashboard không xử lý ảnh.
- Nếu nâng cấp từ bản cũ (còn ảnh lưu local hoặc cột `file_path`), chạy lần lượt:
  ```bash
  python scripts/migrate_photos_to_cloudinary.py --dry-run   # rồi bỏ --dry-run
  python scripts/migrate_incident_photo_schema.py --dry-run  # rồi bỏ --dry-run
  ```
  (script 2 cần chạy sau script 1, đổi cấu trúc bảng sang cột Cloudinary riêng
  + đổi tên `photo_id`→`incident_photo_id`, `uploaded_at`→`created_at`.)
- Repository `material_repository` khớp vật tư theo `material_rule`
  (NULL trong rule = wildcard khớp mọi giá trị của cột đó).
- `/bc` tự huỷ báo cáo đang nhập dở nếu không thao tác gì trong 3 phút
  (`conversation_timeout` trong `incident_handler.py`). Cần cài lại
  `pip install -r requirements.txt` (đã thêm extra `job-queue`) trên các máy
  đã triển khai trước đó để tính năng này hoạt động.
- Chưa gồm `dashboard/` (Streamlit) trong phạm vi này — báo nếu cần bổ sung.
