"""
Script MỘT LẦN: cập nhật cột incident_photo.file_path từ đường dẫn local
(storage/photos/...) sang URL Cloudinary — dùng sau khi đã upload thủ công
thư mục storage/photos/ lên Cloudinary.

Cách khớp: lấy TÊN FILE (không đuôi) của từng ảnh trong DB, so với public_id
(basename) của từng ảnh trên Cloudinary. Vì tên file sinh ra khi chụp là
uuid4 ngẫu nhiên (VD: before_3f9a1b2c....jpg) nên khớp theo tên file là an toàn,
không lo trùng.

Cách dùng:
    python scripts/migrate_photos_to_cloudinary.py --dry-run   # xem trước, KHÔNG sửa DB
    python scripts/migrate_photos_to_cloudinary.py             # thực sự cập nhật (có xác nhận)
    python scripts/migrate_photos_to_cloudinary.py --prefix fiber_rescue/photos

Yêu cầu .env đã có đủ CLOUDINARY_CLOUD_NAME / CLOUDINARY_API_KEY /
CLOUDINARY_API_SECRET và các biến DB_* như bình thường.
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import cloudinary
import cloudinary.api
import psycopg2
import psycopg2.extras

from config.settings import settings

cloudinary.config(
    cloud_name=settings.cloudinary_cloud_name,
    api_key=settings.cloudinary_api_key,
    api_secret=settings.cloudinary_api_secret,
    secure=True,
)


def list_cloudinary_resources(prefix: str = "") -> dict:
    """Trả về dict {basename_không_đuôi: secure_url} cho toàn bộ ảnh trên Cloudinary
    (duyệt phân trang bằng next_cursor cho tới khi hết)."""
    mapping = {}
    next_cursor = None
    while True:
        kwargs = {"type": "upload", "resource_type": "image", "max_results": 500}
        if prefix:
            kwargs["prefix"] = prefix
        if next_cursor:
            kwargs["next_cursor"] = next_cursor

        result = cloudinary.api.resources(**kwargs)
        for res in result.get("resources", []):
            basename = res["public_id"].rsplit("/", 1)[-1]
            mapping[basename] = res["secure_url"]

        next_cursor = result.get("next_cursor")
        if not next_cursor:
            break
    return mapping


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="Chỉ xem trước, không cập nhật DB")
    parser.add_argument("--prefix", default="", help="Prefix folder trên Cloudinary (nếu có)")
    args = parser.parse_args()

    if not settings.cloudinary_cloud_name:
        print("❌ Chưa cấu hình CLOUDINARY_CLOUD_NAME/API_KEY/API_SECRET trong .env")
        sys.exit(1)

    print("▶ Đang tải danh sách ảnh từ Cloudinary...")
    cloud_map = list_cloudinary_resources(args.prefix)
    print(f"  -> Tìm thấy {len(cloud_map)} ảnh trên Cloudinary.")

    conn = psycopg2.connect(
        host=settings.db_host, port=settings.db_port, dbname=settings.db_name,
        user=settings.db_user, password=settings.db_password,
    )
    read_cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    read_cur.execute(
        "SELECT photo_id, file_path FROM incident_photo WHERE file_path NOT LIKE 'http%'"
    )
    rows = read_cur.fetchall()
    print(f"▶ Có {len(rows)} ảnh trong DB đang lưu đường dẫn local (chưa migrate).")

    matched, unmatched = [], []
    for row in rows:
        local_path = row["file_path"]
        basename_no_ext = os.path.splitext(os.path.basename(local_path))[0]
        cloud_url = cloud_map.get(basename_no_ext)
        if cloud_url:
            matched.append((row["photo_id"], local_path, cloud_url))
        else:
            unmatched.append(local_path)

    print(f"▶ Khớp được {len(matched)}/{len(rows)} ảnh.")
    if unmatched:
        print(f"⚠️  {len(unmatched)} ảnh KHÔNG khớp được (không thấy trên Cloudinary):")
        for p in unmatched[:20]:
            print(f"   - {p}")
        if len(unmatched) > 20:
            print(f"   ... và {len(unmatched) - 20} ảnh khác")

    if args.dry_run:
        print("\n(--dry-run) Không ghi gì vào DB. Chạy lại không kèm --dry-run để áp dụng.")
        read_cur.close()
        conn.close()
        return

    if not matched:
        print("Không có gì để cập nhật.")
        read_cur.close()
        conn.close()
        return

    confirm = input(f"\nGhi đè {len(matched)} dòng trong incident_photo? Gõ 'yes' để tiếp tục: ")
    if confirm.strip().lower() != "yes":
        print("Đã huỷ, không thay đổi gì.")
        read_cur.close()
        conn.close()
        return

    write_cur = conn.cursor()
    for photo_id, _, cloud_url in matched:
        write_cur.execute(
            "UPDATE incident_photo SET file_path = %s WHERE photo_id = %s",
            (cloud_url, photo_id),
        )
    conn.commit()
    print(f"✅ Đã cập nhật {len(matched)} dòng trong incident_photo.")

    read_cur.close()
    write_cur.close()
    conn.close()


if __name__ == "__main__":
    main()
