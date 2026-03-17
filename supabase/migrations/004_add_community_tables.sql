-- ============================================================
-- Bapsang — Community Tables Migration
-- Run this in Supabase SQL Editor
-- ============================================================
-- NOTE: Community stats (total_likes_received, total_posts, badges)
-- live in public.users — no separate user_profiles table needed.
-- ============================================================

-- 1. Add community + onboarding columns to public.users
ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS total_likes_received    INT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS total_posts             INT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS badges                  JSONB NOT NULL DEFAULT '[]',
    ADD COLUMN IF NOT EXISTS preferred_spice_level   TEXT NOT NULL DEFAULT 'medium'
        CHECK (preferred_spice_level IN ('mild', 'medium', 'spicy', 'extra_spicy')),
    ADD COLUMN IF NOT EXISTS dietary_restrictions    JSONB NOT NULL DEFAULT '[]',
    ADD COLUMN IF NOT EXISTS has_completed_onboarding BOOLEAN NOT NULL DEFAULT false;

UPDATE public.users SET display_name = 'Chef' WHERE display_name IS NULL;
ALTER TABLE public.users ALTER COLUMN display_name SET DEFAULT 'Chef';

-- Allow all authenticated users to read any user's profile
-- (needed for showing display_name / badges on community posts)
DROP POLICY IF EXISTS "users_select_own" ON public.users;
CREATE POLICY "users_select_community_profile"
    ON public.users FOR SELECT
    TO authenticated
    USING (true);


-- 2. community_posts — User-shared recipes
CREATE TABLE public.community_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    ingredients JSONB NOT NULL DEFAULT '[]',
    steps JSONB NOT NULL DEFAULT '[]',
    cooking_time INT,
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
    serving_size INT DEFAULT 1,
    image_url TEXT,
    likes_count INT NOT NULL DEFAULT 0,
    comments_count INT NOT NULL DEFAULT 0,
    is_hidden BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "posts_select_visible"
    ON public.community_posts FOR SELECT
    TO authenticated
    USING (is_hidden = false OR user_id = auth.uid());

CREATE POLICY "posts_insert_own"
    ON public.community_posts FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "posts_delete_own"
    ON public.community_posts FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

CREATE INDEX idx_community_posts_user ON public.community_posts(user_id);
CREATE INDEX idx_community_posts_created ON public.community_posts(created_at DESC);
CREATE INDEX idx_community_posts_likes ON public.community_posts(likes_count DESC);


-- 3. community_likes — Post likes (one per user per post)
CREATE TABLE public.community_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES public.community_posts(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, post_id)
);

ALTER TABLE public.community_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "likes_select_authenticated"
    ON public.community_likes FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "likes_insert_own"
    ON public.community_likes FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "likes_delete_own"
    ON public.community_likes FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);


-- 4. community_comments — Post comments
CREATE TABLE public.community_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES public.community_posts(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.community_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "comments_select_authenticated"
    ON public.community_comments FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "comments_insert_own"
    ON public.community_comments FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "comments_delete_own"
    ON public.community_comments FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

CREATE INDEX idx_community_comments_post ON public.community_comments(post_id, created_at);


-- 5. community_reports — Post reports
CREATE TABLE public.community_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES public.community_posts(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(reporter_id, post_id)
);

ALTER TABLE public.community_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "reports_insert_own"
    ON public.community_reports FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = reporter_id);


-- ============================================================
-- Triggers & Functions
-- ============================================================

-- Auto-update likes_count on community_posts + total_likes_received on users
CREATE OR REPLACE FUNCTION public.update_post_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.community_posts
            SET likes_count = likes_count + 1
            WHERE id = NEW.post_id;
        UPDATE public.users
            SET total_likes_received = total_likes_received + 1
            WHERE id = (SELECT user_id FROM public.community_posts WHERE id = NEW.post_id);
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.community_posts
            SET likes_count = likes_count - 1
            WHERE id = OLD.post_id;
        UPDATE public.users
            SET total_likes_received = total_likes_received - 1
            WHERE id = (SELECT user_id FROM public.community_posts WHERE id = OLD.post_id);
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_community_like_changed
    AFTER INSERT OR DELETE ON public.community_likes
    FOR EACH ROW
    EXECUTE FUNCTION public.update_post_likes_count();


-- Auto-update comments_count on community_posts
CREATE OR REPLACE FUNCTION public.update_post_comments_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.community_posts
            SET comments_count = comments_count + 1
            WHERE id = NEW.post_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.community_posts
            SET comments_count = comments_count - 1
            WHERE id = OLD.post_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_community_comment_changed
    AFTER INSERT OR DELETE ON public.community_comments
    FOR EACH ROW
    EXECUTE FUNCTION public.update_post_comments_count();


-- Auto-update total_posts on public.users
CREATE OR REPLACE FUNCTION public.update_user_total_posts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.users
            SET total_posts = total_posts + 1
            WHERE id = NEW.user_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.users
            SET total_posts = total_posts - 1
            WHERE id = OLD.user_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_community_post_changed
    AFTER INSERT OR DELETE ON public.community_posts
    FOR EACH ROW
    EXECUTE FUNCTION public.update_user_total_posts();


-- Auto-hide post when reports >= 3
CREATE OR REPLACE FUNCTION public.check_report_threshold()
RETURNS TRIGGER AS $$
DECLARE
    report_count INT;
BEGIN
    SELECT COUNT(*) INTO report_count
        FROM public.community_reports
        WHERE post_id = NEW.post_id;

    IF report_count >= 3 THEN
        UPDATE public.community_posts
            SET is_hidden = true
            WHERE id = NEW.post_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_report_check_threshold
    AFTER INSERT ON public.community_reports
    FOR EACH ROW
    EXECUTE FUNCTION public.check_report_threshold();


-- Auto-update badges based on milestones (on public.users)
CREATE OR REPLACE FUNCTION public.update_user_badges()
RETURNS TRIGGER AS $$
DECLARE
    current_badges JSONB;
    new_badges JSONB;
BEGIN
    current_badges := NEW.badges;
    new_badges := current_badges;

    IF NEW.total_posts >= 1 AND NOT current_badges @> '"first_post"' THEN
        new_badges := new_badges || '"first_post"'::jsonb;
    END IF;

    IF NEW.total_posts >= 10 AND NOT current_badges @> '"prolific"' THEN
        new_badges := new_badges || '"prolific"'::jsonb;
    END IF;

    IF NEW.total_likes_received >= 10 AND NOT current_badges @> '"popular"' THEN
        new_badges := new_badges || '"popular"'::jsonb;
    END IF;

    IF NEW.total_likes_received >= 50 AND NOT current_badges @> '"star"' THEN
        new_badges := new_badges || '"star"'::jsonb;
    END IF;

    IF NEW.total_likes_received >= 100 AND NOT current_badges @> '"master"' THEN
        new_badges := new_badges || '"master"'::jsonb;
    END IF;

    IF new_badges IS DISTINCT FROM current_badges THEN
        NEW.badges := new_badges;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_user_badge_update
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.update_user_badges();
