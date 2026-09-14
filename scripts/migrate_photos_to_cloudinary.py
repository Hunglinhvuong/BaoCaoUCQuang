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

Ghi chú: script này gọi thẳng REST API Cloudinary bằng `requests`
(utils/cloudinary_client.py), KHÔNG dùng SDK `cloudinary` — vì SDK không áp
dụng đúng proxy (HTTP_PROXY/HTTPS_PROXY) trên môi trường chỉ ra internet qua
proxy.
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import psycopg2
import psycopg2.extras

from config.settings import settings
from utils.cloudinary_client import list_all_resources


def _find_match(local_basename: str, cloud_map: dict):
    """Thử khớp theo nhiều chiến lược, từ chặt tới lỏng:
    1. Khớp chính xác.
    2. Cloudinary bật "Unique filename" khi upload -> tự thêm hậu tố ngẫu nhiên
       phía SAU tên gốc -> thử basename Cloudinary có BẮT ĐẦU bằng tên local không.
    3. Không phân biệt hoa/thường.
    """
    if local_basename in cloud_map:
        return cloud_map[local_basename], "exact"

    for cloud_basename, url in cloud_map.items():
        if cloud_basename.startswith(local_basename):
            return url, "prefix"

    local_lower = local_basename.lower()
    for cloud_basename, url in cloud_map.items():
        if cloud_basename.lower() == local_lower:
            return url, "case-insensitive"

    return None, None


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="Chỉ xem trước, không cập nhật DB")
    parser.add_argument("--prefix", default="", help="Prefix folder trên Cloudinary (nếu có)")
    args = parser.parse_args()

    if not settings.cloudinary_cloud_name:
        print("❌ Chưa cấu hình CLOUDINARY_CLOUD_NAME/API_KEY/API_SECRET trong .env")
        sys.exit(1)

    if settings.cloudinary_proxy:
        print(f"▶ Dùng proxy: {settings.cloudinary_proxy}")
    else:
        print("▶ Không cấu hình proxy (kết nối trực tiếp).")

    print("▶ Đang tải danh sách ảnh từ Cloudinary...")
    cloud_map = list_all_resources(args.prefix)
    print(f"  -> Tìm thấy {len(cloud_map)} ảnh trên Cloudinary.")
    if cloud_map:
        sample = list(cloud_map.keys())[:5]
        print("  -> Mẫu tên file (basename) thực tế trên Cloudinary:")
        for s in sample:
            print(f"       {s}")

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
    match_kinds = {}
    for row in rows:
        local_path = row["file_path"]
        basename_no_ext = os.path.splitext(os.path.basename(local_path))[0]
        cloud_url, kind = _find_match(basename_no_ext, cloud_map)
        if cloud_url:
            matched.append((row["photo_id"], local_path, cloud_url))
            match_kinds[kind] = match_kinds.get(kind, 0) + 1
        else:
            unmatched.append((local_path, basename_no_ext))

    print(f"▶ Khớp được {len(matched)}/{len(rows)} ảnh. Chi tiết: {match_kinds}")
    if unmatched:
        print(f"⚠️  {len(unmatched)} ảnh KHÔNG khớp được (không thấy trên Cloudinary):")
        for p, _ in unmatched[:20]:
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
