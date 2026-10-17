ALTER TABLE plant_types ADD COLUMN perennial BOOLEAN NOT NULL DEFAULT false;

UPDATE plant_types SET perennial = true
WHERE category_id = (SELECT id FROM plant_categories WHERE name = 'Perennial vegetables');
