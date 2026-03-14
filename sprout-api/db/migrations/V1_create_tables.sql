CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    google_id VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE plant_catalog (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
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
    source VARCHAR(255)
);

CREATE TABLE plants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    catalog_id UUID NOT NULL REFERENCES plant_catalog(id),
    sow_date DATE NOT NULL,
    variety VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
