#!/bin/bash
set -e  # Dừng script nếu có lỗi

# === 1. Kiểm tra Git repo ===
if [ ! -d ".git" ]; then
  echo "⚠️  Đây không phải Git repository! Đang khởi tạo Git repository..."
  git init
  echo "✅ Đã khởi tạo Git repository!"
fi

# === 2. Gắn remote nếu chưa có ===
if ! git remote get-url origin &>/dev/null; then
  echo "⚠️  Chưa có remote origin!"
  read -p "🌐 Nhập URL GitHub (ví dụ: https://github.com/tenuser/tenrepo.git): " url
  git remote add origin "$url"
  echo "✅ Đã gắn remote origin!"
fi

# === 3. Thêm tất cả file mới và cập nhật .gitignore ===
git add .

# Tự động thêm script này vào .gitignore nếu chưa có
if ! grep -qx "push_git.sh" .gitignore 2>/dev/null; then
  echo "push_git.sh" >> .gitignore
  echo "✅ Đã thêm push_git.sh vào .gitignore!"
fi

# Xoá script khỏi vùng theo dõi nếu đã add trước đó
git rm --cached push_git.sh 2>/dev/null || true

# === 4. Nhập nội dung commit ===
read -p "📝 Nhập nội dung commit: " message
git commit -m "$message"

# === 5. Đẩy lên GitHub ===
branch=$(git branch --show-current)

# Nếu chưa có nhánh (repo mới), tạo 'main'
if [ -z "$branch" ]; then
  branch="main"
  git branch -M "$branch"
fi

# Thiết lập upstream nếu chưa có
if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} &>/dev/null; then
  git push --set-upstream origin "$branch"
else
  git push
fi

echo ""
echo "✅ Đã đẩy code lên GitHub thành công!"
