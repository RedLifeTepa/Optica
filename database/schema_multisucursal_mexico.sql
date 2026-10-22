-- =====================================================================================
-- ESQUEMA RELACIONAL POSTGRESQL MULTI-SUCURSAL PARA ÓPTICA DENS (MÉXICO CFDI 4.0)
-- Preparado para múltiples sucursales, recetas inmutables con versiones y control PWA/IP
-- =====================================================================================

CREATE TABLE branches (
    id VARCHAR(32) PRIMARY KEY,
    code VARCHAR(32) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    city VARCHAR(120) NOT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(40),
    whatsapp VARCHAR(40),
    is_main BOOLEAN DEFAULT FALSE,
    status VARCHAR(40) DEFAULT 'Activa',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE users (
    id VARCHAR(32) PRIMARY KEY,
    branch_id VARCHAR(32) REFERENCES branches(id),
    name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(30) NOT NULL CHECK (role IN ('ADMIN', 'OPTOMETRIST', 'RECEPTION')),
    cedula_profesional VARCHAR(80),
    ai_authorized BOOLEAN DEFAULT FALSE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMPTZ
);

CREATE TABLE customers (
    id VARCHAR(32) PRIMARY KEY,
    branch_id VARCHAR(32) REFERENCES branches(id),
    internal_code VARCHAR(40) UNIQUE NOT NULL,
    customer_code VARCHAR(40) UNIQUE NOT NULL,
    barcode VARCHAR(64) UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(120) NOT NULL,
    birth_date DATE,
    sex VARCHAR(30),
    phone VARCHAR(40) NOT NULL,
    whatsapp VARCHAR(40),
    email VARCHAR(150),
    address TEXT,
    city VARCHAR(100),
    contact_notes TEXT,
    alt_contact TEXT,
    contact_preference VARCHAR(40) DEFAULT 'WhatsApp',
    whatsapp_consent BOOLEAN DEFAULT FALSE,
    whatsapp_consent_date TIMESTAMPTZ,
    whatsapp_reminders_enabled BOOLEAN DEFAULT TRUE,
    rfc VARCHAR(13) DEFAULT 'XAXX010101000',
    legal_name VARCHAR(200),
    fiscal_postal_code VARCHAR(10),
    tax_regime VARCHAR(120),
    cfdi_use VARCHAR(120),
    fiscal_email VARCHAR(150),
    created_at DATE DEFAULT CURRENT_DATE,
    last_visit DATE,
    next_recommended_visit DATE
);

CREATE TABLE prescriptions (
    id VARCHAR(32) PRIMARY KEY,
    consultation_id VARCHAR(32) NOT NULL,
    customer_id VARCHAR(32) REFERENCES customers(id) NOT NULL,
    branch_id VARCHAR(32) REFERENCES branches(id) NOT NULL,
    version INT NOT NULL DEFAULT 1,
    signed BOOLEAN DEFAULT FALSE,
    signed_at TIMESTAMPTZ,
    professional_name VARCHAR(150) NOT NULL,
    od_sphere NUMERIC(5,2),
    od_cylinder NUMERIC(5,2),
    od_axis INT CHECK (od_axis BETWEEN 0 AND 180),
    od_addition NUMERIC(4,2),
    od_prism VARCHAR(30),
    od_base VARCHAR(40),
    od_va VARCHAR(30),
    od_notes TEXT,
    oi_sphere NUMERIC(5,2),
    oi_cylinder NUMERIC(5,2),
    oi_axis INT CHECK (oi_axis BETWEEN 0 AND 180),
    oi_addition NUMERIC(4,2),
    oi_prism VARCHAR(30),
    oi_base VARCHAR(40),
    oi_va VARCHAR(30),
    oi_notes TEXT,
    dp_binocular NUMERIC(5,2),
    dp_right NUMERIC(5,2),
    dp_left NUMERIC(5,2),
    height_right NUMERIC(5,2),
    height_left NUMERIC(5,2),
    vertex_distance NUMERIC(5,2),
    lens_type VARCHAR(150),
    treatment VARCHAR(150),
    material VARCHAR(120),
    tint_filter VARCHAR(120),
    recommended_use TEXT,
    diagnosis TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE prescription_versions_audit (
    id SERIAL PRIMARY KEY,
    prescription_id VARCHAR(32) REFERENCES prescriptions(id) NOT NULL,
    previous_version INT NOT NULL,
    changed_by VARCHAR(150) NOT NULL,
    change_reason TEXT NOT NULL,
    previous_snapshot JSONB NOT NULL,
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE pwa_install_ip_control (
    ip_address VARCHAR(64) PRIMARY KEY,
    device_info VARCHAR(150),
    browser_info VARCHAR(150),
    impressions_count INT NOT NULL DEFAULT 1 CHECK (impressions_count <= 3),
    installed BOOLEAN DEFAULT FALSE,
    rejected_permanently BOOLEAN DEFAULT FALSE,
    last_seen TIMESTAMPTZ DEFAULT NOW(),
    history_log JSONB DEFAULT '[]'::jsonb
);
