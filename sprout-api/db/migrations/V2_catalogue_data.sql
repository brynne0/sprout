INSERT INTO plant_categories (name) VALUES
    ('Legumes - pea and bean family'),
    ('Brassicas - cabbage family'),
    ('Alliums - onion family'),
    ('Cucurbits - cucumber family'),
    ('Umbellifers - carrot family'),
    ('Beet family'),
    ('Leafy salad crops'),
    ('Solanums, basil, and sweetcorn'),
    ('Perennial vegetables');

INSERT INTO plant_types (name, category_id) VALUES
    ('Broad Beans', (SELECT id FROM plant_categories WHERE name = 'Legumes - pea and bean family')),
    ('Climbing Beans', (SELECT id FROM plant_categories WHERE name = 'Legumes - pea and bean family')),
    ('Dwarf French Beans', (SELECT id FROM plant_categories WHERE name = 'Legumes - pea and bean family')),
    ('Peas', (SELECT id FROM plant_categories WHERE name = 'Legumes - pea and bean family')),
    ('Broccoli', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family')),
    ('Brussels Sprouts', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family')),
    ('Cabbage', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family')),
    ('Cauliflower', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family')),
    ('Kale', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family')),
    ('Radish', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family')),
    ('Swede', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family')),
    ('Turnip', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family')),
    ('Garlic', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family')),
    ('Leek', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family')),
    ('Spring Onion', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family')),
    ('Bulb Onion and Shallot', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family')),
    ('Overwintering Onion', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family'));
    
INSERT INTO plant_catalogue (plant_type_id, variety, description, seed_to_harvest, sowing_to_transplant, position, spacing, hardiness, sowing_windows, transplant_windows, harvest_windows, harvest, source)
VALUES
-- Legumes
  ((SELECT id FROM plant_types WHERE name = 'Broad Beans'), NULL, NULL, '4 months (from late winter and spring sowings)', '4-6 weeks after sowing, when they are about 5-7cm tall', 'Adaptable, will tolerate shade', '20-25 cm equidistant or 15cm apart with 45cm between rows', 'Fully hardy, but can be adversely affect by a long cold spell', '[{"start": "01-01", "end": "04-30"}, {"start": "10-15", "end": "10-31"}]', '[{"start": "02-01", "end": "05-31"}, {"start": "12-01", "end": "12-31"}]', '[{"start": "06-01", "end": "08-15"}]', NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Climbing Beans'), NULL, NULL, '3 months for pods, 4-5 for beans', '2-3 weeks', 'Full sun, can tolerate some shade. Avoid a windy position.', '30cm apart, 60cm between rows', 'Killed by frost and need warmth to thrive', '[{"start": "05-15", "end": "06-30"}]', '[{"start": "06-01", "end": "07-15"}]', '[{"start": "07-15", "end": "10-15"}]', NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Dwarf French Beans'), NULL, NULL, '2.5 months', '3 weeks', 'Full sun and warmth', '30-35cm apart each way', 'Not hardy. They will be killed by frost.', '[{"start": "05-01", "end": "06-30"}]', '[{"start": "05-15", "end": "07-31"}]', '[{"start": "06-15", "end": "10-15"}]', NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Peas'), NULL, NULL, '3-3.5 months', '3 weeks', 'Full sun, moist soil, align rows at 90º to prevailing wind', 'Dwarf varieties: 15cm apart with 30cm between rows across bed. Medium varieties: Double row 30cm apart along length of bed, with plants 20cm apart, or single rows across bed 45cm apart with 20cm between plants. Tall varieties: Single row along length of bed with plants 15cm apart.', 'Hardy, to around -5ºC', '[{"start": "02-15", "end": "04-30"}, {"start": "06-15", "end": "06-30"}, {"start": "11-01", "end": "11-30"}]', '[{"start": "02-01", "end": "05-15"}, {"start": "07-15", "end": "07-31"}]', '[{"start": "06-01", "end": "07-31"}, {"start": "10-01", "end": "10-31"}]', NULL, 'No Dig'),
-- Broccoli 
  ((SELECT id FROM plant_types WHERE name = 'Broccoli'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '[{"start": "02-15", "end": "07-31"}]', NULL, '[{"start": "03-01", "end": "11-30"}]', NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Broccoli'), 'Calabrese', NULL, '3 months', '3-5 weeks', 'Adaptable, tolerates shade', '30-40cm', 'Hardy to approx. -3°C', '[{"start": "02-15", "end": "06-15"}]', '[{"start": "03-15", "end": "08-15"}]', '[{"start": "06-15", "end": "10-15"}]', NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Broccoli'), 'Purple Sprouting', NULL, '9 months', '3-5 weeks', 'Adaptable, tolerates shade', '50-60cm', 'Very hardy to approx. -10°C', '[{"start": "04-15", "end": "06-15"}]', '[{"start": "05-15", "end": "07-15"}]', '[{"start": "08-01", "end": "05-15"}]', NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Broccoli'), 'Kaibroc', NULL, '2 1/2 months', '3-5 weeks', 'Adaptable, tolerates shade', '30-40cm', 'Shoots hardy to approx. -3°C, plants to -6°C', '[{"start": "04-01", "end": "05-31"}, {"start": "07-01", "end": "07-31"}]', '[{"start": "05-01", "end": "05-31"}, {"start": "08-01", "end": "08-31"}]', '[{"start": "07-01", "end": "11-30"}]', NULL, 'No Dig'),
-- Brussels Sprouts
  ((SELECT id FROM plant_types WHERE name = 'Brussels Sprouts'), NULL, 'Suitable for interplanting', '5-7 months', '6-8 weeks', 'Any position, including shade. Will tolerate wind', '60cm equidistant', 'Very hardy', '[{"start": "04-15", "end": "05-15"}]', '[{"start": "05-15", "end": "06-30"}]', '[{"start": "10-01", "end": "01-31", "label": "early"}, {"start": "12-01", "end": "03-31", "label": "late"}]', NULL, 'No Dig'),
-- Cabbage 
  ((SELECT id FROM plant_types WHERE name = 'Cabbage'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '[{"start": "02-15", "end": "08-31"}]', NULL, '[{"start": "01-01", "end": "12-31"}]', NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Cabbage'), 'Spring', 'Suitable for second follow-on planting', '7-8 months', '4-6 weeks', 'Tolerates some shade', '20-30cm', 'Fully hardy. Tight hearts can split below about -5°C', '[{"start": "08-15", "end": "08-31"}]', '[{"start": "09-15", "end": "10-31"}]', '[{"start": "03-15", "end": "05-15"}]', NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Cabbage'), 'Summer', NULL, '4 months', '4-6 weeks', 'Tolerates some shade', '35-40cm', 'Fully hardy', '[{"start": "02-15", "end": "03-31"}]', '[{"start": "04-01", "end": "05-31"}]', '[{"start": "06-01", "end": "07-31"}]', NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Cabbage'), 'Autumn', NULL, '4 months', '4-6 weeks', 'Tolerates some shade', '45-60cm', 'Fully hardy. Tight hearts can split below -5°C', '[{"start": "04-15", "end": "05-15"}]', '[{"start": "05-01", "end": "06-30"}]', '[{"start": "09-01", "end": "11-30"}]', NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Cabbage'), 'Winter', 'Suitable for second follow-on planting', '5 months', '4-6 weeks', 'Tolerates some shade', '40cm', 'Fully hardy', '[{"start": "06-01", "end": "06-31"}]', '[{"start": "07-01", "end": "07-31"}]', '[{"start": "11-01", "end": "03-31"}]', NULL, 'No Dig'),
-- Cauliflower
  ((SELECT id FROM plant_types WHERE name = 'Cauliflower'), NULL, 'Suitable for interplanting in late summer', '4 months (summer and autumn crop), 8 months (early spring crop)', '4-6 weeks', 'Any position, tolerates some shade', '40-55cm equidistant', 'Hardy to -10°C in leaf and -5°C for curds', '[{"start": "02-15", "end": "03-15", "label": "midsummer crop"}, {"start": "06-15", "end": "06-30", "label": "autumn crop"}, {"start": "07-15", "end": "08-31", "label": "early spring crop"}]', '[{"start": "04-01", "end": "04-15"}, {"start": "09-01", "end": "09-15"}]', '[{"start": "03-01", "end": "05-15"}, {"start": "06-15", "end": "07-15"}, {"start": "10-01", "end": "11-30"}]', NULL, 'No Dig'),
-- Kale
  ((SELECT id FROM plant_types WHERE name = 'Kale'), NULL, 'Suitable as a follow on crop', '2-3 months', '3-6 weeks', 'Full sun is ideal, but will tolerate some shade', '45-50cm for large varieties, 35cm for dwarf varieties, 22cm for salad leaves', 'Very hardy, down to at least -10°C', '[{"start": "03-01", "end": "04-30"}, {"start": "05-15", "end": "06-30"}, {"start": "07-15", "end": "08-15", "label": "salad leaves over winter"}]', '[{"start": "04-01", "end": "09-15"}]', '[{"start": "06-01", "end": "03-31", "label": "large"}, {"start": "10-01", "end": "04-30", "label": "salad"}]', NULL, 'No Dig'),
-- Radish 
  ((SELECT id FROM plant_types WHERE name = 'Radish'), 'Spring', 'Suitable for multisowing and as a second or third crop', '6 weeks', '3-4 weeks', 'Full sun or some shade', 'Multisown 15cm equidistant', 'Moderately hardy', '[{"start": "02-15", "end": "04-30"}]', '[{"start": "03-15", "end": "05-15"}]', '[{"start": "04-01", "end": "06-15"}]', NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Radish'), 'Winter', 'Suitable as a follow-on crop', '3 months', '3-4 weeks', 'Full sun or some shade', '20cm equidistant', 'Moderately hardy, down to -4°C', '[{"start": "07-15", "end": "07-31"}]', '[{"start": "08-15", "end": "08-31"}]', '[{"start": "10-01", "end": "01-31"}]', NULL, 'No Dig'),
-- Swede
  ((SELECT id FROM plant_types WHERE name = 'Swede'), NULL, 'Suitable as a second follow-on crop', '4 months', '4 weeks', 'Full sun or a little shade', '30-35cm equidistant', 'Extremely hardy, to at least -10°C', '[{"start": "05-15", "end": "05-31"}]', '[{"start": "06-15", "end": "06-30"}]', '[{"start": "10-01", "end": "03-31"}]', NULL, 'No Dig'),
-- Turnip
  ((SELECT id FROM plant_types WHERE name = 'Turnip'), NULL, 'Suitable for multisowing and interplanting', '2 months', '2-4 weeks', 'Full sun', '25-30cm equidistant', 'Hardy to approx. -5°C', '[{"start": "02-15", "end": "03-15"}, {"start": "08-01", "end": "08-15"}]', '[{"start": "03-15", "end": "04-15"}, {"start": "08-15", "end": "08-31"}]', '[{"start": "05-01", "end": "06-15"}, {"start": "10-01", "end": "11-15"}]', NULL, 'No Dig'),
-- Garlic
  ((SELECT id FROM plant_types WHERE name = 'Garlic'), NULL, 'Suitable for interplanting or intersowing in May or June', '8 months when sown in October', 'Not applicable', 'Adaptable; likes sun and warmth in spring and summer', '10-15cm equidistant or 8-10cm apart in rows 25cm apart', 'Hardy to at least -12°C', '[{"start": "09-15", "end": "12-31"}]', NULL, '[{"start": "06-15", "end": "07-15"}]', NULL, 'No Dig'),
-- Leek
  ((SELECT id FROM plant_types WHERE name = 'Leek'), NULL, 'Suitable for multisowing and as a second follow-on crop', 'Summer: 4.5-5 months, Autumn: 5-6 months, Winter: 10-13 months', '2-3 months', 'Moist, tolerates some shade', 'Clumps at 20-25cm equidistant, singles at 10cm', 'Hardy, but mature summer and autumn varieties can be damaged below -5°C', '[{"start": "04-01", "end": "04-15"}]', '[{"start": "06-01", "end": "07-31"}]', '[{"start": "07-15", "end": "09-30", "label": "summer"}, {"start": "09-01", "end": "01-31", "label": "autumn"}, {"start": "02-01", "end": "04-30", "label": "winter"}]', NULL, 'No Dig'),
-- Spring Onion
  ((SELECT id FROM plant_types WHERE name = 'Spring Onion'), NULL, 'Suitable for multisowing', '2.5 months', '6 weeks', 'Full sun or some shade', 'Multisown 25cm equidistant', 'Hardy, to at least -8°C', '[{"start": "02-15", "end": "06-30"}, {"start": "08-15", "end": "08-31", "label": "overwintering"}]', '[{"start": "04-01", "end": "08-15"}, {"start": "09-15", "end": "10-15", "label": "overwintering"}]', '[{"start": "06-01", "end": "10-31"}, {"start": "04-01", "end": "05-31", "label": "overwintering"}]', NULL, 'No Dig'),
-- Bulb Onion and Shallot
  ((SELECT id FROM plant_types WHERE name = 'Bulb Onion and Shallot'), NULL, 'Suitable for multisowing', '4.5 months from seed, 3.5 months from sets', '6 weeks', 'Full sun', 'Bulb onions: multisown 30cm equidistant, sets 15cm. Shallots: 30cm equidistant from seed or sets', 'Hardy, to at least -8°C', '[{"start": "03-15", "end": "04-15", "label": "from sets"}, {"start": "02-15", "end": "03-31", "label": "from seed"}]', '[{"start": "04-01", "end": "04-30"}]', '[{"start": "07-15", "end": "08-31"}]', NULL, 'No Dig'),
-- Overwintering Onion
  ((SELECT id FROM plant_types WHERE name = 'Overwintering Onion'), NULL, 'Suitable for multisowing and as a second follow-on crop', '7 months', '6 weeks', 'Full sun', 'Multisown 30cm equidistant, sets 15cm', 'Hardy, to at least -8°C', '[{"start": "10-01", "end": "10-15", "label": "from sets"}, {"start": "08-15", "end": "08-31", "label": "from seed"}]', '[{"start": "09-15", "end": "10-15"}]', '[{"start": "06-15", "end": "06-30"}]', NULL, 'No Dig');
