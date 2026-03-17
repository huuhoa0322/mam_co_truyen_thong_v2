CREATE TABLE categories (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  name            TEXT    NOT NULL,
  cover_image_url TEXT,
  created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

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
  is_featured       INTEGER NOT NULL DEFAULT 0,
  created_at        TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at        TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE recipe_ingredients (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  dish_id    INTEGER NOT NULL REFERENCES dishes(id) ON DELETE CASCADE,
  name       TEXT    NOT NULL,
  amount     REAL    NOT NULL,
  unit       TEXT    NOT NULL,
  notes      TEXT,
  is_checked INTEGER NOT NULL DEFAULT 0,
  created_at TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE recipe_steps (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  dish_id       INTEGER NOT NULL REFERENCES dishes(id) ON DELETE CASCADE,
  step_number   INTEGER NOT NULL,
  title         TEXT    NOT NULL,
  description   TEXT    NOT NULL,
  timer_minutes INTEGER,
  timer_label   TEXT,
  created_at    TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at    TEXT    NOT NULL DEFAULT (datetime('now')),
  UNIQUE (dish_id, step_number)
);

CREATE TABLE family_secrets (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  dish_id         INTEGER REFERENCES dishes(id) ON DELETE SET NULL,
  title           TEXT,
  content         TEXT    NOT NULL,
  cover_image_url TEXT,
  tags            TEXT    NOT NULL DEFAULT '[]',
  created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE shopping_items (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  dish_id          INTEGER REFERENCES dishes(id) ON DELETE SET NULL,
  ingredient_name  TEXT    NOT NULL,
  quantity         REAL    NOT NULL DEFAULT 1,
  unit             TEXT    NOT NULL DEFAULT 'cái',
  estimated_price  INTEGER NOT NULL DEFAULT 0,
  actual_price     INTEGER,
  is_checked       INTEGER NOT NULL DEFAULT 0,
  notes            TEXT,
  created_at       TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at       TEXT    NOT NULL DEFAULT (datetime('now'))
);


-- categories
INSERT INTO categories (name) VALUES
  ('Mâm Cỗ'),
  ('Tráng Miệng'),
  ('Món Chay');

-- dishes
INSERT INTO dishes
  (category_id, name, description,
   calories, servings_min, servings_max, cook_time_minutes, difficulty,
   origin_person, origin_note, is_featured)
VALUES
  (1, 'Thịt Kho Tàu', 'Hương vị Tết cổ truyền',
   450, 4, 6, 90, 'Trung bình', 'Bà Nội', 'Công thức gia truyền từ Bà', 1),

  (1, 'Bánh Chưng Truyền Thống', 'Biểu tượng Tết cổ truyền Việt Nam',
   NULL, 8, 12, 480, 'Khó', 'Bà Nội', 'Công thức gốc của Bà • 1985', 1),

  (1, 'Nem Rán', 'Chả giò giòn rụm, hương vị truyền thống',
   NULL, 4, 6, 45, 'Trung bình', NULL, NULL, 0),

  (2, 'Mứt Dừa', 'Sợi dừa ngọt ngào đãi khách ngày Tết',
   NULL, 6, 8, 30, 'Dễ', NULL, NULL, 0);

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
   '["KHO LỬA NHỎ","PHẢI THỬ"]'),

  (2, 'Bánh Chưng Bà Nội',
   'Nhớ ngâm gạo nếp ít nhất 8 tiếng. Bí quyết nằm ở lá dong — rửa thật sạch nhưng nhẹ tay để giữ màu xanh. Buộc lạt vừa chặt tay, không quá siết.',
   '["NGÂM LÂU","LỬA ĐỀU"]'),

  (3, 'Nem Rán giòn lâu',
   'Thêm một chút giấm vào dầu chiên giúp nem giòn lâu hơn. Chiên lửa vừa, đừng để lửa to sẽ bị vàng ngoài sống trong.',
   '["PHẢI THỬ"]'),

  (4, 'Dưa Hành Muối',
   'Dùng hành tím loại nhỏ đều, ngâm nước muối loãng 2 tiếng trước khi muối để hành giòn hơn. Tỉ lệ muối – đường – giấm phải thật cân bằng.',
   '["GIÒN TAN"]'),

  (NULL, 'Các loại Mứt Tết',
   'Gừng, dừa, hạt sen và bí đao — mỗi loại có bí quyết sấy riêng. Mứt gừng thêm chút nước cốt chanh khi sên để cay nhẹ và thơm hơn.',
   '["MỨT","TẾT"]');

-- shopping_items
INSERT INTO shopping_items
  (dish_id, ingredient_name, quantity, unit, estimated_price, actual_price, is_checked, notes)
VALUES
  (1, 'Thịt Ba Chỉ',       1, 'kg',   150000, NULL,   0, NULL),
  (1, 'Trứng Vịt',         6, 'quả',   30000, NULL,   0, NULL),
  (1, 'Nước Dừa Tươi',     2, 'trái',  20000, NULL,   0, NULL),
  (2, 'Lá Dong',           5, 'bó',    50000, NULL,   0, NULL),
  (2, 'Gạo Nếp',           1, 'kg',    40000, NULL,   0, NULL),
  (1, 'Hành Muối',         1, 'hũ',    45000, 45000,  1, NULL),
  (NULL, 'Dầu Ăn',         2, 'L',     90000, 88000,  1, 'Neptune Gold'),
  (NULL, 'Nhang Trầm',     1, 'hộp',  200000, 195000, 1, 'Loại thượng hạng'),
  (NULL, 'Mứt Tết Thập Cẩm', 1, 'kg', 120000, NULL,   0, 'Hữu Nghị');