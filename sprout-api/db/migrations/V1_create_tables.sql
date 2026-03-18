CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    google_id VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE plant_catalogue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category plant_category,
    seed_to_harvest TEXT,
    sowing_to_transplant TEXT,
    position TEXT,
    spacing TEXT,
    hardiness TEXT,
    sowing_windows JSONB,
    harvest_windows JSONB,
    transplant_windows JSONB,
    harvest TEXT,
    source VARCHAR(255)
);

CREATE TABLE plants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    catalogue_id UUID REFERENCES plant_catalogue(id),
    sow_date DATE NOT NULL,
    name_override VARCHAR(255),
    variety VARCHAR(255),
    overrides JSONB,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT plants_must_have_name
        CHECK (catalogue_id IS NOT NULL OR name_override IS NOT NULL)
);

CREATE TYPE plant_category AS ENUM (
    'Legumes - pea and bean family',
    'Brassicas - cabbage family',
    'Alliums - onion family',
    'Cucurbits - cucumber family',
    'Umbellifers - carrot family',
    'Beet family',
    'Leafy salad crops',
    'Solanums, basil, and sweetcorn',
    'Perennial vegetables '
);
