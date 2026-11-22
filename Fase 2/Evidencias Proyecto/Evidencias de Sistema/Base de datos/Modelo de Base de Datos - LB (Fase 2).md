# Modelo de base de datos — LifeBetter AIoT (Fase 2)

Modelo actualizado según la base de datos que usa hoy la plataforma (commit `1386911`, 21-11-2026). Reemplaza al modelo de la Fase 1 (`Fase 1/Evidencias Proyecto/Documentos de Diseño/Modelo de base de datos`), que se diseñó en Oracle Data Modeler antes de la implementación.

## Archivos

| Archivo | Contenido |
|---|---|
| `Diagrama Modelo Lógico - LB (Fase 2).png` | Vista general de las 32 entidades. Al centro están Usuario, Condominio y Departamento, de las que dependen casi todas; arriba personal, soporte, convenios y comunidad, y abajo finanzas, reservas, portería, infraestructura y patentes. Muestra las relaciones principales; las de auditoría (por ejemplo `created_by`) y todas las referencias a Usuario y Condominio están en los diagramas relacionales. |
| `Diagrama Modelo Relacional 1 - Núcleo - LB (Fase 2).png` | Núcleo: perfiles de usuario arriba, `users_user` y `condo_condominium` al centro, y tablas de unión y solicitudes de residentes abajo; columnas, tipos, claves (P, F, U) y `*` para las obligatorias. Las tablas punteadas son de otra área y se muestran solo con su `id`. |
| `Diagrama Modelo Relacional 2 - Finanzas - LB (Fase 2).png` | Finanzas: cobros arriba, tablas compartidas al centro y espacios comunes con sus reservas abajo; columnas, tipos, claves (P, F, U) y `*` para las obligatorias. Las tablas punteadas son de otra área y se muestran solo con su `id`. |
| `Diagrama Modelo Relacional 3 - Seguridad - LB (Fase 2).png` | Seguridad: control vehicular arriba, tablas compartidas al centro y portería abajo; columnas, tipos, claves (P, F, U) y `*` para las obligatorias. Las tablas punteadas son de otra área y se muestran solo con su `id`. |
| `Diagrama Modelo Relacional 4 - Comunidad e infraestructura - LB (Fase 2).png` | Comunidad e infraestructura: foro, reclamos y mascotas arriba, tablas compartidas al centro, convenios e infraestructura abajo; columnas, tipos, claves (P, F, U) y `*` para las obligatorias. Las tablas punteadas son de otra área y se muestran solo con su `id`. |
| `Diagrama Modelo Relacional 5 - Mesa de soporte - LB (Fase 2).png` | Mesa de soporte: tickets y mensajes arriba y tablas compartidas abajo; columnas, tipos, claves (P, F, U) y `*` para las obligatorias. Las tablas punteadas son de otra área y se muestran solo con su `id`. |
| `Fuentes de los diagramas/` | Distribución por filas de cada diagrama (`Distribución de los diagramas.json`) y lista de relaciones del modelo lógico (`Modelo Lógico.mmd`). Todos los diagramas se dibujaron con una distribución manual para que las relaciones no se crucen. |
| `Modelo Base de Datos - LB (Fase 2).sql` | Script DDL en sintaxis PostgreSQL: tablas, claves primarias, únicas, foráneas y restricciones. |

## Motor y generación

- Las tablas se crean con las migraciones del ORM de Django (`python manage.py migrate`).
- En desarrollo se usa SQLite; el motor se cambia a PostgreSQL con la variable `DB_ENGINE` (el proyecto incluye `psycopg2`).
- El aislamiento entre condominios se aplica en la capa de aplicación: cada consulta se filtra por los condominios asignados al usuario (`users_user_condominiums`).

## Cambios respecto de la Fase 1

| Tabla en Fase 1 | Tabla actual |
|---|---|
| `condominiums` | `condo_condominium` |
| `departments` | `condo_department` |
| `users` | `users_user` |
| `common_areas` | `espacioscomunes_commonarea` |
| `reservations` | `espacioscomunes_reservation` |
| `concierge_logs` | `security_conciergelogbookentry` |
| `packages` | `security_parceldelivery` |
| `visitor_access_passes` | `security_visitorpassqr` |
| `common_expense_bills` | `expenses_expensebill` |
| `transbank_transactions` | `payments_transbanktransaction` |

En la Fase 1 había 10 tablas. Hoy el proyecto tiene 32 tablas propias. Las nuevas cubren: gastos comunes por período, multas, personal, foro, inspecciones físicas, estacionamientos, mejoras del edificio, vehículos autorizados y lecturas de patentes (LPR), notificaciones, cámaras, reclamos, mascotas, convenios, dispositivos para notificaciones push, la mesa de soporte, las solicitudes de alta y baja de residentes y las alertas del botón de emergencia.

## Tablas del proyecto

Las tablas están agrupadas igual que los diagramas relacionales. En cada área se listan sus relaciones como `tabla.columna → tabla referenciada` (cardinalidad: muchos a uno, salvo que se indique lo contrario).

### Diagrama 1 · Núcleo: usuarios y condominios

En el diagrama, arriba están las tablas que dependen de un usuario (ficha de empleado, notificaciones y dispositivos push), al centro `users_user` y `condo_condominium`, y abajo las que unen a ambos (`users_user_condominiums` y `condo_department`) junto a las solicitudes de alta y baja de residentes (`users_residentrequest`).

**`users_user`** — Usuario

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `password` | VARCHAR(128) |  | Sí |  |
| `last_login` | TIMESTAMP |  | No |  |
| `is_superuser` | BOOLEAN |  | Sí |  |
| `username` | VARCHAR(150) | UK | Sí |  |
| `first_name` | VARCHAR(150) |  | Sí |  |
| `last_name` | VARCHAR(150) |  | Sí |  |
| `is_staff` | BOOLEAN |  | Sí |  |
| `is_active` | BOOLEAN |  | Sí |  |
| `date_joined` | TIMESTAMP |  | Sí |  |
| `email` | VARCHAR(254) | UK | Sí |  |
| `role` | VARCHAR(15) |  | Sí | Valores: ADMIN, CONSERJE, RESIDENTE |
| `phone_number` | VARCHAR(15) |  | No |  |
| `must_change_password` | BOOLEAN |  | Sí |  |

**`users_user_condominiums`** — Relación usuario-condominio

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `user_id` | BIGINT | FK → `users_user` | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |

- Única por (user, condominium)

**`condo_condominium`** — Condominio

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `cover_image_url` | VARCHAR(500) |  | Sí |  |
| `name` | VARCHAR(120) |  | Sí |  |
| `rut` | VARCHAR(20) | UK | Sí |  |
| `address` | VARCHAR(255) |  | Sí |  |
| `city` | VARCHAR(100) |  | Sí |  |
| `total_floors` | SMALLINT |  | Sí |  |
| `applicable_laws` | VARCHAR(255) |  | Sí |  |
| `general_physical_state` | VARCHAR(15) |  | Sí | Valores: OPTIMO, BUENO, REGULAR, CRITICO |
| `is_active` | BOOLEAN |  | Sí |  |
| `created_at` | TIMESTAMP |  | Sí |  |

**`condo_department`** — Departamento

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `number` | VARCHAR(20) |  | Sí |  |
| `floor` | SMALLINT |  | Sí |  |
| `parking_number` | VARCHAR(15) |  | No |  |
| `storage_number` | VARCHAR(15) |  | No |  |
| `resident_id` | BIGINT | FK → `users_user` | No |  |
| `share_percentage` | NUMERIC(7,6) |  | Sí |  |
| `occupancy_status` | VARCHAR(15) |  | Sí | Valores: HABITADO, DESOCUPADO, MANTENCION |
| `tenure_condition` | VARCHAR(15) |  | Sí | Valores: PROPIETARIO, ARRENDADO, INMOBILIARIA |
| `physical_state` | VARCHAR(15) |  | Sí | Valores: OPTIMO, BUENO, REGULAR, CRITICO |
| `physical_notes` | TEXT |  | Sí |  |
| `is_active` | BOOLEAN |  | Sí |  |
| `created_at` | TIMESTAMP |  | Sí |  |

- Única por (condominium, number)

**`users_staffprofile`** — Ficha de Empleado

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `user_id` | BIGINT | FK → `users_user` | Sí |  |
| `rut` | VARCHAR(12) | UK | Sí |  |
| `position` | VARCHAR(20) |  | Sí | Valores: CONSERJE, JARDINERO, ASEO, SEGURIDAD, MANTENCION |
| `shift` | VARCHAR(15) |  | Sí | Valores: MANANA, TARDE, NOCHE, ROTATIVO |
| `balance` | NUMERIC(10,2) |  | Sí |  |
| `logbook_notes` | TEXT |  | No |  |
| `hire_date` | DATE |  | Sí |  |

**`security_notification`** — notification

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `recipient_id` | BIGINT | FK → `users_user` | Sí |  |
| `category` | VARCHAR(20) |  | Sí | Valores: VEHICULO, ENCOMIENDA, GASTO_COMUN, SEGURIDAD, RECLAMO, SOPORTE, RESIDENTES |
| `title` | VARCHAR(140) |  | Sí |  |
| `message` | TEXT |  | Sí |  |
| `action_url` | VARCHAR(255) |  | Sí |  |
| `is_read` | BOOLEAN |  | Sí |  |
| `created_at` | TIMESTAMP |  | Sí |  |

**`mobile_api_pushdevice`** — Dispositivo Push

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `user_id` | BIGINT | FK → `users_user` | Sí |  |
| `token` | VARCHAR(255) | UK | Sí |  |
| `platform` | VARCHAR(10) |  | Sí | Valores: android, ios, other |
| `is_active` | BOOLEAN |  | Sí |  |
| `created_at` | TIMESTAMP |  | Sí |  |
| `last_seen` | TIMESTAMP |  | Sí |  |

**`users_residentrequest`** — Solicitud de alta o baja de residente

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `kind` | VARCHAR(5) |  | Sí | Valores: ALTA, BAJA |
| `status` | VARCHAR(10) |  | Sí | Valores: PENDIENTE, APROBADA, RECHAZADA |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `department_id` | BIGINT | FK → `condo_department` | No |  |
| `resident_id` | BIGINT | FK → `users_user` | No |  |
| `first_name` | VARCHAR(150) |  | Sí |  |
| `last_name` | VARCHAR(150) |  | Sí |  |
| `email` | VARCHAR(254) |  | Sí |  |
| `phone_number` | VARCHAR(20) |  | Sí |  |
| `password_hash` | VARCHAR(128) |  | Sí |  |
| `reason` | TEXT |  | Sí |  |
| `requested_by_id` | BIGINT | FK → `users_user` | No |  |
| `reviewed_by_id` | BIGINT | FK → `users_user` | No |  |
| `review_note` | TEXT |  | Sí |  |
| `reviewed_at` | TIMESTAMP |  | No |  |
| `created_at` | TIMESTAMP |  | Sí |  |

**Relaciones del diagrama**

- `users_user_condominiums.user_id` → `users_user` (muchos a uno)
- `users_user_condominiums.condominium_id` → `condo_condominium` (muchos a uno)
- `condo_department.condominium_id` → `condo_condominium` (muchos a uno)
- `condo_department.resident_id` → `users_user` (muchos a uno, opcional)
- `users_staffprofile.user_id` → `users_user` (uno a uno)
- `security_notification.recipient_id` → `users_user` (muchos a uno)
- `mobile_api_pushdevice.user_id` → `users_user` (muchos a uno)
- `users_residentrequest.condominium_id` → `condo_condominium` (muchos a uno)
- `users_residentrequest.department_id` → `condo_department` (muchos a uno, opcional)
- `users_residentrequest.resident_id` → `users_user` (muchos a uno, opcional)
- `users_residentrequest.requested_by_id` → `users_user` (muchos a uno, opcional)
- `users_residentrequest.reviewed_by_id` → `users_user` (muchos a uno, opcional)

### Diagrama 2 · Finanzas: gastos comunes, multas, pagos y reservas

En el diagrama, arriba están los cobros (transacciones Webpay, boletas, multas y gastos comunes), al centro las tablas compartidas (`users_user`, `condo_department` y `condo_condominium`) y abajo los espacios comunes y sus reservas.

**`expenses_commonexpense`** — Gasto Común Global

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `title` | VARCHAR(200) |  | Sí |  |
| `description` | TEXT |  | No |  |
| `period` | DATE |  | Sí |  |
| `total_amount` | NUMERIC(12,2) |  | Sí |  |
| `is_closed` | BOOLEAN |  | Sí |  |
| `created_at` | TIMESTAMP |  | Sí |  |

**`expenses_expensebill`** — Boleta de Gasto Común

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `department_id` | BIGINT | FK → `condo_department` | Sí |  |
| `common_expense_id` | BIGINT | FK → `expenses_commonexpense` | Sí |  |
| `calculated_amount` | NUMERIC(12,2) |  | Sí |  |
| `due_date` | DATE |  | Sí |  |
| `status` | VARCHAR(10) |  | Sí | Valores: PENDING, PAID, OVERDUE |
| `due_reminder_sent_at` | TIMESTAMP |  | No |  |
| `overdue_notice_sent_at` | TIMESTAMP |  | No |  |
| `created_at` | TIMESTAMP |  | Sí |  |

- Única por (department, common_expense)

**`expenses_condominiumfine`** — Multa de Copropiedad

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `department_id` | BIGINT | FK → `condo_department` | Sí |  |
| `category` | VARCHAR(25) |  | Sí | Valores: RUIDOS_MOLESTOS, ESTACIONAMIENTO, ESPACIOS_COMUNES, MASCOTAS_RESIDUOS, OBRAS_FACHADA, OTRA_REGLAMENTO |
| `regulation_article` | VARCHAR(100) |  | Sí |  |
| `description` | TEXT |  | Sí |  |
| `evidence_reference` | VARCHAR(150) |  | Sí |  |
| `amount_utm` | NUMERIC(6,2) |  | No |  |
| `utm_value` | NUMERIC(9,0) |  | No |  |
| `amount` | NUMERIC(10,0) |  | Sí |  |
| `infraction_date` | DATE |  | Sí |  |
| `status` | VARCHAR(20) |  | Sí | Valores: EMITIDA, APELADA, CONFIRMADA, IMPUTADA_GGCC, ANULADA |
| `issued_by_id` | BIGINT | FK → `users_user` | No |  |
| `appeal_text` | TEXT |  | Sí |  |
| `appealed_at` | TIMESTAMP |  | No |  |
| `resolution_notes` | TEXT |  | Sí |  |
| `resolved_by_id` | BIGINT | FK → `users_user` | No |  |
| `resolved_at` | TIMESTAMP |  | No |  |
| `expense_bill_id` | BIGINT | FK → `expenses_expensebill` | No |  |
| `created_at` | TIMESTAMP |  | Sí |  |
| `updated_at` | TIMESTAMP |  | Sí |  |

**`payments_transbanktransaction`** — Transacción Webpay

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `bill_id` | BIGINT | FK → `expenses_expensebill` | Sí |  |
| `buy_order` | VARCHAR(26) | UK | Sí |  |
| `session_id` | VARCHAR(61) |  | Sí |  |
| `tbk_token` | VARCHAR(255) |  | No |  |
| `amount` | NUMERIC(12,2) |  | Sí |  |
| `status` | VARCHAR(15) |  | Sí | Valores: INITIALIZED, AUTHORIZED, FAILED |
| `authorization_code` | VARCHAR(10) |  | No |  |
| `response_code` | INTEGER |  | No |  |
| `payment_type_code` | VARCHAR(10) |  | No |  |
| `shares_number` | INTEGER |  | Sí |  |
| `created_at` | TIMESTAMP |  | Sí |  |
| `updated_at` | TIMESTAMP |  | Sí |  |

**`espacioscomunes_commonarea`** — Espacio Común

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `name` | VARCHAR(100) |  | Sí |  |
| `description` | TEXT |  | No |  |
| `capacity` | INTEGER |  | Sí |  |
| `fee` | NUMERIC(10,2) |  | Sí |  |
| `is_active` | BOOLEAN |  | Sí |  |

**`espacioscomunes_reservation`** — Reserva

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `common_area_id` | BIGINT | FK → `espacioscomunes_commonarea` | Sí |  |
| `department_id` | BIGINT | FK → `condo_department` | Sí |  |
| `user_id` | BIGINT | FK → `users_user` | Sí |  |
| `start_time` | TIMESTAMP |  | Sí |  |
| `end_time` | TIMESTAMP |  | Sí |  |
| `status` | VARCHAR(10) |  | Sí | Valores: CONFIRMED, CANCELLED |
| `created_at` | TIMESTAMP |  | Sí |  |

- Restricción: la hora de término debe ser posterior a la de inicio

**Relaciones del diagrama**

- `expenses_commonexpense.condominium_id` → `condo_condominium` (muchos a uno)
- `expenses_expensebill.department_id` → `condo_department` (muchos a uno)
- `expenses_expensebill.common_expense_id` → `expenses_commonexpense` (muchos a uno)
- `expenses_condominiumfine.condominium_id` → `condo_condominium` (muchos a uno)
- `expenses_condominiumfine.department_id` → `condo_department` (muchos a uno)
- `expenses_condominiumfine.issued_by_id` → `users_user` (muchos a uno, opcional)
- `expenses_condominiumfine.resolved_by_id` → `users_user` (muchos a uno, opcional)
- `expenses_condominiumfine.expense_bill_id` → `expenses_expensebill` (muchos a uno, opcional)
- `payments_transbanktransaction.bill_id` → `expenses_expensebill` (muchos a uno)
- `espacioscomunes_commonarea.condominium_id` → `condo_condominium` (muchos a uno)
- `espacioscomunes_reservation.common_area_id` → `espacioscomunes_commonarea` (muchos a uno)
- `espacioscomunes_reservation.department_id` → `condo_department` (muchos a uno)
- `espacioscomunes_reservation.user_id` → `users_user` (muchos a uno)

### Diagrama 3 · Seguridad: accesos, patentes, encomiendas y bitácora

En el diagrama, arriba están el control vehicular (vehículos autorizados, lecturas de patentes y estacionamientos), al centro las tablas compartidas (`users_user`, `condo_condominium` y `condo_department`) y abajo la operación de portería (pases QR, encomiendas, bitácora, alertas de emergencia y cámaras).

**`security_authorizedvehicle`** — authorized vehicle

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `department_id` | BIGINT | FK → `condo_department` | Sí |  |
| `owner_id` | BIGINT | FK → `users_user` | No |  |
| `plate` | VARCHAR(10) |  | Sí |  |
| `brand_model` | VARCHAR(80) |  | Sí |  |
| `is_active` | BOOLEAN |  | Sí |  |
| `created_at` | TIMESTAMP |  | Sí |  |

- Única por (condominium, plate)

**`security_platerecognitionlog`** — plate recognition log

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `camera_name` | VARCHAR(60) |  | Sí |  |
| `plate_detected` | VARCHAR(10) |  | Sí |  |
| `confidence` | NUMERIC(5,2) |  | Sí |  |
| `direction` | VARCHAR(10) |  | Sí | Valores: ENTRADA, SALIDA |
| `access_status` | VARCHAR(25) |  | Sí | Valores: AUTORIZADO_RESIDENTE, VISITA_REGISTRADA, NO_AUTORIZADO |
| `matched_vehicle_id` | BIGINT | FK → `security_authorizedvehicle` | No |  |
| `snapshot_url` | VARCHAR(200) |  | Sí |  |
| `snapshot` | VARCHAR(100) |  | Sí |  |
| `source` | VARCHAR(12) |  | Sí | Valores: CAMARA, SIMULADOR, FOTO |
| `parking_spot_id` | BIGINT | FK → `condo_parkingspot` | No |  |
| `parking_action` | VARCHAR(120) |  | Sí |  |
| `detected_at` | TIMESTAMP |  | Sí |  |

**`condo_parkingspot`** — Estacionamiento

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `code` | VARCHAR(15) |  | Sí |  |
| `level` | VARCHAR(30) |  | Sí |  |
| `spot_type` | VARCHAR(15) |  | Sí | Valores: RESIDENTE, VISITA, DISCAPACIDAD |
| `department_id` | BIGINT | FK → `condo_department` | No |  |
| `status` | VARCHAR(15) |  | Sí | Valores: DISPONIBLE, OCUPADO, MANTENCION |
| `current_plate` | VARCHAR(12) |  | Sí |  |
| `occupied_since` | TIMESTAMP |  | No |  |
| `updated_by_id` | BIGINT | FK → `users_user` | No |  |
| `size_category` | VARCHAR(15) |  | Sí | Valores: COMPACTO, ESTANDAR, XL_SUV |
| `layout_type` | VARCHAR(15) |  | Sí | Valores: INDEPENDIENTE, TANDEM, DUPLICADOR |
| `blocking_spot_id` | BIGINT | FK → `condo_parkingspot` | No |  |
| `max_stay_minutes` | SMALLINT |  | Sí |  |

- Única por (condominium, code)

**`security_visitorpassqr`** — visitor pass qr

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `department_id` | BIGINT | FK → `condo_department` | Sí |  |
| `created_by_id` | BIGINT | FK → `users_user` | Sí |  |
| `visitor_name` | VARCHAR(120) |  | Sí |  |
| `visitor_rut` | VARCHAR(15) |  | Sí |  |
| `visitor_plate` | VARCHAR(10) |  | Sí |  |
| `token` | UUID | UK | Sí |  |
| `valid_from` | TIMESTAMP |  | Sí |  |
| `valid_until` | TIMESTAMP |  | Sí |  |
| `status` | VARCHAR(15) |  | Sí | Valores: ACTIVO, UTILIZADO, EXPIRADO, REVOCADO |
| `checked_in_at` | TIMESTAMP |  | No |  |
| `validated_by_id` | BIGINT | FK → `users_user` | No |  |

**`security_parceldelivery`** — Encomienda

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `department_id` | BIGINT | FK → `condo_department` | Sí |  |
| `recipient_name` | VARCHAR(120) |  | Sí |  |
| `courier` | VARCHAR(60) |  | Sí |  |
| `tracking_code` | VARCHAR(80) |  | Sí |  |
| `package_type` | VARCHAR(15) |  | Sí | Valores: CAJA, SOBRE, SUPERMERCADO, MENSAJERIA, OTRO |
| `notes` | VARCHAR(200) |  | Sí |  |
| `status` | VARCHAR(20) |  | Sí | Valores: PENDIENTE_RETIRO, ENTREGADO |
| `received_by_id` | BIGINT | FK → `users_user` | No |  |
| `received_at` | TIMESTAMP |  | Sí |  |
| `delivered_at` | TIMESTAMP |  | No |  |
| `delivered_by_id` | BIGINT | FK → `users_user` | No |  |
| `picked_up_by` | VARCHAR(120) |  | Sí |  |
| `photo` | VARCHAR(100) |  | No |  |

**`security_conciergelogbookentry`** — Registro de Bitácora

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `shift` | VARCHAR(10) |  | Sí | Valores: MANANA, TARDE, NOCHE |
| `category` | VARCHAR(25) |  | Sí | Valores: NOVEDAD_TURNO, RONDA_PERIMETRAL, PROVEEDOR_TECNICO, INCIDENTE_SEGURIDAD, ENTREGA_TURNO |
| `priority` | VARCHAR(10) |  | Sí | Valores: NORMAL, ALTA, CRITICA |
| `title` | VARCHAR(150) |  | Sí |  |
| `detail` | TEXT |  | Sí |  |
| `author_id` | BIGINT | FK → `users_user` | No |  |
| `is_resolved` | BOOLEAN |  | Sí |  |
| `resolved_by_id` | BIGINT | FK → `users_user` | No |  |
| `resolved_at` | TIMESTAMP |  | No |  |
| `created_at` | TIMESTAMP |  | Sí |  |

**`security_emergencyalert`** — Alerta del botón de emergencia

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `kind` | VARCHAR(10) |  | Sí | Valores: INCENDIO, POLICIA |
| `status` | VARCHAR(8) |  | Sí | Valores: ACTIVA, CERRADA |
| `location` | VARCHAR(120) |  | Sí |  |
| `detail` | TEXT |  | Sí |  |
| `triggered_by_id` | BIGINT | FK → `users_user` | No |  |
| `created_at` | TIMESTAMP |  | Sí |  |
| `closed_by_id` | BIGINT | FK → `users_user` | No |  |
| `closed_at` | TIMESTAMP |  | No |  |
| `closing_note` | TEXT |  | Sí |  |
| `notified_count` | INTEGER |  | Sí |  |
| `logbook_entry_id` | BIGINT | FK → `security_conciergelogbookentry` | No |  |

**`security_securitycamera`** — Cámara de Seguridad

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `name` | VARCHAR(80) |  | Sí |  |
| `location` | VARCHAR(20) |  | Sí | Valores: ACCESO, PERIMETRO, ESTACIONAMIENTO, AREA_COMUN, ASCENSOR, OTRO |
| `stream_type` | VARCHAR(10) |  | Sí | Valores: SNAPSHOT, HLS, EMBED, NONE |
| `stream_url` | VARCHAR(500) |  | Sí |  |
| `is_active` | BOOLEAN |  | Sí |  |
| `visible_to_concierge` | BOOLEAN |  | Sí |  |
| `sort_order` | SMALLINT |  | Sí |  |
| `created_at` | TIMESTAMP |  | Sí |  |

**Relaciones del diagrama**

- `security_authorizedvehicle.condominium_id` → `condo_condominium` (muchos a uno)
- `security_authorizedvehicle.department_id` → `condo_department` (muchos a uno)
- `security_authorizedvehicle.owner_id` → `users_user` (muchos a uno, opcional)
- `security_platerecognitionlog.condominium_id` → `condo_condominium` (muchos a uno)
- `security_platerecognitionlog.matched_vehicle_id` → `security_authorizedvehicle` (muchos a uno, opcional)
- `security_platerecognitionlog.parking_spot_id` → `condo_parkingspot` (muchos a uno, opcional)
- `condo_parkingspot.condominium_id` → `condo_condominium` (muchos a uno)
- `condo_parkingspot.department_id` → `condo_department` (muchos a uno, opcional)
- `condo_parkingspot.updated_by_id` → `users_user` (muchos a uno, opcional)
- `condo_parkingspot.blocking_spot_id` → `condo_parkingspot` (muchos a uno, opcional)
- `security_visitorpassqr.condominium_id` → `condo_condominium` (muchos a uno)
- `security_visitorpassqr.department_id` → `condo_department` (muchos a uno)
- `security_visitorpassqr.created_by_id` → `users_user` (muchos a uno)
- `security_visitorpassqr.validated_by_id` → `users_user` (muchos a uno, opcional)
- `security_parceldelivery.condominium_id` → `condo_condominium` (muchos a uno)
- `security_parceldelivery.department_id` → `condo_department` (muchos a uno)
- `security_parceldelivery.received_by_id` → `users_user` (muchos a uno, opcional)
- `security_parceldelivery.delivered_by_id` → `users_user` (muchos a uno, opcional)
- `security_conciergelogbookentry.condominium_id` → `condo_condominium` (muchos a uno)
- `security_conciergelogbookentry.author_id` → `users_user` (muchos a uno, opcional)
- `security_conciergelogbookentry.resolved_by_id` → `users_user` (muchos a uno, opcional)
- `security_emergencyalert.condominium_id` → `condo_condominium` (muchos a uno)
- `security_emergencyalert.triggered_by_id` → `users_user` (muchos a uno, opcional)
- `security_emergencyalert.closed_by_id` → `users_user` (muchos a uno, opcional)
- `security_emergencyalert.logbook_entry_id` → `security_conciergelogbookentry` (uno a uno, opcional)
- `security_securitycamera.condominium_id` → `condo_condominium` (muchos a uno)

### Diagrama 4 · Comunidad e infraestructura

En el diagrama, arriba está la comunidad (foro, reclamos y mascotas), al centro las tablas compartidas (`users_user`, `condo_condominium` y `condo_department`) y abajo los convenios y la infraestructura (inspecciones físicas y mejoras del edificio).

**`users_forumcomment`** — forum comment

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `post_id` | BIGINT | FK → `users_forumpost` | Sí |  |
| `author_id` | BIGINT | FK → `users_user` | Sí |  |
| `content` | TEXT |  | Sí |  |
| `created_at` | TIMESTAMP |  | Sí |  |

**`users_forumpost`** — Publicación del Foro

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `author_id` | BIGINT | FK → `users_user` | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | No |  |
| `category` | VARCHAR(10) |  | Sí | Valores: GENERAL, AVISO, CONSULTA, VENTA, EVENTO, MASCOTAS |
| `title` | VARCHAR(200) |  | Sí |  |
| `content` | TEXT |  | Sí |  |
| `image` | VARCHAR(100) |  | No |  |
| `created_at` | TIMESTAMP |  | Sí |  |
| `updated_at` | TIMESTAMP |  | Sí |  |

**`claims_claimticket`** — Sugerencia / Reclamo

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `department_id` | BIGINT | FK → `condo_department` | Sí |  |
| `author_id` | BIGINT | FK → `users_user` | Sí |  |
| `kind` | VARCHAR(12) |  | Sí | Valores: RECLAMO, SUGERENCIA |
| `category` | VARCHAR(20) |  | Sí | Valores: MANTENCION, ASEO, SEGURIDAD, RUIDOS, ESPACIOS_COMUNES, ADMINISTRACION, OTRO |
| `priority` | VARCHAR(10) |  | Sí | Valores: NORMAL, ALTA, URGENTE |
| `subject` | VARCHAR(150) |  | Sí |  |
| `description` | TEXT |  | Sí |  |
| `photo` | VARCHAR(100) |  | No |  |
| `status` | VARCHAR(12) |  | Sí | Valores: RECIBIDO, EN_GESTION, RESUELTO, RECHAZADO |
| `response` | TEXT |  | Sí |  |
| `responded_by_id` | BIGINT | FK → `users_user` | No |  |
| `responded_at` | TIMESTAMP |  | No |  |
| `created_at` | TIMESTAMP |  | Sí |  |
| `updated_at` | TIMESTAMP |  | Sí |  |

**`pets_pet`** — Mascota

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `department_id` | BIGINT | FK → `condo_department` | Sí |  |
| `owner_id` | BIGINT | FK → `users_user` | Sí |  |
| `name` | VARCHAR(60) |  | Sí |  |
| `species` | VARCHAR(10) |  | Sí | Valores: PERRO, GATO, AVE, ROEDOR, OTRO |
| `breed` | VARCHAR(60) |  | Sí |  |
| `color` | VARCHAR(80) |  | Sí |  |
| `size` | VARCHAR(10) |  | Sí | Valores: PEQUENO, MEDIANO, GRANDE |
| `birth_date` | DATE |  | No |  |
| `microchip` | VARCHAR(30) |  | Sí |  |
| `vaccines_up_to_date` | BOOLEAN |  | Sí |  |
| `is_sterilized` | BOOLEAN |  | Sí |  |
| `photo` | VARCHAR(100) |  | No |  |
| `notes` | VARCHAR(200) |  | Sí |  |
| `is_active` | BOOLEAN |  | Sí |  |
| `created_at` | TIMESTAMP |  | Sí |  |

**`partnerships_partner`** — Alianza / Convenio

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `name` | VARCHAR(100) |  | Sí |  |
| `category` | VARCHAR(15) |  | Sí | Valores: ALIMENTACION, HOGAR, SALUD, MASCOTAS, SERVICIOS, EDUCACION, OTRO |
| `description` | VARCHAR(200) |  | Sí |  |
| `benefit` | VARCHAR(150) |  | Sí |  |
| `discount_code` | VARCHAR(40) |  | Sí |  |
| `conditions` | VARCHAR(200) |  | Sí |  |
| `contact_phone` | VARCHAR(20) |  | Sí |  |
| `website` | VARCHAR(300) |  | Sí |  |
| `address` | VARCHAR(150) |  | Sí |  |
| `valid_until` | DATE |  | No |  |
| `is_active` | BOOLEAN |  | Sí |  |
| `created_by_id` | BIGINT | FK → `users_user` | No |  |
| `created_at` | TIMESTAMP |  | Sí |  |

**`partnerships_partner_condominiums`** — Relación convenio-condominio

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `partner_id` | BIGINT | FK → `partnerships_partner` | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |

- Única por (partner, condominium)

**`condo_physicalinspection`** — Inspección Física

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `department_id` | BIGINT | FK → `condo_department` | No |  |
| `inspector_id` | BIGINT | FK → `users_user` | No |  |
| `condition` | VARCHAR(15) |  | Sí | Valores: OPTIMO, BUENO, REGULAR, CRITICO |
| `summary` | VARCHAR(150) |  | Sí |  |
| `findings` | TEXT |  | Sí |  |
| `requires_action` | BOOLEAN |  | Sí |  |
| `inspected_at` | TIMESTAMP |  | Sí |  |

**`condo_buildingimprovement`** — Plan de Mejora

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | Sí |  |
| `related_inspection_id` | BIGINT | FK → `condo_physicalinspection` | No |  |
| `title` | VARCHAR(150) |  | Sí |  |
| `category` | VARCHAR(20) |  | Sí | Valores: ESTRUCTURAL, SEGURIDAD_AIOT, AREAS_COMUNES, ASCENSORES_REDES, EFICIENCIA |
| `description` | TEXT |  | Sí |  |
| `contractor_name` | VARCHAR(120) |  | Sí |  |
| `estimated_budget` | NUMERIC(12,0) |  | Sí |  |
| `actual_cost` | NUMERIC(12,0) |  | Sí |  |
| `status` | VARCHAR(15) |  | Sí | Valores: PROPUESTA, LICITACION, EN_EJECUCION, COMPLETADA, CANCELADA |
| `progress_percentage` | SMALLINT |  | Sí |  |
| `target_end_date` | DATE |  | No |  |
| `created_by_id` | BIGINT | FK → `users_user` | No |  |
| `created_at` | TIMESTAMP |  | Sí |  |

**Relaciones del diagrama**

- `users_forumcomment.post_id` → `users_forumpost` (muchos a uno)
- `users_forumcomment.author_id` → `users_user` (muchos a uno)
- `users_forumpost.author_id` → `users_user` (muchos a uno)
- `users_forumpost.condominium_id` → `condo_condominium` (muchos a uno, opcional)
- `claims_claimticket.condominium_id` → `condo_condominium` (muchos a uno)
- `claims_claimticket.department_id` → `condo_department` (muchos a uno)
- `claims_claimticket.author_id` → `users_user` (muchos a uno)
- `claims_claimticket.responded_by_id` → `users_user` (muchos a uno, opcional)
- `pets_pet.condominium_id` → `condo_condominium` (muchos a uno)
- `pets_pet.department_id` → `condo_department` (muchos a uno)
- `pets_pet.owner_id` → `users_user` (muchos a uno)
- `partnerships_partner.created_by_id` → `users_user` (muchos a uno, opcional)
- `partnerships_partner_condominiums.partner_id` → `partnerships_partner` (muchos a uno)
- `partnerships_partner_condominiums.condominium_id` → `condo_condominium` (muchos a uno)
- `condo_physicalinspection.condominium_id` → `condo_condominium` (muchos a uno)
- `condo_physicalinspection.department_id` → `condo_department` (muchos a uno, opcional)
- `condo_physicalinspection.inspector_id` → `users_user` (muchos a uno, opcional)
- `condo_buildingimprovement.condominium_id` → `condo_condominium` (muchos a uno)
- `condo_buildingimprovement.related_inspection_id` → `condo_physicalinspection` (muchos a uno, opcional)
- `condo_buildingimprovement.created_by_id` → `users_user` (muchos a uno, opcional)

### Diagrama 5 · Mesa de soporte

En el diagrama, arriba están los tickets y sus mensajes, y abajo las tablas compartidas (`users_user` y `condo_condominium`).

**`soporte_supportticket`** — Ticket de soporte

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `requester_id` | BIGINT | FK → `users_user` | Sí |  |
| `condominium_id` | BIGINT | FK → `condo_condominium` | No |  |
| `category` | VARCHAR(15) |  | Sí | Valores: FALLA, ACCESO, AIOT, APP, PAGOS, DATOS, CAPACITACION, MEJORA |
| `priority` | VARCHAR(10) |  | Sí | Valores: BAJA, MEDIA, ALTA, CRITICA |
| `subject` | VARCHAR(150) |  | Sí |  |
| `description` | TEXT |  | Sí |  |
| `attachment` | VARCHAR(100) |  | No |  |
| `status` | VARCHAR(20) |  | Sí | Valores: ABIERTO, EN_REVISION, ESPERANDO_CLIENTE, RESUELTO, CERRADO |
| `assigned_to_id` | BIGINT | FK → `users_user` | No |  |
| `first_response_at` | TIMESTAMP |  | No |  |
| `resolved_at` | TIMESTAMP |  | No |  |
| `created_at` | TIMESTAMP |  | Sí |  |
| `updated_at` | TIMESTAMP |  | Sí |  |

**`soporte_supportmessage`** — Mensaje de soporte

| Columna | Tipo | Clave | Obligatoria | Observación |
|---|---|---|---|---|
| `id` | BIGINT | PK | Sí |  |
| `ticket_id` | BIGINT | FK → `soporte_supportticket` | Sí |  |
| `author_id` | BIGINT | FK → `users_user` | Sí |  |
| `body` | TEXT |  | Sí |  |
| `is_internal` | BOOLEAN |  | Sí |  |
| `from_support` | BOOLEAN |  | Sí |  |
| `created_at` | TIMESTAMP |  | Sí |  |

**Relaciones del diagrama**

- `soporte_supportticket.requester_id` → `users_user` (muchos a uno)
- `soporte_supportticket.condominium_id` → `condo_condominium` (muchos a uno, opcional)
- `soporte_supportticket.assigned_to_id` → `users_user` (muchos a uno, opcional)
- `soporte_supportmessage.ticket_id` → `soporte_supportticket` (muchos a uno)
- `soporte_supportmessage.author_id` → `users_user` (muchos a uno)

## Tablas que Django crea por defecto

No se detallan en los diagramas porque las genera el framework y no forman parte del diseño del proyecto:

- `auth_group`, `auth_permission` y `auth_group_permissions`: grupos y permisos de Django. El usuario del proyecto (`users_user`) se relaciona con ellas mediante `users_user_groups` y `users_user_user_permissions`.
- `django_content_type`: registro de los modelos instalados, usado por los permisos y el panel de administración.
- `django_session`: sesiones de los usuarios de la web.
- `django_admin_log`: historial de cambios hechos desde el panel Django Admin.
- `django_migrations`: control de las migraciones aplicadas.
