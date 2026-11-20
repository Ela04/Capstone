# Evidencias de pruebas — LifeBetter AIoT

Una carpeta por caso de la planilla `Casos_de_Prueba_LifeBetter.xlsx` (CP01 a CP61, 65 casos aprobados).
Las capturas se tomaron sobre el sistema en ejecución en el entorno local (Chrome automatizado con Playwright y llamadas reales a la API), con datos ficticios de `seed_data`. Se guardaron en JPG para reducir el peso del repositorio.
La salida completa de la suite automatizada está en `../Pruebas automatizadas/salida_pytest_commit_7ba390c.txt` (104 passed).

| Caso | Qué se prueba | Archivos |
|---|---|---|
| [CP01](<CP01 - Autenticación - Verificar autenticación exitosa vía A>) | Autenticación - Verificar autenticación exitosa vía A | 2 |
| [CP01-B](<CP01-B - Autenticación - Seguridad - Verificar rechazo de cr>) | Autenticación - Seguridad - Verificar rechazo de cr | 4 |
| [CP01-C](<CP01-C - Autenticación - UI - Verificar validación de campos>) | Autenticación - UI - Verificar validación de campos | 4 |
| [CP01-D](<CP01-D - Seguridad - RBAC - Verificar restricción de acceso>) | Seguridad - RBAC - Verificar restricción de acceso | 3 |
| [CP01-E](<CP01-E - Autenticación - API - Verificar validación de campo>) | Autenticación - API - Verificar validación de campo | 3 |
| [CP02](<CP02 - Seguridad - RBAC Panel - Verificar aislamiento estric>) | Seguridad - RBAC Panel - Verificar aislamiento estric | 4 |
| [CP03](<CP03 - Gestión de Personal (Admin) - Verificar la creación a>) | Gestión de Personal (Admin) - Verificar la creación a | 4 |
| [CP04](<CP04 - Validación - Integridad de Datos - Verificar el recha>) | Validación - Integridad de Datos - Verificar el recha | 2 |
| [CP05](<CP05 - Enrolamiento Residentes (Conserjería) - Verificar el>) | Enrolamiento Residentes (Conserjería) - Verificar el | 5 |
| [CP06](<CP06 - Navegación - Dashboards RBAC - Verificar enrutamiento>) | Navegación - Dashboards RBAC - Verificar enrutamiento | 4 |
| [CP07](<CP07 - Autenticación - Redirección Web - Verificar flujo de>) | Autenticación - Redirección Web - Verificar flujo de | 4 |
| [CP08](<CP08 - Interfaz Gráfica - Sidebar - Verificar contraste visu>) | Interfaz Gráfica - Sidebar - Verificar contraste visu | 6 |
| [CP09](<CP09 - Comunidad - Foro Residente - Verificar listado y deta>) | Comunidad - Foro Residente - Verificar listado y deta | 5 |
| [CP10](<CP10 - Gestión de Usuario - Perfil - Verificar visualización>) | Gestión de Usuario - Perfil - Verificar visualización | 4 |
| [CP11](<CP11 - Condominio - RBAC y Catastro - Verificar control de a>) | Condominio - RBAC y Catastro - Verificar control de a | 5 |
| [CP12](<CP12 - Condominio - Inspección Física - Verificar registro d>) | Condominio - Inspección Física - Verificar registro d | 4 |
| [CP13](<CP13 - Condominio - Estacionamientos - Verificar alternancia>) | Condominio - Estacionamientos - Verificar alternancia | 5 |
| [CP14](<CP14 - Condominio - Mejoras del Edificio - Verificar creació>) | Condominio - Mejoras del Edificio - Verificar creació | 6 |
| [CP15](<CP15 - Espacios Comunes - Amenidades - Verificar CRUD gerenc>) | Espacios Comunes - Amenidades - Verificar CRUD gerenc | 8 |
| [CP16](<CP16 - Seguridad AIoT - LPR Patentes - Verificar webhook de>) | Seguridad AIoT - LPR Patentes - Verificar webhook de | 7 |
| [CP17](<CP17 - Seguridad AIoT - Accesos QR - Verificar ciclo de vida>) | Seguridad AIoT - Accesos QR - Verificar ciclo de vida | 7 |
| [CP18](<CP18 - Gastos Comunes - Prorrateo y PDF - Verificar cálculo>) | Gastos Comunes - Prorrateo y PDF - Verificar cálculo | 9 |
| [CP19](<CP19 - Gastos Comunes - Retrocompatibilidad - Verificar retr>) | Gastos Comunes - Retrocompatibilidad - Verificar retr | 3 |
| [CP20](<CP20 - Seguridad - Encomiendas - Verificar recepción de enco>) | Seguridad - Encomiendas - Verificar recepción de enco | 7 |
| [CP21](<CP21 - Seguridad - Bitácora - Verificar registro de novedade>) | Seguridad - Bitácora - Verificar registro de novedade | 5 |
| [CP22](<CP22 - Condominio - Estacionamientos - Verificar plano cenit>) | Condominio - Estacionamientos - Verificar plano cenit | 2 |
| [CP23](<CP23 - Gastos Comunes - Multas Ley 21.442 - Verificar ciclo>) | Gastos Comunes - Multas Ley 21.442 - Verificar ciclo | 12 |
| [CP24](<CP24 - Seguridad - Mensajes de Sesión - Verificar que los me>) | Seguridad - Mensajes de Sesión - Verificar que los me | 4 |
| [CP25](<CP25 - Seguridad - Notificación de Encomiendas - Verificar q>) | Seguridad - Notificación de Encomiendas - Verificar q | 6 |
| [CP26](<CP26 - Comunidad - Buzón de Reclamos - Verificar ingreso de>) | Comunidad - Buzón de Reclamos - Verificar ingreso de | 7 |
| [CP27](<CP27 - Comunidad - Atención de Reclamos - Verificar atención>) | Comunidad - Atención de Reclamos - Verificar atención | 8 |
| [CP28](<CP28 - Seguridad - Correspondencia en Portería - Verificar e>) | Seguridad - Correspondencia en Portería - Verificar e | 3 |
| [CP29](<CP29 - Conserjería - Dashboard de Turno - Verificar que el d>) | Conserjería - Dashboard de Turno - Verificar que el d | 2 |
| [CP30](<CP30 - Interfaz Gráfica - Menú de Perfil y Notificaciones>) | Interfaz Gráfica - Menú de Perfil y Notificaciones | 6 |
| [CP31](<CP31 - Seguridad - Aislamiento Multi-Condominio - Verificar>) | Seguridad - Aislamiento Multi-Condominio - Verificar | 4 |
| [CP32](<CP32 - Seguridad - Aislamiento Multi-Condominio - Verificar>) | Seguridad - Aislamiento Multi-Condominio - Verificar | 3 |
| [CP33](<CP33 - Comunidad - Aislamiento Multi-Condominio - Verificar>) | Comunidad - Aislamiento Multi-Condominio - Verificar | 5 |
| [CP34](<CP34 - Gastos Comunes - Avisos de Pago y Vencimiento - Verif>) | Gastos Comunes - Avisos de Pago y Vencimiento - Verif | 6 |
| [CP35](<CP35 - Seguridad - Matriz de Cámaras - Verificar la configur>) | Seguridad - Matriz de Cámaras - Verificar la configur | 5 |
| [CP36](<CP36 - Gestión de Usuario - Perfil del Personal - Verificar>) | Gestión de Usuario - Perfil del Personal - Verificar | 4 |
| [CP37](<CP37 - Comunidad - Registro de Mascotas - Verificar que el r>) | Comunidad - Registro de Mascotas - Verificar que el r | 14 |
| [CP38](<CP38 - Comunidad - Alianzas y Beneficios - Verificar la admi>) | Comunidad - Alianzas y Beneficios - Verificar la admi | 6 |
| [CP39](<CP39 - Asistente LifeBetter - Ley 21.442 - Verificar que el>) | Asistente LifeBetter - Ley 21.442 - Verificar que el | 5 |
| [CP40](<CP40 - Autenticación - Recuperación de Contraseña - Verifica>) | Autenticación - Recuperación de Contraseña - Verifica | 11 |
| [CP41](<CP41 - Dashboard - Gráficos del Administrador - Verificar lo>) | Dashboard - Gráficos del Administrador - Verificar lo | 2 |
| [CP42](<CP42 - Estacionamientos - Sincronización con LPR - Verificar>) | Estacionamientos - Sincronización con LPR - Verificar | 6 |
| [CP43](<CP43 - Espacios Comunes - Reservas del Residente - Verificar>) | Espacios Comunes - Reservas del Residente - Verificar | 7 |
| [CP44](<CP44 - Seguridad AIoT - Cliente LPR de Borde - Verificar la>) | Seguridad AIoT - Cliente LPR de Borde - Verificar la | 1 |
| [CP45](<CP45 - Seguridad - Foto de Encomiendas - Verificar el regist>) | Seguridad - Foto de Encomiendas - Verificar el regist | 5 |
| [CP46](<CP46 - Asistente LifeBetter - Biblioteca Oficial y Modelo Lo>) | Asistente LifeBetter - Biblioteca Oficial y Modelo Lo | 5 |
| [CP47](<CP47 - App Móvil - Acceso, Inicio, Pagos y Encomiendas - Ver>) | App Móvil - Acceso, Inicio, Pagos y Encomiendas - Ver | 23 |
| [CP48](<CP48 - App Móvil - Pases QR y Validación en Portería - Verif>) | App Móvil - Pases QR y Validación en Portería - Verif | 8 |
| [CP49](<CP49 - App Móvil - Módulos del Residente - Verificar desde l>) | App Móvil - Módulos del Residente - Verificar desde l | 20 |
| [CP50](<CP50 - App Móvil - Notificaciones Push y Avisos - Verificar>) | App Móvil - Notificaciones Push y Avisos - Verificar | 7 |
| [CP51](<CP51 - Panel Gerencial - Navegación por Condominio y Personal>) | Panel Gerencial - Navegación por Condominio y Personal | 3 |
| [CP52](<CP52 - Dashboard del Residente - Indicadores y Reservas sin Montos>) | Dashboard del Residente - Indicadores y Reservas sin Montos | 1 |
| [CP53](<CP53 - Portada Pública (Home)>) | Portada Pública (Home) | 2 |
| [CP54](<CP54 - Seguridad AIoT - Simulador LPR y Encomiendas por Rol>) | Seguridad AIoT - Simulador LPR y Encomiendas por Rol | 2 |
| [CP55](<CP55 - Validación de Datos - RUT, Nombres y Teléfonos>) | Validación de Datos - RUT, Nombres y Teléfonos | 4 |
| [CP56](<CP56 - Gastos Comunes - Aviso de Boleta Emitida>) | Gastos Comunes - Aviso de Boleta Emitida | 3 |
| [CP57](<CP57 - Interfaz Gráfica - Confirmación de Cierre de Sesión>) | Interfaz Gráfica - Confirmación de Cierre de Sesión | 3 |
| [CP58](<CP58 - Datos de Demostración - Fotos de Fachadas, Cámaras y Foro>) | Datos de Demostración - Fotos de Fachadas, Cámaras y Foro | 3 |
| [CP59](<CP59 - Mesa de Soporte LifeBetter - Tickets, Acceso y SLA>) | Mesa de Soporte LifeBetter - Tickets, Acceso y SLA | 15 |
| [CP60](<CP60 - Informe Mensual - KPIs, PDF y Acceso>) | Informe Mensual - KPIs, PDF y Acceso | 5 |
| [CP61](<CP61 - Portada Pública - Video Promocional y Modo Día>) | Portada Pública - Video Promocional y Modo Día | 5 |
