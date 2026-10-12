# MINI-PROJECT SHORT TECHNICAL REPORT
**Course:** Cross-Platform Mobile App Development (VKU)  
**Mini-Project Title:** Mini-Project 3: OCR Expense Tracker & Receipt Parser (Flutter & Dart)  
**Team / Student Name:** Nguyen Van Cuong  
**Submission Date:** 12/10/2026  

---

## 1. GENERAL INFORMATION & DELIVERABLE LINKS
* **Team Members:**
  1. Nguyen Van Cuong — Student ID: 23ITB021 — Role: Team Lead / Full-Stack Flutter Architecture — Contribution: 100%
* **🔗 Live Demo URL:** [https://cuong1608-svvh.github.io/Mini-Project-3-OCR-Expense-Tracker-Receipt-Parser-Flutter-Dart-/](https://cuong1608-svvh.github.io/Mini-Project-3-OCR-Expense-Tracker-Receipt-Parser-Flutter-Dart-/)
* **💻 GitHub Repository:** [https://github.com/Cuong1608-svVH/Mini-Project-3-OCR-Expense-Tracker-Receipt-Parser-Flutter-Dart-.git](https://github.com/Cuong1608-svVH/Mini-Project-3-OCR-Expense-Tracker-Receipt-Parser-Flutter-Dart-.git)

---

## 2. FEATURE IMPLEMENTATION CHECKLIST

| # | Required Feature | Status | Implementation Details & Acceptance Level |
|:---:|---|:---:|---|
| 1 | **On-device Offline OCR Receipt Scanning** | ✅ Complete | Tích hợp **Google ML Kit Text Recognition** (chạy 100% On-device Offline trên mobile) kết hợp Web OCR (Tesseract.js) trên Chrome. Không phụ thuộc cloud API. |
| 2 | **Regex Heuristic Parser Engine** | ✅ Complete | Bóc tách tự động: Điểm bán / Thương hiệu (`WinMart`, `WinMart+`, `Circle K`, `Highlands Coffee`), Ngày giờ (`dd/MM/yyyy HH:mm`), Tổng tiền thanh toán (`Tiền cần thanh toán`, `TỔNG TIỀN`), và tự động gợi ý Danh mục chi tiêu. Đạt 100% Unit Tests (5/5 tests passed). |
| 3 | **Interactive Animated Charts (`CustomPainter`)** | ✅ Complete | Vẽ hoàn toàn bằng **CustomPainter** thuần (0 thư viện ngoài):<br>• **Animated Pie Chart**: Hiệu ứng quét cung tròn mượt mà, cảm ứng chạm highlight lát cắt (**Explosion Effect**) và hiển thị danh mục, số tiền, % tại tâm.<br>• **Animated Bar Chart**: Cột mọc lên theo animation, chạm hiển thị **Floating Tooltip** chứa thứ ngày và số tiền chi tiết. |
| 4 | **Giao diện MISA Money Keeper Clone** | ✅ Complete | Tông màu chủ đạo **Xanh dương nhạt** (`#2A85FF`) và **Trắng tinh tế** (`#FFFFFF`). Thanh điều hướng 4 Tab (Tổng quan, Sổ giao dịch, Báo cáo, Tiện ích) với nút tròn nổi trung tâm (+). Sổ giao dịch gom nhóm theo ngày kèm sub-total tổng chi trong ngày. |
| 5 | **Local Offline Data Persistence** | ✅ Complete | Lưu trữ dữ liệu hoàn toàn cục bộ, bảo mật:<br>• **SQLite** (`sqflite` trên Mobile + `sqflite_common_ffi` trên Desktop).<br>• Tự động đồng bộ sang **HTML5 LocalStorage** (`shared_preferences`) trên Web, không bị mất dữ liệu khi F5 Reload. |
| 6 | **Xuất dữ liệu ra file CSV (Excel Friendly)** | ✅ Complete | Bộ lọc xuất theo *Tháng này*, *Tháng trước*, hoặc *Tất cả*. Định dạng mã hóa **UTF-8 with BOM (`\uFEFF`)** giúp Microsoft Excel trên Windows mở trực tiếp không bị lỗi font tiếng Việt. Hỗ trợ chia sẻ/mở file trực tiếp. |
| 7 | **Hóa đơn mẫu Việt Nam tích hợp sẵn** | ✅ Complete | Tích hợp sẵn 5 mẫu hóa đơn Việt Nam phổ biến (bao gồm 2 mẫu hóa đơn thực tế của WinMart: *Meat Deli & Cam - 68.097 ₫*, *Táo Gala & Xốt mè rang - 237.576 ₫*) để kiểm thử 1-click tức thì. |

---

## 3. TECHNICAL ARCHITECTURE & PROJECT STRUCTURE

### 3.1. Directory Structure (Clean Architecture & MVVM)
```
lib/
├── core/
│   ├── theme/app_theme.dart             # MISA Theme: Primary Blue, White cards, status colors
│   └── utils/
│       ├── currency_formatter.dart      # Format tiền tệ VND (150.000 ₫) & parse chuỗi số
│       └── date_formatter.dart          # Format ngày giờ tiếng Việt, MISA day headers
├── models/
│   ├── category_item.dart               # Category model (Icon, Color, Expense/Income flag)
│   ├── transaction_item.dart            # Transaction entity (CRUD, OCR metadata, image path)
│   └── parsed_receipt.dart              # DTO lưu trữ kết quả trích xuất Heuristic Parser
├── services/
│   ├── database_service.dart            # SQLite & Web LocalStorage persistent storage
│   ├── heuristic_parser_service.dart    # Thuật toán Regex Heuristics trích xuất hóa đơn
│   ├── ocr_service.dart                 # On-device Google ML Kit & Web OCR abstraction
│   ├── sample_receipts_data.dart        # Bộ 5 mẫu hóa đơn Việt Nam thử nghiệm
│   ├── csv_export_service.dart          # Xuất CSV UTF-8 with BOM và Share sheet
│   └── web_ocr_helper.dart              # JS Interop cho Web OCR trên browser
├── widgets/
│   └── charts/
│       ├── animated_pie_chart.dart      # CustomPainter Interactive Animated Pie Chart
│       └── animated_bar_chart.dart      # CustomPainter Interactive Animated Bar Chart
├── providers/
│   └── expense_provider.dart            # State Management (ChangeNotifier) điều phối nghiệp vụ
├── screens/
│   ├── main_navigation_screen.dart      # 4-tab BottomAppBar + Center Notched FAB
│   ├── dashboard_screen.dart            # Tổng quan số dư, tóm tắt thu/chi, biểu đồ tóm tắt
│   ├── transactions_screen.dart         # Sổ giao dịch gom nhóm theo ngày (phong cách MISA)
│   ├── reports_screen.dart              # Báo cáo phân tích với Pie Chart & Bar Chart
│   ├── ocr_scanner_screen.dart          # Quét camera, chọn ảnh, thử hóa đơn mẫu
│   ├── receipt_review_screen.dart       # Kiểm tra kết quả OCR & chỉnh sửa trước khi lưu
│   ├── add_edit_transaction_screen.dart # Form nhập tay giao dịch thu/chi
│   ├── csv_export_screen.dart           # Xuất báo cáo CSV lọc theo kỳ
│   └── settings_screen.dart             # Tiện ích, làm mới dữ liệu CSDL
└── main.dart                            # Entrypoint cấu hình MultiProvider và Theme
```

### 3.2. State Management & Data Flow
* Sử dụng mô hình **Provider & ChangeNotifier**:
  1. **UI Layer**: Gửi các thao tác người dùng (thêm, sửa, xóa, đổi tháng lọc, tìm kiếm) tới `ExpenseProvider`.
  2. **Service Layer**: `ExpenseProvider` giao tiếp với `DatabaseService` để cập nhật cơ sở dữ liệu (SQLite trên Native, LocalStorage trên Web).
  3. **Reactive Notification**: Gọi `notifyListeners()`, kích hoạt tính toán lại các metric:
     - `monthlyExpense`, `monthlyIncome`, `monthlyNet`, `totalBalance`.
     - `pieChartSections`: Tập hợp dữ liệu lát cắt danh mục cho biểu đồ tròn.
     - `recentDaysBarChartItems` / `last6MonthsBarChartItems`: Tập hợp dữ liệu cột cho biểu đồ cột.
  4. **Widget Rebuild**: Các widget lắng nghe (`context.watch<ExpenseProvider>()`) tự động vẽ lại giao diện mượt mà.

### 3.3. Exception Handling Strategies
* **Cross-Platform Resilience**: Kiểm tra `kIsWeb` và `Platform` an toàn để không xảy ra lỗi `Unsupported operation: Platform._operatingSystem` trên Web.
* **OCR Fallback**: Nếu ảnh mờ hoặc OCR không nhận diện được văn bản đầy đủ, hệ thống không gây crash mà cung cấp `ParsedReceipt` mặc định và cho phép người dùng tự chỉnh sửa trước khi lưu.
* **Async Context Guarding**: Sử dụng `if (!context.mounted) return;` trước mọi thao tác hiển thị `SnackBar` hay điều hướng sau `await`.

---

## 4. EMPIRICAL EVIDENCE & SCREENSHOTS

### 4.1. Tổng quan Giao diện Dashboard & Sổ giao dịch MISA
* **Màn hình Tổng quan (Dashboard)**: Thẻ số dư ví khả dụng với gradient xanh MISA sang trọng, 2 thẻ tóm tắt Thu tháng này (xanh lá) và Chi tháng này (đỏ), banner gọi nhanh Quét hóa đơn AI, biểu đồ tròn `CustomPainter` thu nhỏ và danh sách giao dịch gần nhất.
* **Màn hình Sổ giao dịch (Transactions)**: Các giao dịch được gom nhóm tự động theo từng ngày (`Hôm nay, 12/10/2026`, `Hôm qua...`), hiển thị tổng chi tiêu trong ngày ở tiêu đề nhóm. Mỗi bản ghi có icon danh mục trực quan, giờ giao dịch, nhãn `[OCR]` và hỗ trợ vuốt để xóa (`Dismissible`).

### 4.2. Biểu đồ tương tác Animated Charts (`CustomPainter`)
* **Animated Pie Chart**: Khi mở tab Báo cáo, các lát cắt cung tròn xoay và mở rộng góc quét mượt mà. Chạm vào bất kỳ lát cắt nào sẽ kích hoạt hiệu ứng bật nhẹ ra ngoài (**Explosion Effect**) và hiển thị tên danh mục, số tiền, tỷ lệ % chính xác tại tâm biểu đồ.
* **Animated Bar Chart**: Các cột chi tiêu mọc dần lên theo animation. Khi người dùng chạm hoặc vuốt qua các cột, **Floating Tooltip** màu tối sang trọng sẽ hiển thị ngay phía trên đỉnh cột với mũi tên trỏ xuống, hiển thị ngày trong tuần và số tiền chính xác.

### 4.3. Quét hóa đơn thực tế & Bóc tách Regex Heuristics
* **Thử nghiệm trên 2 hóa đơn WinMart thực tế**:
  - *Hóa đơn 1 (06/03/2026)*: Bộ parser bóc tách thành công Tên cửa hàng `WinMart`, Ngày giờ `06/03/2026 11:28`, Danh mục `Mua sắm & Siêu thị`, và Tổng tiền thực trả `68.097 ₫` (sau khi trừ ưu đãi 400.000đ từ tổng 468.097đ).
  - *Hóa đơn 2 (25/04/2026)*: Bộ parser bóc tách thành công Tên cửa hàng `WinMart+`, Ngày giờ `25/04/2026 10:31`, Danh mục `Mua sắm & Siêu thị`, và Số tiền `237.576 ₫`.
* **Màn hình Review**: Cho phép người dùng kiểm tra lại thông tin, chỉnh sửa số tiền/danh mục và mở rộng xem toàn bộ văn bản OCR thô trước khi lưu vào sổ giao dịch.

### 4.4. Xuất Báo cáo CSV Chuẩn UTF-8 BOM
* Cho phép chọn xuất theo *Tháng này*, *Tháng trước* hoặc *Tất cả*.
* File CSV được xuất ra với mã hóa UTF-8 BOM (`\uFEFF`), khi mở trực tiếp trong Microsoft Excel hiển thị tiếng Việt hoàn toàn chuẩn xác, không bị lỗi font.

---

## 5. TECHNICAL CHALLENGES & RESOLUTIONS

### Thách thức 1: Hạn chế nền tảng của Google ML Kit khi chạy trên Trình duyệt Web
* **Vấn đề gặp phải**: Thư viện `google_mlkit_text_recognition` theo thiết kế của Google là thư viện C++ native chỉ hỗ trợ Mobile (Android & iOS). Khi chạy ứng dụng trên Google Chrome (Web) để demo, việc tải ảnh lên bị trả về rỗng vì plugin không thể gọi native channel.
* **Giải pháp khắc phục**:
  1. Tích hợp giải pháp **Web OCR (Tesseract.js)** chạy trực tiếp trong trình duyệt thông qua JavaScript Interop (`dart:js_interop`) khi chạy trên nền tảng Web.
  2. Bổ sung bộ dữ liệu mẫu gồm 5 hóa đơn Việt Nam phổ biến (bao gồm 2 hóa đơn WinMart thực tế của người dùng) cho phép kiểm thử thuật toán trích xuất tự động tức thì trên Web với 1-click mà không cần phụ thuộc camera thiết bị.

### Thách thức 2: Sự đa dạng và phức tạp của cấu trúc hóa đơn bán lẻ Việt Nam
* **Vấn đề gặp phải**: Các hóa đơn bán lẻ thực tế (như WinMart) có các định dạng rất đặc thù:
  - Có các khoản chiết khấu, ưu đãi (`Khấu trừ: 400,000`), khiến dòng `TỔNG TIỀN` (468,097) khác với số tiền thực tế khách phải trả (`Tiền cần thanh toán: 68,097`).
  - Dấu phân cách tiền tệ sử dụng dấu phẩy cho hàng nghìn (`68,097` thay vì `68.097`).
  - Ngày giờ giao dịch nằm liền kề với mã cửa hàng/thu ngân (`06/03/2026 11:28|MSCH:1645`).
* **Giải pháp khắc phục**:
  1. Tinh chỉnh thuật toán duyệt ngược từ dưới lên và ưu tiên các từ khóa thanh toán thực tế: `'tiền cần thanh toán'`, `'tien can thanh toan'`, `'cần thanh toán'` lên hàng ưu tiên số 1 để lấy số tiền thực trả sau khuyến mãi.
  2. Tối ưu hàm `_extractAmountFromLine` để tự động nhận diện cả dấu chấm và dấu phẩy phân cách hàng nghìn VND 3 chữ số (`xxx,xxx` hoặc `xxx.xxx`).
  3. Tách biệt regex nhận diện ngày `dd/MM/yyyy` và giờ `HH:mm` độc lập với các ký tự phân cách pipe (`|`) phía sau.

### Thách thức 3: Mất dữ liệu khi Reload (F5) trang Web
* **Vấn đề gặp phải**: Trên môi trường Web, SQLite không có file system gốc nên ban đầu dữ liệu chỉ lưu trong RAM. Khi người dùng bấm F5 Reload trang để kiểm tra, toàn bộ giao dịch vừa nhập bị xóa trắng.
* **Giải pháp khắc phục**:
  - Triển khai cơ chế lưu trữ kép (**Dual-Storage Strategy**) trong `DatabaseService`:
    - Trên Android/Windows Desktop: Lưu trữ vào SQLite database file (`.db`).
    - Trên Web Browser: Tự động tuần tự hóa danh sách giao dịch sang JSON và lưu vào **HTML5 LocalStorage** thông qua `shared_preferences`.
  - Nhờ vậy, dữ liệu giao dịch tự nhập của người dùng được lưu trữ vĩnh viễn trên trình duyệt, không bao giờ bị mất khi F5 reload hay đóng mở tab.
