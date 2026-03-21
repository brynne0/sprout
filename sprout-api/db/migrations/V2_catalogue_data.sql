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

INSERT INTO plant_types (name, category_id, icon) VALUES
    ('Broad Beans', (SELECT id FROM plant_categories WHERE name = 'Legumes - pea and bean family'), NULL),
    ('Climbing Beans', (SELECT id FROM plant_categories WHERE name = 'Legumes - pea and bean family'), NULL),
    ('Dwarf French Beans', (SELECT id FROM plant_categories WHERE name = 'Legumes - pea and bean family'), NULL),
    ('Peas', (SELECT id FROM plant_categories WHERE name = 'Legumes - pea and bean family'),'peas.png'),
    ('Broccoli', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family'),'broccoli.png'),
    ('Brussels Sprouts', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family'),'brussels-sprouts.png'),
    ('Cabbage', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family'),'cabbage.png'),
    ('Cauliflower', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family'),'cauliflower.png'),
    ('Kale', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family'),'kale.png'),
    ('Radish', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family'), 'radish.png'),
    ('Swede', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family'), NULL),
    ('Turnip', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family'), NULL),
    ('Garlic', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family'), 'garlic.png'),
    ('Leek', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family'), NULL),
    ('Spring Onion', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family'), NULL),
    ('Bulb Onion and Shallot', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family'), NULL),
    ('Overwintering Onion', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family'), NULL),
    ('Zucchini', (SELECT id FROM plant_categories WHERE name = 'Cucurbits - cucumber family'), 'zucchini.png'),
    ('Cucumber', (SELECT id FROM plant_categories WHERE name = 'Cucurbits - cucumber family'), 'cucumber.png'),
    ('Melon', (SELECT id FROM plant_categories WHERE name = 'Cucurbits - cucumber family'), 'melon.png'),
    ('Pumpkin', (SELECT id FROM plant_categories WHERE name = 'Cucurbits - cucumber family'), 'pumpkin.png');

INSERT INTO plant_catalogue (plant_type_id, variety, description, seed_to_harvest, sowing_to_transplant, position, spacing, hardiness, sowing_windows, transplant_windows, harvest_windows, harvest, suitability, source)
VALUES
-- Legumes
  ((SELECT id FROM plant_types WHERE name = 'Broad Beans'), NULL, NULL, '4 months (from late winter and spring sowings)', '4-6 weeks after sowing, when they are about 5-7cm tall', 'Adaptable, will tolerate shade', '20-25 cm equidistant or 15cm apart with 45cm between rows', 'Fully hardy, but can be adversely affect by a long cold spell', '[{"start": "01-01", "end": "04-30"}, {"start": "10-15", "end": "10-31"}]', '[{"start": "02-01", "end": "05-31"}, {"start": "12-01", "end": "12-31"}]', '[{"start": "06-01", "end": "08-15"}]', NULL, NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Climbing Beans'), NULL, NULL, '3 months for pods, 4-5 for beans', '2-3 weeks', 'Full sun, can tolerate some shade. Avoid a windy position.', '30cm apart, 60cm between rows', 'Killed by frost and need warmth to thrive', '[{"start": "05-15", "end": "06-30"}]', '[{"start": "06-01", "end": "07-15"}]', '[{"start": "07-15", "end": "10-15"}]', NULL, NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Dwarf French Beans'), NULL, NULL, '2.5 months', '3 weeks', 'Full sun and warmth', '30-35cm apart each way', 'Not hardy. They will be killed by frost.', '[{"start": "05-01", "end": "06-30"}]', '[{"start": "05-15", "end": "07-31"}]', '[{"start": "06-15", "end": "10-15"}]', NULL, NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Peas'), NULL, NULL, '3-3.5 months', '3 weeks', 'Full sun, moist soil, align rows at 90º to prevailing wind', 'Dwarf varieties: 15cm apart with 30cm between rows across bed. Medium varieties: Double row 30cm apart along length of bed, with plants 20cm apart, or single rows across bed 45cm apart with 20cm between plants. Tall varieties: Single row along length of bed with plants 15cm apart.', 'Hardy, to around -5ºC', '[{"start": "02-15", "end": "04-30"}, {"start": "06-15", "end": "06-30"}, {"start": "11-01", "end": "11-30"}]', '[{"start": "02-01", "end": "05-15"}, {"start": "07-15", "end": "07-31"}]', '[{"start": "06-01", "end": "07-31"}, {"start": "10-01", "end": "10-31"}]', NULL, NULL, 'No Dig'),
-- Broccoli
  ((SELECT id FROM plant_types WHERE name = 'Broccoli'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '[{"start": "02-15", "end": "07-31"}]', NULL, '[{"start": "03-01", "end": "11-30"}]', NULL, NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Broccoli'), 'Calabrese', NULL, '3 months', '3-5 weeks', 'Adaptable, tolerates shade', '30-40cm', 'Hardy to approx. -3°C', '[{"start": "02-15", "end": "06-15"}]', '[{"start": "03-15", "end": "08-15"}]', '[{"start": "06-15", "end": "10-15"}]', NULL, NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Broccoli'), 'Purple Sprouting', NULL, '9 months', '3-5 weeks', 'Adaptable, tolerates shade', '50-60cm', 'Very hardy to approx. -10°C', '[{"start": "04-15", "end": "06-15"}]', '[{"start": "05-15", "end": "07-15"}]', '[{"start": "08-01", "end": "05-15"}]', NULL, NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Broccoli'), 'Kaibroc', NULL, '2 1/2 months', '3-5 weeks', 'Adaptable, tolerates shade', '30-40cm', 'Shoots hardy to approx. -3°C, plants to -6°C', '[{"start": "04-01", "end": "05-31"}, {"start": "07-01", "end": "07-31"}]', '[{"start": "05-01", "end": "05-31"}, {"start": "08-01", "end": "08-31"}]', '[{"start": "07-01", "end": "11-30"}]', NULL, NULL, 'No Dig'),
-- Brussels Sprouts
  ((SELECT id FROM plant_types WHERE name = 'Brussels Sprouts'), NULL, NULL, '5-7 months', '6-8 weeks', 'Any position, including shade. Will tolerate wind', '60cm equidistant', 'Very hardy', '[{"start": "04-15", "end": "05-15"}]', '[{"start": "05-15", "end": "06-30"}]', '[{"start": "10-01", "end": "01-31", "label": "early"}, {"start": "12-01", "end": "03-31", "label": "late"}]', NULL, '{interplant}', 'No Dig'),
-- Cabbage
  ((SELECT id FROM plant_types WHERE name = 'Cabbage'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, '[{"start": "02-15", "end": "08-31"}]', NULL, '[{"start": "01-01", "end": "12-31"}]', NULL, NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Cabbage'), 'Spring', NULL, '7-8 months', '4-6 weeks', 'Tolerates some shade', '20-30cm', 'Fully hardy. Tight hearts can split below about -5°C', '[{"start": "08-15", "end": "08-31"}]', '[{"start": "09-15", "end": "10-31"}]', '[{"start": "03-15", "end": "05-15"}]', NULL, '{follow-on}', 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Cabbage'), 'Summer', NULL, '4 months', '4-6 weeks', 'Tolerates some shade', '35-40cm', 'Fully hardy', '[{"start": "02-15", "end": "03-31"}]', '[{"start": "04-01", "end": "05-31"}]', '[{"start": "06-01", "end": "07-31"}]', NULL, NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Cabbage'), 'Autumn', NULL, '4 months', '4-6 weeks', 'Tolerates some shade', '45-60cm', 'Fully hardy. Tight hearts can split below -5°C', '[{"start": "04-15", "end": "05-15"}]', '[{"start": "05-01", "end": "06-30"}]', '[{"start": "09-01", "end": "11-30"}]', NULL, NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Cabbage'), 'Winter', NULL, '5 months', '4-6 weeks', 'Tolerates some shade', '40cm', 'Fully hardy', '[{"start": "06-01", "end": "06-31"}]', '[{"start": "07-01", "end": "07-31"}]', '[{"start": "11-01", "end": "03-31"}]', NULL, '{follow-on}', 'No Dig'),
-- Cauliflower
  ((SELECT id FROM plant_types WHERE name = 'Cauliflower'), NULL, NULL, '4 months (summer and autumn crop), 8 months (early spring crop)', '4-6 weeks', 'Any position, tolerates some shade', '40-55cm equidistant', 'Hardy to -10°C in leaf and -5°C for curds', '[{"start": "02-15", "end": "03-15", "label": "midsummer crop"}, {"start": "06-15", "end": "06-30", "label": "autumn crop"}, {"start": "07-15", "end": "08-31", "label": "early spring crop"}]', '[{"start": "04-01", "end": "04-15"}, {"start": "09-01", "end": "09-15"}]', '[{"start": "03-01", "end": "05-15"}, {"start": "06-15", "end": "07-15"}, {"start": "10-01", "end": "11-30"}]', NULL, '{interplant}', 'No Dig'),
-- Kale
  ((SELECT id FROM plant_types WHERE name = 'Kale'), NULL, NULL, '2-3 months', '3-6 weeks', 'Full sun is ideal, but will tolerate some shade', '45-50cm for large varieties, 35cm for dwarf varieties, 22cm for salad leaves', 'Very hardy, down to at least -10°C', '[{"start": "03-01", "end": "04-30"}, {"start": "05-15", "end": "06-30"}, {"start": "07-15", "end": "08-15", "label": "salad leaves over winter"}]', '[{"start": "04-01", "end": "09-15"}]', '[{"start": "06-01", "end": "03-31", "label": "large"}, {"start": "10-01", "end": "04-30", "label": "salad"}]', NULL, '{follow-on}', 'No Dig'),
-- Radish
  ((SELECT id FROM plant_types WHERE name = 'Radish'), 'Spring', NULL, '6 weeks', '3-4 weeks', 'Full sun or some shade', 'Multisown 15cm equidistant', 'Moderately hardy', '[{"start": "02-15", "end": "04-30"}]', '[{"start": "03-15", "end": "05-15"}]', '[{"start": "04-01", "end": "06-15"}]', NULL, '{multisow,follow-on}', 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Radish'), 'Winter', NULL, '3 months', '3-4 weeks', 'Full sun or some shade', '20cm equidistant', 'Moderately hardy, down to -4°C', '[{"start": "07-15", "end": "07-31"}]', '[{"start": "08-15", "end": "08-31"}]', '[{"start": "10-01", "end": "01-31"}]', NULL, '{follow-on}', 'No Dig'),
-- Swede
  ((SELECT id FROM plant_types WHERE name = 'Swede'), NULL, NULL, '4 months', '4 weeks', 'Full sun or a little shade', '30-35cm equidistant', 'Extremely hardy, to at least -10°C', '[{"start": "05-15", "end": "05-31"}]', '[{"start": "06-15", "end": "06-30"}]', '[{"start": "10-01", "end": "03-31"}]', NULL, '{follow-on}', 'No Dig'),
-- Turnip
  ((SELECT id FROM plant_types WHERE name = 'Turnip'), NULL, NULL, '2 months', '2-4 weeks', 'Full sun', '25-30cm equidistant', 'Hardy to approx. -5°C', '[{"start": "02-15", "end": "03-15"}, {"start": "08-01", "end": "08-15"}]', '[{"start": "03-15", "end": "04-15"}, {"start": "08-15", "end": "08-31"}]', '[{"start": "05-01", "end": "06-15"}, {"start": "10-01", "end": "11-15"}]', NULL, '{multisow,interplant}', 'No Dig'),
-- Garlic
  ((SELECT id FROM plant_types WHERE name = 'Garlic'), NULL, NULL, '8 months when sown in October', 'Not applicable', 'Adaptable; likes sun and warmth in spring and summer', '10-15cm equidistant or 8-10cm apart in rows 25cm apart', 'Hardy to at least -12°C', '[{"start": "09-15", "end": "12-31"}]', NULL, '[{"start": "06-15", "end": "07-15"}]', NULL, '{interplant}', 'No Dig'),
-- Leek
  ((SELECT id FROM plant_types WHERE name = 'Leek'), NULL, NULL, 'Summer: 4.5-5 months, Autumn: 5-6 months, Winter: 10-13 months', '2-3 months', 'Moist, tolerates some shade', 'Clumps at 20-25cm equidistant, singles at 10cm', 'Hardy, but mature summer and autumn varieties can be damaged below -5°C', '[{"start": "04-01", "end": "04-15"}]', '[{"start": "06-01", "end": "07-31"}]', '[{"start": "07-15", "end": "09-30", "label": "summer"}, {"start": "09-01", "end": "01-31", "label": "autumn"}, {"start": "02-01", "end": "04-30", "label": "winter"}]', NULL, '{multisow,follow-on}', 'No Dig'),
-- Spring Onion
  ((SELECT id FROM plant_types WHERE name = 'Spring Onion'), NULL, NULL, '2.5 months', '6 weeks', 'Full sun or some shade', 'Multisown 25cm equidistant', 'Hardy, to at least -8°C', '[{"start": "02-15", "end": "06-30"}, {"start": "08-15", "end": "08-31", "label": "overwintering"}]', '[{"start": "04-01", "end": "08-15"}, {"start": "09-15", "end": "10-15", "label": "overwintering"}]', '[{"start": "06-01", "end": "10-31"}, {"start": "04-01", "end": "05-31", "label": "overwintering"}]', NULL, '{multisow}', 'No Dig'),
-- Bulb Onion and Shallot
  ((SELECT id FROM plant_types WHERE name = 'Bulb Onion and Shallot'), NULL, NULL, '4.5 months from seed, 3.5 months from sets', '6 weeks', 'Full sun', 'Bulb onions: multisown 30cm equidistant, sets 15cm. Shallots: 30cm equidistant from seed or sets', 'Hardy, to at least -8°C', '[{"start": "03-15", "end": "04-15", "label": "from sets"}, {"start": "02-15", "end": "03-31", "label": "from seed"}]', '[{"start": "04-01", "end": "04-30"}]', '[{"start": "07-15", "end": "08-31"}]', NULL, '{multisow}', 'No Dig'),
-- Overwintering Onion
  ((SELECT id FROM plant_types WHERE name = 'Overwintering Onion'), NULL, NULL, '7 months', '6 weeks', 'Full sun', 'Multisown 30cm equidistant, sets 15cm', 'Hardy, to at least -8°C', '[{"start": "10-01", "end": "10-15", "label": "from sets"}, {"start": "08-15", "end": "08-31", "label": "from seed"}]', '[{"start": "09-15", "end": "10-15"}]', '[{"start": "06-15", "end": "06-30"}]', NULL, '{multisow,follow-on}', 'No Dig'),
-- Zucchini and Summer Squash
  ((SELECT id FROM plant_types WHERE name = 'Zucchini'), NULL, NULL, '2 months', '3-4 weeks', 'Need warmth and full sun; won''t thrive in a cold, shady spot', '60cm minimum, but 90cm gives a whole season of fruiting', 'Not hardy; will be killed by frost', '[{"start": "04-15", "end": "05-31"}]', '[{"start": "05-15", "end": "06-30"}]', '[{"start": "06-15", "end": "09-30"}]', NULL, '{interplant}', 'No Dig'),
-- Cucumber
  ((SELECT id FROM plant_types WHERE name = 'Cucumber'), 'Ridge', NULL, '80 days', '4-6 weeks', 'Full sun', '60-90cm', 'Tender; needs warmth and is killed by frost', '[{"start": "05-01", "end": "05-31", "label": "under cover"}, {"start": "06-01", "end": "06-30", "label": "outdoors"}]', '[{"start": "06-01", "end": "06-30", "label": "outdoors"}]', '[{"start": "07-15", "end": "09-15"}]', NULL, NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Cucumber'), 'Cordon', NULL, '70 days', '4-6 weeks', 'Under cover', '90cm', 'Tender; needs warmth and is killed by frost', '[{"start": "04-15", "end": "05-31", "label": "under cover"}]', '[{"start": "05-15", "end": "06-30", "label": "under cover"}]', '[{"start": "06-25", "end": "10-07", "label": "under cover"}]', NULL, NULL, 'No Dig'),
-- Melon
  ((SELECT id FROM plant_types WHERE name = 'Melon'), NULL, NULL, '5 months', '6-8 weeks', 'Full sun and sheltered, ideally under cover', '50-60cm apart', 'Not hardy; needs warmth and will be killed by frost', '[{"start": "03-15", "end": "03-31", "label": "under cover"}]', '[{"start": "05-15", "end": "05-31", "label": "under cover"}]', '[{"start": "08-15", "end": "09-30", "label": "under cover"}]', NULL, NULL, 'No Dig'),
-- Pumpkin
  ((SELECT id FROM plant_types WHERE name = 'Pumpkin'), NULL, NULL, '4.5-5.5 months', '4 weeks', 'Full sun and warmth', '1m apart', 'Tender; will be killed by frost and needs summer warmth to thrive', '[{"start": "04-15", "end": "04-30"}]', '[{"start": "05-15", "end": "05-31"}]', '[{"start": "09-01", "end": "10-15"}]', NULL, '{interplant}', 'No Dig');
