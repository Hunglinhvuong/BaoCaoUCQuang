import asyncio
import logging
import uuid

import cloudinary
import cloudinary.uploader
from telegram import File

from config.settings import settings

logger = logging.getLogger(__name__)

cloudinary.config(
    cloud_name=settings.cloudinary_cloud_name,
    api_key=settings.cloudinary_api_key,
    api_secret=settings.cloudinary_api_secret,
    secure=True,
)


class PhotoService:
    """Upload ảnh Telegram thẳng lên Cloudinary — KHÔNG lưu file cục bộ.

    Ảnh được tải về RAM (bytes) từ Telegram rồi upload ngay lên Cloudinary,
    trả về secure_url để lưu vào cột incident_photo.file_path.
    """

    async def save_photo(self, tg_file: File, session_id: str, photo_type: str) -> str:
        file_bytes = await tg_file.download_as_bytearray()
        public_id = f"{session_id}/{photo_type.lower()}_{uuid.uuid4().hex}"

        # cloudinary.uploader.upload là hàm đồng bộ (blocking network call) ->
        # chạy trong thread riêng để không chặn event loop của bot.
        result = await asyncio.to_thread(
            cloudinary.uploader.upload,
            bytes(file_bytes),
            folder=settings.cloudinary_folder,
            public_id=public_id,
            resource_type="image",
            overwrite=False,
        )
        return result["secure_url"]
