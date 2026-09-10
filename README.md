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

## Ghi chú

- Ảnh lưu tại `storage/photos/<session_id>/`.
- Repository `material_repository` khớp vật tư theo `material_rule`
  (NULL trong rule = wildcard khớp mọi giá trị của cột đó).
- Chưa gồm `dashboard/` (Streamlit) trong phạm vi này — báo nếu cần bổ sung.
