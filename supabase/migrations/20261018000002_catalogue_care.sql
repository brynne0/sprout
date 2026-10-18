-- Germination, care, pests and harvest notes from No Dig and Rebel Gardening, plus sowing windows matched to the text.
-- NULLs leave the current value alone, so unfilled rows are safe to run.

-- Per plant type
UPDATE plant_types pt SET
    germination = COALESCE(v.germination, pt.germination),
    care = COALESCE(v.care, pt.care),
    pests = COALESCE(v.pests, pt.pests)
FROM (VALUES
-- Legumes
    ('Broad Beans', 'Sow under cover in 5cm modules', 'Water in dry weather once flowering. Support with two levels of string around posts', 'Net seedlings against birds. Blackfly hits later sowings and dry plants in May-June: sow early, water, pinch out the tops once the main stem is full of flowers, and hose them off'),
    ('Climbing Beans', 'One seed per 5cm module, laid flat and covered to twice its thickness; no need to soak', 'Twist stems around the canes at first; a teepee 90-120cm wide, or a double row of 2.5m sticks. Once in full flower, soak twice a week in dry weather', 'Rarely a problem. Wrap mesh around young plants if deer or rabbits bite the tops. Watering prevents blackfly'),
    ('Dwarf French Beans', 'One seed per 3cm module under cover; warmth helps. Summer sowings can go direct, 3cm deep', 'Fleece early plantings. Once flowering, water twice a week in dry weather, or pods won''t set. No support needed', 'Watering keeps blackfly away. Pick often so pods don''t reach the soil, where slugs eat them. Yellow leaves in cool soil recover once it warms'),
    ('Peas', '2-3 seeds per 3-5cm module, planted out as a clump; old seed germinates erratically', 'Support all but dwarf varieties from early May with stakes, pea sticks and strings every 15cm. Water regularly once flowering if dry', 'Fleece early plantings against rabbits and pigeons, then use bird netting. Pea weevil notches on leaves are harmless. Pea moth maggots appear from July, so early sowings avoid them. Powdery mildew mostly hits late sowings; Terrain resists it'),
-- Brassicas
    ('Broccoli', 'Sow thinly in a tray under cover, lightly covered, and prick out into 3-5cm modules within a week. For a few plants, sow 2 per module and thin', 'Plant deep, burying the stem. Fleece in spring, mesh in summer, for 4-6 weeks after planting. Water until established, then in dry weather as heads form. Snap off yellowing lower leaves', 'Covers keep off flea beetle, cabbage root fly and caterpillars; bird netting for pigeons. Squash caterpillars, and expect a few in late calabrese heads. Wash off aphids, water, and add 3cm of compost'),
    ('Brussels Sprouts', 'Sow thinly in a tray and prick out into 3cm modules, or 2 per module and thin. Pot on into 7cm pots after a month', 'Plant deep. Mesh on hoops for 6-8 weeks after planting. Stake and tie in during late summer. Pull off yellowing lower leaves. Water at planting and in a dry September', 'Mesh keeps off flea beetle, cabbage root fly, swede midge and caterpillars; swap it for bird netting on a frame if there are pigeons. Squash caterpillars in late summer, especially in the tops. Compost and watering keep aphids and whitefly down'),
    ('Cabbage', 'Always under cover. Sow thinly in a tray to prick out, or 2 per 3-5cm module and thin', 'Plant deep, burying the stem. Cover for the first 6-8 weeks: fleece in spring, mesh later. Water until established, then summer and autumn types in dry weather as hearts form. Remove yellowing lower leaves', 'Covers keep off flea beetle, cabbage root fly, birds and rabbits; keep bird netting on throughout where there are pigeons. Removing yellow leaves keeps slugs down'),
    ('Cauliflower', 'Under cover with warmth; February sowings in the house. Sow thinly in a tray to prick out, or 2 per module and thin', 'Plant up to 5cm deep. Fleece or mesh from day one, mesh through summer. Water in dry weather as curds swell. Snap off yellowing outer leaves', 'Covers keep off flea beetle, cabbage root fly and caterpillars. Late-summer plantings avoid most insects but need netting against pigeons. Squash caterpillars. Removing yellow leaves reduces slugs'),
    ('Kale', '2 seeds per 3cm module and thin, or sow in a tray to prick out; multisow for salad leaves', 'Plant deep. Mesh for at least 6 weeks after planting. Water only in very dry weather once established. Remove yellowing lower leaves; stake tall varieties in windy gardens', 'Mesh keeps off insects and rabbits; bird netting on hoops so pigeons can''t peck through. Removing yellow leaves reduces slugs'),
    ('Radish', 'Spring: multisow 5 per 3cm module; keep February sowings warm in the house, then move to a cold greenhouse. Winter: 2 per module', 'Plant deep to bury the stems. Fleece in March-April, then fine mesh; keep mesh on winter radish until late September. Water spring radish every 2 days in dry weather, winter radish only in a dry early autumn', 'Fine mesh from mid-spring keeps off flea beetle and cabbage root fly'),
    ('Swede', '2 seeds per 4cm module under cover and thin, or sow in a tray and prick out', 'Plant deep, up to the first true leaf. Mesh for the first 6-8 weeks (until mid-August), then bird netting if there are pigeons. Water until established and in a dry early autumn as roots swell. Twist off yellowing lower leaves', 'Mesh keeps off flea beetle, cabbage root fly and swede midge, which stunts growth. Removing yellow leaves reduces slugs'),
    ('Turnip', 'Multisow 5-6 seeds per 3cm module for clumps of 3-4. Germinate early sowings in the house, then move them to a cold greenhouse', 'Fleece early plantings for at least a month; mesh in late summer and autumn. Water until established, and in dry spells as roots swell', 'Covers keep off flea beetle, pigeons and cabbage root fly, including its second generation in late summer'),
-- Alliums
    ('Bulb Onion and Shallot', 'Multisow 6 seeds per 3cm module, or 6 per cm in outdoor drills to lift and transplant after 5 weeks. Plant sets with the tip about 3cm below the surface', 'Fleece spring plantings, mesh later if there are rabbits. Water only if it''s dry as bulbs form in June. Hoe regularly while the leaves are upright', 'Downy mildew browns leaves in a wet late spring; those bulbs don''t store long. Check sets are firm with no white mould at the base (onion white rot). Against allium leaf miner, transplant in May and harvest by August'),
    ('Garlic', 'Plant the biggest cloves, flat base down, tip just below the surface; October is best', 'Little needed beyond weeding. Water in late May-early June if spring is dry. Snap off hardneck scapes before the flowers open; they''re edible', 'Mesh in spring if allium leaf miner or leek moth are about. Mild rust is fine; if leaves are covered, harvest straight away. Onion white rot yellows leaves and rots roots: bin affected plants, don''t compost'),
    ('Leek', 'Multisow 4-5 seeds per module in the second week of April. From 3cm modules, pot on into 7cm pots after about 8 weeks', 'Plant with the root ball 3-5cm deep (7cm for whiter stems), water in and don''t backfill. Keep watered in dry weather, especially late summer', 'Allium leaf miner makes pale lines in leaves; mesh for the plant''s whole life prevents it. Leek moth shows as stalled growth in late summer; mesh from planting to early September. Mesh also stops rabbits. Remove rust-covered lower leaves in autumn'),
    ('Overwintering Onion', 'Multisow 6 seeds per 3cm module, not before the last week of August', 'Mesh over winter against rabbits (fleece holds too much moisture). Hoe in spring while the leaves are upright', 'Check sets are firm with no white mould at the base'),
    ('Spring Onion', 'Multisow 10 seeds per 3cm module, or 3 seeds per cm in outdoor drills 2.5cm deep', 'Fleece spring plantings, mesh later if there are rabbits. Water in dry weather for better leaves', 'Later sowings get downy mildew in damp August weather'),
-- Cucurbits
    ('Cucumber', 'One seed per 5cm module, laid flat and lightly covered, no more than 4 weeks before the last frost. Needs steady warmth, ideally indoors at night. Pot on to 7cm after 2 weeks, then 10cm. Don''t overwater, or stems damp off', 'Plant 5cm deep after the last frost, even under cover. Cordons: plant on a string, twist the stem around it, remove all sideshoots, and loop the tip back down at the top. Remove fruits until 60cm tall, then every second one. Water twice a week outdoors, every 2-3 days under cover', 'Slugs can damage young ridge plants in cool, wet weather. Under cover, watch for red spider mite (the predatory mite Phytoseiulus helps) and whitefly. Cut off lower leaves with powdery mildew. Don''t wet leaves under cover on cloudy days, to prevent downy mildew'),
    ('Melon', 'One seed per 3cm module, germinated in the house. Keep above 10°C at night once in the greenhouse. Pot on to 7cm after 3-4 weeks, and 10cm in late April. Water only when pots feel light', 'Plant 5cm deep under cover, on a string for cordons, and twist the stem around it every 2-3 days. Pinch out sideshoots until 1-1.2m, then let them grow and pinch each tip once a melon forms. In a cool summer keep only 3-4 melons. Water moderately, more in heat, less as fruits ripen', 'Hose aphids off in late spring. Slug and woodlice nibbles are minor. Red spider mite is serious if it comes early'),
    ('Pumpkin', 'Sow one seed flat per 5cm module, a month before the last frost. Needs 20-25°C, so keep in the house for the first week. Pot on to 9cm once true leaves grow. Without a greenhouse, sow in late April-early May', 'Plant after the last frost, 5cm deeper than in the pot; water every 2 days in dry weather for a week. Fleece in cold, windy late May. No pruning or thinning; small fruits rotting is normal. Water once or twice as fruits swell in a dry summer', 'If slugs are bad, check with a torch for a few nights after planting. Powdery mildew in late summer is normal and helps ripening'),
    ('Zucchini', 'Sow one seed per 5cm module or small pot, laid flat and lightly covered, 2-3 weeks before the last frost. Keep above 16°C at night for 5 days. Pot on to 10cm after 15-20 days', 'Plant after the last frost, 5cm deeper than in the pot; water every 2 days for the first week or two. Fleece if cool and windy. Water often in hot, dry weather or it stops fruiting. In containers, feed weekly once fruits form', 'Slugs can damage young plants. Powdery mildew on older leaves after midsummer is normal; remove them if you like'),
-- Umbellifers
    ('Bulb Fennel', 'Avoid April sowings, which bolt. Sow 2 seeds per 3cm module and thin to the strongest. Keep early sowings in the house for about a week, then under cover and frost-free', 'Plant with the module top at least 2cm below ground. Lay fleece over spring plantings until early May. Water until growing strongly, and while bulbs swell from late May', 'Few pests. Spring fleece keeps rabbits off, and slugs can take direct-sown seedlings at the two-leaf stage'),
    ('Carrot', 'Sow direct, never transplant, as that breaks the tap root. Wait for warmer weather. About 3 seeds per cm in 1-2cm drills; water the drill first if dry. Mark rows with a radish every 5cm. Thin to 2-3 per cm after about 6 weeks', 'Fleece early sowings to speed growth. Weed carefully while small. Rarely needs water, except in a dry early summer as roots swell; drier soil gives sweeter roots', 'Carrot root fly is about mid-May to June: swap fleece for mesh on hoops in early May and keep early sowings covered. Summer sowings can go uncovered from late June, but cover before 10 August. Sow away from slug hiding places and don''t leave mature roots in too long'),
    ('Celeriac', 'Needs light to germinate, so don''t cover the seeds. Scatter on wet seed compost, mist, and cover with glass or polythene at 15-20°C in the light; uncover once seedlings appear (about 2 weeks). Prick out into 3cm modules after 3-4 weeks. Never let seedlings get cold, or they bolt later', 'Plant with the module top 1cm below the surface and water in. Fleece or mesh for about a month if cool. Water twice more after planting and in hot, dry spells', 'The cover after planting keeps off aphids, which can stunt plants. Late blight causes brown leaf patches in autumn. Avoid beds with rotting wooden edges, where slugs and woodlice hide'),
    ('Celery', 'Needs light to germinate, so don''t cover the seeds. Sow thinly under cover on wet seed compost, mist, and cover with glass or polythene at 15-20°C in the light; uncover at the first leaves. Avoid frosty conditions, which cause bolting. Prick out into 3cm modules after about 3 weeks. A late-May sowing gives tender celery in September and October', 'Plant after the last frost, root ball top 1cm below the surface, and water in well. Fleece May plantings if cool. Needs more water than any other vegetable: twice a week if it doesn''t rain. Modern varieties don''t need blanching. Twist off sideshoots from the base; they''re edible', 'Mesh for the first month keeps aphids off. Keep away from slug hiding places. Early blight: light brown spots in early summer; remove damaged leaves. Late blight: browning leaves in damp late summer; remove them, harvest promptly, and grow resistant varieties for autumn'),
    ('Chervil', 'Germination is erratic: sow in a small tray under cover and prick out into modules at the two-leaf stage, or sow 2-3 per module and thin to one. Plant out while small', 'Only grows in mild winter weather, so grow some under cover for bigger winter harvests. Water in a dry autumn or early spring. Fleece laid on top speeds growth in the cold', 'Few pests. Where there are rabbits, cover over winter with netting, mesh or fleece'),
    ('Coriander', 'Sow 2 seeds per 3cm module, or direct in rows 20cm apart. For summer leaves, sow every 4-6 weeks until early July. Sowings from mid-July (late July is best) crop through autumn, winter and early spring', 'Water generously in summer for more leaves and later flowering. Early autumn sowings planted under cover are much more productive over winter', 'Slugs can damage new plantings: clear nearby hiding places and check after dark'),
    ('Dill', 'Sow 2-3 seeds per 3cm module, or in a tray to prick out. From April, sow direct a seed every 2.5cm in 1cm drills. Plant 3cm deep to support the long stems', 'Fleece early spring plantings for the first month to keep them warm', 'Fleece keeps rabbits off spring plantings; use bird netting on hoops in summer'),
    ('Parsley', 'Slow: can take 3 weeks to come up. Sow in a tray under cover and prick out into modules, or direct in a drill once spring warms. Plant a little below soil level. Early sowings, especially flat-leaf, may flower in summer; summer sowings overwinter and crop into spring', 'Fleece early spring plantings. Grow a plant or two under cover for winter picking. Remove yellowing older leaves', 'Fleece, then bird netting, keeps rabbits off. Extra water is the best remedy for spring aphids. Aphids spread a virus that turns overwintered leaves bright yellow; twist out and compost those plants'),
    ('Parsnip', 'Sow direct, as transplanting breaks the tap root, on a still day so the seeds don''t blow away. Seeds about 1cm apart in 3cm drills; water the drill first if dry and tamp down after. Keep moist for the 2 weeks it takes to germinate. Mark rows with radishes. Fleece early sowings', 'Thin at the first true leaves: 2.5cm for small, 5cm for medium, 10cm for big roots. Remove fleece before it gets hot, often late April. Weed until the leaves close over; cover your skin, as the sap irritates. Rarely needs watering. Leaves rotting in winter is normal', 'Canker rots the shoulders in wet, heavy soil; cut it off after harvest, and later sowings suffer less. Carrot fly damage is usually superficial. Lift and store if rodents chew the crowns'),
-- Beet family
    ('Beetroot', 'Sow under cover. February-March sowings need 5-7 days'' warmth in the house, then the greenhouse; use bolt-resistant Boltardy or Pablo before late March. Multisow 3 multigerm or 5 monogerm seeds per 3cm module, aiming for 4 seedlings; the thinnings are edible. Not after mid-July', 'Plant clumps with most of the stems below the soil. Fleece early plantings for a few weeks, on hoops if nights are frosty. Water 2-3 times after planting, then not for a month or more; a little once roots reach golf-ball size. Dry weather makes roots sweeter', 'Fleece or mesh keeps off birds, rabbits and deer. Leaf miner blotches rarely matter. If you see rodent teeth marks, harvest straight away; the beets are still edible'),
    ('Chard', 'Sow under cover no earlier than mid-April, or plants may bolt. One seed per 3cm module gives 2-3 seedlings: thin to 1-2 for cooking leaves, or sow 2 seeds for salad. Or sow direct 5cm apart, thinning to 5cm for salad or 15cm for cooking', 'Plant with the stems below the soil and water in. Keep watered in dry weather. Remove fading outer leaves. Later summer sowings overwinter better', 'Removing old outer leaves reduces slug damage. Net against birds if they strip the leaves'),
    ('Spinach', 'Don''t sow between mid-April and late July, or it bolts. Multisow 2-3 seeds per 3cm module for salad, or one per module for cooking leaves. Plant 1cm deeper than the root ball. Can also sow direct in late March or August', 'Water until growing strongly (5-7 days), and twice a week in dry spring weather. Fleece or mesh spring plantings; mesh over winter boosts late-winter growth. Remove stalks and yellow leaves as you pick', 'Plant into clear ground away from slug hiding places. Leatherjackets can cut through early plantings: dig out the grub, and keep spare plants for 2 weeks'),
-- Leafy salad crops
    ('Chicory', 'Don''t sow in spring, or plants flower. Sow thinly in a tray to prick out into 3cm modules, or 2 per module and thin to one. Later sowings give more valuable late-autumn harvests. Pot on into 7cm pots if there''s no space yet', 'Plant with the module top below soil level. Water every couple of days in hot weather until growing strongly. Hearts form in autumn. Loose hearts stand frost best; fleece firm hearts for a late winter harvest', 'Few insect pests. Slugs eat seedlings, so bigger transplants from 5cm modules or 7cm pots help. Keep rabbits off with netting or mesh, not fleece, which gets too hot'),
    ('Corn Salad', 'Sow direct in rows, a seed every 1-2cm, thinning to 7-10cm; or 2-3 seeds per 3cm module under cover. Keep moist; it takes at least a week to come up. Plant just below the surface', 'Hardy enough to stand outside all winter; fleece in really cold spells', 'Mostly ignored by pests. Powdery mildew hits August sowings in a dry autumn; keep watered, or sow in early September'),
    ('Endive', 'Germination is variable: sow in a small tray and prick out into 3cm modules, or 2 per module and thin. Or sow direct in rows 25cm apart, 5-10cm between seeds', 'Plant with the root ball top below soil level. Water generously in dry weather. Blanching is optional: cover with a large pot for at most a week before cutting the whole head', 'Slugs do little damage and rarely eat frisée. No root aphid, unlike lettuce. Rabbits and deer love it; bird netting lets through more autumn light than mesh'),
    ('Land Cress', 'Sow in a tray to prick out into 3cm modules, or 2-3 per module and thin to the strongest. Plant slightly deeper than the module', 'Water until new growth shows; outdoors it rarely needs more. Under cover, water every 2-3 weeks in winter, weekly if sunny', 'Bird netting or mesh in winter keeps pigeons off. Spring flea beetle damage doesn''t set back established plants. Small slugs hide under leaves but rarely do much harm'),
    ('Lettuce', 'Sow in a tray to prick out into 3cm modules, or 2 per module and thin to one. Seeds need light: top with perlite or vermiculite, or cover with glass. Keep February sowings in the house; shade summer sowings for the first week. For year-round leaves, sow in late February, late May, mid-July and early September (under cover). Sow direct for cut-and-come-again', 'Plant with the root ball 1cm below soil. Water at planting and 2 days later, then only in hot weather: a soak every 2-3 days, in the morning. Keep winter lettuce under cover fairly dry. Fleece early spring plantings and keep a few spares', 'Mesh or netting from May keeps rabbits and birds off. Clear slug habitat nearby. In spring, leatherjackets and wireworms cut young plants: rummage under the plant to remove them. Root aphids in late summer make plants wilt suddenly; remove those, and mulch to keep the soil moist. Regular picking prevents downy mildew, which worsens from October'),
    ('Mizuna and Mustards', 'Multisow 3 seeds per 3cm module under cover, or direct in drills 20cm apart; mizuna suits cutting as a thick sward. Two plants per module give bigger leaves. Plant out burying the long stems. Thin direct sowings to 2.5cm for salad or 10cm for big leaves', 'Water the bed before planting if it''s dry, water in, and keep watering in dry weather. Fleece spring plantings', 'Mesh for about 3 weeks after planting (5 after direct sowing). Spring fleece keeps rabbits and pigeons off. Slugs love mizuna; grow mustards in slug-prone spots'),
    ('Pak Choi', 'Always under cover: 3 seeds per 3cm module, or a small tray pricked out at the two-leaf stage within 5 days. Plant out young, burying the spindly stems', 'Water well in dry weather, in the morning so leaves are dry by night. Fleece spring crops. Remove yellow or rotting lower leaves', 'In late summer, mesh on hoops straight after planting keeps off flea beetles, thrips, pigeons and egg-laying butterflies; the first month is critical. Removing yellow leaves and watering in the morning reduce slugs'),
    ('Rocket', 'Sow in 3cm modules under cover; direct-sown seedlings get eaten. Salad rocket: 3 seeds per module. Wild rocket: sow in a tray and prick out singly. Plant salad rocket with the stems below ground. Keep wild rocket under cover over winter in 7-9cm pots and plant out very early in spring', 'Water regularly in dry weather. Remove yellowing leaves as you pick. Hardy, but salad rocket barely grows outdoors in winter', 'Fine mesh after planting keeps off flea beetles and pigeons; keep it on wild rocket until it finishes in summer. Late-summer sowings suffer far less from flea beetle'),
    ('Winter Purslane', 'Sow the tiny seeds in a tray to prick out into 3cm modules, or a few per module thinned to 1-3. Barely cover them. Spring sowings flower in April', 'Water in, then little needed. Moderate frost browns older leaves. Remove stalks of white male flowers in winter, which taste poor. Clear plants by late April, before they self-seed', 'Untroubled by pests'),
    ('Wombok', 'Sow in late July; spring sowings bolt. Sow under cover in a tray to prick out, or 2 per 3cm module and thin. Plant out at 15-21 days old, no older', 'Plant with the module top 5cm below soil. In dry weather, water every 2-3 days after planting, then soak twice a week unless it rains; less as autumn goes on', 'Fine mesh from planting until harvest, and still check for caterpillars. Twist off yellowing outer leaves, holding the centre, to remove slug hiding places'),
-- Solanums, basil, and sweetcorn
    ('Basil', 'Sow under cover on a heat mat or indoor windowsill. Roots rot in soggy compost, so mix in up to 60% sand, vermiculite or perlite and water as little as you dare. Multisow 3 per module and thin to 1-2 after 10 days. Or split a supermarket pot into 9cm pots', 'Plant after the last frost, once it''s warm; grows well in containers and under cover. Water twice a week in the ground, daily in containers in summer', 'Slugs eat seedlings, especially if planted out while cool. Green caterpillars do slight damage in high summer. More disease in cool, damp weather'),
    ('Capsicum', 'Sow early with warmth, easiest in the house. Sow singly in 3cm modules, or in a tray and prick out at the first true leaf. Pot on about every 3 weeks, into 7cm then 9cm pots', 'Plant 5cm deep after the last frost, once it''s warm. Water only when pots feel light, more as fruits swell, less in late summer. Feed regularly in containers. Support with string around a cane once established, as stems snap under heavy fruit. From mid-August, pinch out new stems and small flowers so the last fruits ripen', 'Fairly trouble-free. Wash aphids off new growth in spring until predators arrive'),
    ('Chilli', 'Sow early with warmth, easiest in the house. Sow singly in 3cm modules, or in a tray and prick out at the first true leaf. Pot on about every 3 weeks, into 7cm then 9cm pots', 'Plant 5cm deep after the last frost, once it''s warm; grows well in 25cm pots. Water sparingly (lush growth means fewer flowers), and less in late summer. No feeding needed. Tie to a cane if needed. From mid-August, pinch out new stems and small flowers. To overwinter, cut back by two-thirds, keep frost-free and barely water', 'Fairly trouble-free. Wash aphids off new growth in spring until predators arrive'),
    ('Eggplant', 'Sow under cover by the end of March, thinly in a small tray, and prick out into 3cm modules. Pot on into 7cm pots at about 6 weeks old or 5cm tall', 'Plant mid-May under cover, or outdoors after the last frost, burying the stem 5cm. Don''t overwater young plants; water more once fruits swell. Remove browning lower leaves. Under cover, train two stems up strings: remove sideshoots until 30-35cm tall, keep one strong one near the top as the second stem, then remove the rest and pinch off the first flower bud. Outdoors, grow as a bush held up with string around a cane', 'Aphids and whitefly in late spring: hose them off and predators follow. Red spider mite shows as pale, matt undersides on young leaves; wetting leaves under cover helps'),
    ('Potato', 'Chit seed potatoes from late winter on a light windowsill, not in the dark. Supermarket potatoes may be treated not to sprout. Plant with a trowel, shoots up, the top at least 5cm deep. No more than 3 weeks before the last frost unless you can fleece them', 'If a night of 3°C or lower is forecast, pull compost over the leaves or use double fleece. Cover any tubers that show with compost so they don''t turn green. In a dry early summer, water generously twice a week for the last 2 weeks', 'Late blight in warm, wet weather turns leaves grey-brown and limp within days: cut plants at ground level, compost the tops, and wait a few days before lifting. Blackleg (black, collapsing stems) comes from infected seed; the tubers are edible, but don''t save them for seed. Slugs chew tubers, so lift promptly. In former grassland, bait wireworms overnight with half a potato and remove them'),
    ('Sweetcorn', 'Sow under cover about a month before the last frost, one seed 1cm deep per module; or direct, 1-2cm deep, after the last frost. Sow early and late varieties together for a run of cobs; early ones suit cool summers', 'Plant after the last frost, in a block to help pollination. Fleece for 2-3 weeks if cold; plants yellow and sit still until the soil warms. Water in, then soak twice a week in dry weather as cobs swell', 'Rodents, badgers and birds take ripening cobs: harvest promptly, even slightly under-ripe. Mice eat the seeds'),
    ('Tomato', 'Sow 6-8 weeks before the last frost (not February), in warmth under cover, thinly in a tray or one per 3cm module. Prick out at the seed-leaf stage. Pot on into 7cm pots at two true leaves, then 9cm after 10-12 days', 'Plant after the last frost, deeper than in the pot; grow at least half under cover in a damp climate. Cordons: stake or string, twist the stem in, snap off sideshoots. Remove lower leaves from a month after planting, half the first truss, and the tops in early August. Water the soil, not the leaves: twice a week under cover (more in heat), weekly from September. Irregular watering splits fruit. Feed only in containers', 'Blossom end rot (black patches under the fruit) means too little water. Spray aphids off in spring until predators arrive. Leaf roll isn''t serious. Late blight is worst outdoors: compost affected leaves, and remove the plant once stems blacken. Slugs and woodlice eat fruit on the ground'),
-- Perennial vegetables
    ('Artichoke', 'Start in seed trays indoors and plant out at five leaves. Or get a division from a friend''s established plant', 'Warm, sunny, well-drained spot with room to spread. Water well and keep weed-free', 'Slugs and snails love young plants; coffee grounds or eggshells help. Ladybirds control aphids'),
    ('Asparagus', 'Crowns (one-year-old roots) crop a year sooner. From seed, sow singly in modules in early spring; a week in the house, then the greenhouse. Pot on into 7cm pots after 5-6 weeks, and into bigger pots after a couple of months', 'Plant in full sun, ideally in a north-south line: spread the roots over a shallow 10cm dish, domed in the middle, and cover with compost. Water in the first spring only. Keep weeding. Support the tall ferns with wires between posts. Remove berry-bearing female stems in early autumn. Cut ferns down once they yellow, and mulch with compost in November', 'Rabbits or slugs may graze the first spears, but healthy plants shrug it off. Asparagus beetle eats leaves and stems, mainly a problem in drier areas'),
    ('Chives', 'Buy pot plants or divide a clump in spring, as seed-raised chives run to seed quickly: cut a section from the edge and replant at the same depth. From seed, sow 3 per 7cm pot under cover and thin to 1-2', 'Little care needed; more prolific in the ground than in pots. Cut back hard in early summer to stop self-seeding and get fresh leaves. Water in a dry summer. Dies back in cold winters', 'Generally untroubled. Grow in containers if your plot has onion white rot or allium leaf miner'),
    ('Mint', 'Easiest to buy small pot plants and plant in spring. For more, lift sections of root, or root 10cm cuttings in 5cm modules of compost with 30% vermiculite or perlite', 'Invasive roots: grow in a pot sunk into the bed, rim just above ground. Water regularly, especially in containers. Let the early summer flowers bloom for insects, then cut back hard in late summer. Cut all stems to 5cm once the leaves drop in late autumn', 'Regular watering prevents powdery mildew on older leaves'),
    ('Oregano', 'Sprinkle seeds on top of moist, well-drained compost in early spring and keep warm, like on a sunny windowsill. Pot on the seedlings and keep them warm until late spring', 'Plant out after the last frost, hardening off by day for a week first. Needs very good drainage: add a handful of gravel. Water sparingly, more in pots. Cut right back in midsummer. Repot potted plants every year or so in spring', 'No problems as long as drainage is good'),
    ('Perennial Kale', 'Doesn''t make seed: buy young plants, or root 15cm sideshoots in water or a 7cm pot of moist compost (about 3 weeks)', 'Plant any time, ideally spring or summer. Stake tall varieties (1.5m) in a sheltered corner. Water new plants until growing strongly, and in dry weather for more leaves. Twist off unwanted new stems. Pick off yellow or damaged leaves', 'Bird netting over the top of a wooden frame keeps pigeons off. Spray grey aphids off new leaves in spring. Caterpillars don''t kill it'),
    ('Raspberry', NULL, NULL, 'Net against birds, mice and other small animals'),
    ('Rhubarb', 'Easiest from a pot plant (spring to autumn) or a dormant crown (November-March). From seed, sow in 7cm pots under cover in early spring, pot on into 9cm, and plant out in summer', 'Water in dry spells for more stems. Mulch the crown with compost or manure once the leaves die back in autumn. Cut out flower stems at the base. Remove a section if the crown gets too big. To force, cover part of a crown with a tall pot in late winter and pick the pink stalks a month later; uncover within 2 months, and force each plant only every other year', 'Crowns are remarkably resistant to pests and diseases'),
    ('Rosemary', 'Easiest to buy a pot plant in spring. Or in early spring, root 10cm cuttings of new growth in modules of compost with a third vermiculite', 'Plant a little below the surface and water in. Cut back the flowered stems in midsummer to keep it compact. New growth can get frost damage in a cold spring. Replace after 7-10 years once bare at the base', NULL),
    ('Sorrel', 'Multisow in 3-5cm modules and thin to 1-2, or sow in a tray and prick out; or direct in early spring. Tiny seeds and slow early growth. Germinates faster in warmth, so fleece sowings and plantings for about a month', 'Tolerates dry spells, but watering gives more leaves and less bolting. Remove flower stalks in late spring and early summer, or let it flower, then cut it down for fresh leaves: broad-leaved to 5cm in June, buckler-leaved almost to the ground in mid-July', 'Watering makes plants less prone to beetle damage. Buckler-leaved sorrel gets brown leaf spots in dry summers, increasing in autumn'),
    ('Strawberry', 'Start from runners in early spring, or plants in early summer. For new plants, pin a still-attached runner onto a pot of compost after fruiting, keep it moist, and cut it free once rooted', 'Keep the soil moist but the plant dry; water the soil in the morning. Feed weekly with tomato feed. Snip off runners while fruiting. Cut back once fruiting stops so it regrows next year', 'Straw around the plant deters slugs and snails and keeps the soil warm. Net against birds. Grey mould in damp weather: keep the plant dry and remove affected fruit at once'),
    ('Thyme', 'Home-raised plants are tougher than soft garden-centre ones. In March, sow 2-3 seeds per small pot or module, or root 4cm cuttings in half compost, half sand or vermiculite. Keep warm under cover and plant out in early summer', 'Water summer plantings every 2 days for a week or two; at other times just water in. After flowering in midsummer, cut back hard, leaving a little green wood, to keep it compact. Mulch with 2cm of compost every autumn', NULL),
-- Flowers
    ('Calendula', 'Scatter seeds among other crops in mid-spring, dust with compost and water well. Thin seedlings to about 10cm', 'Grows well among crops like tomatoes and beans. Water in dry spells. Keep picking flowers for more', 'Untroubled by pests'),
    ('Nasturtium', 'Sow in spring where it''s to grow: push seeds 1.5cm deep and 10cm apart into watered, raked soil. Thin to one every 30cm after a couple of weeks', 'Grow near brassicas or beans. Little feeding or watering needed, except in very dry weather; pots need occasional water. Support climbing types with a cane or trellis', 'Lures caterpillars and aphids away from other veg. Grow a few plants so some stay good to eat'),
    ('Sunflower', 'One seed per cell of compost, watered well, somewhere warm and sunny indoors. Pot on at 5cm, and plant out at 30cm tall after the last frost', 'For height, leave them be; for more flowers, pinch out the tips. Stake against wind and rain', 'Ladybirds keep aphids down. Thistles around the base can deter squirrels. Good air flow and drainage prevent white mould')
) AS v(name, germination, care, pests)
WHERE pt.name = v.name;

-- Per catalogue entry (variety NULL is the general entry)
UPDATE plant_catalogue pc SET
    harvest = COALESCE(v.harvest, pc.harvest),
    height = COALESCE(v.height, pc.height)
FROM (VALUES
-- Legumes
    ('Broad Beans', NULL, 'Pick when pods are fat but before they darken, pushing them down at the stem. Cut plants at the base and leave the roots in the soil', NULL),
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
    ('Cucumber', 'Cordon', 'Keep picking, a large fruit every other day; smaller ones are less seedy. Keeps a week in the fridge', NULL),
    ('Cucumber', 'Ridge', 'Keep picking, up to one a day in warm weather. Peel at least half the knobbly skin. Keeps a week in the fridge', NULL),
    ('Melon', NULL, 'Pick when it yellows and smells sweet, or cracks around the stalk. Cut with a short stalk; keeps 2 weeks somewhere cool', NULL),
    ('Pumpkin', NULL, 'Pick before the first frost, once leaves die back, stalks turn brown and the skin sounds hollow when tapped. Keep the stalk intact. Cure on a sunny windowsill for 2 weeks; stores for months somewhere warm and dry', NULL),
    ('Zucchini', NULL, 'Pick the first fruits very small, then before the flower at the tip dies. Cut the stalk for better storage. Flowers are edible. Wear gloves and long sleeves; leaf hairs can cause a rash. Keeps a week in the fridge', NULL),
-- Umbellifers
    ('Bulb Fennel', NULL, 'Pick while plump, before sideshoots appear or the bulb lengthens; slice under it rather than pulling. The leaves taste of dill. Lift the last before the first frost; they keep a month in a cool shed', NULL),
    ('Carrot', 'Early', 'From about 10 weeks, pull roots whose shoulders show so the rest can swell. Last harvest around late July, before they turn fibrous. Keeps 1-2 weeks if cool', NULL),
    ('Carrot', 'Maincrop', 'Harvest by thinning until early autumn, then lift big roots. Lift to store before nights drop below -5°C: twist off the leaves, leave soil on, and keep in paper sacks in a frost-free shed for 3-5 months', NULL),
    ('Celeriac', NULL, 'Harvest from mid-October as needed until late November, then lift the rest. Cut under the root with a trowel, leaving a few fibrous roots on. Store in an open crate below 10°C; keeps until April', NULL),
    ('Celery', NULL, 'Cut single outer stalks from about 3 months, or whole heads while small. Ends at the first -2°C frost. Keeps several days in a bag in the fridge. The leaves are good for stock', NULL),
    ('Chervil', NULL, 'Pick often, twisting outer leaves off at the base with the whole stalk; leave the centre to grow. Edible white flowers appear in late April or May', NULL),
    ('Coriander', NULL, 'Start picking the lower stalks once leaves touch neighbouring plants. Leaves get smaller once it flowers; the first flower stems are edible, and later the seeds', NULL),
    ('Dill', NULL, 'Snap off larger leaves at the base every few days, before it flowers. Flowers and seeds are edible. Long stems keep a week in water', NULL),
    ('Parsley', NULL, 'Twist or cut the largest lower leaves close to the stem; the centre keeps growing for months. Growth is slow in winter', NULL),
    ('Parsnip', NULL, 'Lift as needed, finishing before new leaves sprout at the end of winter. Lever long roots out with a spade. In sodden soil, lift them all in early December. Store unwashed, leaves off, in a box or paper bag in a shed', NULL),
-- Beet family
    ('Beetroot', NULL, 'Twist out the largest root from each clump so the rest keep growing. Lift the last before nights drop below -4°C; twist off the leaves, leave soil on, and store in a box in a cool, dark shed until spring. Eat small beets first', NULL),
    ('Chard', NULL, 'Pick salad leaves at 10cm, cooking leaves once plants pass 30cm. Twist outer leaves off at the base and leave the centre; pick every few days in summer. Keeps a week in a bag in the fridge', NULL),
    ('Spinach', NULL, 'Pick small for salad or larger for cooking; leaves get smaller through spring. Once a flower stalk appears, pick for about another week, then remove the plant. Keeps 5 days in a bag in the fridge', NULL),
-- Leafy salad crops
    ('Chicory', NULL, 'Cut under the head and trim off tough outer leaves; finish before March, when leaves turn bitter. If outer leaves rot, cut at once; a good heart is usually inside. Firm hearts store 4-6 weeks in a box below 10°C', NULL),
    ('Corn Salad', NULL, 'Cut whole plants at the base, or higher up for a smaller second harvest of sideshoots a month later. Little growth in winter, then new leaves before it flowers in spring', NULL),
    ('Endive', NULL, 'Twist medium outer leaves off at the base, leaving the centre rosette. Or let it heart up and cut the whole head, trimming any rot; hearts stand 2 weeks down to -2°C. Keeps a week in the fridge', NULL),
    ('Land Cress', NULL, 'Once leaves touch, twist off larger leaves or cut a handful, leaving the centre to regrow. Flower stalks are edible, but it self-seeds if left. Keeps a few days cool and damp', NULL),
    ('Lettuce', NULL, 'Once plants touch, push larger outer leaves off with your thumb at least weekly, leaving the centre; plants crop for 10 weeks, or 6 months from autumn sowings. Cut heads when the centre folds in and pales. For cut-and-come-again, cut above the smallest leaf. Keeps a few days in the fridge', NULL),
    ('Mizuna and Mustards', NULL, 'Pick leaves at the base once they are the size you like, without rocking the plant, and take the stalks too. Mustards get hotter as they grow. Keeps 5 days in the fridge', NULL),
    ('Pak Choi', NULL, 'Pick outer leaves while holding the centre, or cut whole plants at the base, biggest in a clump first. Autumn plants crop until frost; harvest spring ones before they flower. Keeps a few days in the fridge', NULL),
    ('Rocket', 'Salad', 'Once plants touch, pick outer leaves every few days, less often as it cools. The first flush is the most tender. Keeps a few days in the fridge', NULL),
    ('Rocket', 'Wild', 'Pick leaves singly, or cut the whole plant above the tiniest leaves; it regrows in 2-3 weeks. Pick off flower stems to keep it cropping. The first flush in April is the most tender', NULL),
    ('Winter Purslane', NULL, 'Cut bushy plants above the small developing leaves, taking as much stalk as you can. Cut again within 4 weeks. Growth stops in midwinter and restarts in February', NULL),
    ('Wombok', NULL, 'Ready in October, with about 2 weeks before outer leaves decay. Cut before hard frost blows heads open. Tight hearts store a month in a cool shed', NULL),
-- Solanums, basil, and sweetcorn
    ('Basil', NULL, 'Before it flowers, pick 5cm from the top of each plant, then pinch out the tips of new stems every few days. Remove flower stems. Picked stems keep a few days in water, and root quickly', NULL),
    ('Capsicum', NULL, 'Ready when pale, matt fruits turn dark, glossy green; leaving them to colour gives sweeter fruit but a smaller crop. Cut stalks with secateurs. Pick all before the first frost, or move pots under cover. Eat within 2 weeks', NULL),
    ('Chilli', NULL, 'Ready when fruits turn dark, glossy green, or leave them to colour. Snap stalks off with an upward twist, careful of the fragile stems. Pick before the first frost, or move pots under cover. Dry on a sunny windowsill or store in oil', NULL),
    ('Eggplant', NULL, 'Pick while glossy; over-mature fruits turn matt, seedy and fibrous. Snap the stalk upwards or cut it. Keep picking for more fruit. Keeps about a week at room temperature, not in the fridge', NULL),
    ('Potato', 'First Early', 'Ready when the leaves lose their shine and pale; don''t wait for the tops to die. Pull the stems gently and rummage for the rest, even the tiniest. Eat fresh; they don''t store', NULL),
    ('Potato', 'Maincrop', 'Lift once the leaves pale; cut tall blight-resistant varieties back at the end of August. Dry the skins and store in paper sacks somewhere dark and frost-free, checking for rot every few weeks', NULL),
    ('Potato', 'Second Early', 'Lift as for first earlies. Dry the skins for a few hours in the sun, then store in paper sacks somewhere dark and frost-free; they keep until April. Rub off sprouts in late winter', NULL),
    ('Sweetcorn', NULL, 'Ready when the tassels turn brown and kernels inside the sheath are pale yellow-cream. Snap the cob downwards and eat it fresh; the sugar soon turns to starch', NULL),
    ('Tomato', NULL, 'Fully coloured fruits are sweetest; picking half-coloured ones gives bigger yields. Snap the stalk upwards, leaving the calyx on. Ripen at room temperature, never in the fridge. In early October, pick everything left to ripen indoors', NULL),
-- Perennial vegetables
    ('Artichoke', 'Green Globe', 'Cut buds with secateurs at golf-ball size; more buds follow', 'Up to 1m'),
    ('Asparagus', NULL, 'Pick a few spears 2 years after planting crowns (3 from seed), and properly a year later. Snap spears at 15-20cm, close to the soil. Stop after the longest day so the ferns can grow. Best fresh', NULL),
    ('Chives', NULL, 'Cut close to the ground with scissors or a knife, from early spring to late autumn. Regular cutting keeps new growth coming', NULL),
    ('Mint', NULL, 'Pinch out the tips of new shoots from mid-spring. Young leaves for salads, older ones for cooking or tea. Hang cut stems indoors to dry for winter', NULL),
    ('Oregano', 'Hera', 'Pinch off new growth as needed, and harvest often. When you cut it back in midsummer, dry the leaves in the sun', 'Medium-sized bush'),
    ('Perennial Kale', NULL, 'Pick weekly all year, though there is little growth in winter. Push older leaves off at the base of the stalk on each stem', NULL),
    ('Raspberry', NULL, NULL, NULL),
    ('Rhubarb', NULL, 'Wait a year after planting before picking. Pick from March to July, then stop so the leaves feed the roots. Twist and pull each stalk firmly at the base. The leaves are slightly poisonous; compost them', NULL),
    ('Rosemary', NULL, 'Cut 4-6cm from the tips of green, tender stems as needed, all year. A small pick in the first summer', NULL),
    ('Sorrel', NULL, 'Pick once neighbouring plants touch, every few days for small, soft leaves. Leaves pull off easily and keep a week if moist. Cut buckler-leaved sorrel in clusters, removing old leaves and flower stems', NULL),
    ('Strawberry', NULL, NULL, NULL),
    ('Strawberry', 'Baron Solemacher', 'Expect at least two years of fruit before replacing', NULL),
    ('Thyme', NULL, 'Cut new growth from the stem tips. A little goes a long way, so you can pick all year, even though it barely grows in winter', NULL),
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

UPDATE plant_catalogue
SET sowing_windows = '[{"start": "03-15", "end": "04-15", "label": "under cover"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Melon');

UPDATE plant_catalogue
SET harvest_windows = '[{"start": "07-01", "end": "09-30", "label": "under cover"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Cucumber') AND variety = 'Cordon';

UPDATE plant_catalogue SET
    sowing_windows = '[{"start": "04-15", "end": "05-15"}]',
    transplant_windows = '[{"start": "05-15", "end": "06-15"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Pumpkin');

UPDATE plant_catalogue
SET harvest_windows = '[{"start": "03-01", "end": "05-15"}, {"start": "06-01", "end": "12-31"}, {"start": "11-01", "end": "04-30", "label": "under cover"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Chard');

UPDATE plant_catalogue
SET transplant_windows = '[{"start": "03-15", "end": "04-15"}, {"start": "08-15", "end": "09-15"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Spinach');

-- Until 10 September
UPDATE plant_catalogue
SET sowing_windows = '[{"start": "07-15", "end": "09-10"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Chervil');

UPDATE plant_catalogue
SET harvest_windows = '[{"start": "04-15", "end": "11-30"}, {"start": "12-01", "end": "03-15", "label": "under cover"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Coriander');

UPDATE plant_catalogue SET
    sowing_windows = '[{"start": "08-15", "end": "09-15"}]',
    transplant_windows = '[{"start": "09-15", "end": "10-15"}]',
    harvest_windows = '[{"start": "10-15", "end": "04-15"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Corn Salad');

UPDATE plant_catalogue SET
    transplant_windows = '[{"start": "08-01", "end": "08-31"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Wombok');

UPDATE plant_catalogue SET
    transplant_windows = '[{"start": "03-01", "end": "03-15"}, {"start": "08-01", "end": "09-15"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Pak Choi');

UPDATE plant_catalogue SET
    sowing_windows = '[{"start": "08-15", "end": "09-15"}, {"start": "09-01", "end": "09-15", "label": "under cover"}]',
    transplant_windows = '[{"start": "09-01", "end": "10-15"}, {"start": "10-01", "end": "10-15", "label": "under cover"}]',
    harvest_windows = '[{"start": "11-01", "end": "04-30"}, {"start": "11-01", "end": "04-30", "label": "under cover"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Winter Purslane');

UPDATE plant_catalogue SET
    sowing_windows = '[{"start": "04-01", "end": "04-15"}]',
    harvest_windows = '[{"start": "06-15", "end": "07-15"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Potato') AND variety = 'First Early';

UPDATE plant_catalogue SET
    harvest_windows = '[{"start": "08-15", "end": "09-30"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Potato') AND variety = 'Maincrop';

UPDATE plant_catalogue SET
    harvest_windows = '[{"start": "06-15", "end": "10-15", "label": "under cover"}, {"start": "08-01", "end": "09-30"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Tomato');

UPDATE plant_catalogue SET
    sowing_windows = '[{"start": "02-15", "end": "06-15"}]',
    transplant_windows = '[{"start": "04-01", "end": "08-15"}, {"start": "10-01", "end": "11-30"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Sorrel');

UPDATE plant_catalogue SET
    sowing_windows = '[{"start": "04-01", "end": "05-15", "label": "indoors"}, {"start": "04-01", "end": "08-31", "label": "direct"}]',
    transplant_windows = '[{"start": "05-15", "end": "06-15"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Sunflower');

UPDATE plant_catalogue
SET transplant_windows = '[{"start": "05-15", "end": "06-15"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Oregano') AND variety = 'Hera';

-- Notes for these now come from Rebel Gardening too
UPDATE plant_catalogue SET source = 'Bingenheimer, Rebel Gardening'
WHERE (plant_type_id, variety) IN (SELECT id, v FROM plant_types, (VALUES ('Artichoke', 'Green Globe'), ('Oregano', 'Hera')) AS x(n, v) WHERE name = n);

-- Bolt-resistant varieties from mid-February; not later than mid-July, or roots have no time to swell
UPDATE plant_catalogue SET
    sowing_windows = '[{"start": "02-15", "end": "07-15"}]',
    transplant_windows = '[{"start": "04-01", "end": "08-15"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Beetroot');

-- Fixes the impossible 06-31 end date
UPDATE plant_catalogue
SET sowing_windows = '[{"start": "06-01", "end": "06-30"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Cabbage') AND variety = 'Winter';
