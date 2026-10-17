-- Local test account: sign in as test@example.com, the code arrives in Mailpit (http://127.0.0.1:54324)

INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new, email_change
) VALUES (
    '00000000-0000-0000-0000-000000000000', '11111111-1111-1111-1111-111111111111',
    'authenticated', 'authenticated', 'test@example.com', '', NOW(),
    '{"provider": "email", "providers": ["email"]}', '{}', NOW(), NOW(),
    '', '', '', ''
) ON CONFLICT (id) DO NOTHING;

INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
VALUES (
    '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111',
    '{"sub": "11111111-1111-1111-1111-111111111111", "email": "test@example.com", "email_verified": true}',
    'email', NOW(), NOW(), NOW()
) ON CONFLICT (provider_id, provider) DO NOTHING;

-- Dates are day offsets from today, so stages stay the same whenever this runs
DELETE FROM plants WHERE user_id = '11111111-1111-1111-1111-111111111111';

WITH seed (name, cat_variety, custom_variety, year_offset, sow, repot, transplant, harvest, overrides, notes, archived) AS (
    VALUES
    ('Garlic', NULL::text, NULL::text, 0, '{8}'::int[], '{}'::int[], '{}'::int[], '{}'::int[], NULL::jsonb, 'Planned, sow window open, reminder next week', false),
    ('Tomato', NULL, 'Black Krim', 0, '{}', '{}', '{}', '{}', NULL, 'Custom variety, no dates', false),
    ('Basil', NULL, NULL, 0, '{30,60}', '{}', '{}', '{}', NULL, 'Succession sowings, reminders later', false),
    ('Sunflower', NULL, NULL, 0, '{}', '{}', '{}', '{}', NULL, NULL, false),
    ('Lettuce', NULL, NULL, 0, '{-21}', '{}', '{4}', '{}',
        jsonb_build_object('transplant_windows', jsonb_build_array(jsonb_build_object(
            'start', to_char(CURRENT_DATE - 7, 'MM-DD'), 'end', to_char(CURRENT_DATE + 21, 'MM-DD')))),
        'Sown, transplant window open (override), reminder this week', false),
    ('Carrot', 'Maincrop', NULL, 0, '{-130}', '{}', '{}', '{}', NULL, 'Sown, no transplant step', false),
    ('Capsicum', NULL, NULL, 0, '{-240}', '{}', '{-150}', '{}', NULL, NULL, false),
    ('Strawberry', 'Baron Solemacher', NULL, 0, '{-220}', '{-170}', '{}', '{}', NULL, 'Growing via repot', false),
    ('Kale', NULL, NULL, 0, '{-45}', '{}', '{-45}', '{}', NULL, 'Sown and transplanted the same day', false),
    ('Leek', NULL, NULL, 0, '{-190}', '{}', '{-3}', '{}', NULL, 'Transplanted 3 days ago, no longer a reminder', false),
    ('Radish', 'Winter', NULL, 0, '{-90}', '{}', '{-58}', '{5}', NULL, 'Growing, harvest reminder this week', false),
    ('Zucchini', NULL, NULL, 0, '{-180}', '{}', '{-145}', '{-100,-70,-7}', NULL, NULL, false),
    ('Calendula', NULL, NULL, 0, '{-150}', '{}', '{}', '{-20}', NULL, NULL, false),
    ('Peas', NULL, NULL, -1, '{-400}', '{}', '{}', '{-300}', NULL, 'Last season, not archived', false),
    ('Mint', NULL, NULL, NULL, '{}', '{}', '{-500}', '{}', NULL, 'All years', false),
    ('Broad Beans', NULL, NULL, 0, '{-30}', '{}', '{}', '{}', NULL, 'Archived, should not show', true)
)
INSERT INTO plants (
    user_id, plant_type_id, catalogue_id, custom_variety, year,
    sow_dates, repot_dates, transplant_dates, harvest_dates, overrides, notes, archived_at
)
SELECT
    '11111111-1111-1111-1111-111111111111', pt.id, pc.id, s.custom_variety,
    EXTRACT(YEAR FROM CURRENT_DATE)::int + s.year_offset,
    ARRAY(SELECT CURRENT_DATE + o FROM unnest(s.sow) o),
    ARRAY(SELECT CURRENT_DATE + o FROM unnest(s.repot) o),
    ARRAY(SELECT CURRENT_DATE + o FROM unnest(s.transplant) o),
    ARRAY(SELECT CURRENT_DATE + o FROM unnest(s.harvest) o),
    s.overrides, s.notes,
    CASE WHEN s.archived THEN NOW() END
FROM seed s
JOIN plant_types pt ON pt.name = s.name
LEFT JOIN plant_catalogue pc
    ON pc.plant_type_id = pt.id
    AND pc.variety IS NOT DISTINCT FROM s.cat_variety
    AND s.custom_variety IS NULL;
