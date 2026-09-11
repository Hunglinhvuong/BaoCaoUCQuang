import os
from dataclasses import dataclass, field
from typing import Tuple

from dotenv import load_dotenv

load_dotenv()


def _parse_admin_ids(raw: str) -> Tuple[int, ...]:
    return tuple(int(x) for x in raw.split(",") if x.strip())


@dataclass(frozen=True)
class Settings:
    telegram_bot_token: str = os.getenv("TELEGRAM_BOT_TOKEN", "")

    db_host: str = os.getenv("DB_HOST", "localhost")
    db_port: int = int(os.getenv("DB_PORT", "5432"))
    db_name: str = os.getenv("DB_NAME", "fiber_rescue")
    db_user: str = os.getenv("DB_USER", "postgres")
    db_password: str = os.getenv("DB_PASSWORD", "")
    db_min_pool: int = int(os.getenv("DB_MIN_POOL", "2"))
    db_max_pool: int = int(os.getenv("DB_MAX_POOL", "10"))

    photo_storage_dir: str = os.getenv("PHOTO_STORAGE_DIR", "storage/photos")
    persistence_file: str = os.getenv("PERSISTENCE_FILE", "storage/bot_persistence.pickle")
    timezone: str = os.getenv("APP_TIMEZONE", "Asia/Ho_Chi_Minh")

    admin_telegram_ids: Tuple[int, ...] = field(
        default_factory=lambda: _parse_admin_ids(os.getenv("ADMIN_TELEGRAM_IDS", ""))
    )

    @property
    def dsn(self) -> str:
        return (
            f"postgresql://{self.db_user}:{self.db_password}"
            f"@{self.db_host}:{self.db_port}/{self.db_name}"
        )


settings = Settings()
