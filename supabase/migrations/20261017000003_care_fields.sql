-- Germination, care (feeding, cutting back...) and pests are the same for every variety, so they
-- live on plant_types
ALTER TABLE plant_types
    ADD COLUMN germination TEXT,
    ADD COLUMN care TEXT,
    ADD COLUMN pests TEXT;

-- Hardiness reads as the frost limit first ("Hardy to -5°C" or "Tender, killed by frost"),
-- then any caveat

UPDATE plant_catalogue pc SET hardiness = v.new
FROM (VALUES
    ('Annual', NULL),
    ('Perennial', NULL),
    ('Annual, not frost hardy', 'Tender, killed by frost'),
    ('Not frost hardy', 'Tender, killed by frost'),
    ('Not hardy; will be killed by frost', 'Tender, killed by frost'),
    ('Not hardy. They will be killed by frost.', 'Tender, killed by frost'),
    ('Tender, will be killed by frost', 'Tender, killed by frost'),
    ('Killed by frost and need warmth to thrive', 'Tender, killed by frost. Needs warmth to thrive'),
    ('Killed by frost; grows best when nighttime temperatures are above 12°C', 'Tender, killed by frost. Grows best with nights above 12°C'),
    ('Will not tolerate frost; need nighttime temperatures above 10°C for strong growth', 'Tender, killed by frost. Needs nights above 10°C'),
    ('Not hardy, killed by frost, but more cold tolerant than aubergines and peppers', 'Tender, killed by frost. More cold tolerant than eggplant and capsicum'),
    ('Not hardy; needs warmth and will be killed by frost', 'Tender, killed by frost. Needs warmth'),
    ('Tender; needs warmth and is killed by frost', 'Tender, killed by frost. Needs warmth'),
    ('Not hardy; one of the most warmth-demanding plants', 'Tender, killed by frost. One of the most warmth-demanding plants'),
    ('Tender; will be killed by frost and needs summer warmth to thrive', 'Tender, killed by frost. Needs summer warmth to thrive'),
    ('Some frost resistance to about -2°C', 'Hardy to -2°C'),
    ('Slightly hardy to about -3°C', 'Hardy to -3°C'),
    ('Hardy to approx. -3°C', 'Hardy to -3°C'),
    ('Hardy down to about -3°C, but mature plants go soft if they freeze', 'Hardy to -3°C. Mature plants go soft if they freeze'),
    ('Fairly hardy; mizuna to -3°C and mustard to -5°C', 'Hardy to -3°C. Mustard to -5°C'),
    ('Hardy to approx. -4°C', 'Hardy to -4°C'),
    ('Moderately hardy, down to -4°C', 'Hardy to -4°C'),
    ('Seedlings stand spring frosts to about -4°C', 'Hardy to -4°C as seedlings'),
    ('Hardy to approx. -5°C', 'Hardy to -5°C'),
    ('Hardy, to around -5ºC', 'Hardy to -5°C'),
    ('Will tolerate slight frost; plants hardy to -5°C', 'Hardy to -5°C'),
    ('Hardy to -5°C or colder', 'Hardy to -5°C or colder'),
    ('Mature plants stand frost to about -5°C, depending how much leaf cover is above them', 'Hardy to -5°C, depending on leaf cover'),
    ('Hardy, but mature summer and autumn varieties can be damaged below -5°C', 'Hardy. Mature summer and autumn varieties damaged below -5°C'),
    ('Shoots hardy to approx. -3°C, plants to -6°C', 'Hardy to -6°C. Shoots damaged below -3°C'),
    ('Hardy to at least -6°C', 'Hardy to -6°C or colder'),
    ('Hardy to about -8°C', 'Hardy to -8°C'),
    ('Hardy to about -8°C, sometimes lower', 'Hardy to -8°C, sometimes lower'),
    ('Hardy, to at least -8°C', 'Hardy to -8°C or colder'),
    ('Hardy to approx. -10°C', 'Hardy to -10°C'),
    ('Very hardy to approx. -10°C', 'Hardy to -10°C'),
    ('Very hardy, to -10°C', 'Hardy to -10°C'),
    ('Hardy to -10°C and possibly colder', 'Hardy to -10°C or colder'),
    ('Extremely hardy, to at least -10°C', 'Hardy to -10°C or colder'),
    ('Very hardy, down to at least -10°C', 'Hardy to -10°C or colder'),
    ('Hardy to -10°C in leaf and -5°C for curds', 'Hardy to -10°C. Curds damaged below -5°C'),
    ('Hardy to -10°C, although hearts damaged by lighter frosts', 'Hardy to -10°C. Hearts damaged by lighter frosts'),
    ('Hardy; non-headed plants -10°C, headed plants -4°C', 'Hardy to -10°C. Headed plants only to -4°C'),
    ('Roots hardy to at least -10°C, but spears damaged by frost', 'Hardy to -10°C. Spears damaged by frost'),
    ('Hardy to at least -12°C', 'Hardy to -12°C or colder'),
    ('Hardy to approx. -15°C', 'Hardy to -15°C'),
    ('Very hardy to approx. -15°C', 'Hardy to -15°C'),
    ('Hardy, down to -15°C or lower', 'Hardy to -15°C or colder'),
    ('Very hardy to -15°C or lower', 'Hardy to -15°C or colder'),
    ('Very hardy, down to at least -15°C', 'Hardy to -15°C or colder'),
    ('Hardy; young or looseleaf plants to -15°C, mature hearted plants to -5°C', 'Hardy to -15°C. Mature hearted plants only to -5°C'),
    ('Very hardy to approx. -20°C', 'Hardy to -20°C'),
    ('Hardy to about -30°C', 'Hardy to -30°C'),
    ('Very hardy, perhaps to -30°C, but dormant even in mild winters', 'Hardy to -30°C. Dormant even in mild winters'),
    ('Fully hardy, but can be adversely affect by a long cold spell', 'Fully hardy. A long cold spell can set them back'),
    ('Fully hardy. Tight hearts can split below about -5°C', 'Fully hardy. Tight hearts can split below -5°C'),
    ('Hardy, but stalks are damaged by moderate frost', 'Hardy. Stalks damaged by moderate frost')
) AS v(old, new)
WHERE pc.hardiness = v.old;

-- Views are recreated rather than replaced so the new columns sit next to related ones

DROP VIEW plants_with_details;
DROP VIEW catalogue_with_details;

CREATE VIEW plants_with_details WITH (security_invoker = true) AS
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
    COALESCE(p.overrides->>'germination', pt.germination) AS germination,
    COALESCE(p.overrides->>'seed_to_harvest', pc.seed_to_harvest) AS seed_to_harvest,
    COALESCE(p.overrides->>'sowing_to_transplant', pc.sowing_to_transplant) AS sowing_to_transplant,
    COALESCE(p.overrides->>'care', pt.care) AS care,
    COALESCE(p.overrides->>'pests', pt.pests) AS pests,
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
    pt.germination,
    pt.care,
    pt.pests,
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

GRANT SELECT ON plants_with_details, catalogue_with_details TO authenticated;
