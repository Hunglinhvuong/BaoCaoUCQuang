import uuid
from pathlib import Path

from telegram import File

from config.settings import settings


class PhotoService:
    def __init__(self):
        self.base_dir = Path(settings.photo_storage_dir)
        self.base_dir.mkdir(parents=True, exist_ok=True)

    async def save_photo(self, tg_file: File, session_id: str, photo_type: str) -> str:
        """Lưu 1 ảnh Telegram vào storage/photos/<session_id>/<type>_<uuid>.jpg
        và trả về đường dẫn file trên đĩa (dùng để ghi vào incident_photo.file_path)."""
        session_dir = self.base_dir / session_id
        session_dir.mkdir(parents=True, exist_ok=True)

        filename = f"{photo_type}_{uuid.uuid4().hex}.jpg"
        file_path = session_dir / filename

        await tg_file.download_to_drive(custom_path=str(file_path))
        return str(file_path)
