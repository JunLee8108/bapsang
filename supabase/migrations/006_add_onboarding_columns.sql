-- ============================================================
-- Bapsang — Add onboarding columns to public.users
-- Run this in Supabase SQL Editor
-- ============================================================

ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS preferred_spice_level TEXT NOT NULL DEFAULT 'medium'
        CHECK (preferred_spice_level IN ('mild', 'medium', 'spicy', 'extra_spicy')),
    ADD COLUMN IF NOT EXISTS dietary_restrictions JSONB NOT NULL DEFAULT '[]',
    ADD COLUMN IF NOT EXISTS has_completed_onboarding BOOLEAN NOT NULL DEFAULT false;
