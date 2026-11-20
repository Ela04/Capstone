# LifeBetter AIoT — Proyecto Capstone (PTY4614)

Plataforma SaaS para la gestión inteligente de condominios: gastos comunes según la Ley 21.442, pagos con Webpay Plus, control de acceso con lectura de patentes (LPR) y pases QR, encomiendas, comunidad y un asistente normativo con IA. Tiene una plataforma web (Django) y una app móvil (Expo) para residentes y conserjes.

- **Equipo:** Gabriela Antúnez Torres · Ariel (Israel Ignacio) Oñate Calfulen
- **Sección:** 002V · Duoc UC, sede Plaza Oeste · Escuela de Informática y Telecomunicaciones
- **Docente:** Luis Alberto Bravo Yanes
- **Código fuente:** repositorio `Ela04/LifeBetter_Project` (privado)

Este repositorio reúne la documentación y las evidencias de las 3 fases.

## Estado del proyecto (20-11-2026, commit 7ba390c del código)

| Indicador | Resultado |
|---|---|
| Funcionalidades especificadas | 151 (150 completadas, 1 en progreso: cliente LPR de borde con cámara física) |
| Casos de prueba | 65 de 65 aprobados (CP01 a CP61) |
| Pruebas automatizadas (pytest) | 104 de 104 PASSED |
| Defectos detectados en el Ciclo 4 | 4, todos corregidos |
| Entorno | Local (Python 3.14.7, Django 5.2.19, app Expo) |

## Estructura

Los archivos individuales siguen el formato `Apellido_Nombre_N.N_APT122_Documento.docx`.

### Fase 1 — Definición del proyecto
- [`Evidencias Individuales`](<Fase 1/Evidencias Individuales>): autoevaluación de competencias (1.1), diario de reflexión (1.2) y autoevaluación (1.3) de cada integrante.
- [`Evidencias Grupales`](<Fase 1/Evidencias Grupales>): formativa 1.4, guía 1.5 de definición del proyecto, presentación y planilla de evaluación.
- [`Evidencias Proyecto`](<Fase 1/Evidencias Proyecto>):
  - **Documentos de Diseño:** requerimientos IEEE 830, historias de usuario, casos de uso, diagramas de clases y actividad, modelo de base de datos, mockups y Carta Gantt.
  - **Documentos de Gestión:** plan del proyecto, actas de reunión, estados de avance, CANVAS, stakeholders y resolución de conflictos.

### Fase 2 — Desarrollo del proyecto
- [`Evidencias Individuales`](<Fase 2/Evidencias Individuales>): diario de reflexión 2.1 de cada integrante.
- [`Evidencias Grupales`](<Fase 2/Evidencias Grupales>): guía 2.4 de desarrollo, guía 2.6 del informe final, plan de trabajo, presentación de Fase 2 y planilla de evaluación del avance.
- [`Evidencias de Proyecto/Documento de Diseño`](<Fase 2/Evidencias de Proyecto/Documento de Diseño>):
  - `LifeBetter_Modulos_y_Estado.xlsx`: matriz de las 151 funcionalidades, con la ruta del código y su evidencia.
  - `Casos_de_Prueba_LifeBetter.xlsx`: 65 casos de prueba, pruebas estándar de QA, evidencia pytest y totales.
  - `Resultados de pruebas 23.docx`: fichas de evidencia de los casos CP01 a CP61, reporte de defectos y métricas.
  - [`Evidencias de pruebas`](<Fase 2/Evidencias de Proyecto/Documento de Diseño/Evidencias de pruebas>): una carpeta por caso de prueba con sus capturas reales.
  - [`Pruebas automatizadas`](<Fase 2/Evidencias de Proyecto/Documento de Diseño/Pruebas automatizadas>): salida completa de pytest (104 passed).
  - `Plan de pruebas`: plan de pruebas y su Gantt.

### Fase 3 — Presentación del proyecto
Pendiente: diarios de reflexión 3.1 y presentación final ante la comisión.
