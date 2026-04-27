# Matriz mínima de pruebas - TaskSync RC

## Información general

**Nombre de la app:** TaskSync RC  
**Tipo de app:** App de tareas con persistencia local y sincronización remota  
**Plataforma evaluada:** Web / Android  
**Versión evaluada:** 1.0.0+1  
**Fecha de prueba:**  
**Equipo evaluador:**  

---

## Objetivo de la matriz

Esta matriz permite validar si la app cumple condiciones mínimas de calidad antes de considerarse una versión candidata a entrega.

No se busca demostrar que la app es perfecta.  
Se busca evidenciar:

- Qué se probó.
- Qué funcionó.
- Qué falló.
- Qué riesgos quedan abiertos.
- Si la app puede o no considerarse Release Candidate.

---

## Estados posibles

| Estado | Significado |
|---|---|
| Pendiente | El caso todavía no se ha ejecutado |
| Aprobado | El resultado obtenido coincide con el resultado esperado |
| Falló | El resultado obtenido no coincide con el resultado esperado |
| No aplica | El caso no aplica para esta app o plataforma |

---

## Matriz de pruebas

| ID | Categoría | Escenario | Pasos | Resultado esperado | Estado | Evidencia / Observación |
|---|---|---|---|---|---|---|
| CP-01 | Inicio | Abrir la app | Ejecutar la app en web o Android | La app abre sin pantalla blanca ni crash | Pendiente | |
| CP-02 | Build | Verificar versión | Revisar `pubspec.yaml` | La app tiene versión definida, por ejemplo `1.0.0+1` | Pendiente | |
| CP-03 | Datos | Cargar tareas locales | Abrir la pantalla principal | La app muestra tareas existentes o estado vacío | Pendiente | |
| CP-04 | UI State | Loading inicial | Abrir la app o simular carga lenta | Se muestra un indicador de carga y la app no parece congelada | Pendiente | |
| CP-05 | UI State | Lista vacía | Ejecutar la app sin tareas registradas | Se muestra un mensaje claro de estado vacío | Pendiente | |
| CP-06 | Funcionalidad | Crear tarea válida | Presionar “Nueva tarea”, ingresar título y descripción, guardar | La tarea aparece en la lista | Pendiente | |
| CP-07 | Validación | Crear tarea sin título | Abrir formulario y guardar sin escribir título | La app muestra validación y no guarda la tarea | Pendiente | |
| CP-08 | UI extrema | Crear tarea con texto largo | Usar el menú QA: “crear texto largo” | La tarjeta no genera overflow ni rompe el diseño | Pendiente | |
| CP-09 | Funcionalidad | Completar tarea | Marcar una tarea con el checkbox | La tarea cambia visualmente a completada | Pendiente | |
| CP-10 | Sincronización | Ver estado sincronizado | Crear una tarea con conexión normal | La tarea queda como “Sincronizada” si Firebase responde correctamente | Pendiente | |
| CP-11 | Sincronización | Error de red | Usar el menú QA: “simular error de red” | La app no crashea y la tarea queda como “Sincronización pendiente” | Pendiente | |
| CP-12 | Permisos | Error permission-denied | Usar el menú QA: “simular permission-denied” | La app no crashea, registra el error y deja la tarea pendiente | Pendiente | |
| CP-13 | Error inesperado | Error remoto inesperado | Usar el menú QA: “simular error inesperado” | La app no se rompe y registra el error en logs | Pendiente | |
| CP-14 | Error de UI | Error desde acción de usuario | Usar el menú QA: “simular error de UI” | La app muestra mensaje controlado y registra el error técnico | Pendiente | |
| CP-15 | Sincronización | Sincronizar pendientes | Presionar “Sincronizar pendientes” | La app intenta reenviar tareas pendientes a Firebase | Pendiente | |
| CP-16 | Remoto | Actualizar desde Firebase | Presionar “Actualizar desde Firebase” | La app intenta traer datos remotos sin romper la UI | Pendiente | |
| CP-17 | Logs | Revisar logs en debug | Ejecutar la app con `flutter run` y probar acciones QA | La terminal muestra logs de info, warning o error según el caso | Pendiente | |
| CP-18 | Usuario | Mensajes amigables | Provocar un error simulado | El usuario ve un mensaje entendible, no un stacktrace | Pendiente | |
| CP-19 | Release Web | Generar build web | Ejecutar `flutter build web --release` | Se genera la carpeta `build/web/` | Pendiente | |
| CP-20 | Release Android | Generar APK release | Ejecutar `flutter build apk --release` | Se genera un `.apk` en `build/app/outputs/flutter-apk/` | Pendiente | |

---

## Casos adicionales por dominio

Cada equipo debe agregar al menos tres casos relacionados con el tipo de app que esté analizando.

Ejemplos:

| ID | Categoría | Escenario | Pasos | Resultado esperado | Estado | Evidencia / Observación |
|---|---|---|---|---|---|---|
| CP-D01 | Dominio | Fecha pasada en reserva | Intentar crear una reserva con fecha anterior a hoy | La app bloquea la acción y muestra mensaje claro | Pendiente | |
| CP-D02 | Dominio | Cupo agotado | Intentar inscribirse en un evento sin cupos | La app no permite la inscripción | Pendiente | |
| CP-D03 | Dominio | Doble acción | Presionar dos veces rápidamente el botón Guardar | La app crea un solo registro | Pendiente | |

---

## Evidencias sugeridas

Para cada caso pueden registrar:

- Captura de pantalla.
- Mensaje mostrado al usuario.
- Fragmento relevante de logs.
- Descripción breve del comportamiento.
- Estado visual de la tarea.
- Error observado en terminal o consola.

---

## Resumen de resultados

| Resultado | Cantidad |
|---|---:|
| Casos aprobados | |
| Casos fallidos | |
| Casos pendientes | |
| Casos no aplica | |

---

## Observaciones generales

Escribir aquí observaciones importantes encontradas durante la prueba.

Ejemplo:

- La app funciona correctamente en el flujo principal.
- Los errores simulados no generan crash.
- La sincronización pendiente se muestra correctamente.
- Falta mejorar el mensaje visual cuando Firebase rechaza permisos.
- Falta probar en dispositivo físico Android.