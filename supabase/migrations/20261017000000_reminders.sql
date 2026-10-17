CREATE TYPE task_type AS ENUM ('sow', 'repot', 'transplant', 'harvest');

-- Planned tasks. The date arrays on plants only hold what was actually done
CREATE TABLE reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
    plant_id UUID NOT NULL REFERENCES plants(id) ON DELETE CASCADE,
    type task_type NOT NULL,
    due_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX reminders_user_id_idx ON reminders (user_id);
CREATE INDEX reminders_plant_id_idx ON reminders (plant_id);

ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own reminders" ON reminders
    FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
CREATE POLICY "Users can add reminders to their own plants" ON reminders
    FOR INSERT TO authenticated WITH CHECK (
        user_id = (SELECT auth.uid())
        AND EXISTS (SELECT 1 FROM plants p WHERE p.id = plant_id AND p.user_id = (SELECT auth.uid()))
    );
CREATE POLICY "Users can update their own reminders" ON reminders
    FOR UPDATE TO authenticated
    USING (user_id = (SELECT auth.uid()))
    WITH CHECK (user_id = (SELECT auth.uid()));
CREATE POLICY "Users can delete their own reminders" ON reminders
    FOR DELETE TO authenticated USING (user_id = (SELECT auth.uid()));

GRANT SELECT, INSERT, UPDATE, DELETE ON reminders TO authenticated;

-- Logs a reminder as done on the given day and removes it in one transaction.
-- Runs as the caller, so RLS on reminders and plants still applies
CREATE FUNCTION public.complete_reminder(reminder_id UUID, done_on DATE)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
    r public.reminders;
BEGIN
    DELETE FROM public.reminders WHERE id = reminder_id RETURNING * INTO r;
    IF r.id IS NULL THEN
        RAISE EXCEPTION 'Reminder not found';
    END IF;
    UPDATE public.plants SET
        sow_dates = CASE WHEN r.type = 'sow' THEN array_append(sow_dates, done_on) ELSE sow_dates END,
        repot_dates = CASE WHEN r.type = 'repot' THEN array_append(repot_dates, done_on) ELSE repot_dates END,
        transplant_dates = CASE WHEN r.type = 'transplant' THEN array_append(transplant_dates, done_on) ELSE transplant_dates END,
        harvest_dates = CASE WHEN r.type = 'harvest' THEN array_append(harvest_dates, done_on) ELSE harvest_dates END
    WHERE id = r.plant_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.complete_reminder(UUID, DATE) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.complete_reminder(UUID, DATE) TO authenticated;

-- Existing future dates were plans, so move them into reminders
INSERT INTO reminders (user_id, plant_id, type, due_date)
SELECT user_id, id, 'sow'::task_type, d FROM plants, unnest(sow_dates) d WHERE d > CURRENT_DATE
UNION ALL
SELECT user_id, id, 'repot'::task_type, d FROM plants, unnest(repot_dates) d WHERE d > CURRENT_DATE
UNION ALL
SELECT user_id, id, 'transplant'::task_type, d FROM plants, unnest(transplant_dates) d WHERE d > CURRENT_DATE
UNION ALL
SELECT user_id, id, 'harvest'::task_type, d FROM plants, unnest(harvest_dates) d WHERE d > CURRENT_DATE;

UPDATE plants SET
    sow_dates = ARRAY(SELECT d FROM unnest(sow_dates) d WHERE d <= CURRENT_DATE),
    repot_dates = ARRAY(SELECT d FROM unnest(repot_dates) d WHERE d <= CURRENT_DATE),
    transplant_dates = ARRAY(SELECT d FROM unnest(transplant_dates) d WHERE d <= CURRENT_DATE),
    harvest_dates = ARRAY(SELECT d FROM unnest(harvest_dates) d WHERE d <= CURRENT_DATE);
