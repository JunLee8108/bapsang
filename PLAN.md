# Recommendation Landing Page — Implementation Plan

## Current State
- Login (Apple/Google) ✅ Done
- Onboarding (display name, spice level, dietary restrictions) ✅ Done
- RootView → Login → Onboarding (first signup only) → MainTabView ✅ Done
- MainTabView "Recommend" tab → PlaceholderView (temporary) ⏳ Needs replacement

## Goal
Build the **RecommendationView** — the first screen users see after login.
Entry point for selecting ingredients and getting AI-powered Korean recipe recommendations.

---

## Implementation Steps

### Step 1: RecipeCategory Model
**File**: `Bapsang/Models/RecipeCategory.swift`

- `RecipeCategory` struct (id, name, icon, description)
- Default Korean food categories: Soup/Stew, Stir-fry, Rice, Noodles, Side Dishes, One-Plate

### Step 2: RecommendationViewModel
**File**: `Bapsang/Features/Recommendation/RecommendationViewModel.swift`

- `@Observable` class
- Time-based greeting (Good morning / Good afternoon / Good evening)
- Category data
- Prepared for future Supabase integration (recent recipes, etc.)

### Step 3: CategoryCard Component
**File**: `Bapsang/Components/CategoryCard.swift`

- Reusable card UI: icon + name + short description
- Orange gradient + `.ultraThinMaterial` style (matches existing design)
- Tap action ready for Phase 2 navigation

### Step 4: EmptyStateView Component
**File**: `Bapsang/Components/EmptyStateView.swift`

- Shown when no recent recipes exist
- Icon + message + optional action button

### Step 5: RecommendationView
**File**: `Bapsang/Features/Recommendation/RecommendationView.swift`

- Greeting section (time-based)
- **"Select Ingredients" CTA button at the top**
- **"Today's Recommended Categories" grid below**
- Recent recipes section (empty state for now)
- Stagger animation on card appearance

### Step 6: MainTabView Update
**File**: `Bapsang/Core/MainTabView.swift`

- Replace first tab's PlaceholderView → RecommendationView
- Keep NavigationStack

---

## File Summary

| Action | File | Type |
|--------|------|------|
| Create | `Models/RecipeCategory.swift` | New |
| Create | `Features/Recommendation/RecommendationViewModel.swift` | New |
| Create | `Components/CategoryCard.swift` | New |
| Create | `Components/EmptyStateView.swift` | New |
| Create | `Features/Recommendation/RecommendationView.swift` | New |
| Modify | `Core/MainTabView.swift` | Replace PlaceholderView |

---

## UI Wireframe

```
┌──────────────────────────────────┐
│  NavBar: "What Should I Eat?"    │
├──────────────────────────────────┤
│                                  │
│  Good evening!                   │
│  What shall we cook today?       │
│                                  │
├──────────────────────────────────┤
│  ┌──────────────────────────┐    │
│  │  🥕  Select Ingredients  │    │
│  │      (CTA Button)        │    │
│  └──────────────────────────┘    │
│                                  │
├──────────────────────────────────┤
│  Today's Recommended Categories  │
│                                  │
│  ┌──────────┐ ┌──────────┐      │
│  │ 🍲       │ │ 🥘       │      │
│  │Soup/Stew │ │ Stir-fry │      │
│  └──────────┘ └──────────┘      │
│  ┌──────────┐ ┌──────────┐      │
│  │ 🍚       │ │ 🍜       │      │
│  │   Rice   │ │ Noodles  │      │
│  └──────────┘ └──────────┘      │
│  ┌──────────┐ ┌──────────┐      │
│  │ 🥗       │ │ 🍳       │      │
│  │  Sides   │ │One-Plate │      │
│  └──────────┘ └──────────┘      │
│                                  │
├──────────────────────────────────┤
│  Recent Recipes                  │
│  ┌──────────────────────────┐    │
│  │  📭 No recipes yet       │    │
│  │     Start exploring!      │    │
│  └──────────────────────────┘    │
│                                  │
├──────────────────────────────────┤
│ [🍽 Recommend] [📖 Saved] [⚙ Settings] │
└──────────────────────────────────┘
```

## Design Principles
- Match existing orange gradient + `.ultraThinMaterial` style from LoginView
- `@Observable` pattern (iOS 17+)
- **English UI text**
- Stagger animation on card appearance

---

## Supabase Database Schema

### Current Tables
- `public.users` — auth.users 1:1 mapping (with trigger) ✅
  - Includes community columns: `display_name`, `total_likes_received`, `total_posts`, `badges`
  - Includes onboarding columns: `preferred_spice_level`, `dietary_restrictions`, `has_completed_onboarding`
  - No separate `user_profiles` table — all profile data lives here

### New Tables Needed

#### 1. `recipe_categories` — Category master data
```sql
CREATE TABLE public.recipe_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,              -- "Soup/Stew"
    icon TEXT NOT NULL,              -- "🍲"
    description TEXT,                -- "Warm and comforting Korean soups"
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Seed data
INSERT INTO public.recipe_categories (name, icon, description, sort_order) VALUES
    ('Soup/Stew',  '🍲', 'Warm and comforting Korean soups and stews', 1),
    ('Stir-fry',   '🥘', 'Quick and flavorful stir-fried dishes',     2),
    ('Rice',       '🍚', 'Hearty rice-based Korean meals',            3),
    ('Noodles',    '🍜', 'Delicious Korean noodle dishes',            4),
    ('Side Dishes','🥗', 'Traditional Korean banchan',                5),
    ('One-Plate',  '🍳', 'Simple all-in-one plate meals',             6);

-- Anyone logged in can read categories
ALTER TABLE public.recipe_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "categories_select_authenticated"
    ON public.recipe_categories FOR SELECT
    TO authenticated
    USING (true);
```

#### 2. `recipes` — AI-generated recipes
```sql
CREATE TABLE public.recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.recipe_categories(id) ON DELETE SET NULL,
    title TEXT NOT NULL,              -- "Kimchi Jjigae"
    description TEXT,                 -- Short summary
    ingredients JSONB NOT NULL,       -- [{"name":"kimchi","amount":"200g"}, ...]
    steps JSONB NOT NULL,             -- [{"order":1,"text":"Cut kimchi..."}, ...]
    cooking_time INT,                 -- Minutes
    difficulty TEXT CHECK (difficulty IN ('easy','medium','hard')),
    serving_size INT DEFAULT 1,
    ai_raw_response JSONB,           -- Full AI response for debugging
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "recipes_select_own"
    ON public.recipes FOR SELECT
    USING (auth.uid() = user_id);
CREATE POLICY "recipes_insert_own"
    ON public.recipes FOR INSERT
    WITH CHECK (auth.uid() = user_id);
CREATE POLICY "recipes_delete_own"
    ON public.recipes FOR DELETE
    USING (auth.uid() = user_id);

CREATE INDEX idx_recipes_user_id ON public.recipes(user_id);
CREATE INDEX idx_recipes_category_id ON public.recipes(category_id);
```

#### 3. ~~`saved_recipes`~~ → `saved_items` (replaced)
> **`saved_recipes` 테이블은 폐기됨** (migration `008_drop_saved_recipes.sql`로 DROP).
> `recipes` (AI 생성) 테이블만 참조하는 구조였기 때문에, 기본 레시피와 커뮤니티 레시피를
> 모두 저장할 수 없었음. 이를 대체하는 `saved_items` 테이블이 도입됨 (migration `007_add_saved_items.sql`).

```sql
-- NEW: saved_items (multi-source bookmarks)
CREATE TABLE public.saved_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    source_type TEXT NOT NULL CHECK (source_type IN ('default', 'community')),
    source_id UUID NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, source_type, source_id)
);
-- source_type: 'default' = 기본 제공 레시피, 'community' = 커뮤니티 게시물
-- AI 레시피 추가 시 source_type에 'ai' 값 추가 예정
```

#### 4. `recent_views` — Recently viewed recipes (for recommendation page)
```sql
CREATE TABLE public.recent_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    viewed_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.recent_views ENABLE ROW LEVEL SECURITY;
CREATE POLICY "views_select_own"
    ON public.recent_views FOR SELECT
    USING (auth.uid() = user_id);
CREATE POLICY "views_insert_own"
    ON public.recent_views FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_recent_views_user_id ON public.recent_views(user_id, viewed_at DESC);
```

#### 5. `chat_sessions` — AI chat history
```sql
CREATE TABLE public.chat_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    recipe_id UUID REFERENCES public.recipes(id) ON DELETE SET NULL,
    messages JSONB NOT NULL DEFAULT '[]',  -- [{role,content,timestamp}, ...]
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "chat_select_own"
    ON public.chat_sessions FOR SELECT
    USING (auth.uid() = user_id);
CREATE POLICY "chat_insert_own"
    ON public.chat_sessions FOR INSERT
    WITH CHECK (auth.uid() = user_id);
CREATE POLICY "chat_update_own"
    ON public.chat_sessions FOR UPDATE
    USING (auth.uid() = user_id);

CREATE TRIGGER on_chat_sessions_updated
    BEFORE UPDATE ON public.chat_sessions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
```

### Table Relationship Diagram

```
auth.users
    │
    ▼ (1:1 trigger)
public.users  ← 프로필 통합 (display_name, badges, stats, spice, dietary, onboarding)
    │
    ├──▶ recipes (1:N)            — AI가 생성한 레시피
    │       │
    │       └──▶ recent_views  (1:N)      — 최근 조회
    │
    ├──▶ saved_items (1:N)         — 북마크 (default/community/ai)
    ├──▶ chat_sessions (1:N)      — AI 대화 기록
    ├──▶ community_posts (1:N)    — 커뮤니티 게시물
    ├──▶ community_likes (1:N)    — 좋아요
    ├──▶ community_comments (1:N) — 댓글
    ├──▶ community_reports (1:N) — 게시물 신고
    ├──▶ community_comment_reports (1:N) — 댓글 신고
    │
    └── recipe_categories (read-only, shared)
```
