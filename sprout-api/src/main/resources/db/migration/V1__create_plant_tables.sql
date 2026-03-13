CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE plant_catalog (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    variety VARCHAR(255),
    description TEXT,
    sunlight VARCHAR(255),
    temperature VARCHAR(255),
    spacing_cm INT,
    sowing_windows JSONB,
    harvest_windows JSONB,
    transplant_windows JSONB,
    harvest TEXT,
    transplant_time TEXT,
    source VARCHAR(255)
);

CREATE TABLE plants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    catalog_id UUID NOT NULL REFERENCES plant_catalog(id),
    sow_date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);