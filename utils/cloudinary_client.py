"""
Client Cloudinary tự viết bằng `requests`, KHÔNG dùng SDK `cloudinary` chính thức.

Lý do: bản SDK cloudinary (urllib3 nội bộ) không áp dụng đúng `api_proxy` cho
API listing (cloudinary.api.resources), khiến máy chủ chỉ ra internet qua
proxy (HTTP_PROXY/HTTPS_PROXY) không kết nối được. `requests` hỗ trợ `proxies=`
ổn định, rõ ràng, không phụ thuộc hành vi nội bộ khó đoán của SDK.
"""
import hashlib
import time
from typing import Dict, Optional

import requests

from config.settings import settings


def _get_proxies() -> Optional[Dict[str, str]]:
    if not settings.cloudinary_proxy:
        return None
    return {"http": settings.cloudinary_proxy, "https": settings.cloudinary_proxy}


def _sign_params(params: Dict[str, str], api_secret: str) -> str:
    """Thuật toán ký request của Cloudinary: nối các tham số (sắp xếp theo key)
    dạng key=value&key2=value2, cộng api_secret, rồi SHA1."""
    to_sign = "&".join(f"{k}={params[k]}" for k in sorted(params.keys()))
    return hashlib.sha1((to_sign + api_secret).encode("utf-8")).hexdigest()


def upload_image(file_bytes: bytes, public_id: str, folder: str) -> str:
    """Upload 1 ảnh (bytes) lên Cloudinary bằng signed upload qua REST API.
    Trả về secure_url."""
    timestamp = str(int(time.time()))
    params_to_sign = {"folder": folder, "public_id": public_id, "timestamp": timestamp}
    signature = _sign_params(params_to_sign, settings.cloudinary_api_secret)

    url = f"https://api.cloudinary.com/v1_1/{settings.cloudinary_cloud_name}/image/upload"
    data = {**params_to_sign, "api_key": settings.cloudinary_api_key, "signature": signature}
    files = {"file": ("photo.jpg", bytes(file_bytes), "image/jpeg")}

    resp = requests.post(url, data=data, files=files, proxies=_get_proxies(), timeout=30)
    resp.raise_for_status()
    return resp.json()["secure_url"]


def list_all_resources(prefix: str = "") -> Dict[str, str]:
    """Liệt kê toàn bộ ảnh trên Cloudinary (Admin API, có phân trang).
    Trả về dict {basename_không_đuôi: secure_url}."""
    mapping: Dict[str, str] = {}
    next_cursor = None
    url = f"https://api.cloudinary.com/v1_1/{settings.cloudinary_cloud_name}/resources/image/upload"
    auth = (settings.cloudinary_api_key, settings.cloudinary_api_secret)

    while True:
        params = {"max_results": 500}
        if prefix:
            params["prefix"] = prefix
        if next_cursor:
            params["next_cursor"] = next_cursor

        resp = requests.get(url, auth=auth, params=params, proxies=_get_proxies(), timeout=30)
        resp.raise_for_status()
        result = resp.json()

        for res in result.get("resources", []):
            basename = res["public_id"].rsplit("/", 1)[-1]
            mapping[basename] = res["secure_url"]

        next_cursor = result.get("next_cursor")
        if not next_cursor:
            break

    return mapping
