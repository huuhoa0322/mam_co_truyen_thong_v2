# Implementation Plan: Mâm Cỗ Truyền Thống - Phase 1

## Goal Description
Trong dự án này, chúng ta sẽ bắt đầu thiết kế luồng UI và tích hợp chức năng theo file [Requirement.txt](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/Requirement.txt). Giai đoạn này tập trung vào Layout chung (Bottom Navigation Bar) và 4 Màn hình chính dựa trên Schema SQLite sẵn có.

## Proposed Changes

### 1. Global Layout & Navigation
Cần tạo khung cấu trúc MainScreen dùng `BottomNavigationBar` để chứa 4 tab.
#### [NEW] `lib/views/main_screen.dart`
- Tích hợp `BottomNavigationBar` với 4 items: "Trang chủ", "Chi tiết", "Đi chợ", "Bí kíp".
- Quản lý state chuyển đổi giữa 4 màn hình con.

### 2. Màn hình 2: Homepage ([lib/views/home/home.dart](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/views/home/home.dart))
- **`lib/views/home/widgets/featured_dishes.dart`**: Widget Query món ăn nổi bật (`isFeatured = 1`), bỏ dòng "Xem tất cả". 
- **`lib/views/home/widgets/category_list.dart`**: Widget "Bộ sưu tập", thiết kế lưới Card cho Category (CRUD Database Categories), nhấn Card chuyển sang danh sách Dish by Category. Có nút (+) tạo Dish.
- **`lib/views/home/widgets/new_dishes.dart`**: Top 3 món có `createdAt` mới nhất. Nút "Xem tất cả" sang màn All Dishes (với nút (+) tạo Dish).

### 3. Màn hình 3: Công thức chi tiết ([lib/views/recipe_details/recipe_details.dart](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/views/recipe_details/recipe_details.dart))
- Flow 1 (Đi từ BottomNav thủ công): Hiện UI empty state có nút "Chọn món ăn" -> Chọn Dish từ list -> Load Nguyên liệu & Cách làm.
- Flow 2 (Đi từ Screen 2): Nhận Dish ID qua argument -> Load UI ảnh, Info.
- **`lib/views/recipe_details/widgets/recipe_info_header.dart`**: Header image và thông tin hiển thị món.
- **`lib/views/recipe_details/widgets/ingredients_list.dart`**: Quản lý "Nguyên liệu" (CRUD `recipe_ingredients`).
- **`lib/views/recipe_details/widgets/recipe_steps_list.dart`**: "Cách làm" (CRUD `recipe_steps`). Quản lý Custom Button "Bắt đầu tính giờ" theo step_timer hoặc Đếm ngược cả món.
- **`lib/views/recipe_details/widgets/family_secret_form.dart`**: Form "Bí kíp gia truyền" (CRUD `family_secrets` gắn liền với Dish).

### 4. Màn hình 4: Danh sách đi chợ ([lib/views/shopping_lists/shopping_lists.dart](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/views/shopping_lists/shopping_lists.dart))
- **`lib/views/shopping_lists/widgets/dish_selector.dart`**: UI Empty State Khi chưa có dữ liệu giỏ hàng, hiển thị Text "Hãy chọn món ăn để đi chợ" + Button "Chọn món ăn". Selector sẽ chọn món và lấy `recipe_ingredients` sang `shopping_items`.
- **`lib/views/shopping_lists/widgets/shopping_items_list.dart`**: Cấu hình List view load `shopping_items`. Cho phép sửa `ingredient_name`, tick checkbox và điền Actual Price / Estimated Price cho mỗi item.
- **`lib/views/shopping_lists/widgets/budget_header.dart`**: Widget hiển thị Ngân sách. Cập nhật label "Ngân sách dự kiến" ngay lập tức khi Items ở dưới List thay đổi theo Provider/ViewModel.

### 5. Màn hình 5: Bí kíp gia truyền ([lib/views/family_secret/family_secret.dart](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/views/family_secret/family_secret.dart))
- **`lib/views/family_secret/widgets/secret_list.dart`**: Lấy All `family_secrets` (cả có Dish lẫn riêng lẻ).
- **`lib/views/family_secret/widgets/create_secret_modal.dart`**: Form/Dialog CRUD Bí kíp. Chức năng "Tạo bí kíp mới" -> Tự động sinh `dish` record và lưu `family_secrets` tương ứng. Tự động đồng bộ với màn hình 3.

## Verification Plan
1. **Automated Tests:** Unit Tests cơ bản cho Helper Logic tạo Timer/Budget Calculator.
2. **Manual Verification:** Build app lên Emulator/Phone.
    - Test Flow 1: Nhấn từng thẻ CRUD, check Database SQLite có lưu record mới không.
    - Test Flow 2: Update Price -> Check label Ngân sách thay đổi realtime không.
    - Test Flow 3: Thử timer đếm ngược có hoạt động trơn tru không.
