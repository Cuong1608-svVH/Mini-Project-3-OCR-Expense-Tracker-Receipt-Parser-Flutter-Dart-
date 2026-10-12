class SampleReceiptItem {
  final String id;
  final String title;
  final String merchant;
  final String ocrText;
  final double expectedTotal;
  final String categoryName;

  const SampleReceiptItem({
    required this.id,
    required this.title,
    required this.merchant,
    required this.ocrText,
    required this.expectedTotal,
    required this.categoryName,
  });
}

class SampleReceiptsData {
  static const List<SampleReceiptItem> samples = [
    SampleReceiptItem(
      id: 'winmart_real_2',
      title: 'Hóa đơn WinMart+ (Táo Gala & Nước xốt)',
      merchant: 'WinMart+',
      categoryName: 'Mua sắm & Siêu thị',
      expectedTotal: 237576,
      ocrText: '''
WinMart+
PHIẾU TÍNH TIỀN
25/04/2026 10:31|MSCH:4179|NV:09016727
PTT:417901260404425
Mã CQT: M1-26-CPN7O-04138504425
Mặt hàng/giá     SL       KM       T.Tiền
LÊ GIA mắm tôm 110g
17,500           1                 17,500
KEWPIE Nước xốt mè rang chai 500ml
133,500          1        -19,600 113,900
WMNK Táo Royal Gala NZL
89,900           1.344    -14,650 106,176
-----------------------------------------
TỔNG TIỀN        -34,250          237,576
Tiền cần thanh toán               237,576
Quét QR để xuất hóa đơn hoặc truy cập xuathoadon.winmart.vn trong 60 phút
Mã HD: D996  Tel: 2471066866
''',
    ),
    SampleReceiptItem(
      id: 'winmart_real_1',
      title: 'Hóa đơn WinMart (Thịt Meat Deli & Cam)',
      merchant: 'WinMart',
      categoryName: 'Mua sắm & Siêu thị',
      expectedTotal: 68097,
      ocrText: '''
WinMart
PHIẾU TÍNH TIỀN
06/03/2026 11:28|MSCH:1645|NV:09020371
PTT:164503260301812
Mã CQT: M1-26-CPN7O-03035601812
Mặt hàng/giá     SL       KM       T.Tiền
WMNK Cam vàng TQ
59,000           0.346    -3,460   16,954
MEAT DELI [SIG] Thịt heo xay đặc biệt
182,900          0.36              65,844
MEAT DELI Thịt heo xay
149,900          0.366             54,863
MEAT DELI [PRE] Ba rọi rút sườn (S)
287,900          0.42             120,918
MEAT DELI [SIG] Nạc dăm đầu giòn
301,900          0.318             96,004
MEAT DELI [SIG] Nạc dăm đầu giòn
301,900          0.376            113,514
-----------------------------------------
TỔNG TIỀN        -3,460           468,097
Khấu trừ, ưu đãi khác             400,000
Tiền cần thanh toán                68,097
SĐT Khách: ***850   Điểm tích lũy: 9,866,800
Quét QR để xuất hóa đơn trong 60 phút
Mã HD: BF5C  Tel: 02471066866
''',
    ),
    SampleReceiptItem(
      id: 'highlands',
      title: 'Hóa đơn Highlands Coffee',
      merchant: 'Highlands Coffee',
      categoryName: 'Cafe & Trà sữa',
      expectedTotal: 129000,
      ocrText: '''
HIGHLANDS COFFEE
TẦNG 1, TÒA NHÀ BITEXCO
Q.1, TP. HỒ CHÍ MINH
HÓA ĐƠN BÁN LẺ
Ngày: 12/10/2026 09:30
Thu ngân: Nguyen Thi Lan
--------------------------------
1. Phin Sữa Đá (L)        39.000
2. Freeze Trà Xanh (L)    65.000
3. Bánh Mì Thịt Nướng     25.000
--------------------------------
Tổng số lượng: 3
Cộng tiền hàng:          129.000
VAT (10%):                Đã bao gồm
TỔNG CỘNG:               129.000 ₫
Tiền mặt:                150.000
Tiền thối lại:            21.000
Cảm ơn Quý Khách! Hẹn Gặp Lại!
''',
    ),
    SampleReceiptItem(
      id: 'circle_k',
      title: 'Hóa đơn Circle K',
      merchant: 'Circle K',
      categoryName: 'Mua sắm & Siêu thị',
      expectedTotal: 68000,
      ocrText: '''
CIRCLE K VIETNAM
Cửa hàng: CMT8 - Q.3, TP.HCM
Tel: 1900 636 726
HÓA ĐƠN TÍNH TIỀN
Ngày 10/10/2026 21:15
--------------------------------
1  Mì Trộn Trứng Xúc Xích   35.000
1  Nước Ngọt Coca Cola       15.000
1  Kẹo Cao Su Doublemint    18.000
--------------------------------
Tổng cộng:                   68.000
Tiền thanh toán:             68.000 ₫
Thẻ Visa:                    68.000
Mã chuẩn chi: 994821
CẢM ƠN QUÝ KHÁCH!
''',
    ),
    SampleReceiptItem(
      id: 'restaurant',
      title: 'Nhà Hàng Cơm Niêu Sài Gòn',
      merchant: 'Nhà Hàng Cơm Niêu Sài Gòn',
      categoryName: 'Ăn uống',
      expectedTotal: 580000,
      ocrText: '''
NHÀ HÀNG CƠM NIÊU SÀI GÒN
59 Hồ Xuân Hương, Phường 6, Quận 3, TP.HCM
PHIẾU TẠM TÍNH
Bàn: VIP-02
Ngày: 09/10/2026 19:30
--------------------------------
Cơm niêu đặc biệt (2)       80.000
Cá bống kho tộ             180.000
Canh cua rau đay            95.000
Thịt ba chỉ luộc cà pháo   145.000
Khăn lạnh + Trà đá (4)      20.000
Phí phục vụ (5%):           26.000
VAT (8%):                   34.000
--------------------------------
TỔNG CỘNG:                 580.000 ₫
Bằng số: 580.000 VNĐ
(Năm trăm tám mươi nghìn đồng)
Cảm ơn Quý khách rất nhiều!
''',
    ),
    SampleReceiptItem(
      id: 'grab',
      title: 'Hóa đơn di chuyển GrabCar',
      merchant: 'Grab',
      categoryName: 'Di chuyển & Xăng xe',
      expectedTotal: 85000,
      ocrText: '''
GRAB VIETNAM
E-RECEIPT / BIÊN LAI ĐIỆN TỬ
Mã chuyến xe: A-99214710
Ngày: 08/10/2026 08:15
Tài xế: Tran Van Minh (Biển số: 51F-123.45)
--------------------------------
Lộ trình: Quận 7 -> Quận 1
Cước phí chuyến đi:         75.000
Phí cầu đường / Sân bay:    10.000
Giảm giá:                        0
--------------------------------
TỔNG THANH TOÁN:            85.000 ₫
Phương thức: Ví Moca / GrabPay
Cảm ơn bạn đã lựa chọn Grab!
''',
    ),
  ];
}
