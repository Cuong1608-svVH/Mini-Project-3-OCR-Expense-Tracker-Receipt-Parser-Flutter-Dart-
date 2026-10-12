# 📱 Mini-Project 3: OCR Expense Tracker & Receipt Parser (Flutter & Dart)
### Clone Giao Diện Sổ Thu Chi MISA • On-Device Offline AI • Animated CustomPainter Charts

Ứng dụng quản lý tài chính cá nhân phát triển bằng Flutter với công nghệ AI trên thiết bị (**On-Device AI**) chạy hoàn toàn **Offline**, bóc tách hóa đơn tự động và lưu trữ cục bộ bảo mật.

---

## 🌟 Tính Năng Nổi Bật

### 1. 🔍 On-Device Offline OCR & Regex Heuristic Parser
* **Google ML Kit Text Recognition**: Nhận diện ký tự trực tiếp trên thiết bị (On-Device), hoạt động 100% không cần kết nối mạng.
* **Regex Heuristic Parser**: Thuật toán thông minh tự động trích xuất:
  * **Tên điểm bán / Cửa hàng**: Nhận diện chuỗi cửa hàng phổ biến tại Việt Nam (WinMart, Circle K, Highlands Coffee, Phúc Long, Quán ăn, v.v.).
  * **Ngày giờ giao dịch**: Đa định dạng `dd/MM/yyyy`, `yyyy-MM-dd`, `Ngày ... tháng ... năm ...`, kèm giờ phút.
  * **Tổng tiền thanh toán**: Bóc tách số tiền VND có dấu phân cách (`150.000 ₫`, `150,000`, `150k`).
  * **Gợi ý danh mục tự động**: Tự phân loại vào *Ăn uống, Mua sắm siêu thị, Di chuyển, Hóa đơn tiện ích...*
* **Tích hợp sẵn 5 mẫu hóa đơn Việt Nam**: Cho phép kiểm thử ngay lập tức (WinMart, Highlands, Circle K, Cơm Niêu Sài Gòn, GrabCar) trên bất kỳ thiết bị nào kể cả máy tính.

### 2. 📊 Animated Interactive Charts với `CustomPainter`
* **Biểu đồ tròn (Animated Pie Chart)**:
  * Vẽ từng cung tròn tỷ lệ chi tiêu với chuyển động mượt mà (`Curves.easeOutCubic`).
  * **Tương tác cảm ứng (Touch / Tap)**: Chạm vào bất kỳ lát cắt nào để phóng to (explosion effect) và xem chi tiết danh mục, số tiền, tỷ lệ % ở tâm biểu đồ.
* **Biểu đồ cột (Animated Bar Chart)**:
  * Hiệu ứng cột mọc lên sinh động theo tuần hoặc 6 tháng gần nhất.
  * **Interactive Floating Tooltip**: Chạm vào cột để hiển thị tooltip nổi hiển thị thứ ngày và số tiền chính xác.

### 3. 🎨 Giao diện Chuẩn MISA Money Keeper
* Tông màu chủ đạo **Xanh dương nhạt thanh lịch** (`#2A85FF`, `#E8F3FF`) và **Trắng tinh tế** (`#FFFFFF`).
* Thẻ số dư ví, tổng thu tháng, tổng chi tháng trực quan.
* Sổ giao dịch gom nhóm theo ngày (tiêu đề ngày trong tuần, ngày/tháng, tổng chi trong ngày; danh sách khoản chi phía dưới).
* Nút trung tâm tròn nổi bật hỗ trợ mở nhanh Quét OCR hoặc Nhập tay.

### 4. 📁 Xuất Dữ Liệu Ra File CSV (Excel)
* Lựa chọn phạm vi: *Tháng này*, *Tháng trước*, hoặc *Tất cả lịch sử*.
* Định dạng mã hóa **UTF-8 with BOM (`\uFEFF`)**: Đảm bảo mở trực tiếp trên Microsoft Excel trên Windows không bị lỗi font tiếng Việt.
* Tích hợp hộp thoại **Chia sẻ / Mở file** trực tiếp sau khi xuất.

### 5. 💾 Cơ Sở Dữ Liệu Offline (SQLite)
* Sử dụng SQLite cục bộ (`sqflite` cho mobile và `sqflite_common_ffi` cho Windows desktop).
* Khởi tạo sẵn dữ liệu mẫu thực tế để trải nghiệm ngay khi mở app lần đầu.

---

## 📂 Cấu Trúc Mã Nguồn

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart             # Bảng màu MISA Money Keeper (Xanh dương, trắng)
│   └── utils/
│       ├── currency_formatter.dart    # Format tiền tệ VND (150.000 ₫)
│       └── date_formatter.dart        # Format ngày giờ tiếng Việt
├── models/
│   ├── category_item.dart             # Model danh mục chi tiêu & thu nhập
│   ├── transaction_item.dart          # Model giao dịch tài chính
│   └── parsed_receipt.dart            # Model kết quả bóc tách OCR
├── services/
│   ├── database_service.dart          # SQLite Local Database (hỗ trợ cả FFI Desktop)
│   ├── heuristic_parser_service.dart  # Thuật toán Regex Heuristics trích xuất hóa đơn
│   ├── ocr_service.dart               # Tầng Google ML Kit Offline & Cross-platform
│   ├── sample_receipts_data.dart      # Bộ dữ liệu 5 hóa đơn mẫu Việt Nam
│   └── csv_export_service.dart        # Xuất CSV UTF-8 BOM và chia sẻ file
├── widgets/
│   └── charts/
│       ├── animated_pie_chart.dart    # CustomPainter Biểu đồ tròn tương tác
│       └── animated_bar_chart.dart    # CustomPainter Biểu đồ cột tương tác
├── providers/
│   └── expense_provider.dart          # Quản lý trạng thái Provider / ChangeNotifier
├── screens/
│   ├── main_navigation_screen.dart    # Bottom Navigation Bar 4 tab + Center FAB
│   ├── dashboard_screen.dart          # Màn hình Tổng quan MISA
│   ├── transactions_screen.dart       # Sổ giao dịch gom nhóm theo ngày
│   ├── reports_screen.dart            # Báo cáo phân tích với Pie & Bar Chart
│   ├── ocr_scanner_screen.dart        # Quét camera, chọn ảnh, thử hóa đơn mẫu
│   ├── receipt_review_screen.dart     # Kiểm tra kết quả OCR & chỉnh sửa trước khi lưu
│   ├── add_edit_transaction_screen.dart # Nhập giao dịch thủ công
│   ├── csv_export_screen.dart         # Màn hình xuất file CSV
│   └── settings_screen.dart           # Tiện ích và cài đặt
└── main.dart                          # Khởi tạo SQLite FFI, Providers và Theme
```

---

## 🚀 Hướng Dẫn Chạy Ứng Dụng

Dự án sử dụng Flutter tại đường dẫn: `D:\flutter\bin\flutter.bat`

### 1. Chạy trên Windows Desktop:
```powershell
& "D:\flutter\bin\flutter.bat" run -d windows
```

### 2. Chạy trên Thiết Bị Android (hoặc Giả lập):
```powershell
& "D:\flutter\bin\flutter.bat" run -d android
```

### 3. Chạy trên Trình Duyệt Web (Chrome):
```powershell
& "D:\flutter\bin\flutter.bat" run -d chrome
```

### 4. Chạy Toàn Bộ Unit Tests:
```powershell
& "D:\flutter\bin\flutter.bat" test
```
*(Bao gồm kiểm thử thuật toán Regex Heuristic Parser và xuất file CSV UTF-8 BOM)*
