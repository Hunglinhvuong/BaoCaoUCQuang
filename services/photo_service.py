import asyncio
import logging
import uuid

from telegram import File

from config.settings import settings
from utils.cloudinary_client import upload_image

logger = logging.getLogger(__name__)


class PhotoService:
    """Upload ảnh Telegram thẳng lên Cloudinary — KHÔNG lưu file cục bộ.

    Ảnh được tải về RAM (bytes) từ Telegram rồi upload ngay lên Cloudinary
    qua utils.cloudinary_client (tự viết bằng requests, hỗ trợ proxy ổn định
    hơn SDK chính thức), trả về secure_url để lưu vào incident_photo.file_path.
    """

    async def save_photo(self, tg_file: File, session_id: str, photo_type: str) -> str:
        file_bytes = await tg_file.download_as_bytearray()
        public_id = f"{photo_type.lower()}_{uuid.uuid4().hex}"

        # requests.post là hàm đồng bộ (blocking network call) -> chạy trong
        # thread riêng để không chặn event loop của bot.
        return await asyncio.to_thread(
            upload_image,
            bytes(file_bytes),
            public_id,
            f"{settings.cloudinary_folder}/{session_id}",
        )
