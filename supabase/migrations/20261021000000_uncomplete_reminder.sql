-- Unlike array_remove, keeps other logs on the same day
CREATE FUNCTION public.array_remove_last(arr DATE[], val DATE)
RETURNS DATE[]
LANGUAGE sql
IMMUTABLE
SET search_path = ''
AS $$
    SELECT CASE WHEN pos IS NULL THEN arr ELSE arr[:pos - 1] || arr[pos + 1:] END
    FROM (SELECT (array_positions(arr, val))[cardinality(array_positions(arr, val))] AS pos) s;
$$;

-- Reverses complete_reminder
CREATE FUNCTION public.uncomplete_reminder(
    reminder_id UUID,
    for_plant UUID,
    task public.task_type,
    due DATE,
    done_on DATE
)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
    INSERT INTO public.reminders (id, plant_id, type, due_date)
    VALUES (reminder_id, for_plant, task, due);
    UPDATE public.plants SET
        sow_dates = CASE WHEN task = 'sow' THEN public.array_remove_last(sow_dates, done_on) ELSE sow_dates END,
        repot_dates = CASE WHEN task = 'repot' THEN public.array_remove_last(repot_dates, done_on) ELSE repot_dates END,
        transplant_dates = CASE WHEN task = 'transplant' THEN public.array_remove_last(transplant_dates, done_on) ELSE transplant_dates END,
        harvest_dates = CASE WHEN task = 'harvest' THEN public.array_remove_last(harvest_dates, done_on) ELSE harvest_dates END
    WHERE id = for_plant;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Plant not found';
    END IF;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.array_remove_last(DATE[], DATE) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.array_remove_last(DATE[], DATE) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.uncomplete_reminder(UUID, UUID, public.task_type, DATE, DATE) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.uncomplete_reminder(UUID, UUID, public.task_type, DATE, DATE) TO authenticated;
