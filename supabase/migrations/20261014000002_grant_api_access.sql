GRANT SELECT ON plant_categories, plant_types, plant_catalogue TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON plants TO authenticated;
GRANT SELECT ON plants_with_details, catalogue_with_details TO authenticated;
