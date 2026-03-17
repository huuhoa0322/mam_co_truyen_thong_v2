# Task Tracker: Phát Triển App Mâm Cỗ Truyền Thống

## Phase 1: Setup Architecture & Database (Done)
- [x] Tạo `lib/entities/` cho SQLite Data Models.
- [x] Tạo & config [lib/sql/mam_co.sql](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/sql/mam_co.sql) từ AssetBundle.
- [x] Xây dựng class Singleton [AppDatabase](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/implementations/local/app_database.dart#6-60).

## Phase 2: Khởi tạo ViewModels
- [x] Thiết lập Base Repository / Data Providers.
- [x] Viết [HomeViewModel](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/viewmodels/home/home_view_model.dart#6-160) (Load Categories, Featured Dishes, Last 3 Dishes).
- [ ] Viết `RecipeViewModel` (Load Info, Timer Control, Nguyên liệu & Cách làm list, CRUD logic).
- [ ] Viết `ShoppingListViewModel` (Load `shopping_items`, Update Quantity/Price -> Tính BudgetSummary).
- [ ] Viết `SecretViewModel` (CRUD `family_secrets`).
- [ ] Inject `GetIt` / `Provider`.

## Phase 3: Xây dựng Layouts
- [ ] Global Layout: Tạo [MainScreen](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/views/main_screen.dart#7-13) với `BottomNavigationBar` (4 Tabs: Trang chủ, Chi tiết, Đi chợ, Bí kíp).
- [ ] **Tab 1: Homepage ([lib/views/home/home.dart](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/views/home/home.dart))**
  - [x] Widget ẩn [lib/views/home/widgets/featured_dishes.dart](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/views/home/widgets/featured_dishes.dart)
  - [x] Widget Categories [lib/views/home/widgets/category_list.dart](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/views/home/widgets/category_list.dart)
  - [x] Widget New Dishes [lib/views/home/widgets/new_dishes.dart](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/views/home/widgets/new_dishes.dart)
  - [x] Hoàn thiện CRUD dữ liệu ngay trên Home (LongPress to Edit/Delete, Add Buttons)
- [ ] **Tab 2: Recipe Detail ([lib/views/recipe_details/recipe_details.dart](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/views/recipe_details/recipe_details.dart))**
  - [ ] Widget Info `lib/views/recipe_details/widgets/recipe_info_header.dart`
  - [ ] Widget Ingredients `lib/views/recipe_details/widgets/ingredients_list.dart`
  - [ ] Widget Steps `lib/views/recipe_details/widgets/recipe_steps_list.dart`
  - [ ] Widget Secret Form `lib/views/recipe_details/widgets/family_secret_form.dart`
  - [ ] Timer logic
- [ ] **Tab 3: Shopping List ([lib/views/shopping_lists/shopping_lists.dart](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/views/shopping_lists/shopping_lists.dart))**
  - [ ] Dropdown Select Dish `lib/views/shopping_lists/widgets/dish_selector.dart`
  - [ ] Interactive Item List `lib/views/shopping_lists/widgets/shopping_items_list.dart`
  - [ ] Budget Header `lib/views/shopping_lists/widgets/budget_header.dart`
- [ ] **Tab 4: Family Secret ([lib/views/family_secret/family_secret.dart](file:///d:/DH%202022%20-%202026/Tai%20lieu%20hoc/8.%20Spring%202026/PRM392_393/393/PE/mam_co_truyen_thong_v2/lib/views/family_secret/family_secret.dart))**
  - [ ] Widget List Secret `lib/views/family_secret/widgets/secret_list.dart`
  - [ ] Widget Create Secret `lib/views/family_secret/widgets/create_secret_modal.dart`

  
## Phase 4: Integration & Testing
- [ ] Review kết nối Navigation, pass Data (ID) giữa các Tab.
- [ ] Review Behavior Timer.
- [ ] Review Behavior Auto-update "Ngân sách đi chợ".
- [ ] Review CRUD functions với local DB.
- [ ] Build release test.
