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
    ('Swede', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family'), 'swede-temp.png'),
    ('Turnip', (SELECT id FROM plant_categories WHERE name = 'Brassicas - cabbage family'), 'turnip.png'),
    ('Garlic', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family'), 'garlic.png'),
    ('Leek', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family'), 'leak-temp.png'),
    ('Spring Onion', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family'), NULL),
    ('Bulb Onion and Shallot', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family'), 'onion.png'),
    ('Overwintering Onion', (SELECT id FROM plant_categories WHERE name = 'Alliums - onion family'), 'onion.png'),
    ('Zucchini', (SELECT id FROM plant_categories WHERE name = 'Cucurbits - cucumber family'), 'zucchini.png'),
    ('Cucumber', (SELECT id FROM plant_categories WHERE name = 'Cucurbits - cucumber family'), 'cucumber.png'),
    ('Melon', (SELECT id FROM plant_categories WHERE name = 'Cucurbits - cucumber family'), 'melon.png'),
    ('Pumpkin', (SELECT id FROM plant_categories WHERE name = 'Cucurbits - cucumber family'), 'pumpkin.png'),
    ('Carrot', (SELECT id FROM plant_categories WHERE name = 'Umbellifers - carrot family'), NULL),
    ('Celeriac', (SELECT id FROM plant_categories WHERE name = 'Umbellifers - carrot family'), NULL),
    ('Celery', (SELECT id FROM plant_categories WHERE name = 'Umbellifers - carrot family'), NULL),
    ('Bulb Fennel', (SELECT id FROM plant_categories WHERE name = 'Umbellifers - carrot family'), NULL),
    ('Parsnip', (SELECT id FROM plant_categories WHERE name = 'Umbellifers - carrot family'), NULL),
    ('Coriander', (SELECT id FROM plant_categories WHERE name = 'Umbellifers - carrot family'), NULL),
    ('Chervil', (SELECT id FROM plant_categories WHERE name = 'Umbellifers - carrot family'), NULL),
    ('Dill', (SELECT id FROM plant_categories WHERE name = 'Umbellifers - carrot family'), NULL),
    ('Parsley', (SELECT id FROM plant_categories WHERE name = 'Umbellifers - carrot family'), NULL),
    ('Beetroot', (SELECT id FROM plant_categories WHERE name = 'Beet family'), NULL),
    ('Chard', (SELECT id FROM plant_categories WHERE name = 'Beet family'), NULL),
    ('Spinach', (SELECT id FROM plant_categories WHERE name = 'Beet family'), NULL),
    ('Chicory', (SELECT id FROM plant_categories WHERE name = 'Leafy salad crops'), NULL),
    ('Endive', (SELECT id FROM plant_categories WHERE name = 'Leafy salad crops'), NULL),
    ('Lettuce', (SELECT id FROM plant_categories WHERE name = 'Leafy salad crops'), NULL),
    ('Wombok', (SELECT id FROM plant_categories WHERE name = 'Leafy salad crops'), NULL),
    ('Mizuna and Mustards', (SELECT id FROM plant_categories WHERE name = 'Leafy salad crops'), NULL),
    ('Pak Choi', (SELECT id FROM plant_categories WHERE name = 'Leafy salad crops'), NULL),
    ('Rocket', (SELECT id FROM plant_categories WHERE name = 'Leafy salad crops'), NULL),
    ('Corn Salad', (SELECT id FROM plant_categories WHERE name = 'Leafy salad crops'), NULL),
    ('Land Cress', (SELECT id FROM plant_categories WHERE name = 'Leafy salad crops'), NULL),
    ('Winter Purslane', (SELECT id FROM plant_categories WHERE name = 'Leafy salad crops'), NULL),
    ('Eggplant', (SELECT id FROM plant_categories WHERE name = 'Solanums, basil, and sweetcorn'), NULL),
    ('Capsicum', (SELECT id FROM plant_categories WHERE name = 'Solanums, basil, and sweetcorn'), NULL),
    ('Chilli', (SELECT id FROM plant_categories WHERE name = 'Solanums, basil, and sweetcorn'), NULL),
    ('Basil', (SELECT id FROM plant_categories WHERE name = 'Solanums, basil, and sweetcorn'), NULL),
    ('Potato', (SELECT id FROM plant_categories WHERE name = 'Solanums, basil, and sweetcorn'), NULL),
    ('Sweetcorn', (SELECT id FROM plant_categories WHERE name = 'Solanums, basil, and sweetcorn'), NULL),
    ('Tomato', (SELECT id FROM plant_categories WHERE name = 'Solanums, basil, and sweetcorn'), NULL);

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
  ((SELECT id FROM plant_types WHERE name = 'Cucumber'), 'Ridge', NULL, '80 days', '4-6 weeks', 'Full sun', '60-90cm', 'Tender; needs warmth and is killed by frost', '[{"start": "05-01", "end": "05-31", "label": "under cover"}, {"start": "06-01", "end": "06-30"}]', '[{"start": "06-01", "end": "06-30"}]', '[{"start": "07-15", "end": "09-15"}]', NULL, NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Cucumber'), 'Cordon', NULL, '70 days', '4-6 weeks', 'Under cover', '90cm', 'Tender; needs warmth and is killed by frost', '[{"start": "04-15", "end": "05-31", "label": "under cover"}]', '[{"start": "05-15", "end": "06-30", "label": "under cover"}]', '[{"start": "06-25", "end": "10-07", "label": "under cover"}]', NULL, NULL, 'No Dig'),
-- Melon
  ((SELECT id FROM plant_types WHERE name = 'Melon'), NULL, NULL, '5 months', '6-8 weeks', 'Full sun and sheltered, ideally under cover', '50-60cm apart', 'Not hardy; needs warmth and will be killed by frost', '[{"start": "03-15", "end": "03-31", "label": "under cover"}]', '[{"start": "05-15", "end": "05-31", "label": "under cover"}]', '[{"start": "08-15", "end": "09-30", "label": "under cover"}]', NULL, NULL, 'No Dig'),
-- Pumpkin
  ((SELECT id FROM plant_types WHERE name = 'Pumpkin'), NULL, NULL, '4.5-5.5 months', '4 weeks', 'Full sun and warmth', '1m apart', 'Tender; will be killed by frost and needs summer warmth to thrive', '[{"start": "04-15", "end": "04-30"}]', '[{"start": "05-15", "end": "05-31"}]', '[{"start": "09-01", "end": "10-15"}]', NULL, '{interplant}', 'No Dig'),
-- Carrot
  ((SELECT id FROM plant_types WHERE name = 'Carrot'), 'Early', NULL, '10 weeks', NULL, 'Adaptable; will tolerate some shade', 'Rows 15cm apart', 'Seedlings stand spring frosts to about -4°C', '[{"start": "03-15", "end": "04-15"}, {"start": "06-01", "end": "06-30"}]', NULL, '[{"start": "06-01", "end": "07-31"}, {"start": "09-01", "end": "09-30"}]', NULL, '{intersow,follow-on}', 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Carrot'), 'Maincrop', NULL, 'From 12 weeks for fresh carrots, 5 months for storing', NULL, 'Adaptable; will tolerate some shade', 'Rows 30cm apart', 'Mature plants stand frost to about -5°C, depending how much leaf cover is above them', '[{"start": "06-01", "end": "06-30"}]', NULL, '[{"start": "09-01", "end": "12-31"}]', NULL, '{intersow,follow-on}', 'No Dig'),
-- Celeriac
  ((SELECT id FROM plant_types WHERE name = 'Celeriac'), NULL, NULL, '6-7 months', '8 weeks', 'Full sun or shade in moisture-retentive soil', '35-40cm in an equidistant grid pattern', 'Hardy to -10°C and possibly colder', '[{"start": "03-15", "end": "03-31"}]', '[{"start": "05-15", "end": "05-31"}]', '[{"start": "10-15", "end": "11-30"}]', NULL, '{interplant}', 'No Dig'),
-- Celery
  ((SELECT id FROM plant_types WHERE name = 'Celery'), NULL, NULL, '3.5 months', '8 weeks', 'Full sun or shade in moisture-retentive soil', '25-30cm apart in an equidistant grid pattern', 'Hardy, but stalks are damaged by moderate frost', '[{"start": "03-15", "end": "05-31"}]', '[{"start": "05-15", "end": "07-31"}]', '[{"start": "06-01", "end": "10-31"}]', NULL, '{follow-on}', 'No Dig'),
-- Bulb Fennel
  ((SELECT id FROM plant_types WHERE name = 'Bulb Fennel'), NULL, NULL, '13 weeks early sowings, 8 weeks summer sowings', '4-5 weeks', 'Can tolerate shade, but early plantings benefit from warmth and sunshine', '20cm', 'Slightly hardy to about -3°C', '[{"start": "02-15", "end": "02-28"}, {"start": "07-15", "end": "07-31"}]', '[{"start": "03-15", "end": "04-15"}, {"start": "08-15", "end": "08-31"}]', '[{"start": "05-15", "end": "06-30"}, {"start": "09-15", "end": "11-15"}]', NULL, '{interplant,follow-on}', 'No Dig'),
-- Parsnip
  ((SELECT id FROM plant_types WHERE name = 'Parsnip'), NULL, NULL, '6 months', NULL, 'Grows in all soils, and tolerates some shade', '5-10cm apart with 30cm between rows', 'Very hardy, down to at least -15°C', '[{"start": "02-15", "end": "06-15"}]', NULL, '[{"start": "09-15", "end": "03-31"}]', NULL, '{interplant}', 'No Dig'),
-- Coriander
  ((SELECT id FROM plant_types WHERE name = 'Coriander'), NULL, NULL, '8 weeks', '4 weeks', 'Tolerates shade', '15-20cm equidistant or rows 20cm apart', 'Hardy to -5°C or colder', '[{"start": "02-15", "end": "09-15"}]', '[{"start": "03-15", "end": "09-15"}, {"start": "09-15", "end": "10-15", "label": "under cover"}]', '[{"start": "03-15", "end": "11-30"}, {"start": "12-01", "end": "03-15", "label": "under cover"}]', NULL, NULL, 'No Dig'),
-- Chervil
  ((SELECT id FROM plant_types WHERE name = 'Chervil'), NULL, NULL, '8 weeks', '4 weeks', 'Adaptable, tolerates shade', '20cm equidistant', 'Hardy to approx. -10°C', '[{"start": "07-15", "end": "08-31"}]', '[{"start": "08-15", "end": "09-15"}, {"start": "09-15", "end": "10-15", "label": "under cover"}]', '[{"start": "09-15", "end": "10-31"}, {"start": "02-15", "end": "05-15"}]', NULL, '{interplant}', 'No Dig'),
-- Dill
  ((SELECT id FROM plant_types WHERE name = 'Dill'), NULL, NULL, '6 weeks', '3-4 weeks', 'Can grow in shade', '15-23cm', 'Some frost resistance to about -2°C', '[{"start": "02-15", "end": "09-15"}]', '[{"start": "03-15", "end": "09-15"}, {"start": "09-15", "end": "10-15", "label": "under cover"}]', '[{"start": "04-01", "end": "10-31"}, {"start": "11-01", "end": "03-31", "label": "under cover"}]', NULL, '{interplant}', 'No Dig'),
-- Parsley
  ((SELECT id FROM plant_types WHERE name = 'Parsley'), NULL, NULL, '10 weeks early sowings, 8 weeks summer sowings', '5-6 weeks', 'Prefers sun but tolerates shade', '15-20cm', 'Hardy to about -8°C', '[{"start": "02-15", "end": "07-31"}]', '[{"start": "05-01", "end": "08-31"}]', '[{"start": "04-01", "end": "12-31"}]', NULL, NULL, 'No Dig'),
-- Beetroot
  ((SELECT id FROM plant_types WHERE name = 'Beetroot'), NULL, NULL, '13 weeks spring sowing, 10 weeks summer sowing', '3-5 weeks', 'Adaptable, tolerates shade', '30-35cm', 'Hardy to approx. -4°C', '[{"start": "03-01", "end": "06-30"}]', '[{"start": "04-01", "end": "07-31"}]', '[{"start": "06-01", "end": "12-31"}]', NULL, '{multisow,follow-on,interplant}', 'No Dig'),
-- Chard
  ((SELECT id FROM plant_types WHERE name = 'Chard'), NULL, NULL, '7-10 weeks', '3-4 weeks', 'Any; tolerates shade', '22-30cm equidistant or direct-sown in rows 30cm apart, with 5-15cm between plants', 'Will tolerate slight frost; plants hardy to -5°C', '[{"start": "04-15", "end": "07-31"}, {"start": "08-15", "end": "09-15", "label": "under cover"}]', '[{"start": "05-15", "end": "07-31"}, {"start": "09-01", "end": "10-31", "label": "under cover"}]', '[{"start": "03-01", "end": "04-30"}, {"start": "06-01", "end": "12-31"}, {"start": "11-01", "end": "04-30", "label": "under cover"}]', NULL, '{multisow,follow-on}', 'No Dig'),
-- Spinach
  ((SELECT id FROM plant_types WHERE name = 'Spinach'), NULL, NULL, '6-7 weeks', '2-4 weeks', 'Full sun or some shade, where slugs aren''t too numerous', '20-22cm equidistant for multisown clumps, or direct-sown in rows 20cm apart, with 10cm between plants', 'Hardy, down to -15°C or lower', '[{"start": "02-15", "end": "03-31"}, {"start": "08-01", "end": "08-31"}]', '[{"start": "03-15", "end": "04-15"}, {"start": "09-01", "end": "09-15"}]', '[{"start": "09-01", "end": "05-31"}]', NULL, '{multisow,follow-on}', 'No Dig'),
-- Chicory
  ((SELECT id FROM plant_types WHERE name = 'Chicory'), NULL, NULL, '3 months', '3-5 weeks', 'Prefers full sun, but will tolerate shade', '30cm equidistant', 'Hardy; young or looseleaf plants to -15°C, mature hearted plants to -5°C', '[{"start": "06-15", "end": "07-15"}]', '[{"start": "07-01", "end": "08-15"}]', '[{"start": "09-01", "end": "02-28"}]', NULL, '{follow-on,interplant}', 'No Dig'),
-- Endive
  ((SELECT id FROM plant_types WHERE name = 'Endive'), NULL, NULL, '7-8 weeks for outer leaves, 11 weeks for hearts', '3 weeks', 'Full sun is best, and they like moisture', '22cm equidistant for outer leaves, 30cm for hearts, rows 25cm apart sown direct', 'Hardy to -10°C, although hearts damaged by lighter frosts', '[{"start": "06-15", "end": "08-01"}, {"start": "09-01", "end": "09-15", "label": "under cover"}]', '[{"start": "07-15", "end": "08-31"}, {"start": "09-15", "end": "10-15", "label": "under cover"}]', '[{"start": "08-15", "end": "11-15"}, {"start": "11-15", "end": "03-31", "label": "under cover"}]', NULL, '{follow-on}', 'No Dig'),
-- Lettuce
  ((SELECT id FROM plant_types WHERE name = 'Lettuce'), NULL, NULL, '6 weeks for leaf, 10-12 weeks for hearts, 4-5 weeks for cut-and-come-again', '3-4 weeks', 'Full sun or light shade; full sun in winter', 'Leaf 22cm equidistant, hearting 30cm, cut-and-come-again rows 15-22cm apart', 'Hardy, but don''t thrive in regular frost. To -7°C in a polytunnel', '[{"start": "02-15", "end": "09-15", "label": "under cover"}, {"start": "03-15", "end": "08-01"}]', '[{"start": "03-01", "end": "09-15"}, {"start": "09-15", "end": "10-15", "label": "under cover"}]', '[{"start": "05-01", "end": "10-31"}, {"start": "11-01", "end": "04-30", "label": "under cover"}]', NULL, '{interplant}', 'No Dig'),
-- Wombok
  ((SELECT id FROM plant_types WHERE name = 'Wombok'), NULL, NULL, '10 weeks', '2-3 weeks', 'Full sun for fewer slugs', '30-35cm', 'Hardy; non-headed plants -10°C, headed plants -4°C', '[{"start": "07-15", "end": "07-31"}]', '[{"start": "08-15", "end": "08-31"}]', '[{"start": "10-01", "end": "11-30"}]', NULL, '{follow-on}', 'No Dig'),
-- Mizuna and Mustards
  ((SELECT id FROM plant_types WHERE name = 'Mizuna and Mustards'), NULL, NULL, '5-6 weeks', '2-3 weeks', 'Cool, moist conditions. Grow well in some shade', '20-22cm equidistant or in rows 20cm apart', 'Fairly hardy; mizuna to -3°C and mustard to -5°C', '[{"start": "02-15", "end": "03-15"}, {"start": "07-15", "end": "08-15"}, {"start": "09-01", "end": "09-15", "label": "under cover"}]', '[{"start": "03-01", "end": "03-31"}, {"start": "08-15", "end": "09-30"}, {"start": "10-01", "end": "10-15", "label": "under cover"}]', '[{"start": "04-01", "end": "05-15"}, {"start": "09-15", "end": "11-15"}, {"start": "11-01", "end": "04-30", "label": "under cover"}]', NULL, '{multisow,follow-on}', 'No Dig'),
-- Pak Choi
  ((SELECT id FROM plant_types WHERE name = 'Pak Choi'), NULL, NULL, '6 weeks', '2-3 weeks', 'Full sun or shade, but beware of slugs', '20-25cm equidistant', 'Hardy down to about -3°C, but mature plants go soft if they freeze', '[{"start": "02-01", "end": "02-28"}, {"start": "07-15", "end": "08-31"}]', '[{"start": "03-01", "end": "03-15"}, {"start": "08-15", "end": "08-31"}]', '[{"start": "04-01", "end": "05-15"}, {"start": "09-15", "end": "11-30"}]', NULL, '{multisow,follow-on}', 'No Dig'),
-- Rocket
  ((SELECT id FROM plant_types WHERE name = 'Rocket'), 'Salad', NULL, '4-5 weeks', '2-3 weeks', 'Moist soil in full sun or some shade', '22cm equidistant', 'Hardy to at least -6°C', '[{"start": "08-01", "end": "09-15"}, {"start": "09-01", "end": "09-15", "label": "under cover"}]', '[{"start": "08-15", "end": "09-15"}, {"start": "10-01", "end": "10-31", "label": "under cover"}]', '[{"start": "08-15", "end": "12-15"}, {"start": "02-01", "end": "04-15", "label": "under cover"}, {"start": "11-01", "end": "12-31", "label": "under cover"}]', NULL, '{follow-on}', 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Rocket'), 'Wild', NULL, '10-30 weeks', 'Up to 6 months', 'Moist soil in full sun or some shade', '22cm equidistant', 'Hardy to at least -6°C', '[{"start": "09-01", "end": "09-15"}]', '[{"start": "03-01", "end": "03-31"}]', '[{"start": "04-01", "end": "06-30"}]', NULL, '{follow-on}', 'No Dig'),
-- Corn Salad
  ((SELECT id FROM plant_types WHERE name = 'Corn Salad'), NULL, NULL, '2-4 months', '4 weeks', 'Adaptable; full sun or part shade', '10cm equidistant', 'Very hardy to approx. -10°C', '[{"start": "08-15", "end": "08-31"}]', '[{"start": "09-15", "end": "09-30"}]', '[{"start": "11-01", "end": "04-15"}]', NULL, '{follow-on}', 'No Dig'),
-- Land Cress
  ((SELECT id FROM plant_types WHERE name = 'Land Cress'), NULL, NULL, '10 weeks', '4-5 weeks', 'Full sun or shade', '20-22cm equidistant', 'Very hardy to -15°C or lower', '[{"start": "08-01", "end": "09-15"}, {"start": "09-01", "end": "09-15", "label": "under cover"}]', '[{"start": "09-01", "end": "09-30"}, {"start": "10-01", "end": "10-15", "label": "under cover"}]', '[{"start": "10-15", "end": "04-30"}, {"start": "11-01", "end": "04-30", "label": "under cover"}]', NULL, '{follow-on}', 'No Dig'),
-- Winter Purslane
  ((SELECT id FROM plant_types WHERE name = 'Winter Purslane'), NULL, NULL, '10 weeks', '4-5 weeks', 'Adaptable, will grow in shade', '22cm equidistant', 'Very hardy, to -10°C', '[{"start": "08-01", "end": "08-31"}, {"start": "09-01", "end": "09-15", "label": "under cover"}]', '[{"start": "09-01", "end": "09-30"}, {"start": "10-01", "end": "10-15", "label": "under cover"}]', '[{"start": "10-15", "end": "04-30"}, {"start": "11-01", "end": "04-30", "label": "under cover"}]', NULL, '{follow-on}', 'No Dig'),
-- Eggplant
  ((SELECT id FROM plant_types WHERE name = 'Eggplant'), NULL, NULL, '4 months', '2-3 months', 'Under cover or outdoors in a sheltered, sunny position with as much warmth as possible', '40-50cm apart', 'Will not tolerate frost; need nighttime temperatures above 10°C for strong growth', '[{"start": "02-01", "end": "03-31", "label": "under cover"}]', '[{"start": "05-15", "end": "05-31", "label": "under cover"}]', '[{"start": "07-15", "end": "10-15", "label": "under cover"}]', NULL, NULL, 'No Dig'),
-- Capsicum
  ((SELECT id FROM plant_types WHERE name = 'Capsicum'), NULL, NULL, '4 months for green fruits under cover', '3 months', 'Grow under cover or outdoors, in a warm, sunny, sheltered position', '45cm apart', 'Not hardy; one of the most warmth-demanding plants', '[{"start": "02-15", "end": "03-15"}]', '[{"start": "05-15", "end": "06-15"}]', '[{"start": "07-15", "end": "10-31"}]', NULL, NULL, 'No Dig'),
-- Chilli
  ((SELECT id FROM plant_types WHERE name = 'Chilli'), NULL, NULL, '4 months for green fruits under cover', '3 months', 'Grow under cover or outdoors, in a warm, sunny, sheltered position', '30cm apart', 'Not hardy; one of the most warmth-demanding plants', '[{"start": "02-15", "end": "03-15"}]', '[{"start": "05-15", "end": "06-15"}]', '[{"start": "07-15", "end": "10-31"}]', NULL, NULL, 'No Dig'),
-- Basil
  ((SELECT id FROM plant_types WHERE name = 'Basil'), NULL, NULL, '7 weeks', '4-6 weeks', 'Full sun', '22-30cm apart', 'Killed by frost; grows best when nighttime temperatures are above 12°C', '[{"start": "04-01", "end": "06-30"}]', '[{"start": "05-01", "end": "07-31"}]', '[{"start": "06-01", "end": "09-30"}]', NULL, NULL, 'No Dig'),
-- Potato
  ((SELECT id FROM plant_types WHERE name = 'Potato'), 'First Early', NULL, '2 months', NULL, 'Full sun is best, to keep leaves dry', '35-40cm or 30cm for a small, very early harvest', 'Not frost hardy', '[{"start": "03-15", "end": "03-31"}]', NULL, '[{"start": "06-01", "end": "06-30"}]', NULL, NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Potato'), 'Second Early', NULL, '3 months', NULL, 'Full sun is best, to keep leaves dry', '45-50cm', 'Not frost hardy', '[{"start": "04-15", "end": "04-30"}]', NULL, '[{"start": "07-15", "end": "07-31"}]', NULL, NULL, 'No Dig'),
  ((SELECT id FROM plant_types WHERE name = 'Potato'), 'Maincrop', NULL, '4 months', NULL, 'Full sun is best, to keep leaves dry', 'Up to 60cm', 'Not frost hardy', '[{"start": "04-15", "end": "05-15"}]', NULL, '[{"start": "08-15", "end": "08-31"}]', NULL, NULL, 'No Dig'),
-- Sweetcorn
  ((SELECT id FROM plant_types WHERE name = 'Sweetcorn'), NULL, NULL, '3 months for early varieties', '4-5 weeks', 'Full sun and warmth', '25-30cm equidistant', 'Tender, will be killed by frost', '[{"start": "04-15", "end": "05-15", "label": "under cover"}, {"start": "05-15", "end": "06-15"}]', '[{"start": "05-15", "end": "06-15"}]', '[{"start": "08-01", "end": "09-30"}]', NULL, '{interplant}', 'No Dig'),
-- Tomato
  ((SELECT id FROM plant_types WHERE name = 'Tomato'), NULL, NULL, '3 months for cherry, 4 months for medium to large under cover, 4.5 months outdoors', '6 weeks', 'Full sun, and shelter for cordon varieties', '40-55cm apart', 'Not hardy, killed by frost, but more cold tolerant than aubergines and peppers', '[{"start": "03-15", "end": "03-31", "label": "under cover"}]', '[{"start": "05-01", "end": "05-31", "label": "under cover"}, {"start": "05-15", "end": "05-31"}]', '[{"start": "06-15", "end": "10-15", "label": "under cover"}, {"start": "07-15", "end": "09-30"}]', NULL, NULL, 'No Dig');
