import os
import logging
import time
from bot.bot import run

os.environ['TZ'] = 'Asia/Ho_Chi_Minh'
time.tzset()

logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO,
)
logging.getLogger("httpx").setLevel(logging.WARNING)

if __name__ == "__main__":
    run()

