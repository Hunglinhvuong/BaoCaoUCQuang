import logging
from typing import Optional

from psycopg2 import pool as pg_pool

from config.settings import settings

logger = logging.getLogger(__name__)

_pool: Optional[pg_pool.SimpleConnectionPool] = None


def get_sync_pool() -> pg_pool.SimpleConnectionPool:
    global _pool
    if _pool is None:
        _pool = pg_pool.SimpleConnectionPool(
            1,
            settings.db_max_pool,
            host=settings.db_host,
            port=settings.db_port,
            dbname=settings.db_name,
            user=settings.db_user,
            password=settings.db_password,
        )
        logger.info("Sync DB pool (dashboard) initialized")
    return _pool


def get_sync_connection():
    return get_sync_pool().getconn()


def release_sync_connection(conn) -> None:
    get_sync_pool().putconn(conn)
