-- ============================================================
-- Bapsang — Default Recipes Table + Seed Data
-- Run this in Supabase SQL Editor (after 002)
-- ============================================================

-- default_recipes — Pre-built recipes available to all users
CREATE TABLE public.default_recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES public.recipe_categories(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    korean_name TEXT NOT NULL,
    emoji TEXT NOT NULL,
    description TEXT,
    difficulty TEXT NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
    cooking_time INT NOT NULL,
    serving_size INT DEFAULT 2,
    ingredients JSONB NOT NULL DEFAULT '[]',
    steps JSONB NOT NULL DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.default_recipes ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read default recipes
CREATE POLICY "default_recipes_select_authenticated"
    ON public.default_recipes FOR SELECT
    TO authenticated
    USING (true);

CREATE INDEX idx_default_recipes_category ON public.default_recipes(category_id);

-- ============================================================
-- Seed Data (references category IDs by subquery)
-- ============================================================

-- Soup/Stew
INSERT INTO public.default_recipes (category_id, name, korean_name, emoji, description, difficulty, cooking_time, sort_order)
SELECT id, v.name, v.korean_name, v.emoji, v.description, v.difficulty, v.cooking_time, v.sort_order
FROM public.recipe_categories c,
(VALUES
    ('Kimchi Jjigae',    '김치찌개',   '🍲', 'Spicy kimchi stew with pork and tofu',                'easy',   25, 1),
    ('Doenjang Jjigae',  '된장찌개',   '🫕', 'Fermented soybean paste stew with vegetables',        'easy',   20, 2),
    ('Sundubu Jjigae',   '순두부찌개',  '🥘', 'Soft tofu stew with seafood or pork',                 'easy',   20, 3),
    ('Budae Jjigae',     '부대찌개',   '🍲', 'Army stew with sausage, spam, and ramyeon',           'medium', 30, 4),
    ('Tteokguk',         '떡국',      '🥣', 'Rice cake soup traditionally eaten on New Year''s',   'easy',   30, 5),
    ('Samgyetang',       '삼계탕',    '🐔', 'Ginseng chicken soup with rice stuffing',             'hard',   60, 6)
) AS v(name, korean_name, emoji, description, difficulty, cooking_time, sort_order)
WHERE c.name = 'Soup/Stew';

-- Stir-fry
INSERT INTO public.default_recipes (category_id, name, korean_name, emoji, description, difficulty, cooking_time, sort_order)
SELECT id, v.name, v.korean_name, v.emoji, v.description, v.difficulty, v.cooking_time, v.sort_order
FROM public.recipe_categories c,
(VALUES
    ('Jeyuk Bokkeum',   '제육볶음',   '🥩', 'Spicy stir-fried pork with gochujang',                     'easy',   20, 1),
    ('Tteokbokki',      '떡볶이',    '🌶️', 'Spicy stir-fried rice cakes',                               'easy',   20, 2),
    ('Ojingeo Bokkeum', '오징어볶음',  '🦑', 'Spicy stir-fried squid with vegetables',                    'medium', 15, 3),
    ('Dakgalbi',        '닭갈비',    '🍗', 'Spicy stir-fried chicken with cabbage and rice cakes',       'medium', 25, 4),
    ('Japchae',         '잡채',      '🍜', 'Glass noodles stir-fried with vegetables and beef',          'medium', 30, 5)
) AS v(name, korean_name, emoji, description, difficulty, cooking_time, sort_order)
WHERE c.name = 'Stir-fry';

-- Rice
INSERT INTO public.default_recipes (category_id, name, korean_name, emoji, description, difficulty, cooking_time, sort_order)
SELECT id, v.name, v.korean_name, v.emoji, v.description, v.difficulty, v.cooking_time, v.sort_order
FROM public.recipe_categories c,
(VALUES
    ('Bibimbap',          '비빔밥',      '🍚', 'Mixed rice with vegetables, meat, and gochujang',  'medium', 30, 1),
    ('Kimchi Fried Rice', '김치볶음밥',   '🍳', 'Fried rice with kimchi topped with a fried egg',   'easy',   15, 2),
    ('Tuna Mayo Rice',    '참치마요덮밥',  '🐟', 'Simple tuna and mayo over steamed rice',           'easy',   10, 3),
    ('Omurice',           '오므라이스',   '🥚', 'Fried rice wrapped in a soft omelette',            'medium', 20, 4),
    ('Dolsot Bibimbap',   '돌솥비빔밥',   '🔥', 'Hot stone pot bibimbap with crispy rice',          'medium', 35, 5)
) AS v(name, korean_name, emoji, description, difficulty, cooking_time, sort_order)
WHERE c.name = 'Rice';

-- Noodles
INSERT INTO public.default_recipes (category_id, name, korean_name, emoji, description, difficulty, cooking_time, sort_order)
SELECT id, v.name, v.korean_name, v.emoji, v.description, v.difficulty, v.cooking_time, v.sort_order
FROM public.recipe_categories c,
(VALUES
    ('Kalguksu',      '칼국수',   '🍜', 'Hand-cut knife noodles in anchovy broth',           'medium', 30, 1),
    ('Bibim Guksu',   '비빔국수',  '🥢', 'Spicy cold mixed noodles',                          'easy',   15, 2),
    ('Japchae',       '잡채',     '🍝', 'Sweet potato glass noodles with vegetables',         'medium', 30, 3),
    ('Jjajangmyeon',  '짜장면',   '🍜', 'Noodles in black bean sauce',                        'medium', 25, 4),
    ('Ramyeon',       '라면',     '🍜', 'Korean instant noodles with egg and scallions',      'easy',   10, 5)
) AS v(name, korean_name, emoji, description, difficulty, cooking_time, sort_order)
WHERE c.name = 'Noodles';

-- Side Dishes
INSERT INTO public.default_recipes (category_id, name, korean_name, emoji, description, difficulty, cooking_time, sort_order)
SELECT id, v.name, v.korean_name, v.emoji, v.description, v.difficulty, v.cooking_time, v.sort_order
FROM public.recipe_categories c,
(VALUES
    ('Gyeran Mari',      '계란말이',   '🥚', 'Rolled egg omelette with vegetables',       'easy', 10, 1),
    ('Gamja Jorim',      '감자조림',   '🥔', 'Braised potatoes in sweet soy glaze',       'easy', 20, 2),
    ('Sigeumchi Namul',  '시금치나물',  '🥬', 'Seasoned spinach side dish',                'easy', 10, 3),
    ('Kongnamul Muchim', '콩나물무침',  '🌱', 'Seasoned soybean sprouts',                  'easy', 10, 4),
    ('Eomuk Bokkeum',   '어묵볶음',   '🍢', 'Stir-fried fish cake with soy sauce',       'easy', 10, 5)
) AS v(name, korean_name, emoji, description, difficulty, cooking_time, sort_order)
WHERE c.name = 'Side Dishes';

-- One-Plate
INSERT INTO public.default_recipes (category_id, name, korean_name, emoji, description, difficulty, cooking_time, sort_order)
SELECT id, v.name, v.korean_name, v.emoji, v.description, v.difficulty, v.cooking_time, v.sort_order
FROM public.recipe_categories c,
(VALUES
    ('Kimchijeon',    '김치전',    '🥞', 'Crispy kimchi pancake',                                  'easy',   15, 1),
    ('Ramyeon',       '라면',     '🍜', 'Quick Korean ramyeon with egg',                           'easy',   10, 2),
    ('Cheese Toast',  '치즈토스트', '🧀', 'Korean street-style cheese toast',                        'easy',   10, 3),
    ('Gyeran Bap',    '계란밥',   '🍳', 'Simple egg over rice with sesame oil and soy sauce',      'easy',    5, 4),
    ('Chamchi Gimbap','참치김밥',  '🍙', 'Tuna kimbap rolls',                                       'medium', 25, 5)
) AS v(name, korean_name, emoji, description, difficulty, cooking_time, sort_order)
WHERE c.name = 'One-Plate';
