-- ============================================================
-- Bapsang — Merge user_profiles into public.users
-- Run this in Supabase SQL Editor
-- ============================================================
-- Rationale: user_profiles duplicated id, display_name, created_at
-- with public.users. Merging eliminates the redundancy and removes
-- the need for ensureProfile() — rows already exist at signup.
-- ============================================================

-- 1. Add community columns to public.users
ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS total_likes_received INT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS total_posts          INT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS badges               JSONB NOT NULL DEFAULT '[]';

-- Set display_name default to 'Chef' for users who haven't set one
UPDATE public.users SET display_name = 'Chef' WHERE display_name IS NULL;
ALTER TABLE public.users ALTER COLUMN display_name SET DEFAULT 'Chef';

-- 2. Migrate existing data from user_profiles (if any rows exist)
UPDATE public.users u
SET
    display_name         = COALESCE(p.display_name, u.display_name),
    total_likes_received = p.total_likes_received,
    total_posts          = p.total_posts,
    badges               = p.badges
FROM public.user_profiles p
WHERE u.id = p.id;

-- 3. Add RLS policy: any authenticated user can read community-visible
--    fields (display_name, badges, stats) of all users.
--    (Existing policies already allow own-row SELECT/UPDATE.)
CREATE POLICY "users_select_community_profile"
    ON public.users FOR SELECT
    TO authenticated
    USING (true);

-- Drop the old own-only SELECT policy (now superseded)
DROP POLICY IF EXISTS "users_select_own" ON public.users;

-- 4. Update triggers: point from user_profiles → public.users

-- 4a. update_post_likes_count — likes INSERT/DELETE
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

-- 4b. update_user_total_posts — post INSERT/DELETE
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

-- 4c. update_user_badges — fires BEFORE UPDATE on public.users
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

-- Drop old trigger on user_profiles, create on public.users
DROP TRIGGER IF EXISTS on_profile_badge_update ON public.user_profiles;

CREATE TRIGGER on_user_badge_update
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.update_user_badges();

-- 5. Drop user_profiles table (cascade drops its RLS policies)
DROP TABLE IF EXISTS public.user_profiles CASCADE;
