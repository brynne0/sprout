CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    google_id VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE plant_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE plant_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    category_id INTEGER REFERENCES plant_categories(id)
);

CREATE TABLE plant_catalogue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plant_type_id UUID NOT NULL REFERENCES plant_types(id),
    variety VARCHAR(255),
    description TEXT,
    seed_to_harvest TEXT,
    sowing_to_transplant TEXT,
    position TEXT,
    spacing TEXT,
    hardiness TEXT,
    sowing_windows JSONB,
    harvest_windows JSONB,
    transplant_windows JSONB,
    harvest TEXT,
    suitability JSONB,
    source VARCHAR(255),
    UNIQUE(plant_type_id, variety)
);

CREATE TABLE plants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plant_type_id UUID NOT NULL REFERENCES plant_types(id),
    catalogue_id UUID REFERENCES plant_catalogue(id),
    custom_variety VARCHAR(255),
    sow_dates DATE[] DEFAULT '{}',
    transplant_dates DATE[] DEFAULT '{}',
    overrides JSONB,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
