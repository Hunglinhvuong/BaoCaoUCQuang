import os
import cloudinary
import cloudinary.uploader
from dotenv import load_dotenv

# 1. Tải cấu hình từ file .env
load_dotenv()

cloudinary.config(
    cloud_name="p0x7kszi",
    api_key="546165376548241",
    api_secret="CTKkVaarf1KqRpr4hlsOPXv5bII",
    secure=True
)

# 2. ĐƯỜNG DẪN GỐC (Trỏ tới thư mục chứa các FolderID)
TARGET_FOLDER = './storage/photos'

# Các định dạng ảnh được phép upload
ALLOWED_EXTENSIONS = ('.jpg', '.jpeg', '.png', '.gif', '.webp', '.svg')

def upload_nested_folders():
    if not os.path.exists(TARGET_FOLDER):
        print(f"❌ Đường dẫn không tồn tại: {TARGET_FOLDER}")
        return

    print("🔍 Đang quét cấu trúc thư mục để tìm ảnh...")
    
    # os.walk sẽ duyệt qua thư mục gốc và TẤT CẢ các thư mục con bên trong nó
    for root, dirs, files in os.walk(TARGET_FOLDER):
        for file_name in files:
            # Kiểm tra định dạng file ảnh
            if file_name.lower().endswith(ALLOWED_EXTENSIONS):
                # Tạo đường dẫn đầy đủ từ local (ví dụ: ./storage/photos/FolderID_1/pic.jpg)
                file_path = os.path.join(root, file_name)
                
                # Lấy tên thư mục cha trực tiếp của ảnh (chính là FolderID) để đồng bộ lên Cloudinary
                parent_folder_name = os.path.basename(root)
                cloudinary_folder_path = f"my_project_uploads/{parent_folder_name}"

                print(f"📤 Đang upload: {file_name} (Thuộc thư mục: {parent_folder_name})...")
                
                try:
                    # Tiến hành upload
                    response = cloudinary.uploader.upload(
                        file_path,
                        folder=cloudinary_folder_path, # Tự động gom nhóm theo FolderID trên Cloudinary
                        use_filename=True,
                        unique_filename=False
                    )
                    print(f"✅ Thành công: {file_name} -> {response['secure_url']}")
                except Exception as e:
                    print(f"❌ Lỗi khi upload file {file_name}: {e}")
            else:
                # Bỏ qua các file hệ thống như .gitkeep, .DS_Store...
                if not file_name.startswith('.'):
                    print(f"⏩ Bỏ qua file không phải ảnh: {file_name}")

    print("\n🎉 Quá trình quét và upload cấu trúc thư mục hoàn tất!")

if __name__ == "__main__":
    upload_nested_folders()
