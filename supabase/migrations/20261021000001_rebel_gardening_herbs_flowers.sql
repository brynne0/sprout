-- Sage, lavender, ginger, zinnia and dahlia from Rebel Gardening

INSERT INTO plant_types (name, category_id, icon, colour, kind, perennial, germination, care, pests) VALUES
    ('Sage', (SELECT id FROM plant_categories WHERE name = 'Perennial vegetables'), 'sage', 'sage', 'herb', true,
     'Scatter on well-drained soil in a sunny spot, cover with 3mm of compost and water well; can take over a month to come up. Or root spring cuttings of new growth in a small pot under a plastic bowl on a warm windowsill. Or divide an established plant with a sharp knife and replant both halves',
     'Thin seedlings and water often until established. Divide only occasionally. Cut back after flowering for good regrowth next year',
     'Powdery mildew in early spring: keep watered, pick off affected leaves and thin for air flow. Rosemary beetle strips leaves; check often and remove beetles and larvae by hand'),
    ('Lavender', (SELECT id FROM plant_categories WHERE name = 'Perennial vegetables'), 'lavender', 'purple', 'herb', true,
     'Sow indoors; takes 1-3 months to germinate. Plugs or young plants flower sooner',
     'Water regularly in the first year, then it tolerates dry conditions. Prune in late summer after flowering, taking about 2cm off the previous year''s growth, or it turns woody',
     'Root rot in heavy or wet soil; grow in pots if your soil doesn''t drain. Attracts rosemary beetles, but they don''t harm it'),
    ('Ginger', (SELECT id FROM plant_categories WHERE name = 'Perennial vegetables'), 'ginger', 'yellow', 'herb', true,
     'Bury a piece of supermarket root with at least two "eyes" in a little compost, eyes poking out. Keep warm and moist for a few weeks until shoots appear',
     'Repot into a large pot and keep covering the stem with compost as it grows. Water generously. Move outside in summer, into shade if very hot, and bring in before the first frost',
     'Resists most diseases. Red spider mite in a crowded greenhouse; mist regularly to keep it humid'),
    ('Zinnia', (SELECT id FROM plant_categories WHERE name = 'Flowers'), 'flower', 'pink', 'flower', false,
     'Sow where it''s to grow, or in a well-drained pot; it doesn''t like being moved',
     'Stake, as damaged plants won''t flower. Never let it dry out: water at the roots, and check pots often. Save seed at the end of the season',
     'Botrytis shrivels leaves under fluffy grey mould: keep air flowing, clear dead leaves, and water the soil, not the leaves'),
    ('Dahlia', (SELECT id FROM plant_categories WHERE name = 'Flowers'), 'flower-2', 'pink', 'flower', true,
     'Start tubers or seed in a greenhouse or sunny spot indoors, and plant out after the last frost. Let only five shoots grow from each tuber for the best flowers',
     'Stake against wind and rain; choose compact varieties for pots. Deadhead to the first green leaves below the flower. Overwinter in the ground under mulch, or lift the tubers',
     'Earwigs: put straw-filled pots under the plant and move them away. Coffee grounds or eggshells deter slugs and snails');

-- Seasons from the book as months: spring March-May, summer June-August, autumn September-November
INSERT INTO plant_catalogue (plant_type_id, variety, seed_to_harvest, sowing_to_transplant, position, spacing, height, hardiness, sowing_windows, transplant_windows, flowering_windows, harvest_windows, harvest, source)
VALUES
-- Sage
  ((SELECT id FROM plant_types WHERE name = 'Sage'), NULL, NULL, NULL, 'Warm, sunny, sheltered spot. Tolerates dappled light, but the flavour suffers', NULL, '30-80cm', NULL, '[{"start": "03-01", "end": "05-31", "label": "direct"}, {"start": "09-01", "end": "11-30", "label": "direct"}, {"start": "03-01", "end": "05-31", "label": "cuttings"}]', '[{"start": "03-01", "end": "05-31"}, {"start": "09-01", "end": "11-30"}]', NULL, '[{"start": "01-01", "end": "12-31"}]', 'Pick leaves all year; best before it flowers. The purple flowers are edible too. Lasts 6-10 years', 'Rebel Gardening'),
-- Lavender
  ((SELECT id FROM plant_types WHERE name = 'Lavender'), NULL, 'Few flowers in the first year; full flowering from year two', NULL, 'Sunny spot with well-drained soil, or well-drained pots. Somewhere you walk past often', NULL, 'Small to large bush', NULL, NULL, '[{"start": "03-01", "end": "05-31"}]', NULL, NULL, 'Pick just before the flowers open for the best fragrance. Hang upside down to dry', 'Rebel Gardening'),
-- Ginger
  ((SELECT id FROM plant_types WHERE name = 'Ginger'), NULL, NULL, 'A few weeks, once shoots appear', 'Indoors or in pots. Outside in summer in full sun, or partial shade if very hot', NULL, '30cm', 'Bring in before the first frost', '[{"start": "03-01", "end": "05-31", "label": "indoors"}]', '[{"start": "06-01", "end": "08-31", "label": "pots outside"}]', NULL, '[{"start": "09-01", "end": "11-30"}]', 'Once it stops producing leaves in autumn, dig up the root and cut part away, leaving the rest to grow next year', 'Rebel Gardening'),
-- Zinnia
  ((SELECT id FROM plant_types WHERE name = 'Zinnia'), NULL, NULL, NULL, 'Sunny, well-drained spot. Grows well in pots', NULL, '15cm-1m, depending on variety', NULL, '[{"start": "06-01", "end": "08-31", "label": "direct"}]', NULL, NULL, NULL, 'Pick or deadhead to keep it flowering. The petals are bitter but good in salads or cocktails', 'Rebel Gardening'),
-- Dahlia
  ((SELECT id FROM plant_types WHERE name = 'Dahlia'), NULL, NULL, 'Plant out after any frosts', 'Warm, sunny, sheltered spot', NULL, 'Up to 1.5m', 'Unlikely to survive a frost', NULL, '[{"start": "03-01", "end": "08-31"}]', '[{"start": "08-01", "end": "09-30"}]', '[{"start": "08-01", "end": "09-30"}]', 'Snip flowers rather than whole stems to encourage more; they keep going until the first frost. All dahlias are edible, from water chestnut to spicy apple', 'Rebel Gardening');
