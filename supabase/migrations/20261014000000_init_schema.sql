CREATE TYPE suitability_tag AS ENUM ('multisow', 'interplant', 'follow-on', 'intersow');
CREATE TYPE plant_kind AS ENUM ('vegetable', 'herb', 'fruit', 'flower');

-- Shared reference data (read-only for users)

CREATE TABLE plant_categories (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE plant_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    category_id INTEGER REFERENCES plant_categories(id),
    icon TEXT,
    colour TEXT,
    kind plant_kind NOT NULL DEFAULT 'vegetable'
);

CREATE TABLE plant_catalogue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plant_type_id UUID NOT NULL REFERENCES plant_types(id),
    variety TEXT,
    seed_to_harvest TEXT,
    sowing_to_transplant TEXT,
    position TEXT,
    spacing TEXT,
    height TEXT,
    hardiness TEXT,
    sowing_windows JSONB,
    harvest_windows JSONB,
    transplant_windows JSONB,
    flowering_windows JSONB,
    harvest TEXT,
    suitability suitability_tag[],
    source TEXT,
    UNIQUE (plant_type_id, variety)
);

-- Per-user plants (users live in Supabase's auth.users)

CREATE TABLE plants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
    plant_type_id UUID NOT NULL REFERENCES plant_types(id),
    catalogue_id UUID REFERENCES plant_catalogue(id),
    custom_variety TEXT,
    sow_dates DATE[] NOT NULL DEFAULT '{}',
    repot_dates DATE[] NOT NULL DEFAULT '{}',
    transplant_dates DATE[] NOT NULL DEFAULT '{}',
    harvest_dates DATE[] NOT NULL DEFAULT '{}',
    overrides JSONB,
    notes TEXT,
    year INTEGER,
    archived_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX plants_user_id_idx ON plants (user_id);

-- Row Level Security

ALTER TABLE plant_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE plant_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE plant_catalogue ENABLE ROW LEVEL SECURITY;
ALTER TABLE plants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Signed-in users can read categories" ON plant_categories
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Signed-in users can read plant types" ON plant_types
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Signed-in users can read the catalogue" ON plant_catalogue
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can read their own plants" ON plants
    FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
CREATE POLICY "Users can add their own plants" ON plants
    FOR INSERT TO authenticated WITH CHECK (user_id = (SELECT auth.uid()));
CREATE POLICY "Users can update their own plants" ON plants
    FOR UPDATE TO authenticated
    USING (user_id = (SELECT auth.uid()))
    WITH CHECK (user_id = (SELECT auth.uid()));
CREATE POLICY "Users can delete their own plants" ON plants
    FOR DELETE TO authenticated USING (user_id = (SELECT auth.uid()));

-- Plants merged with catalogue defaults (replaces PLANT_SELECT in the old API).
-- security_invoker makes the plants RLS policies apply through the view.

CREATE VIEW plants_with_details WITH (security_invoker = true) AS
SELECT
    p.id,
    p.plant_type_id,
    p.catalogue_id,
    p.custom_variety,
    pt.name,
    pt.icon,
    pt.colour,
    pt.kind,
    COALESCE(pc.variety, p.custom_variety) AS variety,
    p.sow_dates,
    p.repot_dates,
    p.transplant_dates,
    p.harvest_dates,
    p.notes,
    COALESCE(p.overrides->>'position', pc.position) AS position,
    COALESCE(p.overrides->>'hardiness', pc.hardiness) AS hardiness,
    COALESCE(p.overrides->>'spacing', pc.spacing) AS spacing,
    COALESCE(p.overrides->>'height', pc.height) AS height,
    COALESCE(p.overrides->>'seed_to_harvest', pc.seed_to_harvest) AS seed_to_harvest,
    COALESCE(p.overrides->>'sowing_to_transplant', pc.sowing_to_transplant) AS sowing_to_transplant,
    COALESCE(p.overrides->>'harvest', pc.harvest) AS harvest,
    COALESCE(p.overrides->'suitability', to_jsonb(pc.suitability)) AS suitability,
    COALESCE(p.overrides->'sowing_windows', pc.sowing_windows) AS sowing_windows,
    COALESCE(p.overrides->'harvest_windows', pc.harvest_windows) AS harvest_windows,
    COALESCE(p.overrides->'transplant_windows', pc.transplant_windows) AS transplant_windows,
    COALESCE(p.overrides->'flowering_windows', pc.flowering_windows) AS flowering_windows,
    p.year,
    p.archived_at,
    pcat.name AS category_name
FROM plants p
JOIN plant_types pt ON pt.id = p.plant_type_id
LEFT JOIN plant_catalogue pc ON pc.id = p.catalogue_id
LEFT JOIN plant_categories pcat ON pcat.id = pt.category_id;

-- Catalogue entries with their plant type's name, icon, colour and category.

CREATE VIEW catalogue_with_details WITH (security_invoker = true) AS
SELECT
    pc.id,
    pc.plant_type_id,
    pt.name,
    pt.icon,
    pt.colour,
    pt.kind,
    pc.variety,
    pc.position,
    pc.hardiness,
    pc.spacing,
    pc.height,
    pc.harvest,
    pc.source,
    pc.seed_to_harvest,
    pc.sowing_to_transplant,
    pc.suitability,
    pc.sowing_windows,
    pc.harvest_windows,
    pc.transplant_windows,
    pc.flowering_windows,
    pcat.name AS category_name
FROM plant_catalogue pc
JOIN plant_types pt ON pt.id = pc.plant_type_id
LEFT JOIN plant_categories pcat ON pcat.id = pt.category_id;

-- Lets a signed-in user delete their own account; their plants cascade.

CREATE FUNCTION public.delete_my_account()
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
    DELETE FROM auth.users WHERE id = auth.uid();
$$;

REVOKE EXECUTE ON FUNCTION public.delete_my_account() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.delete_my_account() TO authenticated;
