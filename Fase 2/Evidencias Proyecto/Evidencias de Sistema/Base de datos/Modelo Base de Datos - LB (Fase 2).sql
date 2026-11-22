-- Modelo de base de datos de LifeBetter AIoT (Fase 2)
-- Generado desde los modelos de Django del commit 7ba390c (20-11-2026).
-- Motor: SQLite en desarrollo; este script usa la sintaxis de PostgreSQL, motor configurable con DB_ENGINE.
-- Incluye solo las tablas propias del proyecto. Las tablas que Django crea por defecto
-- (auth_*, django_content_type, django_session, django_admin_log y django_migrations) se describen
-- en el documento del modelo y no se detallan aquí.

-- Usuarios, personal y foro: relación user-condominium
CREATE TABLE "users_user_condominiums" (
    "id" BIGSERIAL PRIMARY KEY,
    "user_id" BIGINT NOT NULL,
    "condominium_id" BIGINT NOT NULL,
    CONSTRAINT "uq_users_user_condominiums_user_condominium" UNIQUE ("user_id", "condominium_id")
);

-- Usuarios, personal y foro: Usuario
CREATE TABLE "users_user" (
    "id" BIGSERIAL PRIMARY KEY,
    "password" VARCHAR(128) NOT NULL,
    "last_login" TIMESTAMP,
    "is_superuser" BOOLEAN NOT NULL,
    "username" VARCHAR(150) NOT NULL UNIQUE,
    "first_name" VARCHAR(150) NOT NULL,
    "last_name" VARCHAR(150) NOT NULL,
    "is_staff" BOOLEAN NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "date_joined" TIMESTAMP NOT NULL,
    "email" VARCHAR(254) NOT NULL UNIQUE,
    "role" VARCHAR(15) NOT NULL,
    "phone_number" VARCHAR(15),
    "must_change_password" BOOLEAN NOT NULL
);

-- Usuarios, personal y foro: Publicación del Foro
CREATE TABLE "users_forumpost" (
    "id" BIGSERIAL PRIMARY KEY,
    "author_id" BIGINT NOT NULL,
    "condominium_id" BIGINT,
    "category" VARCHAR(10) NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "content" TEXT NOT NULL,
    "image" VARCHAR(100),
    "created_at" TIMESTAMP NOT NULL,
    "updated_at" TIMESTAMP NOT NULL
);

-- Usuarios, personal y foro: forum comment
CREATE TABLE "users_forumcomment" (
    "id" BIGSERIAL PRIMARY KEY,
    "post_id" BIGINT NOT NULL,
    "author_id" BIGINT NOT NULL,
    "content" TEXT NOT NULL,
    "created_at" TIMESTAMP NOT NULL
);

-- Usuarios, personal y foro: Ficha de Empleado
CREATE TABLE "users_staffprofile" (
    "id" BIGSERIAL PRIMARY KEY,
    "user_id" BIGINT NOT NULL UNIQUE,
    "rut" VARCHAR(12) NOT NULL UNIQUE,
    "position" VARCHAR(20) NOT NULL,
    "shift" VARCHAR(15) NOT NULL,
    "balance" NUMERIC(10,2) NOT NULL,
    "logbook_notes" TEXT,
    "hire_date" DATE NOT NULL
);

-- Usuarios, personal y foro: Solicitud de alta/baja de residente
CREATE TABLE "users_residentrequest" (
    "id" BIGSERIAL PRIMARY KEY,
    "kind" VARCHAR(5) NOT NULL,
    "status" VARCHAR(10) NOT NULL,
    "condominium_id" BIGINT NOT NULL,
    "department_id" BIGINT,
    "resident_id" BIGINT,
    "first_name" VARCHAR(150) NOT NULL,
    "last_name" VARCHAR(150) NOT NULL,
    "email" VARCHAR(254) NOT NULL,
    "phone_number" VARCHAR(20) NOT NULL,
    "password_hash" VARCHAR(128) NOT NULL,
    "reason" TEXT NOT NULL,
    "requested_by_id" BIGINT,
    "reviewed_by_id" BIGINT,
    "review_note" TEXT NOT NULL,
    "reviewed_at" TIMESTAMP,
    "created_at" TIMESTAMP NOT NULL
);

-- Condominios, unidades e infraestructura: Condominio
CREATE TABLE "condo_condominium" (
    "id" BIGSERIAL PRIMARY KEY,
    "cover_image_url" VARCHAR(500) NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "rut" VARCHAR(20) NOT NULL UNIQUE,
    "address" VARCHAR(255) NOT NULL,
    "city" VARCHAR(100) NOT NULL,
    "total_floors" SMALLINT NOT NULL,
    "applicable_laws" VARCHAR(255) NOT NULL,
    "general_physical_state" VARCHAR(15) NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "created_at" TIMESTAMP NOT NULL
);

-- Condominios, unidades e infraestructura: Departamento
CREATE TABLE "condo_department" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "number" VARCHAR(20) NOT NULL,
    "floor" SMALLINT NOT NULL,
    "parking_number" VARCHAR(15),
    "storage_number" VARCHAR(15),
    "resident_id" BIGINT,
    "share_percentage" NUMERIC(7,6) NOT NULL,
    "occupancy_status" VARCHAR(15) NOT NULL,
    "tenure_condition" VARCHAR(15) NOT NULL,
    "physical_state" VARCHAR(15) NOT NULL,
    "physical_notes" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "created_at" TIMESTAMP NOT NULL,
    CONSTRAINT "uq_condo_department_condominium_number" UNIQUE ("condominium_id", "number")
);

-- Condominios, unidades e infraestructura: Inspección Física
CREATE TABLE "condo_physicalinspection" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "department_id" BIGINT,
    "inspector_id" BIGINT,
    "condition" VARCHAR(15) NOT NULL,
    "summary" VARCHAR(150) NOT NULL,
    "findings" TEXT NOT NULL,
    "requires_action" BOOLEAN NOT NULL,
    "inspected_at" TIMESTAMP NOT NULL
);

-- Condominios, unidades e infraestructura: Estacionamiento
CREATE TABLE "condo_parkingspot" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "code" VARCHAR(15) NOT NULL,
    "level" VARCHAR(30) NOT NULL,
    "spot_type" VARCHAR(15) NOT NULL,
    "department_id" BIGINT,
    "status" VARCHAR(15) NOT NULL,
    "current_plate" VARCHAR(12) NOT NULL,
    "occupied_since" TIMESTAMP,
    "updated_by_id" BIGINT,
    "size_category" VARCHAR(15) NOT NULL,
    "layout_type" VARCHAR(15) NOT NULL,
    "blocking_spot_id" BIGINT,
    "max_stay_minutes" SMALLINT NOT NULL,
    CONSTRAINT "uq_condo_parkingspot_condominium_code" UNIQUE ("condominium_id", "code")
);

-- Condominios, unidades e infraestructura: Plan de Mejora
CREATE TABLE "condo_buildingimprovement" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "related_inspection_id" BIGINT,
    "title" VARCHAR(150) NOT NULL,
    "category" VARCHAR(20) NOT NULL,
    "description" TEXT NOT NULL,
    "contractor_name" VARCHAR(120) NOT NULL,
    "estimated_budget" NUMERIC(12,0) NOT NULL,
    "actual_cost" NUMERIC(12,0) NOT NULL,
    "status" VARCHAR(15) NOT NULL,
    "progress_percentage" SMALLINT NOT NULL,
    "target_end_date" DATE,
    "created_by_id" BIGINT,
    "created_at" TIMESTAMP NOT NULL
);

-- Gastos comunes y multas: Gasto Común Global
CREATE TABLE "expenses_commonexpense" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "description" TEXT,
    "period" DATE NOT NULL,
    "total_amount" NUMERIC(12,2) NOT NULL,
    "is_closed" BOOLEAN NOT NULL,
    "created_at" TIMESTAMP NOT NULL
);

-- Gastos comunes y multas: Boleta de Gasto Común
CREATE TABLE "expenses_expensebill" (
    "id" BIGSERIAL PRIMARY KEY,
    "department_id" BIGINT NOT NULL,
    "common_expense_id" BIGINT NOT NULL,
    "calculated_amount" NUMERIC(12,2) NOT NULL,
    "due_date" DATE NOT NULL,
    "status" VARCHAR(10) NOT NULL,
    "due_reminder_sent_at" TIMESTAMP,
    "overdue_notice_sent_at" TIMESTAMP,
    "created_at" TIMESTAMP NOT NULL,
    CONSTRAINT "uq_expenses_expensebill_department_common_expense" UNIQUE ("department_id", "common_expense_id")
);

-- Gastos comunes y multas: Multa de Copropiedad
CREATE TABLE "expenses_condominiumfine" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "department_id" BIGINT NOT NULL,
    "category" VARCHAR(25) NOT NULL,
    "regulation_article" VARCHAR(100) NOT NULL,
    "description" TEXT NOT NULL,
    "evidence_reference" VARCHAR(150) NOT NULL,
    "amount_utm" NUMERIC(6,2),
    "utm_value" NUMERIC(9,0),
    "amount" NUMERIC(10,0) NOT NULL,
    "infraction_date" DATE NOT NULL,
    "status" VARCHAR(20) NOT NULL,
    "issued_by_id" BIGINT,
    "appeal_text" TEXT NOT NULL,
    "appealed_at" TIMESTAMP,
    "resolution_notes" TEXT NOT NULL,
    "resolved_by_id" BIGINT,
    "resolved_at" TIMESTAMP,
    "expense_bill_id" BIGINT,
    "created_at" TIMESTAMP NOT NULL,
    "updated_at" TIMESTAMP NOT NULL
);

-- Pagos Webpay Plus: Transacción Webpay
CREATE TABLE "payments_transbanktransaction" (
    "id" SERIAL PRIMARY KEY,
    "bill_id" BIGINT NOT NULL,
    "buy_order" VARCHAR(26) NOT NULL UNIQUE,
    "session_id" VARCHAR(61) NOT NULL,
    "tbk_token" VARCHAR(255),
    "amount" NUMERIC(12,2) NOT NULL,
    "status" VARCHAR(15) NOT NULL,
    "authorization_code" VARCHAR(10),
    "response_code" INTEGER,
    "payment_type_code" VARCHAR(10),
    "shares_number" INTEGER NOT NULL,
    "created_at" TIMESTAMP NOT NULL,
    "updated_at" TIMESTAMP NOT NULL
);

-- Espacios comunes y reservas: Espacio Común
CREATE TABLE "espacioscomunes_commonarea" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "capacity" INTEGER NOT NULL,
    "fee" NUMERIC(10,2) NOT NULL,
    "is_active" BOOLEAN NOT NULL
);

-- Espacios comunes y reservas: Reserva
CREATE TABLE "espacioscomunes_reservation" (
    "id" BIGSERIAL PRIMARY KEY,
    "common_area_id" BIGINT NOT NULL,
    "department_id" BIGINT NOT NULL,
    "user_id" BIGINT NOT NULL,
    "start_time" TIMESTAMP NOT NULL,
    "end_time" TIMESTAMP NOT NULL,
    "status" VARCHAR(10) NOT NULL,
    "created_at" TIMESTAMP NOT NULL,
    CONSTRAINT "reservation_end_time_after_start_time" CHECK ("end_time" > "start_time")
);

-- Seguridad, accesos y conserjería: authorized vehicle
CREATE TABLE "security_authorizedvehicle" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "department_id" BIGINT NOT NULL,
    "owner_id" BIGINT,
    "plate" VARCHAR(10) NOT NULL,
    "brand_model" VARCHAR(80) NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "created_at" TIMESTAMP NOT NULL,
    CONSTRAINT "uq_security_authorizedvehicle_condominium_plate" UNIQUE ("condominium_id", "plate")
);

-- Seguridad, accesos y conserjería: plate recognition log
CREATE TABLE "security_platerecognitionlog" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "camera_name" VARCHAR(60) NOT NULL,
    "plate_detected" VARCHAR(10) NOT NULL,
    "confidence" NUMERIC(5,2) NOT NULL,
    "direction" VARCHAR(10) NOT NULL,
    "access_status" VARCHAR(25) NOT NULL,
    "matched_vehicle_id" BIGINT,
    "snapshot_url" VARCHAR(200) NOT NULL,
    "snapshot" VARCHAR(100) NOT NULL,
    "source" VARCHAR(12) NOT NULL,
    "parking_spot_id" BIGINT,
    "parking_action" VARCHAR(120) NOT NULL,
    "detected_at" TIMESTAMP NOT NULL
);

-- Seguridad, accesos y conserjería: visitor pass qr
CREATE TABLE "security_visitorpassqr" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "department_id" BIGINT NOT NULL,
    "created_by_id" BIGINT NOT NULL,
    "visitor_name" VARCHAR(120) NOT NULL,
    "visitor_rut" VARCHAR(15) NOT NULL,
    "visitor_plate" VARCHAR(10) NOT NULL,
    "token" UUID NOT NULL UNIQUE,
    "valid_from" TIMESTAMP NOT NULL,
    "valid_until" TIMESTAMP NOT NULL,
    "status" VARCHAR(15) NOT NULL,
    "checked_in_at" TIMESTAMP,
    "validated_by_id" BIGINT
);

-- Seguridad, accesos y conserjería: Encomienda
CREATE TABLE "security_parceldelivery" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "department_id" BIGINT NOT NULL,
    "recipient_name" VARCHAR(120) NOT NULL,
    "courier" VARCHAR(60) NOT NULL,
    "tracking_code" VARCHAR(80) NOT NULL,
    "package_type" VARCHAR(15) NOT NULL,
    "notes" VARCHAR(200) NOT NULL,
    "status" VARCHAR(20) NOT NULL,
    "received_by_id" BIGINT,
    "received_at" TIMESTAMP NOT NULL,
    "delivered_at" TIMESTAMP,
    "delivered_by_id" BIGINT,
    "picked_up_by" VARCHAR(120) NOT NULL,
    "photo" VARCHAR(100)
);

-- Seguridad, accesos y conserjería: Registro de Bitácora
CREATE TABLE "security_conciergelogbookentry" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "shift" VARCHAR(10) NOT NULL,
    "category" VARCHAR(25) NOT NULL,
    "priority" VARCHAR(10) NOT NULL,
    "title" VARCHAR(150) NOT NULL,
    "detail" TEXT NOT NULL,
    "author_id" BIGINT,
    "is_resolved" BOOLEAN NOT NULL,
    "resolved_by_id" BIGINT,
    "resolved_at" TIMESTAMP,
    "created_at" TIMESTAMP NOT NULL
);

-- Seguridad, accesos y conserjería: notification
CREATE TABLE "security_notification" (
    "id" BIGSERIAL PRIMARY KEY,
    "recipient_id" BIGINT NOT NULL,
    "category" VARCHAR(20) NOT NULL,
    "title" VARCHAR(140) NOT NULL,
    "message" TEXT NOT NULL,
    "action_url" VARCHAR(255) NOT NULL,
    "is_read" BOOLEAN NOT NULL,
    "created_at" TIMESTAMP NOT NULL
);

-- Seguridad, accesos y conserjería: Cámara de Seguridad
CREATE TABLE "security_securitycamera" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "name" VARCHAR(80) NOT NULL,
    "location" VARCHAR(20) NOT NULL,
    "stream_type" VARCHAR(10) NOT NULL,
    "stream_url" VARCHAR(500) NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "visible_to_concierge" BOOLEAN NOT NULL,
    "sort_order" SMALLINT NOT NULL,
    "created_at" TIMESTAMP NOT NULL
);

-- Seguridad, accesos y conserjería: Alerta de emergencia
CREATE TABLE "security_emergencyalert" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "kind" VARCHAR(10) NOT NULL,
    "status" VARCHAR(8) NOT NULL,
    "location" VARCHAR(120) NOT NULL,
    "detail" TEXT NOT NULL,
    "triggered_by_id" BIGINT,
    "created_at" TIMESTAMP NOT NULL,
    "closed_by_id" BIGINT,
    "closed_at" TIMESTAMP,
    "closing_note" TEXT NOT NULL,
    "notified_count" INTEGER NOT NULL,
    "logbook_entry_id" BIGINT UNIQUE
);

-- Sugerencias y reclamos: Sugerencia / Reclamo
CREATE TABLE "claims_claimticket" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "department_id" BIGINT NOT NULL,
    "author_id" BIGINT NOT NULL,
    "kind" VARCHAR(12) NOT NULL,
    "category" VARCHAR(20) NOT NULL,
    "priority" VARCHAR(10) NOT NULL,
    "subject" VARCHAR(150) NOT NULL,
    "description" TEXT NOT NULL,
    "photo" VARCHAR(100),
    "status" VARCHAR(12) NOT NULL,
    "response" TEXT NOT NULL,
    "responded_by_id" BIGINT,
    "responded_at" TIMESTAMP,
    "created_at" TIMESTAMP NOT NULL,
    "updated_at" TIMESTAMP NOT NULL
);

-- Mascotas: Mascota
CREATE TABLE "pets_pet" (
    "id" BIGSERIAL PRIMARY KEY,
    "condominium_id" BIGINT NOT NULL,
    "department_id" BIGINT NOT NULL,
    "owner_id" BIGINT NOT NULL,
    "name" VARCHAR(60) NOT NULL,
    "species" VARCHAR(10) NOT NULL,
    "breed" VARCHAR(60) NOT NULL,
    "color" VARCHAR(80) NOT NULL,
    "size" VARCHAR(10) NOT NULL,
    "birth_date" DATE,
    "microchip" VARCHAR(30) NOT NULL,
    "vaccines_up_to_date" BOOLEAN NOT NULL,
    "is_sterilized" BOOLEAN NOT NULL,
    "photo" VARCHAR(100),
    "notes" VARCHAR(200) NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "created_at" TIMESTAMP NOT NULL
);

-- Alianzas y beneficios: relación partner-condominium
CREATE TABLE "partnerships_partner_condominiums" (
    "id" BIGSERIAL PRIMARY KEY,
    "partner_id" BIGINT NOT NULL,
    "condominium_id" BIGINT NOT NULL,
    CONSTRAINT "uq_partnerships_partner_condominiums_partner_condominium" UNIQUE ("partner_id", "condominium_id")
);

-- Alianzas y beneficios: Alianza / Convenio
CREATE TABLE "partnerships_partner" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(100) NOT NULL,
    "category" VARCHAR(15) NOT NULL,
    "description" VARCHAR(200) NOT NULL,
    "benefit" VARCHAR(150) NOT NULL,
    "discount_code" VARCHAR(40) NOT NULL,
    "conditions" VARCHAR(200) NOT NULL,
    "contact_phone" VARCHAR(20) NOT NULL,
    "website" VARCHAR(300) NOT NULL,
    "address" VARCHAR(150) NOT NULL,
    "valid_until" DATE,
    "is_active" BOOLEAN NOT NULL,
    "created_by_id" BIGINT,
    "created_at" TIMESTAMP NOT NULL
);

-- App móvil: Dispositivo Push
CREATE TABLE "mobile_api_pushdevice" (
    "id" BIGSERIAL PRIMARY KEY,
    "user_id" BIGINT NOT NULL,
    "token" VARCHAR(255) NOT NULL UNIQUE,
    "platform" VARCHAR(10) NOT NULL,
    "is_active" BOOLEAN NOT NULL,
    "created_at" TIMESTAMP NOT NULL,
    "last_seen" TIMESTAMP NOT NULL
);

-- Mesa de soporte: Ticket de soporte
CREATE TABLE "soporte_supportticket" (
    "id" BIGSERIAL PRIMARY KEY,
    "requester_id" BIGINT NOT NULL,
    "condominium_id" BIGINT,
    "category" VARCHAR(15) NOT NULL,
    "priority" VARCHAR(10) NOT NULL,
    "subject" VARCHAR(150) NOT NULL,
    "description" TEXT NOT NULL,
    "attachment" VARCHAR(100),
    "status" VARCHAR(20) NOT NULL,
    "assigned_to_id" BIGINT,
    "first_response_at" TIMESTAMP,
    "resolved_at" TIMESTAMP,
    "created_at" TIMESTAMP NOT NULL,
    "updated_at" TIMESTAMP NOT NULL
);

-- Mesa de soporte: Mensaje de soporte
CREATE TABLE "soporte_supportmessage" (
    "id" BIGSERIAL PRIMARY KEY,
    "ticket_id" BIGINT NOT NULL,
    "author_id" BIGINT NOT NULL,
    "body" TEXT NOT NULL,
    "is_internal" BOOLEAN NOT NULL,
    "from_support" BOOLEAN NOT NULL,
    "created_at" TIMESTAMP NOT NULL
);

-- Claves foráneas
ALTER TABLE "users_user_condominiums" ADD CONSTRAINT "fk_users_user_condominiums_user_id" FOREIGN KEY ("user_id") REFERENCES "users_user" ("id");
ALTER TABLE "users_user_condominiums" ADD CONSTRAINT "fk_users_user_condominiums_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "users_forumpost" ADD CONSTRAINT "fk_users_forumpost_author_id" FOREIGN KEY ("author_id") REFERENCES "users_user" ("id");
ALTER TABLE "users_forumpost" ADD CONSTRAINT "fk_users_forumpost_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "users_forumcomment" ADD CONSTRAINT "fk_users_forumcomment_post_id" FOREIGN KEY ("post_id") REFERENCES "users_forumpost" ("id");
ALTER TABLE "users_forumcomment" ADD CONSTRAINT "fk_users_forumcomment_author_id" FOREIGN KEY ("author_id") REFERENCES "users_user" ("id");
ALTER TABLE "users_staffprofile" ADD CONSTRAINT "fk_users_staffprofile_user_id" FOREIGN KEY ("user_id") REFERENCES "users_user" ("id");
ALTER TABLE "users_residentrequest" ADD CONSTRAINT "fk_users_residentrequest_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "users_residentrequest" ADD CONSTRAINT "fk_users_residentrequest_department_id" FOREIGN KEY ("department_id") REFERENCES "condo_department" ("id");
ALTER TABLE "users_residentrequest" ADD CONSTRAINT "fk_users_residentrequest_resident_id" FOREIGN KEY ("resident_id") REFERENCES "users_user" ("id");
ALTER TABLE "users_residentrequest" ADD CONSTRAINT "fk_users_residentrequest_requested_by_id" FOREIGN KEY ("requested_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "users_residentrequest" ADD CONSTRAINT "fk_users_residentrequest_reviewed_by_id" FOREIGN KEY ("reviewed_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "condo_department" ADD CONSTRAINT "fk_condo_department_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "condo_department" ADD CONSTRAINT "fk_condo_department_resident_id" FOREIGN KEY ("resident_id") REFERENCES "users_user" ("id");
ALTER TABLE "condo_physicalinspection" ADD CONSTRAINT "fk_condo_physicalinspection_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "condo_physicalinspection" ADD CONSTRAINT "fk_condo_physicalinspection_department_id" FOREIGN KEY ("department_id") REFERENCES "condo_department" ("id");
ALTER TABLE "condo_physicalinspection" ADD CONSTRAINT "fk_condo_physicalinspection_inspector_id" FOREIGN KEY ("inspector_id") REFERENCES "users_user" ("id");
ALTER TABLE "condo_parkingspot" ADD CONSTRAINT "fk_condo_parkingspot_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "condo_parkingspot" ADD CONSTRAINT "fk_condo_parkingspot_department_id" FOREIGN KEY ("department_id") REFERENCES "condo_department" ("id");
ALTER TABLE "condo_parkingspot" ADD CONSTRAINT "fk_condo_parkingspot_updated_by_id" FOREIGN KEY ("updated_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "condo_parkingspot" ADD CONSTRAINT "fk_condo_parkingspot_blocking_spot_id" FOREIGN KEY ("blocking_spot_id") REFERENCES "condo_parkingspot" ("id");
ALTER TABLE "condo_buildingimprovement" ADD CONSTRAINT "fk_condo_buildingimprovement_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "condo_buildingimprovement" ADD CONSTRAINT "fk_condo_buildingimprovement_related_inspection_id" FOREIGN KEY ("related_inspection_id") REFERENCES "condo_physicalinspection" ("id");
ALTER TABLE "condo_buildingimprovement" ADD CONSTRAINT "fk_condo_buildingimprovement_created_by_id" FOREIGN KEY ("created_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "expenses_commonexpense" ADD CONSTRAINT "fk_expenses_commonexpense_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "expenses_expensebill" ADD CONSTRAINT "fk_expenses_expensebill_department_id" FOREIGN KEY ("department_id") REFERENCES "condo_department" ("id");
ALTER TABLE "expenses_expensebill" ADD CONSTRAINT "fk_expenses_expensebill_common_expense_id" FOREIGN KEY ("common_expense_id") REFERENCES "expenses_commonexpense" ("id");
ALTER TABLE "expenses_condominiumfine" ADD CONSTRAINT "fk_expenses_condominiumfine_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "expenses_condominiumfine" ADD CONSTRAINT "fk_expenses_condominiumfine_department_id" FOREIGN KEY ("department_id") REFERENCES "condo_department" ("id");
ALTER TABLE "expenses_condominiumfine" ADD CONSTRAINT "fk_expenses_condominiumfine_issued_by_id" FOREIGN KEY ("issued_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "expenses_condominiumfine" ADD CONSTRAINT "fk_expenses_condominiumfine_resolved_by_id" FOREIGN KEY ("resolved_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "expenses_condominiumfine" ADD CONSTRAINT "fk_expenses_condominiumfine_expense_bill_id" FOREIGN KEY ("expense_bill_id") REFERENCES "expenses_expensebill" ("id");
ALTER TABLE "payments_transbanktransaction" ADD CONSTRAINT "fk_payments_transbanktransaction_bill_id" FOREIGN KEY ("bill_id") REFERENCES "expenses_expensebill" ("id");
ALTER TABLE "espacioscomunes_commonarea" ADD CONSTRAINT "fk_espacioscomunes_commonarea_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "espacioscomunes_reservation" ADD CONSTRAINT "fk_espacioscomunes_reservation_common_area_id" FOREIGN KEY ("common_area_id") REFERENCES "espacioscomunes_commonarea" ("id");
ALTER TABLE "espacioscomunes_reservation" ADD CONSTRAINT "fk_espacioscomunes_reservation_department_id" FOREIGN KEY ("department_id") REFERENCES "condo_department" ("id");
ALTER TABLE "espacioscomunes_reservation" ADD CONSTRAINT "fk_espacioscomunes_reservation_user_id" FOREIGN KEY ("user_id") REFERENCES "users_user" ("id");
ALTER TABLE "security_authorizedvehicle" ADD CONSTRAINT "fk_security_authorizedvehicle_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "security_authorizedvehicle" ADD CONSTRAINT "fk_security_authorizedvehicle_department_id" FOREIGN KEY ("department_id") REFERENCES "condo_department" ("id");
ALTER TABLE "security_authorizedvehicle" ADD CONSTRAINT "fk_security_authorizedvehicle_owner_id" FOREIGN KEY ("owner_id") REFERENCES "users_user" ("id");
ALTER TABLE "security_platerecognitionlog" ADD CONSTRAINT "fk_security_platerecognitionlog_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "security_platerecognitionlog" ADD CONSTRAINT "fk_security_platerecognitionlog_matched_vehicle_id" FOREIGN KEY ("matched_vehicle_id") REFERENCES "security_authorizedvehicle" ("id");
ALTER TABLE "security_platerecognitionlog" ADD CONSTRAINT "fk_security_platerecognitionlog_parking_spot_id" FOREIGN KEY ("parking_spot_id") REFERENCES "condo_parkingspot" ("id");
ALTER TABLE "security_visitorpassqr" ADD CONSTRAINT "fk_security_visitorpassqr_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "security_visitorpassqr" ADD CONSTRAINT "fk_security_visitorpassqr_department_id" FOREIGN KEY ("department_id") REFERENCES "condo_department" ("id");
ALTER TABLE "security_visitorpassqr" ADD CONSTRAINT "fk_security_visitorpassqr_created_by_id" FOREIGN KEY ("created_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "security_visitorpassqr" ADD CONSTRAINT "fk_security_visitorpassqr_validated_by_id" FOREIGN KEY ("validated_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "security_parceldelivery" ADD CONSTRAINT "fk_security_parceldelivery_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "security_parceldelivery" ADD CONSTRAINT "fk_security_parceldelivery_department_id" FOREIGN KEY ("department_id") REFERENCES "condo_department" ("id");
ALTER TABLE "security_parceldelivery" ADD CONSTRAINT "fk_security_parceldelivery_received_by_id" FOREIGN KEY ("received_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "security_parceldelivery" ADD CONSTRAINT "fk_security_parceldelivery_delivered_by_id" FOREIGN KEY ("delivered_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "security_conciergelogbookentry" ADD CONSTRAINT "fk_security_conciergelogbookentry_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "security_conciergelogbookentry" ADD CONSTRAINT "fk_security_conciergelogbookentry_author_id" FOREIGN KEY ("author_id") REFERENCES "users_user" ("id");
ALTER TABLE "security_conciergelogbookentry" ADD CONSTRAINT "fk_security_conciergelogbookentry_resolved_by_id" FOREIGN KEY ("resolved_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "security_notification" ADD CONSTRAINT "fk_security_notification_recipient_id" FOREIGN KEY ("recipient_id") REFERENCES "users_user" ("id");
ALTER TABLE "security_securitycamera" ADD CONSTRAINT "fk_security_securitycamera_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "security_emergencyalert" ADD CONSTRAINT "fk_security_emergencyalert_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "security_emergencyalert" ADD CONSTRAINT "fk_security_emergencyalert_triggered_by_id" FOREIGN KEY ("triggered_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "security_emergencyalert" ADD CONSTRAINT "fk_security_emergencyalert_closed_by_id" FOREIGN KEY ("closed_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "security_emergencyalert" ADD CONSTRAINT "fk_security_emergencyalert_logbook_entry_id" FOREIGN KEY ("logbook_entry_id") REFERENCES "security_conciergelogbookentry" ("id");
ALTER TABLE "claims_claimticket" ADD CONSTRAINT "fk_claims_claimticket_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "claims_claimticket" ADD CONSTRAINT "fk_claims_claimticket_department_id" FOREIGN KEY ("department_id") REFERENCES "condo_department" ("id");
ALTER TABLE "claims_claimticket" ADD CONSTRAINT "fk_claims_claimticket_author_id" FOREIGN KEY ("author_id") REFERENCES "users_user" ("id");
ALTER TABLE "claims_claimticket" ADD CONSTRAINT "fk_claims_claimticket_responded_by_id" FOREIGN KEY ("responded_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "pets_pet" ADD CONSTRAINT "fk_pets_pet_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "pets_pet" ADD CONSTRAINT "fk_pets_pet_department_id" FOREIGN KEY ("department_id") REFERENCES "condo_department" ("id");
ALTER TABLE "pets_pet" ADD CONSTRAINT "fk_pets_pet_owner_id" FOREIGN KEY ("owner_id") REFERENCES "users_user" ("id");
ALTER TABLE "partnerships_partner_condominiums" ADD CONSTRAINT "fk_partnerships_partner_condominiums_partner_id" FOREIGN KEY ("partner_id") REFERENCES "partnerships_partner" ("id");
ALTER TABLE "partnerships_partner_condominiums" ADD CONSTRAINT "fk_partnerships_partner_condominiums_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "partnerships_partner" ADD CONSTRAINT "fk_partnerships_partner_created_by_id" FOREIGN KEY ("created_by_id") REFERENCES "users_user" ("id");
ALTER TABLE "mobile_api_pushdevice" ADD CONSTRAINT "fk_mobile_api_pushdevice_user_id" FOREIGN KEY ("user_id") REFERENCES "users_user" ("id");
ALTER TABLE "soporte_supportticket" ADD CONSTRAINT "fk_soporte_supportticket_requester_id" FOREIGN KEY ("requester_id") REFERENCES "users_user" ("id");
ALTER TABLE "soporte_supportticket" ADD CONSTRAINT "fk_soporte_supportticket_condominium_id" FOREIGN KEY ("condominium_id") REFERENCES "condo_condominium" ("id");
ALTER TABLE "soporte_supportticket" ADD CONSTRAINT "fk_soporte_supportticket_assigned_to_id" FOREIGN KEY ("assigned_to_id") REFERENCES "users_user" ("id");
ALTER TABLE "soporte_supportmessage" ADD CONSTRAINT "fk_soporte_supportmessage_ticket_id" FOREIGN KEY ("ticket_id") REFERENCES "soporte_supportticket" ("id");
ALTER TABLE "soporte_supportmessage" ADD CONSTRAINT "fk_soporte_supportmessage_author_id" FOREIGN KEY ("author_id") REFERENCES "users_user" ("id");

-- users_user_groups y users_user_user_permissions (relación del usuario con auth_group y auth_permission)
-- son tablas intermedias de Django y no se detallan.
