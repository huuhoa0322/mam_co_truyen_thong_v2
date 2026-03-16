-- ================================================================
--  SỔ TAY MÂM CỖ & CÔNG THỨC TRUYỀN THỐNG
--  Database Schema — SQLite (ID số nguyên tự tăng)
-- ================================================================
--
--  BẢNG               | MAPPING
--  ─────────────────────────────────────────────────────────────
--  categories         | Screen 2 — Bộ sưu tập
--  dishes             | Screen 2, 3, 4 — Entity trung tâm
--  recipe_ingredients | Screen 3 — Nguyên liệu (có checkbox)
--  recipe_steps       | Screen 3 — Các bước + timer
--  family_secrets     | Screen 3, 5 — Bí kíp gia truyền
--  shopping_items     | Screen 4 — Danh sách đi chợ
--
--  LƯU Ý SQLite:
--    - INTEGER PRIMARY KEY AUTOINCREMENT → tự tăng (1, 2, 3...)
--    - BOOLEAN → INTEGER (0 = false, 1 = true)
--    - TEXT[] (tags) → TEXT lưu JSON: '["TAG1","TAG2"]'
--    - Timestamps → TEXT (ISO 8601)
-- ================================================================

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;


-- ================================================================
-- BẢNG 1: categories
-- ================================================================

CREATE TABLE categories (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  name            TEXT    NOT NULL,
  cover_image_url TEXT,
  created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TRIGGER categories_updated_at
  AFTER UPDATE ON categories FOR EACH ROW
BEGIN
  UPDATE categories SET updated_at = datetime('now') WHERE id = NEW.id;
END;


-- ================================================================
-- BẢNG 2: dishes
-- ================================================================

CREATE TABLE dishes (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id       INTEGER REFERENCES categories(id) ON DELETE SET NULL,

  name              TEXT    NOT NULL,
  description       TEXT,
  image_url         TEXT,

  calories          INTEGER,
  servings_min      INTEGER NOT NULL DEFAULT 2,
  servings_max      INTEGER NOT NULL DEFAULT 4,
  cook_time_minutes INTEGER NOT NULL DEFAULT 30,
  difficulty        TEXT    NOT NULL DEFAULT 'Dễ'
                            CHECK (difficulty IN ('Dễ', 'Trung bình', 'Khó')),

  origin_person     TEXT,
  origin_note       TEXT,

  is_featured       INTEGER NOT NULL DEFAULT 0,   -- 0=false, 1=true

  created_at        TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at        TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TRIGGER dishes_updated_at
  AFTER UPDATE ON dishes FOR EACH ROW
BEGIN
  UPDATE dishes SET updated_at = datetime('now') WHERE id = NEW.id;
END;

CREATE INDEX idx_dishes_category ON dishes(category_id);
CREATE INDEX idx_dishes_featured ON dishes(is_featured);
CREATE INDEX idx_dishes_created  ON dishes(created_at DESC);


-- ================================================================
-- BẢNG 3: recipe_ingredients
-- is_checked: tick khi nấu (Screen 3)
-- ================================================================

CREATE TABLE recipe_ingredients (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  dish_id    INTEGER NOT NULL REFERENCES dishes(id) ON DELETE CASCADE,

  name       TEXT    NOT NULL,
  amount     REAL    NOT NULL,
  unit       TEXT    NOT NULL,
  notes      TEXT,
  is_checked INTEGER NOT NULL DEFAULT 0,  -- 0=false, 1=true

  created_at TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TRIGGER recipe_ingredients_updated_at
  AFTER UPDATE ON recipe_ingredients FOR EACH ROW
BEGIN
  UPDATE recipe_ingredients SET updated_at = datetime('now') WHERE id = NEW.id;
END;

CREATE INDEX idx_ingredients_dish ON recipe_ingredients(dish_id);


-- ================================================================
-- BẢNG 4: recipe_steps
-- ================================================================

CREATE TABLE recipe_steps (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  dish_id       INTEGER NOT NULL REFERENCES dishes(id) ON DELETE CASCADE,

  step_number   INTEGER NOT NULL,
  title         TEXT    NOT NULL,
  description   TEXT    NOT NULL,
  timer_minutes INTEGER,        -- NULL = không cần timer
  timer_label   TEXT,           -- 'Hẹn giờ (30p)'

  created_at    TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at    TEXT    NOT NULL DEFAULT (datetime('now')),

  UNIQUE (dish_id, step_number)
);

CREATE TRIGGER recipe_steps_updated_at
  AFTER UPDATE ON recipe_steps FOR EACH ROW
BEGIN
  UPDATE recipe_steps SET updated_at = datetime('now') WHERE id = NEW.id;
END;

CREATE INDEX idx_steps_dish ON recipe_steps(dish_id);


-- ================================================================
-- BẢNG 5: family_secrets
-- dish_id NULL = bí kíp độc lập, không gắn món
-- ================================================================

CREATE TABLE family_secrets (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  dish_id         INTEGER REFERENCES dishes(id) ON DELETE SET NULL,

  title           TEXT,
  content         TEXT    NOT NULL,
  cover_image_url TEXT,
  tags            TEXT    NOT NULL DEFAULT '[]',  -- JSON: '["TAG1","TAG2"]'

  created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TRIGGER family_secrets_updated_at
  AFTER UPDATE ON family_secrets FOR EACH ROW
BEGIN
  UPDATE family_secrets SET updated_at = datetime('now') WHERE id = NEW.id;
END;

CREATE INDEX idx_secrets_dish ON family_secrets(dish_id);


-- ================================================================
-- BẢNG 6: shopping_items  (gộp shopping_lists + shopping_items)
--
-- list_name       : nhóm phiên đi chợ (GROUP BY trong View)
-- dish_id NULL    : item nhập tay không gắn món
-- estimated_price : SUM → budget_amount tự động trong View
-- actual_price    : NULL = chưa mua; có giá = đã mua
-- ================================================================

CREATE TABLE shopping_items (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,

  dish_id          INTEGER REFERENCES dishes(id) ON DELETE SET NULL,
  ingredient_name  TEXT    NOT NULL,
  quantity         REAL    NOT NULL DEFAULT 1,
  unit             TEXT    NOT NULL DEFAULT 'cái',

  estimated_price  INTEGER NOT NULL DEFAULT 0,
  actual_price     INTEGER,        -- NULL = chưa mua

  is_checked       INTEGER NOT NULL DEFAULT 0,  -- 1 → gạch tên + cộng vào spent
  notes            TEXT,

  created_at       TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TRIGGER shopping_items_updated_at
  AFTER UPDATE ON shopping_items FOR EACH ROW
BEGIN
CREATE INDEX idx_shopping_dish ON shopping_items(dish_id);


-- ================================================================
-- VIEW 1: v_shopping_summary  (Screen 4 — header card)
-- ================================================================

CREATE VIEW v_shopping_summary AS
SELECT
  COALESCE(SUM(estimated_price), 0)
    AS budget_amount,

  COALESCE(SUM(CASE WHEN is_checked = 1 AND actual_price IS NOT NULL
                    THEN actual_price ELSE 0 END), 0)
    AS spent_amount,

  CASE
    WHEN COALESCE(SUM(estimated_price), 0)
         - COALESCE(SUM(CASE WHEN is_checked = 1 AND actual_price IS NOT NULL
                              THEN actual_price ELSE 0 END), 0) > 0
    THEN COALESCE(SUM(estimated_price), 0)
         - COALESCE(SUM(CASE WHEN is_checked = 1 AND actual_price IS NOT NULL
                              THEN actual_price ELSE 0 END), 0)
    ELSE 0
  END AS remaining_amount,

  CASE
    WHEN COALESCE(SUM(estimated_price), 0) > 0
    THEN ROUND(
      CAST(COALESCE(SUM(CASE WHEN is_checked = 1 AND actual_price IS NOT NULL
                              THEN actual_price ELSE 0 END), 0) AS REAL)
      * 100.0 / SUM(estimated_price), 1)
    ELSE 0
  END AS budget_used_percent,

  COUNT(*)                                           AS total_items,
  SUM(CASE WHEN is_checked = 1 THEN 1 ELSE 0 END)   AS checked_items,
  SUM(CASE WHEN is_checked = 0 THEN 1 ELSE 0 END)   AS unchecked_items,
  MIN(created_at)                                    AS list_created_at

FROM shopping_items;


-- ================================================================
-- VIEW 2: v_dish_cards  (Screen 2 — render card không cần join)
-- ================================================================

CREATE VIEW v_dish_cards AS
SELECT
  d.id,
  d.name,
  d.description,
  d.image_url,
  d.calories,
  d.servings_min,
  d.servings_max,
  d.difficulty,
  d.is_featured,
  d.origin_person,
  d.origin_note,
  d.created_at,

  CASE
    WHEN d.cook_time_minutes < 60
      THEN CAST(d.cook_time_minutes AS TEXT) || 'p'
    WHEN d.cook_time_minutes % 60 = 0
      THEN CAST(d.cook_time_minutes / 60 AS TEXT) || ' giờ'
    ELSE CAST(d.cook_time_minutes / 60 AS TEXT) || ' giờ '
         || CAST(d.cook_time_minutes % 60 AS TEXT) || 'p'
  END AS cook_time_display,

  c.id   AS category_id,
  c.name AS category_name,

  (SELECT COUNT(*) FROM recipe_ingredients ri WHERE ri.dish_id = d.id)
    AS ingredient_count,

  (SELECT COUNT(*) FROM recipe_steps rs WHERE rs.dish_id = d.id)
    AS step_count

FROM dishes d
LEFT JOIN categories c ON c.id = d.category_id;


-- ================================================================
-- DỮ LIỆU MẪU
-- AUTOINCREMENT: id tự tăng, không cần chỉ định trong INSERT
-- ================================================================

-- categories (id: 1, 2, 3)
INSERT INTO categories (name) VALUES
  ('Mâm Cỗ'),       -- id = 1
  ('Tráng Miệng'),  -- id = 2
  ('Món Chay');     -- id = 3


-- dishes (id: 1, 2, 3, 4)
INSERT INTO dishes
  (category_id, name, description,
   calories, servings_min, servings_max, cook_time_minutes, difficulty,
   origin_person, origin_note, is_featured)
VALUES
  (1, 'Thịt Kho Tàu', 'Hương vị Tết cổ truyền',
   450, 4, 6, 90, 'Trung bình',
   'Bà Nội', 'Công thức gia truyền từ Bà', 1),         -- id = 1

  (1, 'Bánh Chưng Truyền Thống', 'Biểu tượng Tết cổ truyền Việt Nam',
   NULL, 8, 12, 480, 'Khó',
   'Bà Nội', 'Công thức gốc của Bà • 1985', 1),        -- id = 2

  (1, 'Nem Rán', 'Chả giò giòn rụm, hương vị truyền thống',
   NULL, 4, 6, 45, 'Trung bình',
   NULL, NULL, 0),                                      -- id = 3

  (2, 'Mứt Dừa', 'Sợi dừa ngọt ngào đãi khách ngày Tết',
   NULL, 6, 8, 30, 'Dễ',
   NULL, NULL, 0);                                      -- id = 4


-- recipe_ingredients — Thịt Kho Tàu (dish_id = 1)
INSERT INTO recipe_ingredients (dish_id, name, amount, unit) VALUES
  (1, 'Thịt ba chỉ (cắt miếng vuông)', 500,  'g'),
  (1, 'Trứng vịt (luộc chín)',          6,    'quả'),
  (1, 'Nước dừa tươi',                  500,  'ml'),
  (1, 'Nước mắm ngon',                  3,    'muỗng'),
  (1, 'Đường thốt nốt',                 2,    'muỗng'),
  (1, 'Tỏi băm',                        2,    'tép'),
  (1, 'Hành tím',                       2,    'củ'),
  (1, 'Tiêu xay',                       0.5,  'muỗng');

-- recipe_ingredients — Bánh Chưng (dish_id = 2)
INSERT INTO recipe_ingredients (dish_id, name, amount, unit) VALUES
  (2, 'Gạo nếp',        1,   'kg'),
  (2, 'Đậu xanh cà vỏ', 300, 'g'),
  (2, 'Thịt ba chỉ',    400, 'g'),
  (2, 'Lá dong',        20,  'lá'),
  (2, 'Lạt tre',        10,  'sợi'),
  (2, 'Muối',           1,   'muỗng'),
  (2, 'Tiêu xay',       0.5, 'muỗng');

-- recipe_ingredients — Nem Rán (dish_id = 3)
INSERT INTO recipe_ingredients (dish_id, name, amount, unit) VALUES
  (3, 'Thịt heo xay',       300, 'g'),
  (3, 'Miến dong',           50, 'g'),
  (3, 'Mộc nhĩ (ngâm nở)',  30,  'g'),
  (3, 'Cà rốt (bào sợi)',   1,   'củ'),
  (3, 'Trứng',              2,   'quả'),
  (3, 'Bánh tráng nem',     20,  'tờ'),
  (3, 'Dầu ăn (chiên)',     500, 'ml'),
  (3, 'Nước mắm, tỏi, ớt', 1,   'phần');

-- recipe_ingredients — Mứt Dừa (dish_id = 4)
INSERT INTO recipe_ingredients (dish_id, name, amount, unit) VALUES
  (4, 'Dừa già (nạo sợi)', 500, 'g'),
  (4, 'Đường cát trắng',   300, 'g'),
  (4, 'Vani',              1,   'ống'),
  (4, 'Màu thực phẩm',     1,   'ít');


-- recipe_steps — Thịt Kho Tàu (dish_id = 1)
INSERT INTO recipe_steps (dish_id, step_number, title, description, timer_minutes, timer_label) VALUES
  (1, 1, 'Ướp thịt',
   'Trộn thịt ba chỉ với tỏi băm, hành tím, nước mắm và đường. Ướp ít nhất 30 phút.',
   30, 'Hẹn giờ (30p)'),
  (1, 2, 'Chuẩn bị trứng',
   'Luộc trứng vịt chín kỹ. Bóc vỏ cẩn thận. Có thể chiên sơ để tạo lớp vỏ dai.',
   NULL, NULL),
  (1, 3, 'Thắng nước màu & Kho',
   'Đảo thịt cho săn lại. Thêm nước dừa đun sôi, vớt bọt. Cho trứng vào, hạ lửa nhỏ liu riu.',
   60, 'Kho liu riu (60p)'),
  (1, 4, 'Hoàn thiện',
   'Nêm lại gia vị. Thịt mềm, nước kho sánh vàng là hoàn thành.',
   NULL, NULL);

-- recipe_steps — Bánh Chưng (dish_id = 2)
INSERT INTO recipe_steps (dish_id, step_number, title, description, timer_minutes, timer_label) VALUES
  (2, 1, 'Ngâm gạo và đậu',
   'Ngâm gạo nếp ít nhất 8 tiếng, ngâm đậu xanh 4 tiếng. Để ráo trước khi gói.',
   480, 'Ngâm gạo (8 giờ)'),
  (2, 2, 'Chuẩn bị lá dong',
   'Rửa sạch nhẹ tay để giữ màu xanh. Chần sơ nước sôi cho lá mềm dễ gói.',
   NULL, NULL),
  (2, 3, 'Gói bánh',
   'Xếp lá, cho lần lượt: gạo – đậu – thịt – đậu – gạo. Gói chặt, buộc lạt vừa tay.',
   NULL, NULL),
  (2, 4, 'Luộc bánh',
   'Xếp bánh vào nồi, đổ nước ngập. Luộc 8–10 tiếng, thêm nước sôi khi cạn.',
   600, 'Luộc bánh (10 giờ)');


-- family_secrets
INSERT INTO family_secrets (dish_id, title, content, tags) VALUES
  (1, 'Bí quyết nước kho ngon',
   'Nhớ dùng nước dừa Xiêm bạo để nước kho tự nhiên ngọt thanh mà không cần thêm nhiều đường nhé con.',
   '["KHO LỬA NHỎ","PHẢI THỬ"]'),             -- id = 1

  (2, 'Bánh Chưng Bà Nội',
   'Nhớ ngâm gạo nếp ít nhất 8 tiếng. Bí quyết nằm ở lá dong — rửa thật sạch nhưng nhẹ tay để giữ màu xanh. Buộc lạt vừa chặt tay, không quá siết.',
   '["NGÂM LÂU","LỬA ĐỀU"]'),                 -- id = 2

  (3, 'Nem Rán giòn lâu',
   'Thêm một chút giấm vào dầu chiên giúp nem giòn lâu hơn. Chiên lửa vừa, đừng để lửa to sẽ bị vàng ngoài sống trong.',
   '["PHẢI THỬ"]'),                            -- id = 3

  (4, 'Dưa Hành Muối',
   'Dùng hành tím loại nhỏ đều, ngâm nước muối loãng 2 tiếng trước khi muối để hành giòn hơn. Tỉ lệ muối – đường – giấm phải thật cân bằng.',
   '["GIÒN TAN"]'),                            -- id = 4

  (NULL, 'Các loại Mứt Tết',
   'Gừng, dừa, hạt sen và bí đao — mỗi loại có bí quyết sấy riêng. Mứt gừng thêm chút nước cốt chanh khi sên để cay nhẹ và thơm hơn.',
   '["MỨT","TẾT"]');                           -- id = 5, không gắn món


-- shopping_items — Phiên 'Danh Sách Di Chợ' / 'Tết Giáp Thìn'
-- budget_amount = SUM(estimated_price) = 745.000đ (tự tính trong View)
INSERT INTO shopping_items
  (dish_id, ingredient_name, quantity, unit, estimated_price, actual_price, is_checked, notes)
VALUES
  -- Từ droplist chọn Thịt Kho Tàu (dish_id = 1)
  (1, 'Thịt Ba Chỉ',    1, 'kg',    150000, NULL,   0, NULL),
  (1, 'Trứng Vịt',      6, 'quả',    30000, NULL,   0, NULL),
  (1, 'Nước Dừa Tươi',  2, 'trái',   20000, NULL,   0, NULL),

  -- Từ droplist chọn Bánh Chưng (dish_id = 2)
  (2, 'Lá Dong',        5, 'bó',     50000, NULL,   0, NULL),
  (2, 'Gạo Nếp',        1, 'kg',     40000, NULL,   0, NULL),

  -- Đã mua: is_checked=1, actual_price có giá → cộng vào spent_amount
  (1, 'Hành Muối',      1, 'hũ',     45000, 45000,  1, NULL),

  -- Nhập tay: dish_id = NULL
  (NULL, 'Dầu Ăn',         2, 'L',      90000, 88000,  1, 'Neptune Gold'),
  (NULL, 'Nhang Trầm',     1, 'hộp',   200000, 195000, 1, 'Loại thượng hạng'),
  (NULL, 'Mứt Tết Thập Cẩm', 1, 'kg', 120000, NULL,   0, 'Hữu Nghị');


-- ================================================================
-- KIỂM TRA
-- ================================================================

-- Screen 2: Gợi ý món ngon
-- SELECT * FROM v_dish_cards WHERE is_featured = 1;

-- Screen 2: Bộ sưu tập Mâm Cỗ
-- SELECT * FROM v_dish_cards WHERE category_name = 'Mâm Cỗ';

-- Screen 2: Món ngon phải thử (3 mới nhất)
-- SELECT id, name, difficulty, cook_time_display
-- FROM v_dish_cards ORDER BY created_at DESC LIMIT 3;

-- Screen 3: Nguyên liệu + checkbox
-- SELECT id, name, amount, unit, is_checked
-- FROM recipe_ingredients WHERE dish_id = 1;

-- Screen 3: Bước thực hiện
-- SELECT step_number, title, description, timer_minutes, timer_label
-- FROM recipe_steps WHERE dish_id = 1 ORDER BY step_number;

-- Screen 3: Bí kíp
-- SELECT title, content, tags FROM family_secrets WHERE dish_id = 1;

-- Screen 4: Header ngân sách (tự tính)
-- SELECT budget_amount, spent_amount, remaining_amount, budget_used_percent
-- FROM v_shopping_summary;

-- Screen 4: Danh sách items nhóm theo món
-- SELECT id, ingredient_name, quantity, unit,
--        estimated_price, actual_price, is_checked
-- FROM shopping_items
-- ORDER BY dish_id NULLS LAST;

-- Screen 4: Droplist → nguyên liệu của món để thêm vào giỏ
-- SELECT id, name, amount, unit FROM recipe_ingredients WHERE dish_id = 1;

-- Screen 5: Tất cả bí kíp
-- SELECT fs.id, fs.title, fs.content, fs.tags, d.name AS dish_name
-- FROM family_secrets fs
-- LEFT JOIN dishes d ON d.id = fs.dish_id
-- ORDER BY fs.updated_at DESC;