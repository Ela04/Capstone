-- ============================================================================
-- SCRIPT DDL: BASE DE DATOS LIFEBETTER AIoT (POSTGRESQL 14+)
-- PROYECTO: Plataforma Inteligente de Gestión Inmobiliaria y Control de Accesos
-- ASIGNATURA: Capstone (PTY4614) - Duoc UC Sede Plaza Oeste
-- AUTORES: Gabriela Antúnez (Líder Arquitectura y Backend), Ariel Oñate
-- FECHA: Septiembre 2026
-- ARQUITECTURA: Multi-Tenant con Row-Level Security (RLS) y UUIDv4
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. EXTENSIONES DE POSTGRESQL
-- ----------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "citext";

-- ----------------------------------------------------------------------------
-- 2. TIPOS ENUMERADOS (ENUMS)
-- ----------------------------------------------------------------------------
CREATE TYPE rol_usuario_enum AS ENUM (
    'SUPERADMIN',
    'ADMIN',
    'CONSERJE',
    'RESIDENTE'
);

CREATE TYPE tipo_residente_enum AS ENUM (
    'PROPIETARIO',
    'ARRENDATARIO'
);

CREATE TYPE estado_ocupacion_enum AS ENUM (
    'OCUPADO',
    'ARRENDADO',
    'DESOCUPADO'
);

CREATE TYPE estado_gasto_comun_enum AS ENUM (
    'BORRADOR',
    'EMITIDO',
    'CERRADO'
);

CREATE TYPE estado_pago_enum AS ENUM (
    'PENDIENTE',
    'PAGADO',
    'VENCIDO'
);

CREATE TYPE metodo_pago_enum AS ENUM (
    'WEBPAY_PLUS',
    'TRANSFERENCIA',
    'EFECTIVO'
);

CREATE TYPE estado_transaccion_enum AS ENUM (
    'INICIADO',
    'APROBADO',
    'RECHAZADO',
    'ANULADO'
);

CREATE TYPE tipo_acceso_enum AS ENUM (
    'PEATONAL_QR',
    'VEHICULAR_PATENTE'
);

CREATE TYPE resultado_acceso_enum AS ENUM (
    'AUTORIZADO',
    'DENEGADO'
);

CREATE TYPE categoria_bitacora_enum AS ENUM (
    'ENCOMIENDA',
    'INCIDENCIA',
    'RUIDOS_MOLESTOS',
    'ENTREGA_TURNO',
    'MANTENCION',
    'OTRO'
);

CREATE TYPE categoria_foro_enum AS ENUM (
    'INICIATIVA',
    'RECLAMO',
    'SUGERENCIA',
    'AVISO_COMUNIDAD'
);

CREATE TYPE estado_foro_enum AS ENUM (
    'ABIERTO',
    'EN_REVISION',
    'RESUELTO',
    'CERRADO'
);

-- ----------------------------------------------------------------------------
-- 3. TABLAS PRINCIPALES (ESQUEMA MULTI-TENANT)
-- ----------------------------------------------------------------------------

-- 3.1 Comunidades / Condominios (Entidad Tenant Raíz)
CREATE TABLE comunidades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(150) NOT NULL,
    rut VARCHAR(12) NOT NULL UNIQUE,
    direccion VARCHAR(255) NOT NULL,
    comuna VARCHAR(100) NOT NULL,
    total_unidades INTEGER NOT NULL DEFAULT 0 CHECK (total_unidades >= 0),
    saldo_fondo_reserva NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (saldo_fondo_reserva >= 0),
    plan_suscripcion VARCHAR(50) NOT NULL DEFAULT 'AIOT_PREMIUM',
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3.2 Usuarios (Autenticación y Perfiles - Multi-Tenant)
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comunidad_id UUID REFERENCES comunidades(id) ON DELETE CASCADE,
    email CITEXT NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    rut VARCHAR(12) NOT NULL,
    telefono VARCHAR(20),
    rol rol_usuario_enum NOT NULL DEFAULT 'RESIDENTE',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_staff BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3.3 Unidades Habitacionales (Departamentos / Casas)
CREATE TABLE unidades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comunidad_id UUID NOT NULL REFERENCES comunidades(id) ON DELETE CASCADE,
    numero VARCHAR(20) NOT NULL,
    piso INTEGER NOT NULL DEFAULT 1,
    torre VARCHAR(50) DEFAULT 'Torre A',
    porcentaje_alicuota NUMERIC(7, 4) NOT NULL CHECK (porcentaje_alicuota > 0 AND porcentaje_alicuota <= 100),
    estado_ocupacion estado_ocupacion_enum NOT NULL DEFAULT 'OCUPADO',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_comunidad_unidad UNIQUE (comunidad_id, numero, torre)
);

-- 3.4 Asignación de Residentes a Unidades (Relación N:M)
CREATE TABLE unidades_residentes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unidad_id UUID NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    tipo_residente tipo_residente_enum NOT NULL DEFAULT 'PROPIETARIO',
    es_titular BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_unidad_usuario UNIQUE (unidad_id, usuario_id)
);

-- 3.5 Gastos Comunes (Período Mensual de Liquidación del Condominio)
CREATE TABLE gastos_comunes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comunidad_id UUID NOT NULL REFERENCES comunidades(id) ON DELETE CASCADE,
    periodo_mes INTEGER NOT NULL CHECK (periodo_mes BETWEEN 1 AND 12),
    periodo_ano INTEGER NOT NULL CHECK (periodo_ano >= 2024),
    total_egresos_ordinarios NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (total_egresos_ordinarios >= 0),
    total_egresos_extraordinarios NUMERIC(14, 2) NOT NULL DEFAULT 0.00 CHECK (total_egresos_extraordinarios >= 0),
    fondo_reserva_porcentaje NUMERIC(5, 2) NOT NULL DEFAULT 5.00 CHECK (fondo_reserva_porcentaje >= 0),
    estado estado_gasto_comun_enum NOT NULL DEFAULT 'BORRADOR',
    fecha_emision DATE,
    fecha_vencimiento DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_gasto_periodo UNIQUE (comunidad_id, periodo_mes, periodo_ano)
);

-- 3.6 Colillas de Cobro Individuales
CREATE TABLE colillas_cobro (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gasto_comun_id UUID NOT NULL REFERENCES gastos_comunes(id) ON DELETE CASCADE,
    unidad_id UUID NOT NULL REFERENCES unidades(id) ON DELETE RESTRICT,
    monto_alicuota NUMERIC(12, 2) NOT NULL CHECK (monto_alicuota >= 0),
    monto_fondo_reserva NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (monto_fondo_reserva >= 0),
    consumos_individuales NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (consumos_individuales >= 0),
    multas_intereses NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (multas_intereses >= 0),
    saldo_anterior NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    total_a_pagar NUMERIC(12, 2) NOT NULL CHECK (total_a_pagar >= 0),
    estado_pago estado_pago_enum NOT NULL DEFAULT 'PENDIENTE',
    fecha_pago TIMESTAMP WITH TIME ZONE,
    pdf_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_colilla_unidad UNIQUE (gasto_comun_id, unidad_id)
);

-- 3.7 Transacciones y Pagos en Línea (Transbank Webpay Plus)
CREATE TABLE pagos_transacciones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    colilla_id UUID NOT NULL REFERENCES colillas_cobro(id) ON DELETE RESTRICT,
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    token_ws VARCHAR(255) NOT NULL UNIQUE,
    buy_order VARCHAR(50) NOT NULL UNIQUE,
    session_id VARCHAR(100) NOT NULL,
    codigo_autorizacion VARCHAR(50),
    monto NUMERIC(12, 2) NOT NULL CHECK (monto > 0),
    metodo_pago metodo_pago_enum NOT NULL DEFAULT 'WEBPAY_PLUS',
    tipo_tarjeta VARCHAR(20),
    ultimos_digitos VARCHAR(4),
    estado estado_transaccion_enum NOT NULL DEFAULT 'INICIADO',
    transbank_response JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3.8 Visitas (Registro de Personas Externas)
CREATE TABLE visitas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comunidad_id UUID NOT NULL REFERENCES comunidades(id) ON DELETE CASCADE,
    nombre_completo VARCHAR(150) NOT NULL,
    rut VARCHAR(12) NOT NULL,
    telefono VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3.9 Invitaciones Dinámicas con Código QR
CREATE TABLE invitaciones_qr (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comunidad_id UUID NOT NULL REFERENCES comunidades(id) ON DELETE CASCADE,
    residente_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    unidad_id UUID NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
    visita_id UUID REFERENCES visitas(id) ON DELETE SET NULL,
    nombre_invitado VARCHAR(150) NOT NULL,
    rut_invitado VARCHAR(12) NOT NULL,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    qr_data_uri TEXT,
    fecha_inicio TIMESTAMP WITH TIME ZONE NOT NULL,
    fecha_expiracion TIMESTAMP WITH TIME ZONE NOT NULL,
    es_un_solo_uso BOOLEAN NOT NULL DEFAULT TRUE,
    usado BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_rango_fechas CHECK (fecha_expiracion > fecha_inicio)
);

-- 3.10 Vehículos (Residentes y Visitas con Auto)
CREATE TABLE vehiculos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comunidad_id UUID NOT NULL REFERENCES comunidades(id) ON DELETE CASCADE,
    unidad_id UUID REFERENCES unidades(id) ON DELETE SET NULL,
    visita_id UUID REFERENCES visitas(id) ON DELETE SET NULL,
    patente VARCHAR(10) NOT NULL,
    marca VARCHAR(50),
    modelo VARCHAR(50),
    color VARCHAR(30),
    es_residente BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_comunidad_patente UNIQUE (comunidad_id, patente)
);

-- 3.11 Dispositivos de Borde (Cámaras AIoT de Portería)
CREATE TABLE dispositivos_camara (
    id VARCHAR(50) PRIMARY KEY,
    comunidad_id UUID NOT NULL REFERENCES comunidades(id) ON DELETE CASCADE,
    ubicacion VARCHAR(100) NOT NULL,
    ip_address VARCHAR(45),
    resolucion VARCHAR(20) DEFAULT '1920x1080',
    fps INTEGER DEFAULT 30,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3.12 Lecturas de Patentes LPR (Inferencia OCR de Visión Computacional)
CREATE TABLE lecturas_patentes_lpr (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    camara_id VARCHAR(50) REFERENCES dispositivos_camara(id) ON DELETE SET NULL,
    comunidad_id UUID NOT NULL REFERENCES comunidades(id) ON DELETE CASCADE,
    patente_detectada VARCHAR(10) NOT NULL,
    porcentaje_confianza NUMERIC(5, 2) NOT NULL CHECK (porcentaje_confianza >= 0 AND porcentaje_confianza <= 100),
    coincide_padron BOOLEAN NOT NULL DEFAULT FALSE,
    vehiculo_id UUID REFERENCES vehiculos(id) ON DELETE SET NULL,
    unidad_notificada_id UUID REFERENCES unidades(id) ON DELETE SET NULL,
    timestamp_deteccion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fue_notificado BOOLEAN NOT NULL DEFAULT FALSE
);

-- 3.13 Registro de Accesos (Historial Peatonal y Vehicular)
CREATE TABLE accesos_registros (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comunidad_id UUID NOT NULL REFERENCES comunidades(id) ON DELETE CASCADE,
    conserje_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
    invitacion_qr_id UUID REFERENCES invitaciones_qr(id) ON DELETE SET NULL,
    vehiculo_id UUID REFERENCES vehiculos(id) ON DELETE SET NULL,
    tipo_acceso tipo_acceso_enum NOT NULL,
    patente_detectada VARCHAR(10),
    resultado resultado_acceso_enum NOT NULL DEFAULT 'AUTORIZADO',
    observaciones TEXT,
    timestamp_acceso TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3.14 Espacios Comunes / Amenidades
CREATE TABLE amenidades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comunidad_id UUID NOT NULL REFERENCES comunidades(id) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    capacidad_maxima INTEGER NOT NULL DEFAULT 10 CHECK (capacidad_maxima > 0),
    costo_reserva NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (costo_reserva >= 0),
    horario_apertura TIME NOT NULL DEFAULT '09:00:00',
    horario_cierre TIME NOT NULL DEFAULT '22:00:00',
    reglamento TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3.15 Reservas de Amenidades
CREATE TABLE reservas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    amenidad_id UUID NOT NULL REFERENCES amenidades(id) ON DELETE CASCADE,
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    unidad_id UUID NOT NULL REFERENCES unidades(id) ON DELETE CASCADE,
    fecha_reserva DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'CONFIRMADA',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_horas_reserva CHECK (hora_fin > hora_inicio)
);

-- 3.16 Bitácora Digital de Conserjería (Registro Inmutable)
CREATE TABLE bitacora_conserjeria (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comunidad_id UUID NOT NULL REFERENCES comunidades(id) ON DELETE CASCADE,
    conserje_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE RESTRICT,
    unidad_id UUID REFERENCES unidades(id) ON DELETE SET NULL,
    categoria categoria_bitacora_enum NOT NULL DEFAULT 'INCIDENCIA',
    descripcion TEXT NOT NULL,
    es_inmutable BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3.17 Foro Comunitario y Buzón de Reclamos / Sugerencias
CREATE TABLE publicaciones_foro (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comunidad_id UUID NOT NULL REFERENCES comunidades(id) ON DELETE CASCADE,
    autor_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    unidad_id UUID REFERENCES unidades(id) ON DELETE SET NULL,
    titulo VARCHAR(200) NOT NULL,
    contenido TEXT NOT NULL,
    categoria categoria_foro_enum NOT NULL DEFAULT 'INICIATIVA',
    estado estado_foro_enum NOT NULL DEFAULT 'ABIERTO',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 4. ÍNDICES DE RENDIMIENTO (OPTIMIZACIÓN DE CONSULTAS)
-- ----------------------------------------------------------------------------
CREATE INDEX idx_usuarios_comunidad ON usuarios(comunidad_id);
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_unidades_comunidad ON unidades(comunidad_id);
CREATE INDEX idx_gastos_comunidad ON gastos_comunes(comunidad_id);
CREATE INDEX idx_colillas_gasto ON colillas_cobro(gasto_comun_id);
CREATE INDEX idx_colillas_unidad ON colillas_cobro(unidad_id);
CREATE INDEX idx_colillas_estado ON colillas_cobro(estado_pago);
CREATE INDEX idx_pagos_token ON pagos_transacciones(token_ws);
CREATE INDEX idx_pagos_order ON pagos_transacciones(buy_order);
CREATE INDEX idx_invitaciones_hash ON invitaciones_qr(token_hash);
CREATE INDEX idx_vehiculos_patente ON vehiculos(patente);
CREATE INDEX idx_lpr_patente ON lecturas_patentes_lpr(patente_detectada);
CREATE INDEX idx_lpr_comunidad ON lecturas_patentes_lpr(comunidad_id);
CREATE INDEX idx_accesos_timestamp ON accesos_registros(timestamp_acceso);
CREATE INDEX idx_reservas_fecha ON reservas(fecha_reserva, amenidad_id);
CREATE INDEX idx_bitacora_comunidad ON bitacora_conserjeria(comunidad_id);

-- ----------------------------------------------------------------------------
-- 5. POLÍTICAS DE AISLAMIENTO MULTI-TENANT (ROW-LEVEL SECURITY - RLS)
-- ----------------------------------------------------------------------------
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE unidades ENABLE ROW LEVEL SECURITY;
ALTER TABLE gastos_comunes ENABLE ROW LEVEL SECURITY;
ALTER TABLE colillas_cobro ENABLE ROW LEVEL SECURITY;
ALTER TABLE visitas ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitaciones_qr ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehiculos ENABLE ROW LEVEL SECURITY;
ALTER TABLE accesos_registros ENABLE ROW LEVEL SECURITY;
ALTER TABLE amenidades ENABLE ROW LEVEL SECURITY;
ALTER TABLE bitacora_conserjeria ENABLE ROW LEVEL SECURITY;
ALTER TABLE publicaciones_foro ENABLE ROW LEVEL SECURITY;

-- Política ejemplar de aislamiento: Cada usuario solo ve registros de su propio tenant
CREATE POLICY tenant_isolation_unidades ON unidades
    FOR ALL
    USING (comunidad_id = NULLIF(current_setting('app.current_tenant', true), '')::uuid);

CREATE POLICY tenant_isolation_gastos ON gastos_comunes
    FOR ALL
    USING (comunidad_id = NULLIF(current_setting('app.current_tenant', true), '')::uuid);

CREATE POLICY tenant_isolation_invitaciones ON invitaciones_qr
    FOR ALL
    USING (comunidad_id = NULLIF(current_setting('app.current_tenant', true), '')::uuid);

CREATE POLICY tenant_isolation_vehiculos ON vehiculos
    FOR ALL
    USING (comunidad_id = NULLIF(current_setting('app.current_tenant', true), '')::uuid);

CREATE POLICY tenant_isolation_bitacora ON bitacora_conserjeria
    FOR ALL
    USING (comunidad_id = NULLIF(current_setting('app.current_tenant', true), '')::uuid);

-- ----------------------------------------------------------------------------
-- 6. DATOS SEMILLA DE PRUEBA (SEED DATA PARA ENTORNO LOCAL)
-- ----------------------------------------------------------------------------
INSERT INTO comunidades (id, nombre, rut, direccion, comuna, total_unidades, saldo_fondo_reserva, plan_suscripcion)
VALUES ('a0000000-0000-0000-0000-000000000001', 'Edificio Los Aromos', '76.123.456-7', 'Av. Central 1234', 'Maipú', 50, 2500000.00, 'AIOT_PREMIUM');

INSERT INTO usuarios (id, comunidad_id, email, password_hash, nombre, apellido, rut, telefono, rol, is_staff)
VALUES 
('b0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'admin@losaromos.cl', 'pbkdf2_sha256$260000$hash_demo', 'Carlos', 'Valenzuela', '12.345.678-9', '+56911112222', 'ADMIN', TRUE),
('b0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', 'conserje@losaromos.cl', 'pbkdf2_sha256$260000$hash_demo', 'Juan', 'Pérez', '15.987.654-3', '+56933334444', 'CONSERJE', FALSE),
('b0000000-0000-0000-0000-000000000003', 'a0000000-0000-0000-0000-000000000001', 'residente.101@losaromos.cl', 'pbkdf2_sha256$260000$hash_demo', 'Gabriela', 'Antúnez', '18.765.432-1', '+56955556666', 'RESIDENTE', FALSE);

INSERT INTO unidades (id, comunidad_id, numero, piso, torre, porcentaje_alicuota, estado_ocupacion)
VALUES 
('c0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', '101', 1, 'Torre A', 2.0000, 'OCUPADO'),
('c0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000001', '102', 1, 'Torre A', 2.0000, 'OCUPADO');

INSERT INTO unidades_residentes (unidad_id, usuario_id, tipo_residente, es_titular)
VALUES ('c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000003', 'PROPIETARIO', TRUE);

INSERT INTO vehiculos (comunidad_id, unidad_id, patente, marca, modelo, color, es_residente)
VALUES ('a0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'ABCD12', 'Toyota', 'Yaris', 'Blanco', TRUE);

INSERT INTO amenidades (comunidad_id, nombre, descripcion, capacidad_maxima, costo_reserva, horario_apertura, horario_cierre)
VALUES ('a0000000-0000-0000-0000-000000000001', 'Quincho Terraza', 'Parrilla equipada con mesas y vista panorámica', 20, 15000.00, '12:00:00', '23:00:00');

-- FIN DEL SCRIPT DDL
