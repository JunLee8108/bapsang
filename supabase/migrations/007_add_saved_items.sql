-- ============================================================
-- Bapsang — Saved Items (multi-source bookmarks)
-- ============================================================

CREATE TABLE public.saved_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    source_type TEXT NOT NULL CHECK (source_type IN ('default', 'community')),
    source_id UUID NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, source_type, source_id)
);

ALTER TABLE public.saved_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "saved_items_select_own"
    ON public.saved_items FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "saved_items_insert_own"
    ON public.saved_items FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "saved_items_delete_own"
    ON public.saved_items FOR DELETE
    USING (auth.uid() = user_id);

CREATE INDEX idx_saved_items_user_type ON public.saved_items(user_id, source_type);
