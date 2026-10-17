-- Raspberry, plus a general strawberry entry alongside the Baron Solemacher variety

INSERT INTO plant_types (name, category_id, icon, colour, kind, perennial, germination, care) VALUES
    ('Raspberry', (SELECT id FROM plant_categories WHERE name = 'Perennial vegetables'), 'raspberry', 'beet', 'fruit', true,
     'Sow in autumn 6mm deep, 2.5cm apart in moist compost; needs a cold winter in a cold frame or unheated shed to germinate',
     'Summer-fruiting varieties need a cane for support');

UPDATE plant_types SET care = 'Feed weekly with tomato feed. Once it stops fruiting, cut back so it regrows next year'
WHERE name = 'Strawberry';

-- Hardiness (H6) and harvest windows are from the RHS, with summer raspberries matched to German seasons
INSERT INTO plant_catalogue (plant_type_id, variety, seed_to_harvest, sowing_to_transplant, position, spacing, height, hardiness, sowing_windows, transplant_windows, harvest_windows, harvest, source)
VALUES
-- Strawberry
  ((SELECT id FROM plant_types WHERE name = 'Strawberry'), NULL, NULL, NULL, 'Full sun. A large, deep pot with good drainage (gravel at the bottom). Keep the soil moist but the plant dry', 'One plant per pot', 'Small bush', 'Hardy to -15°C. Cover flowers and early fruit overnight if frost is forecast', NULL, '[{"start": "03-01", "end": "04-15", "label": "runners"}, {"start": "06-01", "end": "06-30", "label": "plants"}]', '[{"start": "06-01", "end": "08-10", "label": "summer-fruiting"}, {"start": "06-15", "end": "09-30", "label": "perpetual"}]', 'Expect at least two years of fruit before replacing', 'Rebel Gardening, RHS'),
-- Raspberry
  ((SELECT id FROM plant_types WHERE name = 'Raspberry'), NULL, 'Up to 18 months from seed', 'Move seed trays outside to partial shade in spring once it is around 16°C; pot on when seedlings are 2.5cm tall', 'Sunny spot. Pot with good drainage and rich compost', '60-90cm each, so one per pot unless the pot is very large', '2-3m', 'Hardy to -15°C', '[{"start": "09-01", "end": "11-30", "label": "seed"}]', '[{"start": "03-01", "end": "05-31", "label": "canes"}]', '[{"start": "06-15", "end": "08-15", "label": "summer-fruiting"}, {"start": "08-01", "end": "10-31", "label": "autumn-fruiting"}]', 'Pick carefully and often', 'Rebel Gardening, RHS');
