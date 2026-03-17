-- ============================================================
-- Drop deprecated saved_recipes table
--
-- Reason: saved_recipes only referenced the `recipes` (AI-generated)
-- table, so it could not store bookmarks for default or community
-- recipes. Replaced by `saved_items` (migration 007) which supports
-- multiple source types via a source_type + source_id design.
-- ============================================================

DROP TABLE IF EXISTS public.saved_recipes;
