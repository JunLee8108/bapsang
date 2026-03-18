-- ============================================================
-- Bapsang — Comment Reports Migration
-- Separate table for comment reports (mirrors community_reports pattern)
-- ============================================================

-- 1. community_comment_reports — Comment reports
CREATE TABLE public.community_comment_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    comment_id UUID NOT NULL REFERENCES public.community_comments(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(reporter_id, comment_id)
);

ALTER TABLE public.community_comment_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "comment_reports_insert_own"
    ON public.community_comment_reports FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = reporter_id);


-- 2. Add is_hidden column to community_comments
ALTER TABLE public.community_comments
    ADD COLUMN IF NOT EXISTS is_hidden BOOLEAN NOT NULL DEFAULT false;


-- 3. Auto-hide comment when reports >= 3
CREATE OR REPLACE FUNCTION public.check_comment_report_threshold()
RETURNS TRIGGER AS $$
DECLARE
    report_count INT;
BEGIN
    SELECT COUNT(*) INTO report_count
        FROM public.community_comment_reports
        WHERE comment_id = NEW.comment_id;

    IF report_count >= 3 THEN
        UPDATE public.community_comments
            SET is_hidden = true
            WHERE id = NEW.comment_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_comment_report_check_threshold
    AFTER INSERT ON public.community_comment_reports
    FOR EACH ROW
    EXECUTE FUNCTION public.check_comment_report_threshold();
