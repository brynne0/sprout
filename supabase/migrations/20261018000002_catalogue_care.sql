-- Germination, care and harvest notes from No Dig, plus sowing windows matched to the text.
-- NULLs leave the current value alone, so unfilled rows are safe to run.

-- Per plant type
UPDATE plant_types pt SET
    germination = COALESCE(v.germination, pt.germination),
    care = COALESCE(v.care, pt.care)
FROM (VALUES
-- Legumes
    ('Broad Beans', 'Sow under cover in 5cm modules', 'Water in dry weather once flowering. Support with two levels of string around posts. Pinch out the tops once the main stem is full of flowers to deter blackfly'),
    ('Climbing Beans', 'One seed per 5cm module, laid flat and covered to twice its thickness; no need to pre-soak', 'Twist stems around canes at first (teepee 90-120cm wide, or a double row of 2.5m sticks). Soak twice a week in dry weather once in full flower'),
    ('Dwarf French Beans', 'One seed per 3cm module under cover, or 3cm deep outdoors for summer sowings; warmth helps germination', 'Fleece early plantings. Water twice a week in dry weather once flowering; dry roots stop pods setting. No support needed'),
    ('Peas', '2-3 seeds per 3-5cm module, planted out as a clump; old seed germinates erratically', 'Support all but dwarf varieties from early May with stakes, pea sticks and strings every 15cm. Water regularly once flowering if dry'),
-- Brassicas
    ('Broccoli', 'Sow thinly in a seed tray under cover, lightly covered; prick out into 3-5cm modules within a week. For just a few plants, sow 2 per module and thin', 'Transplant deep, burying the stem. Fleece in spring and mesh in summer for 4-6 weeks after planting; bird netting where there are pigeons. Water until established, then in dry weather as heads form. Snap off yellowing lower leaves'),
    ('Brussels Sprouts', 'Sow thinly in a tray and prick out into 3cm modules, or 2 per module and thin; pot on into 7cm pots after a month', 'Plant deep. Mesh on hoops for 6-8 weeks after planting. Stake and tie in during late summer. Pull off yellowing lower leaves. Water at planting and in dry Septembers'),
    ('Cabbage', 'Always under cover. Sow thinly in a tray to prick out, or 2 per 3-5cm module and thin', 'Plant deep, burying the stem. Fleece in spring and mesh later for the first 6-8 weeks; bird netting where there are pigeons. Water until established, then summer and autumn types in dry weather as hearts form. Remove yellowing lower leaves'),
    ('Cauliflower', 'Under cover with warmth (indoors for February sowings). Sow thinly in a tray to prick out, or 2 per module and thin', 'Plant up to 5cm deep. Fleece or mesh from day one; mesh against caterpillars through summer. Water in dry weather as curds swell. Snap off yellowing outer leaves'),
    ('Kale', '2 seeds per 3cm module and thin, or sow in a tray to prick out; multisow for salad leaves', 'Plant deep. Mesh for at least 6 weeks after planting; bird netting on hoops for pigeons. Water only in very dry weather once established. Remove yellowing lower leaves; stake tall varieties in windy gardens'),
    ('Radish', 'Spring: multisow 5 seeds per 3cm module, keeping February sowings warm in the house before moving them to a cold greenhouse. Winter: 2 seeds per module', 'Plant deep to bury the stems. Fleece in March-April, then fine mesh; keep mesh on winter radish until late September. Water spring radish every 2 days in dry weather, winter radish only in a dry early autumn'),
    ('Swede', '2 seeds per 4cm module under cover and thin, or sow in a tray and prick out', 'Plant deep, up to the first true leaf. Mesh for the first 6-8 weeks (until mid-August), then bird netting if there are pigeons. Water until established and in a dry early autumn as roots swell. Twist off yellowing lower leaves'),
    ('Turnip', 'Multisow 5-6 seeds per 3cm module for clumps of 3-4. Germinate early sowings in the house, then move them to a cold greenhouse', 'Fleece early plantings for at least a month; mesh in late summer and autumn. Water until established, and in dry spells as roots swell'),
-- Alliums
    ('Bulb Onion and Shallot', 'Multisow 6 seeds per 3cm module, or 6 per cm in outdoor drills to lift and transplant after 5 weeks. Plant sets with the tip about 3cm below the surface', 'Fleece spring plantings to speed growth, mesh later if there are rabbits. Water only if it''s dry as bulbs form in June. Hoe regularly in spring while the leaves are upright'),
    ('Garlic', 'Plant the biggest cloves, flat base down, tip just below the surface; October is best', 'Little needed beyond weeding. Water in late May-early June if spring is dry. Snap off hardneck scapes before the flowers open; they''re edible'),
    ('Leek', 'Multisow 4-5 seeds per module in the second week of April; pot on from 3cm modules into 7cm pots after about 8 weeks', 'Plant with the root ball 3-5cm deep (7cm for whiter stems), water in and don''t backfill. Keep watered in dry weather, especially late summer. Mesh from planting to early September if leek moth or leaf miner are about. Remove rust-covered lower leaves in autumn'),
    ('Overwintering Onion', 'Multisow 6 seeds per 3cm module, not before the last week of August', 'Mesh over winter against rabbits (fleece holds too much moisture). Hoe in spring while the leaves are upright'),
    ('Spring Onion', 'Multisow 10 seeds per 3cm module, or 3 seeds per cm in outdoor drills 2.5cm deep', 'Fleece spring plantings, mesh later if there are rabbits. Water in dry weather for better leaves'),
-- Cucurbits
    ('Cucumber', NULL, NULL),
    ('Melon', NULL, NULL),
    ('Pumpkin', NULL, NULL),
    ('Zucchini', NULL, NULL),
-- Umbellifers
    ('Bulb Fennel', NULL, NULL),
    ('Carrot', NULL, NULL),
    ('Celeriac', NULL, NULL),
    ('Celery', NULL, NULL),
    ('Chervil', NULL, NULL),
    ('Coriander', NULL, NULL),
    ('Dill', NULL, NULL),
    ('Parsley', NULL, NULL),
    ('Parsnip', NULL, NULL),
-- Beet family
    ('Beetroot', NULL, NULL),
    ('Chard', NULL, NULL),
    ('Spinach', NULL, NULL),
-- Leafy salad crops
    ('Chicory', NULL, NULL),
    ('Corn Salad', NULL, NULL),
    ('Endive', NULL, NULL),
    ('Land Cress', NULL, NULL),
    ('Lettuce', NULL, NULL),
    ('Mizuna and Mustards', NULL, NULL),
    ('Pak Choi', NULL, NULL),
    ('Rocket', NULL, NULL),
    ('Winter Purslane', NULL, NULL),
    ('Wombok', NULL, NULL),
-- Solanums, basil, and sweetcorn
    ('Basil', NULL, NULL),
    ('Capsicum', NULL, NULL),
    ('Chilli', NULL, NULL),
    ('Eggplant', NULL, NULL),
    ('Potato', NULL, NULL),
    ('Sweetcorn', NULL, NULL),
    ('Tomato', NULL, NULL),
-- Perennial vegetables
    ('Artichoke', NULL, NULL),
    ('Asparagus', NULL, NULL),
    ('Chives', NULL, NULL),
    ('Mint', NULL, NULL),
    ('Oregano', NULL, NULL),
    ('Perennial Kale', NULL, NULL),
    ('Raspberry', NULL, NULL),
    ('Rhubarb', NULL, NULL),
    ('Rosemary', NULL, NULL),
    ('Sorrel', NULL, NULL),
    ('Strawberry', NULL, NULL),
    ('Thyme', NULL, NULL),
-- Flowers
    ('Calendula', NULL, NULL),
    ('Nasturtium', NULL, NULL),
    ('Sunflower', NULL, NULL)
) AS v(name, germination, care)
WHERE pt.name = v.name;

-- Per catalogue entry (variety NULL is the general entry)
UPDATE plant_catalogue pc SET
    harvest = COALESCE(v.harvest, pc.harvest),
    height = COALESCE(v.height, pc.height)
FROM (VALUES
-- Legumes
    ('Broad Beans', NULL, 'Pick when pods are fat but before they darken, pushing them down where they meet the stem. Cut stems at the base and leave the roots in the soil', NULL),
    ('Climbing Beans', NULL, 'Pick every 2 days before the beans show through the pod; crops for up to 2 months. Leave some pods to dry on the plant for dry beans', '2.5m supports'),
    ('Dwarf French Beans', NULL, 'Pick 10-15cm pods at least twice a week, before the beans show; crops for up to 8 weeks', NULL),
    ('Peas', NULL, 'Pick every 2-3 days for sweetness, ideally on the day you eat them', 'Dwarf 60cm, medium 90-120cm, tall up to 2.2m'),
-- Brassicas
    ('Broccoli', NULL, 'Cut the central head while the buds are tight, then pick sideshoots for 2-4 months', NULL),
    ('Broccoli', 'Calabrese', 'Cut the central head while tight, then sideshoots; check every 2 days in summer', NULL),
    ('Broccoli', 'Kaibroc', 'Pick shoots young and tender, before the buds open', NULL),
    ('Broccoli', 'Purple Sprouting', 'Pick shoots twice a week before the buds open', NULL),
    ('Brussels Sprouts', NULL, 'Snap buttons off from the bottom up, weekly over 8-10 weeks. Late varieties are sweeter after frost. Cut the leafy tops from late December to March', NULL),
    ('Cabbage', NULL, 'Cut through the stem with a strong knife once the heart feels firm', NULL),
    ('Cabbage', 'Autumn', 'Cut once heads are tight. They stand for up to 2 months, and store up to 2 months in a cool shed', NULL),
    ('Cabbage', 'Spring', 'Cut when the pale centre leaves fold together, before a tight head forms; left too long they flower', NULL),
    ('Cabbage', 'Summer', 'Cut as soon as the heart feels firm; quality drops fast in summer heat', NULL),
    ('Cabbage', 'Winter', 'Looser hearts that stand for 2-3 months; cut Savoys low to use the outer leaves', NULL),
    ('Cauliflower', NULL, 'Check the centre once neighbouring plants'' leaves touch: curds mature in 1-2 weeks in summer, a month in spring. Cut a few early to avoid a glut', NULL),
    ('Kale', NULL, 'Snap off the lowest leaves, spreading picks across plants. Pick the flowering shoots in late winter like broccoli', NULL),
    ('Radish', 'Spring', 'Twist out while young and tender; they turn woody once a flower stem forms. Remove the leaves after harvest', NULL),
    ('Radish', 'Winter', 'Harvest from October as needed. Below about -6°C, lift the rest with soil attached and store in a box in a shed until February', NULL),
    ('Swede', NULL, 'No rush, they stand all winter; finish before spring warmth toughens the roots. Or lift in December to store in a box in a shed until March', NULL),
    ('Turnip', NULL, 'Twist out the largest in each clump; sweetest between cherry and apricot size. Baby turnip leaves are edible. Larger roots store 2-3 months in a cool shed if lifted before hard frosts', NULL),
-- Alliums
    ('Bulb Onion and Shallot', NULL, 'Once a quarter of the necks have folded, bend the rest over and leave a week. Lift with a trowel and cure until the skins are papery; they store until late spring', NULL),
    ('Garlic', NULL, 'Don''t wait for the leaves to yellow: lift when cloves bulge under the skin. Pull some early as green garlic in late spring. Dry somewhere airy, out of direct sun, for a month', NULL),
    ('Leek', NULL, 'Cut the largest from a clump and leave the rest growing. Summer varieties rot by October and winter ones flower in May. Where the soil freezes, lift with roots and soil into a box', NULL),
    ('Overwintering Onion', NULL, 'Harvest as for bulb onions in June. Use them first, as they sprout by late December', NULL),
    ('Spring Onion', NULL, 'Ready within 10 weeks; twist out the largest from each clump over about 2 months', NULL),
-- Cucurbits
    ('Cucumber', 'Cordon', NULL, NULL),
    ('Cucumber', 'Ridge', NULL, NULL),
    ('Melon', NULL, NULL, NULL),
    ('Pumpkin', NULL, NULL, NULL),
    ('Zucchini', NULL, NULL, NULL),
-- Umbellifers
    ('Bulb Fennel', NULL, NULL, NULL),
    ('Carrot', 'Early', NULL, NULL),
    ('Carrot', 'Maincrop', NULL, NULL),
    ('Celeriac', NULL, NULL, NULL),
    ('Celery', NULL, NULL, NULL),
    ('Chervil', NULL, NULL, NULL),
    ('Coriander', NULL, NULL, NULL),
    ('Dill', NULL, NULL, NULL),
    ('Parsley', NULL, NULL, NULL),
    ('Parsnip', NULL, NULL, NULL),
-- Beet family
    ('Beetroot', NULL, NULL, NULL),
    ('Chard', NULL, NULL, NULL),
    ('Spinach', NULL, NULL, NULL),
-- Leafy salad crops
    ('Chicory', NULL, NULL, NULL),
    ('Corn Salad', NULL, NULL, NULL),
    ('Endive', NULL, NULL, NULL),
    ('Land Cress', NULL, NULL, NULL),
    ('Lettuce', NULL, NULL, NULL),
    ('Mizuna and Mustards', NULL, NULL, NULL),
    ('Pak Choi', NULL, NULL, NULL),
    ('Rocket', 'Salad', NULL, NULL),
    ('Rocket', 'Wild', NULL, NULL),
    ('Winter Purslane', NULL, NULL, NULL),
    ('Wombok', NULL, NULL, NULL),
-- Solanums, basil, and sweetcorn
    ('Basil', NULL, NULL, NULL),
    ('Capsicum', NULL, NULL, NULL),
    ('Chilli', NULL, NULL, NULL),
    ('Eggplant', NULL, NULL, NULL),
    ('Potato', 'First Early', NULL, NULL),
    ('Potato', 'Maincrop', NULL, NULL),
    ('Potato', 'Second Early', NULL, NULL),
    ('Sweetcorn', NULL, NULL, NULL),
    ('Tomato', NULL, NULL, NULL),
-- Perennial vegetables
    ('Artichoke', 'Green Globe', NULL, NULL),
    ('Asparagus', NULL, NULL, NULL),
    ('Chives', NULL, NULL, NULL),
    ('Mint', NULL, NULL, NULL),
    ('Oregano', 'Hera', NULL, NULL),
    ('Perennial Kale', NULL, NULL, NULL),
    ('Raspberry', NULL, NULL, NULL),
    ('Rhubarb', NULL, NULL, NULL),
    ('Rosemary', NULL, NULL, NULL),
    ('Sorrel', NULL, NULL, NULL),
    ('Strawberry', NULL, NULL, NULL),
    ('Strawberry', 'Baron Solemacher', NULL, NULL),
    ('Thyme', NULL, NULL, NULL),
-- Flowers
    ('Calendula', NULL, NULL, NULL),
    ('Nasturtium', NULL, NULL, NULL),
    ('Sunflower', NULL, NULL, NULL)
) AS v(name, variety, harvest, height)
JOIN plant_types pt ON pt.name = v.name
WHERE pc.plant_type_id = pt.id AND pc.variety IS NOT DISTINCT FROM v.variety;

-- Sowing windows

UPDATE plant_catalogue
SET sowing_windows = '[{"start": "01-01", "end": "04-30"}, {"start": "10-15", "end": "11-15"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Broad Beans');

UPDATE plant_catalogue
SET sowing_windows = '[{"start": "04-15", "end": "07-15"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Dwarf French Beans');

UPDATE plant_catalogue
SET sowing_windows = '[{"start": "02-15", "end": "04-30"}, {"start": "06-15", "end": "07-15"}, {"start": "11-01", "end": "11-30"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Peas');

UPDATE plant_catalogue
SET sowing_windows = '[{"start": "02-15", "end": "03-15", "label": "midsummer crop"}, {"start": "06-01", "end": "06-30", "label": "autumn crop"}, {"start": "07-15", "end": "07-31", "label": "early spring crop"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Cauliflower');

UPDATE plant_catalogue
SET transplant_windows = '[{"start": "09-15", "end": "09-30"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Cabbage') AND variety = 'Spring';

UPDATE plant_catalogue
SET transplant_windows = '[{"start": "04-01", "end": "04-30", "label": "midsummer crop"}, {"start": "07-01", "end": "08-15", "label": "autumn crop"}, {"start": "08-15", "end": "09-15", "label": "early spring crop"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Cauliflower');

-- Spring radish autumn crop
UPDATE plant_catalogue SET
    sowing_windows = '[{"start": "02-15", "end": "04-30"}, {"start": "09-01", "end": "09-15", "label": "autumn crop"}]',
    transplant_windows = '[{"start": "03-15", "end": "05-15"}, {"start": "09-15", "end": "10-15", "label": "autumn crop"}]',
    harvest_windows = '[{"start": "04-01", "end": "06-15"}, {"start": "10-15", "end": "11-30", "label": "autumn crop"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Radish') AND variety = 'Spring';

-- Sets go in after the spring equinox, to reduce bolting
UPDATE plant_catalogue SET
    sowing_windows = '[{"start": "04-01", "end": "04-30", "label": "from sets"}, {"start": "02-15", "end": "03-31", "label": "from seed"}]',
    transplant_windows = '[{"start": "03-15", "end": "04-30"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Bulb Onion and Shallot');

UPDATE plant_catalogue
SET sowing_windows = '[{"start": "02-15", "end": "07-15"}, {"start": "08-15", "end": "08-31", "label": "overwintering"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Spring Onion');

-- Not before the last week of August, to reduce bolting
UPDATE plant_catalogue
SET sowing_windows = '[{"start": "10-01", "end": "10-15", "label": "from sets"}, {"start": "08-25", "end": "08-31", "label": "from seed"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Overwintering Onion');

-- Fixes the impossible 06-31 end date
UPDATE plant_catalogue
SET sowing_windows = '[{"start": "06-01", "end": "06-30"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Cabbage') AND variety = 'Winter';
