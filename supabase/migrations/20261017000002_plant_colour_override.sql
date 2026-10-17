-- Plants can override their plant type's icon colour via overrides->>'colour'.

CREATE OR REPLACE VIEW plants_with_details WITH (security_invoker = true) AS
SELECT
    p.id,
    p.plant_type_id,
    p.catalogue_id,
    p.custom_variety,
    pt.name,
    pt.icon,
    COALESCE(p.overrides->>'colour', pt.colour) AS colour,
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
