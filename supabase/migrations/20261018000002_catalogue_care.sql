-- Germination, care, pests and harvest notes from No Dig, plus sowing windows matched to the text.
-- NULLs leave the current value alone, so unfilled rows are safe to run.

-- Per plant type
UPDATE plant_types pt SET
    germination = COALESCE(v.germination, pt.germination),
    care = COALESCE(v.care, pt.care),
    pests = COALESCE(v.pests, pt.pests)
FROM (VALUES
-- Legumes
    ('Broad Beans', 'Sow under cover in 5cm modules', 'Water in dry weather once flowering. Support with two levels of string around posts', 'Net seedlings against birds. Blackfly is worst in May-June on later sowings and dry plants; earlier sowing, watering, and pinching out the tops once the main stem is full of flowers all help, and a hose spray washes them off'),
    ('Climbing Beans', 'One seed per 5cm module, laid flat and covered to twice its thickness; no need to pre-soak', 'Twist stems around canes at first (teepee 90-120cm wide, or a double row of 2.5m sticks). Soak twice a week in dry weather once in full flower', 'Rarely needs protection; wrap mesh around young plants if deer or rabbits bite off the tops. Watering also prevents blackfly on young growth'),
    ('Dwarf French Beans', 'One seed per 3cm module under cover, or 3cm deep outdoors for summer sowings; warmth helps germination', 'Fleece early plantings. Water twice a week in dry weather once flowering; dry roots stop pods setting. No support needed', 'Well-watered plants resist blackfly. Pick often so pods don''t touch the soil, where slugs eat them. Yellow leaves in cool soil are from cold, not hunger, and recover when it warms'),
    ('Peas', '2-3 seeds per 3-5cm module, planted out as a clump; old seed germinates erratically', 'Support all but dwarf varieties from early May with stakes, pea sticks and strings every 15cm. Water regularly once flowering if dry', 'Fleece early plantings against rabbits and pigeons, then bird netting once it comes off. Pea weevil notches on leaf edges are harmless in moist, mulched soil. Pea moth maggots appear in pods from July, so early sowings avoid them. Powdery mildew is mostly a problem on late sowings; Terrain resists it'),
-- Brassicas
    ('Broccoli', 'Sow thinly in a seed tray under cover, lightly covered; prick out into 3-5cm modules within a week. For just a few plants, sow 2 per module and thin', 'Transplant deep, burying the stem. Fleece in spring and mesh in summer for 4-6 weeks after planting; bird netting where there are pigeons. Water until established, then in dry weather as heads form. Snap off yellowing lower leaves', 'Covers keep off flea beetle in spring, caterpillars in summer, and cabbage root fly. Squash caterpillars; expect a few in late calabrese heads. If aphids appear, wash them off, water, and add 3cm of compost'),
    ('Brussels Sprouts', 'Sow thinly in a tray and prick out into 3cm modules, or 2 per module and thin; pot on into 7cm pots after a month', 'Plant deep. Mesh on hoops for 6-8 weeks after planting. Stake and tie in during late summer. Pull off yellowing lower leaves. Water at planting and in dry Septembers', 'Mesh keeps off flea beetle, cabbage root fly, swede midge and caterpillars. Squash caterpillars in late summer, especially in the plant tops. Swap mesh for bird netting on a frame if there are pigeons. Compost and watering keep aphids and whitefly down in autumn and winter'),
    ('Cabbage', 'Always under cover. Sow thinly in a tray to prick out, or 2 per 3-5cm module and thin', 'Plant deep, burying the stem. Fleece in spring and mesh later for the first 6-8 weeks; bird netting where there are pigeons. Water until established, then summer and autumn types in dry weather as hearts form. Remove yellowing lower leaves', 'Covers keep off flea beetle, cabbage root fly, birds and rabbits. Removing yellow leaves also keeps slug numbers down'),
    ('Cauliflower', 'Under cover with warmth (indoors for February sowings). Sow thinly in a tray to prick out, or 2 per module and thin', 'Plant up to 5cm deep. Fleece or mesh from day one, and mesh through summer. Water in dry weather as curds swell. Snap off yellowing outer leaves', 'Spring covers keep off flea beetle and cabbage root fly, and summer mesh keeps off caterpillars. Late-summer plantings crop when few insects are about, but net against pigeons. Squash caterpillars. Removing yellow leaves reduces slugs'),
    ('Kale', '2 seeds per 3cm module and thin, or sow in a tray to prick out; multisow for salad leaves', 'Plant deep. Mesh for at least 6 weeks after planting; bird netting on hoops for pigeons. Water only in very dry weather once established. Remove yellowing lower leaves; stake tall varieties in windy gardens', 'Covers keep off insects, pigeons and rabbits; support netting on hoops so pigeons can''t peck through. Removing yellow leaves reduces slugs'),
    ('Radish', 'Spring: multisow 5 seeds per 3cm module, keeping February sowings warm in the house before moving them to a cold greenhouse. Winter: 2 seeds per module', 'Plant deep to bury the stems. Fleece in March-April, then fine mesh; keep mesh on winter radish until late September. Water spring radish every 2 days in dry weather, winter radish only in a dry early autumn', 'Fine mesh from mid-spring keeps off flea beetle and cabbage root fly'),
    ('Swede', '2 seeds per 4cm module under cover and thin, or sow in a tray and prick out', 'Plant deep, up to the first true leaf. Mesh for the first 6-8 weeks (until mid-August), then bird netting if there are pigeons. Water until established and in a dry early autumn as roots swell. Twist off yellowing lower leaves', 'Mesh keeps off flea beetle, cabbage root fly and swede midge, which eats new leaves and stunts growth. Removing yellow leaves reduces slugs'),
    ('Turnip', 'Multisow 5-6 seeds per 3cm module for clumps of 3-4. Germinate early sowings in the house, then move them to a cold greenhouse', 'Fleece early plantings for at least a month; mesh in late summer and autumn. Water until established, and in dry spells as roots swell', 'Covers keep off flea beetle, pigeons and cabbage root fly, including its second generation in late summer'),
-- Alliums
    ('Bulb Onion and Shallot', 'Multisow 6 seeds per 3cm module, or 6 per cm in outdoor drills to lift and transplant after 5 weeks. Plant sets with the tip about 3cm below the surface', 'Fleece spring plantings to speed growth, mesh later if there are rabbits. Water only if it''s dry as bulbs form in June. Hoe regularly in spring while the leaves are upright', 'Downy mildew browns leaves in a wet late spring, and affected bulbs don''t store long. Check sets are firm with no white mould at the base (onion white rot). Where allium leaf miner is a pest, transplant in May and harvest by August to miss both generations'),
    ('Garlic', 'Plant the biggest cloves, flat base down, tip just below the surface; October is best', 'Little needed beyond weeding. Water in late May-early June if spring is dry. Snap off hardneck scapes before the flowers open; they''re edible', 'Mesh in spring if allium leaf miner or leek moth are about. Mild rust is fine, but if leaves are covered, harvest straight away; garlic under cover gets less. Onion white rot yellows leaves and rots roots: pull affected plants and bin them, don''t compost'),
    ('Leek', 'Multisow 4-5 seeds per module in the second week of April; pot on from 3cm modules into 7cm pots after about 8 weeks', 'Plant with the root ball 3-5cm deep (7cm for whiter stems), water in and don''t backfill. Keep watered in dry weather, especially late summer', 'Allium leaf miner leaves pale lines in leaves; mesh for the plant''s whole life prevents it. Leek moth only shows as stalled growth in late summer; if it''s about, mesh from planting to early September. Mesh also stops rabbits eating seedlings. Remove rust-covered lower leaves in autumn'),
    ('Overwintering Onion', 'Multisow 6 seeds per 3cm module, not before the last week of August', 'Mesh over winter against rabbits (fleece holds too much moisture). Hoe in spring while the leaves are upright', 'Check sets are firm with no white mould at the base'),
    ('Spring Onion', 'Multisow 10 seeds per 3cm module, or 3 seeds per cm in outdoor drills 2.5cm deep', 'Fleece spring plantings, mesh later if there are rabbits. Water in dry weather for better leaves', 'Later sowings get downy mildew in damp August weather'),
-- Cucurbits
    ('Cucumber', 'Sow one seed per 5cm module, laid flat and lightly covered, no more than 4 weeks before the last frost. Needs steady warmth, ideally indoors at night. Pot on to 7cm after 2 weeks, then 10cm. Don''t overwater, as stems damp off', 'Plant 5cm deep after the last frost, even under cover. Cordons: plant on a string, twist the stem around it, remove all sideshoots, and loop the tip back down at the top. Remove fruits until 60cm tall, then every second one. Water twice a week outdoors, every 2-3 days under cover', 'Slugs can damage young ridge plants in cool, wet weather. Under cover, watch for red spider mite and whitefly; the predatory mite Phytoseiulus can be released at planting. Cut off lower leaves with powdery mildew. Under cover, don''t wet leaves on cloudy days, to prevent downy mildew'),
    ('Melon', 'Sow one seed per 3cm module and germinate in the house. Keep above 10°C at night once in the greenhouse. Pot on to 7cm after 3-4 weeks, and 10cm in late April. Water only when pots feel light', 'Plant 5cm deep under cover, on a string for cordons. Twist the stem around the string every 2-3 days. Pinch out sideshoots until 1-1.2m, then let them grow and pinch each tip once a melon forms. In a cool summer keep 3-4 melons and remove new sideshoots. Water moderately, more in heat, less once fruits ripen', 'Hose aphids off in late spring. Slug and woodlice nibbles are minor. Red spider mite is serious if it comes early'),
    ('Pumpkin', 'Sow one seed flat per 5cm module, a month before the last frost. Needs 20-25°C, so keep in the house for the first week. Pot on to 9cm once true leaves grow. Without a greenhouse, sow in late April-early May', 'Plant 5cm deeper than in the pot and water every 2 days in dry weather for a week. Fleece in cold, windy late May. Then little needed: no pruning or thinning, and rotting small fruits are normal. Water once or twice as fruits swell if summer is dry', 'If slugs are bad, check with a torch for a few nights after planting. Powdery mildew in late summer is normal and helps ripening'),
    ('Zucchini', 'Sow one seed per 5cm module or small pot, laid flat and lightly covered, 2-3 weeks before the last frost. Keep above 16°C at night for 5 days. Pot on to 10cm after 15-20 days', 'Plant 5cm deeper than in the pot and water every 2 days for the first week or two. Fleece if it''s cool and windy after planting. Water often in hot, dry weather or it stops fruiting. Feed weekly in containers once fruits form', 'Slugs can damage young plants, but warm-weather plantings grow away quickly. Powdery mildew on older leaves after midsummer is normal; remove them if you like'),
-- Umbellifers
    ('Bulb Fennel', 'Avoid April sowings, which bolt. Sow 2 seeds per 3cm module and thin to the strongest. Keep early sowings in the house for about a week, then under cover and frost-free. Ready to plant in 4-5 weeks', 'Plant with the module tops at least 2cm below ground. Fleece directly over spring plantings; it can stay until early May. Water until growing strongly, and while bulbs swell from late May into early summer', 'Few pests. Spring fleece keeps rabbits off, and slugs can take direct-sown seedlings at the two-leaf stage'),
    ('Carrot', 'Sow direct, never transplant, as it breaks the tap root. Wait for warmer weather. About 3 seeds per cm in drills 1-2cm deep; water the drill first if dry. Mark rows with a radish every 5cm. Thin to 2-3 per cm after about 6 weeks', 'Fleece early sowings to speed growth. Weed carefully while small. Rarely needs water, except in a dry early summer as roots swell; drier soil gives sweeter roots', 'Carrot root fly is active mid-May through June, so swap fleece for mesh on hoops in early May and keep early sowings covered. Summer sowings can stay uncovered from late June, but cover before 10 August for the second generation. Sow away from slug hiding places and don''t leave mature roots in too long'),
    ('Celeriac', 'Needs light to germinate, so don''t cover the seeds. Scatter on wet seed compost, mist, and cover the tray with glass or polythene at 15-20°C in the light; remove the cover when seedlings appear (about 2 weeks). Prick out into 3cm modules after 3-4 weeks. Never let seedlings get cold, or they bolt later', 'Plant the module tops 1cm below the surface and water in. Cover with fleece or mesh for about a month if cool. Water twice more after planting and in hot, dry spells. Removing yellow lower leaves is optional', 'Aphids can stunt plants; the cover after planting keeps them off. Late blight causes brown leaf patches in autumn. Avoid beds with rotting wooden edges, where slugs and woodlice hide'),
    ('Celery', 'Needs light to germinate, so don''t cover the seeds. Sow thinly under cover on wet seed compost, mist, and cover the tray with glass or polythene at 15-20°C in the light; remove the cover at the first leaves (about 2 weeks). Avoid frosty conditions, which cause bolting. Prick out into 3cm modules after about 3 weeks and grow on for about 5 more. A second sowing in late May gives tender celery in September and October', 'Plant after the last frost, root ball tops 1cm below the surface, and water in well. Fleece May plantings if cool. Needs more water than any other vegetable: twice a week if it doesn''t rain. Modern varieties don''t need blanching. Twist off sideshoots from the base; they''re edible', 'Mesh for the first month keeps aphids off. Keep away from slug hiding places. Early blight causes light brown spots in early summer; remove damaged leaves. Late blight browns leaves in damp late summer, especially with nights of 13°C or more; remove affected leaves, harvest promptly and grow resistant varieties for autumn'),
    ('Chervil', 'Germination is erratic: sow in a small tray under cover and prick out into modules at the two-leaf stage, or sow 2-3 seeds per module and thin to one. Plant out small, about a month after sowing', 'Hardy, but only grows new leaves in mild winter weather; grow under cover for bigger winter harvests. Water in a dry autumn or early spring. Fleece laid on top speeds growth in cold weather', 'Few pests. Protect over winter with bird netting, mesh or fleece where there are rabbits'),
    ('Coriander', 'Sow 2 seeds per 3cm module, or direct in rows 20cm apart. For summer leaves, sow every 4-6 weeks from mid-February to early July; sowings from mid-July to mid-September (late July is best) crop through autumn, winter and early spring. Plant out after about 4 weeks', 'Water generously in summer for more leaves and later flowering. Early autumn sowings planted under cover are much more productive over winter', 'Slugs can damage new plantings: remove nearby hiding places and check after dark. Rarely a problem in winter'),
    ('Dill', 'Sow 2-3 seeds per 3cm module, or in a tray to prick out. From April, sow direct one seed every 2.5cm in 1cm drills. Plant out after 3-4 weeks, 3cm below soil level to support the long stems', 'Fleece early spring plantings for the first month to keep them warm', 'Fleece keeps rabbits off spring plantings; use bird netting on hoops in summer'),
    ('Parsley', 'Slow, taking up to 3 weeks to come up. Sow in a seed tray under cover and prick out into modules, or direct in a drill once spring warms. Plant out within 6 weeks, a little below soil level. Early sowings, especially flat-leaf, may flower in summer; summer sowings survive winter and crop into spring', 'Fleece early spring plantings. Grow a plant or two under cover for winter picking. Remove yellowing older leaves', 'Fleece, then bird netting, keeps rabbits off. Extra watering is the best remedy for aphids in spring. Aphids spread a virus that turns overwintered leaves bright yellow in spring; twist out and compost affected plants'),
    ('Parsnip', 'Sow direct, as transplanting breaks the tap root. Choose a still day, as the seeds blow away. 3cm drills, seeds about 1cm apart; water the drill first if dry and tamp down after. Needs moist soil for about 2 weeks to germinate. Mark rows with radishes. Fleece early sowings', 'Thin at the first true leaves: 2.5cm for small, 5cm for medium, 10cm for big roots. Remove fleece before it gets hot, often late April. Weed until the leaves close over, covering your skin as the sap irritates. Rarely needs watering. Leaves rotting in winter is normal', 'Canker rots the shoulders in wet, heavy soil; cut it off after harvest, and later sowings suffer less. Carrot fly damage is usually superficial. Lift and store if rodents chew the crowns'),
-- Beet family
    ('Beetroot', 'Sow under cover. February and March sowings need 5-7 days of warmth in the house, then the greenhouse; use bolt-resistant Boltardy or Pablo before late March. Multisow 3 multigerm or 5 monogerm seeds per 3cm module, aiming for 4 seedlings; thin the weaker ones and eat the thinnings. Not later than mid-July', 'Plant clumps 4-6 weeks after sowing, with most of the stems below the soil. Fleece early plantings for a few weeks, on hoops if nights are frosty. Water 2-3 times after planting, then not for a month or more; a little once roots reach golf-ball size. Dry weather makes roots sweeter', 'Fleece or mesh keeps off birds, rabbits and deer. Leaf miner blotches rarely matter. Harvest straight away if you see rodent teeth marks; the beets are still edible'),
    ('Chard', 'Sow under cover no earlier than mid-April, or plants may bolt. One seed per 3cm module gives 2-3 seedlings: thin to 1-2 for cooking leaves, or multisow 2 for salad. Or sow direct 5cm apart, thinning to 5cm for salad or 15cm for cooking. Ready to plant in 3-4 weeks', 'Plant with the stems below the soil and water in. Keep watered in dry weather. Remove fading outer leaves. Later summer sowings overwinter better', 'Removing old outer leaves reduces slug damage. Net against birds if they strip the leaves'),
    ('Spinach', 'Don''t sow between mid-April and late July, or it bolts. Multisow 2-3 seeds per 3cm module for salad clumps, or one plant for cooking leaves. Plant out after 2-3 weeks in late summer, 4 weeks in spring, 1cm deeper than the root ball. Can also sow direct in late March or August', 'Water until growing strongly (5-7 days), and twice a week in dry spring weather. Fleece or mesh spring plantings; mesh over winter boosts growth in late winter. Remove stalks and yellow leaves as you pick', 'Plant into clear ground away from slug hiding places. Leatherjackets can sever stems of early plantings: dig out the grub and keep spare plants for 2 weeks'),
-- Leafy salad crops
    ('Chicory', 'Don''t sow in spring, or plants flower. Sow thinly in a tray to prick out into 3cm modules, or 2 seeds per module and thin to one. Later sowings give more valuable late-autumn harvests. Plant out after 3 weeks, or pot on into 7cm pots if there''s no space yet', 'Plant 30cm apart with the module top below soil level. Water every couple of days in hot weather until growing strongly. Plants heart up in autumn and grow slowly until early winter. Loose hearts stand frost best; fleece firm hearts for a late winter harvest', 'Few insect pests. Slugs eat seedlings, so raise bigger transplants in 5cm modules or 7cm pots. Keep rabbits off with bird netting or mesh, not fleece, which gets too hot'),
    ('Corn Salad', 'Sow direct in rows 15cm apart, a seed every 1-2cm, thinning to 7-10cm; or 2-3 seeds per 3cm module under cover. Needs constant moisture and takes at least a week to come up. Plant out after 4 weeks, 10cm apart, just below the surface', 'Hardy enough to stand outside all winter; fleece in really cold spells', 'Mostly ignored by pests. Powdery mildew hits August sowings in a dry autumn; keep watered, or sow in early September'),
    ('Endive', 'Germination is variable: sow in a small tray and prick out into 3cm modules, or 2 seeds per module and thin. Or sow direct in rows 25cm apart, 5-10cm between seeds. Plant out after 3 weeks', 'Plant 22cm apart for leaves or 30cm for hearts, root ball top below soil level. Water generously in dry weather. Blanching is optional: cover with a large pot for at most a week before cutting the whole head', 'Slugs do only minor damage and rarely eat frisée. Unlike lettuce, it doesn''t get root aphid. Rabbits and deer love it; bird netting lets more autumn light through than mesh'),
    ('Land Cress', 'Sow in a tray to prick out into 3cm modules, or 2-3 seeds per module and thin to the strongest. Plant out 22cm apart, slightly deeper than the module', 'Water until new growth shows; outdoors it rarely needs more. Under cover, water every 2-3 weeks in winter, weekly if sunny', 'Bird netting or mesh in winter keeps pigeons off. Spring flea beetle damage doesn''t set back established plants. Small slugs hide under leaves but rarely do much harm'),
    ('Lettuce', 'Sow in a tray to prick out into 3cm modules, or 2 seeds per module and thin to one. Seeds need light: scatter perlite or vermiculite on top, or cover with glass. Keep February sowings in the house; shade summer sowings for the first week. For year-round leaves, sow late Feb-early March, late May-early June, mid-July and early September (under cover). Direct sow mid-March to early August for cut-and-come-again. Plant out after 4 weeks (early) or 3 weeks (summer)', 'Plant 22cm apart for leaves or 30cm for hearts, root ball top 1cm below soil. Water at planting and 2 days later, then only in hot weather, a soak every 2-3 days. Water in the morning. Keep winter lettuce under cover fairly dry. Fleece early spring plantings, and keep a few spare transplants', 'From May, mesh or netting keeps rabbits and birds off. Reduce slug habitat nearby; morning watering helps too. Leatherjackets and wireworms cut young plants in spring: rummage under the plant to remove them. Root aphids in late summer make plants wilt suddenly; remove them, and keep soil moist with a compost mulch. Regular picking prevents downy mildew, which gets worse from October in damp weather'),
    ('Mizuna and Mustards', 'Multisow 3 seeds per 3cm module under cover, or direct in drills 20cm apart (mizuna suits cutting as a thick sward). Two plants per module give bigger leaves to pick. Plant out after 2-3 weeks, burying the long stems. Thin direct sowings to 2.5cm for salad or 10cm for big leaves', 'Water the bed before planting if it''s dry, water in, and keep watering in dry weather. Fleece spring plantings', 'Mesh for about 3 weeks after planting (5 after direct sowing). Spring fleece keeps rabbits and pigeons off. Slugs love mizuna; grow mustards in slug-prone spots'),
    ('Pak Choi', 'Always under cover: 3 seeds per 3cm module, or a small tray pricked out within 5 days at the two-leaf stage. Plant out at 2-3 weeks old, burying the spindly stems', 'Water well in dry weather, in the morning so leaves are dry by night. Fleece spring crops. Remove yellow or rotting lower leaves', 'In late summer, mesh on hoops straight after planting keeps off flea beetles, thrips, pigeons and egg-laying butterflies; the first month is critical. Removing yellow leaves and watering in the morning reduce slugs'),
    ('Rocket', 'Sow in 3cm modules under cover; direct-sown seedlings get eaten. Salad rocket: multisow 3 seeds per module. Wild rocket: sow in a tray and prick out singly. Plant salad rocket out after 2-3 weeks, stems below ground. Overwinter wild rocket under cover in 7-9cm pots and plant out very early in spring', 'Water regularly in dry weather. Remove yellowing leaves as you pick. Hardy, but salad rocket barely grows outdoors in winter', 'Fine mesh after planting keeps off flea beetles and pigeons; keep it on wild rocket until it finishes in summer. Late-summer sowings get far less flea beetle damage than spring ones'),
    ('Winter Purslane', 'Sow the tiny seeds in a tray to prick out into 3cm modules, or a few per module thinned to 1-3 seedlings. Barely cover them. Spring sowings flower in April. Plant out after about 4 weeks, 20cm apart', 'Water in, then little needed. Moderate frost browns older leaves. Remove stalks of white male flowers in winter, which taste poor. Remove plants by late April to stop self-seeding', 'Untroubled by pests'),
    ('Wombok', 'Sow in late July; spring sowings bolt. Sow under cover in a tray to prick out, or 2 seeds per 3cm module and thin. Plant out at 15-21 days old, no older', 'Plant 30-35cm apart, module top 5cm below soil. In dry weather water every 2-3 days after planting, then a good soak twice a week unless it rains; less as autumn goes on', 'Fine mesh from planting until harvest, and still remove caterpillars. Gently twist off yellowing outer leaves, holding the centre, to remove slug hiding places and stop leaves rotting by October'),
-- Solanums, basil, and sweetcorn
    ('Basil', 'Sow under cover from April (on a heat mat or indoor windowsill) until June. Roots rot in soggy compost, so mix in up to 60% sand, vermiculite or perlite and water as little as you dare. Multisow 3 seeds per module and thin to 1-2 after 10 days. Or divide supermarket pots into 9cm pots', 'Plant after the last frost, once it''s warm; grows well in containers and under cover. Water twice a week in the ground, daily in containers in summer', 'Slugs eat seedlings, especially if planted out while cool. Green caterpillars do slight damage in high summer. More disease in cool, damp weather'),
    ('Capsicum', 'Sow mid-February to mid-March with warmth, easiest in the house. Sow singly in 3cm modules, or thinly in a tray and prick out at the first true leaf. Pot on about every 3 weeks, into 7cm then 9cm pots', 'Plant 5cm deep after the last frost, once it''s warm. Water only when pots feel light, more as fruits swell, less in late summer. Feed regularly in containers. Once established, support with a loop of string tied to a cane, as stems snap under heavy fruit. From mid-August, pinch out new stems and small flowers so the last fruits ripen', 'Fairly trouble-free. Wash aphids off new growth in spring until predators arrive'),
    ('Chilli', 'Sow mid-February to mid-March with warmth, easiest in the house. Sow singly in 3cm modules, or thinly in a tray and prick out at the first true leaf. Pot on about every 3 weeks, into 7cm then 9cm pots', 'Plant 5cm deep after the last frost, once it''s warm; grows well in 25cm pots. Water sparingly, as lush growth means fewer flowers, and less in late summer. No feeding needed. Tie the main stem to a cane if needed. From mid-August, pinch out new stems and small flowers. To overwinter, cut back by two-thirds, keep frost-free and water very sparingly', 'Fairly trouble-free. Wash aphids off new growth in spring until predators arrive'),
    ('Eggplant', 'Sow under cover by the end of March, thinly in a small tray, and prick out into 3cm modules. Pot on into 7cm pots at about 6 weeks old or 5cm tall', 'Plant mid-May under cover, or outdoors after the last frost, burying the stem 5cm. Don''t overwater young plants; water more once fruits swell. Remove browning lower leaves. Under cover, train as a two-stem cordon on strings: remove sideshoots until 30-35cm tall, keep one strong sideshoot near the top as the second stem, twist stems around the strings, and pinch off the first flower bud. Outdoors, grow as a bush held up by a loop of string tied to a cane', 'Aphids and whitefly, mostly in late spring: hose them off and predators soon follow. Red spider mite: watch for pale, matt undersides on young leaves; wetting leaves under cover helps'),
    ('Potato', 'Chit seed potatoes from late winter in a box on a light windowsill, not in the dark. Supermarket potatoes may be treated not to sprout. Plant with a trowel, shoots up, the top at least 5cm below the surface. Not more than 3 weeks before the last frost unless you can fleece them', 'If a night of 3°C or lower is forecast, pull compost over the leaves or use double fleece. Cover tubers that break the surface with compost so they don''t turn green. Rarely needs watering in spring; in a dry early summer, water generously twice a week for the last 2 weeks before harvest', 'Late blight in warm, wet weather turns leaves grey-brown and limp within days: cut plants at ground level straight away, compost the tops, and wait a few days before harvesting. Scab is rare in no dig beds. Blackleg comes from infected seed: stems blacken and fall over; tubers are still edible, but don''t save them for seed. Slugs chew tubers, so lift promptly and eat damaged ones first. Wireworms in former grassland: bait with half a potato on the surface overnight and remove them'),
    ('Sweetcorn', 'Sow under cover about a month before the last frost, one seed 1cm deep per 3-5cm module; or outdoors 1-2cm deep after the last frost. Sow early and late varieties together for a run of cobs, and choose early ones for cool summers', 'Plant after the last frost, about 4 weeks after sowing, 25-30cm apart in a block to help pollination. Fleece for 2-3 weeks if cold; plants yellow and sit still until the soil warms. Water in, then soak twice a week in dry weather as cobs swell. Sideshoots can stay or go', 'Rodents, badgers and birds take ripening cobs: harvest promptly, even slightly under-ripe. Mice eat the seeds'),
    ('Tomato', 'Sow 6-8 weeks before the last frost (not February) in warmth under cover, thinly in a small tray or one per 3cm module. Prick out at the seed-leaf stage. Pot on into 7cm pots at two true leaves (about 3 weeks), then 9cm after 10-12 days; ready to plant about 10 days later', 'Plant after the last frost, deeper than in the pot; in a damp climate grow at least half under cover. Support cordons with a stake or a string under the root ball, tie or twist the stem in, and snap off sideshoots. Cut off lower leaves from a month after planting. Remove half the first truss and the last flowers on trusses; pinch out the tops in early August. Under cover in soil, water twice a week (every 2 days in heat), on the soil not the leaves from July, and once a week from September. Irregular watering splits fruit. No feeding in no dig soil; feed and water containers daily', 'Blossom end rot (black patches under the fruit) means too little water. Spray aphids off in spring until predators arrive in late May. Leaf roll from day-night temperature swings isn''t serious. Late blight, worst outdoors: remove and compost affected leaves, and remove the whole plant once stems blacken; plants under cover suffer much less. Slugs and woodlice eat fruit lying on the ground'),
-- Perennial vegetables
    ('Artichoke', NULL, NULL, NULL),
    ('Asparagus', NULL, NULL, NULL),
    ('Chives', NULL, NULL, NULL),
    ('Mint', NULL, NULL, NULL),
    ('Oregano', NULL, NULL, NULL),
    ('Perennial Kale', NULL, NULL, NULL),
    ('Raspberry', NULL, NULL, NULL),
    ('Rhubarb', 'Easiest from a pot plant (spring to autumn) or a dormant crown (November-March). From seed, sow in 7cm pots under cover in early spring, pot on into 9cm, and plant out in summer', 'Water in dry spring or summer weather for more stems. Mulch around the crown with compost or rotted manure after the leaves die back in autumn. Cut out flower stems at ground level. If the crown gets too big, remove a section and fill the hole with compost', 'Crowns are remarkably resistant to pests and diseases'),
    ('Rosemary', 'Easiest to buy a pot plant in spring. Or root 10cm cuttings of new growth in early spring, in modules of compost with a third vermiculite; plant out in late spring or pot on into 9cm pots for summer', 'Plant with the root ball top a little below the surface and water in. Cut back the flowered stems over the whole plant in midsummer to keep it compact. New growth can get frost damage in cold springs. Replace after 7-10 years once bare at the base', NULL),
    ('Sorrel', NULL, NULL, NULL),
    ('Strawberry', NULL, NULL, NULL),
    ('Thyme', NULL, NULL, NULL),
-- Flowers
    ('Calendula', NULL, NULL, NULL),
    ('Nasturtium', NULL, NULL, NULL),
    ('Sunflower', NULL, NULL, NULL)
) AS v(name, germination, care, pests)
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
    ('Cucumber', 'Cordon', 'Keep picking, a large fruit every other day; smaller ones are less seedy. Keeps a week in the fridge', NULL),
    ('Cucumber', 'Ridge', 'Keep picking, up to one a day in warm weather. Peel at least half the knobbly skin. Keeps a week in the fridge', NULL),
    ('Melon', NULL, 'Pick when it yellows and smells sweet, or cracks around the stalk. Cut with a short stalk; keeps 2 weeks somewhere cool', NULL),
    ('Pumpkin', NULL, 'Pick before the first frost, once leaves die back, stalks turn brown and the skin sounds hollow when tapped. Keep the stalk intact. Cure on a sunny windowsill for 2 weeks; stores for months somewhere warm and dry', NULL),
    ('Zucchini', NULL, 'Pick the first fruits very small, then before the flower at the tip dies. Cut the stalk for better storage. Flowers are edible. Wear gloves and long sleeves; leaf hairs can cause a rash. Keeps a week in the fridge', NULL),
-- Umbellifers
    ('Bulb Fennel', NULL, 'Pick while plump, before sideshoots appear or the bulb lengthens. Slice under the bulb rather than pulling. The leaves taste of dill. Lift the last autumn bulbs before the first frost; they keep up to a month in a cool shed', NULL),
    ('Carrot', 'Early', 'From about 10 weeks, pull roots whose shoulders show so the rest can swell. Last harvest around late July, before they turn fibrous. Keeps 1-2 weeks if cool', NULL),
    ('Carrot', 'Maincrop', 'Harvest by thinning until early autumn, then lift big roots. Lift to store before nights drop below -5°C: twist off the leaves, leave soil on, and keep in paper sacks in a frost-free shed for 3-5 months', NULL),
    ('Celeriac', NULL, 'Harvest from mid-October as needed until late November, then lift the rest. Cut under the root with a trowel, leaving a few fibrous roots on. Store in an open crate below 10°C; keeps until April', NULL),
    ('Celery', NULL, 'Cut single outer stalks from about 3 months, or whole heads while small to spread the harvest. Ends at the first -2°C frost. Keeps several days in a bag in the fridge or with the stem in water. Use the leaves for stock', NULL),
    ('Chervil', NULL, 'Pick often in autumn, twisting outer leaves off at the base with the whole stalk; leave the small centre leaves to grow. Harvest until late April or early May, when the edible white flowers appear', NULL),
    ('Coriander', NULL, 'Start picking the lower stalks once leaves touch neighbouring plants. Leaves get smaller once it flowers; the first flower stems are edible, and later the seeds', NULL),
    ('Dill', NULL, 'Snap off larger leaves at the base every few days, before it flowers. Flowers and seeds are edible. Long stems keep a week in water', NULL),
    ('Parsley', NULL, 'Twist or cut the largest lower leaves close to the stem; the centre keeps growing for months. Growth is slow in winter', NULL),
    ('Parsnip', NULL, 'Harvest as needed from mid-September to March, finishing before new leaves sprout at the end of winter and make roots fibrous. Lever long roots out with a spade. If the soil is sodden in winter, lift all in early December. Store unwashed, leaves removed, in a box or paper bag in a shed into early spring', NULL),
-- Beet family
    ('Beetroot', NULL, 'Twist out the largest root from each clump so the smaller ones keep growing: 6+ weeks of harvest in summer, 3 months in autumn. Lift the last before nights drop below -4°C; twist off the leaves, leave soil on, and store in a box in a cool, dark shed until early spring. Eat small beets first', NULL),
    ('Chard', NULL, 'Pick salad leaves at 10cm, cooking leaves once plants pass 30cm. Twist outer leaves off at the base and leave the centre; pick every few days in summer. Keeps a week in a bag in the fridge', NULL),
    ('Spinach', NULL, 'Pick small for salad or larger for cooking; leaves get smaller through spring. Once a flower stalk appears, pick for about another week, then remove the plant. Keeps 5 days in a bag in the fridge', NULL),
-- Leafy salad crops
    ('Chicory', NULL, 'Harvest from September (early sowings) to November (later ones), and before March, when leaves turn bitter. Cut under the head and trim off tough outer leaves. If outer leaves rot, cut straight away; a good heart is usually inside. Firm hearts store 4-6 weeks in a box below 10°C', NULL),
    ('Corn Salad', NULL, 'From mid-October, cut whole plants at the base, or cut higher for a smaller second harvest of sideshoots a month later. Little growth over winter, then new leaves in spring before it flowers from mid-April', NULL),
    ('Endive', NULL, 'Twist medium outer leaves off at the base, always leaving the centre rosette. Or let it heart up and cut from late September to mid-November, trimming any rot. Hearts stand 2 weeks or more down to -2°C. Keeps a week in a bag in the fridge', NULL),
    ('Land Cress', NULL, 'Once leaves touch, twist larger leaves from the base or cut a handful, leaving the centre to regrow. Crops through winter until it flowers in late April; flower stalks are edible, but it self-seeds if left. Keeps a few days cool and damp', NULL),
    ('Lettuce', NULL, 'Once leaves touch neighbouring plants, push larger outer leaves off with your thumb at least weekly, leaving the centre. Crops for 10 weeks, or 6 months from autumn sowings. Cut heads when the centre folds in and pales, within about 2 weeks. For cut-and-come-again, cut above the smallest leaf for 2-3 cuts. Keeps a few days in a bag in the fridge', NULL),
    ('Mizuna and Mustards', NULL, 'Pick leaves at the base of the stalk once they''re the size you like, without rocking the plant. Mustards get more pungent with size and age. Take the stalks too, so they don''t rot. Keeps 5 days in a bag in the fridge', NULL),
    ('Pak Choi', NULL, 'Ready once neighbouring leaves nearly touch. Cut outer leaves while holding the centre, or cut whole plants at the base, biggest in a clump first. Autumn plants crop into November until frost; harvest spring plants before they flower. Keeps a few days in the fridge', NULL),
    ('Rocket', 'Salad', 'Once plants touch, pick outer leaves every few days, less often as it cools. The first flush in September is the most tender. Overwintered plants flower in spring. Keeps a few days in the fridge', NULL),
    ('Rocket', 'Wild', 'Pick leaves singly, or cut the whole plant above the tiniest leaves; regrows in 2-3 weeks, weekly in May and June. Pick off flower stems to prolong cropping. The first flush in April is the most tender', NULL),
    ('Winter Purslane', NULL, 'Cut bushy plants above the small developing leaves, taking as much stalk as you can. Cut again within 4 weeks. Growth stops in midwinter and restarts in February', NULL),
    ('Wombok', NULL, 'Usually ready in October, with about 2 weeks before outer leaves decay. Cut before hard frost, which blows heads open. Tight hearts store up to a month in a cool shed; check for slugs first', NULL),
-- Solanums, basil, and sweetcorn
    ('Basil', NULL, 'Before it flowers, pick 5cm from the top of each plant, then pinch out the tips of new stems every few days. Remove flower stems. Picked stems keep a few days in water, and root quickly', NULL),
    ('Capsicum', NULL, 'Ready when pale, matt fruits turn dark, glossy green; waiting up to a month for colour gives sweeter fruit but a smaller crop. Cut stalks with secateurs. Pick before the first frost, or move pots under cover. Colouring fruits keep ripening at room temperature; eat within 2 weeks', NULL),
    ('Chilli', NULL, 'Ready when fruits turn dark, glossy green, or leave them to colour. Snap stalks off with an upward twist, careful of the fragile stems. Pick before the first frost, or move pots under cover. Dry on a sunny windowsill or store in oil', NULL),
    ('Eggplant', NULL, 'Pick while glossy; over-mature fruits turn matt, seedy and fibrous. Snap the stalk upwards or cut it. Keep picking for more fruit. Keeps about a week at room temperature, not in the fridge', NULL),
    ('Potato', 'First Early', 'Ready when the leaves lose their shine and turn pale; don''t wait for the tops to die. Pull the stems gently and rummage for the rest, taking even the tiniest. Best eaten fresh, as they sprout too soon to store', NULL),
    ('Potato', 'Maincrop', 'Lift once the leaves pale; cut tall blight-resistant varieties back at the end of August. Pull and rummage, taking even small ones. Dry the skins, then store in paper sacks somewhere dark and frost-free, checking every few weeks for rot', NULL),
    ('Potato', 'Second Early', 'Ready when the leaves pale; don''t wait for the tops to die. Pull and rummage, taking even the tiniest. Dry the skins for a few hours in the sun or a few days in a shed, then store in paper sacks somewhere dark and frost-free; keeps until April. Rub off sprouts in late winter', NULL),
    ('Sweetcorn', NULL, 'Ready when the tassels turn brown and the kernels inside the sheath are pale yellow-cream. Snap the cob downwards off the stem and eat as fresh as possible, before the sugar turns to starch', NULL),
    ('Tomato', NULL, 'Fully coloured fruits are sweetest; picking half-coloured ones gives higher yields. Snap the stalk upwards, leaving the calyx on; cut beefsteaks with a knife. Ripen at room temperature, away from bananas, never in the fridge. In early October, pick everything left to ripen indoors', NULL),
-- Perennial vegetables
    ('Artichoke', 'Green Globe', NULL, NULL),
    ('Asparagus', NULL, NULL, NULL),
    ('Chives', NULL, NULL, NULL),
    ('Mint', NULL, NULL, NULL),
    ('Oregano', 'Hera', NULL, NULL),
    ('Perennial Kale', NULL, NULL, NULL),
    ('Raspberry', NULL, NULL, NULL),
    ('Rhubarb', NULL, NULL, NULL),
    ('Rosemary', NULL, 'Cut 4-6cm from the tips of green, tender stems as needed, all year. A small pick in the first summer', NULL),
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

-- Bolt-resistant varieties from mid-February; not later than mid-July, or roots have no time to swell
UPDATE plant_catalogue SET
    sowing_windows = '[{"start": "02-15", "end": "07-15"}]',
    transplant_windows = '[{"start": "04-01", "end": "08-15"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Beetroot');

-- Fixes the impossible 06-31 end date
UPDATE plant_catalogue
SET sowing_windows = '[{"start": "06-01", "end": "06-30"}]'
WHERE plant_type_id = (SELECT id FROM plant_types WHERE name = 'Cabbage') AND variety = 'Winter';
