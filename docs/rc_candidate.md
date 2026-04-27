# Declaración de Release Candidate - TaskSync RC

## Información general

**Nombre de la app:** TaskSync RC  
**Versión evaluada:** 1.0.0+1  
**Plataforma evaluada:** Web / Android  
**Fecha de evaluación:**  
**Equipo evaluador:**  

---

## ¿Qué es una Release Candidate?

Una Release Candidate, o RC, es una versión candidata a entrega.

No significa que la app sea perfecta.  
Significa que la app ya tiene una calidad mínima suficiente para ser evaluada como posible versión de entrega.

Una build puede considerarse RC si:

- El flujo principal funciona.
- No hay bugs bloqueantes abiertos.
- La versión está definida.
- La app puede ejecutarse o instalarse correctamente.
- Los estados principales de UI están considerados.
- Los errores esperables se manejan de forma controlada.
- Existe evidencia mínima de pruebas.
- Los bugs conocidos están documentados y priorizados.

---

## Criterios mínimos para declarar RC

| Criterio | Estado | Observación |
|---|---|---|
| La app abre sin crash | Pendiente | |
| La versión está definida en `pubspec.yaml` | Pendiente | |
| El flujo principal funciona | Pendiente | |
| La app permite crear tareas válidas | Pendiente | |
| La app valida tareas sin título | Pendiente | |
| La app muestra estado Loading | Pendiente | |
| La app muestra estado Empty | Pendiente | |
| La app muestra estado Data | Pendiente | |
| La app maneja errores sin mostrar stacktrace al usuario | Pendiente | |
| La app registra logs técnicos útiles | Pendiente | |
| La app maneja fallos remotos sin perder datos locales | Pendiente | |
| La app muestra tareas pendientes de sincronización | Pendiente | |
| La matriz mínima de pruebas fue ejecutada | Pendiente | |
| No hay bugs P1 abiertos | Pendiente | |
| Los bugs P2 y P3 están documentados | Pendiente | |
| El README o instrucciones de ejecución están actualizados | Pendiente | |

---

## Resultado de la evaluación

Marcar una opción:

- [ ] Esta build ES candidata a RC-1.
- [ ] Esta build NO ES candidata a RC-1 todavía.

---

## Justificación

Escribir una justificación breve.

Ejemplo si la build sí es RC:

La build `1.0.0+1` puede considerarse RC-1 porque el flujo principal de tareas funciona, la app abre correctamente, permite crear y completar tareas, registra logs útiles, maneja errores simulados sin crashear y no tiene bugs P1 abiertos. Los bugs menores encontrados quedaron documentados en el backlog.

Ejemplo si la build no es RC:

La build `1.0.0+1` todavía no puede considerarse RC-1 porque falta validar la ejecución en Android, hay errores pendientes en la sincronización con Firebase y todavía no se completó la matriz mínima de pruebas. Además, existe al menos un bug P1 abierto que bloquea el flujo principal.

---

## Bugs encontrados

| ID | Título | Prioridad | Estado | Impacto en la RC |
|---|---|---|---|---|
| BUG-01 | | P1 / P2 / P3 | Abierto / Cerrado | |
| BUG-02 | | P1 / P2 / P3 | Abierto / Cerrado | |
| BUG-03 | | P1 / P2 / P3 | Abierto / Cerrado | |

---

## Clasificación de prioridades

| Prioridad | Significado | ¿Bloquea RC? |
|---|---|---|
| P1 | Bloquea el flujo principal, causa crash, pérdida de datos o impide usar la app | Sí |
| P2 | Afecta una funcionalidad importante, pero existe alternativa o workaround | Depende del contexto |
| P3 | Error menor, visual o mejora secundaria | No necesariamente |

---

## Riesgos conocidos

Registrar aquí riesgos que no necesariamente bloquean la RC, pero deben conocerse.

Ejemplos:

- Falta probar en dispositivo físico.
- Falta probar con red inestable real.
- Falta configurar Crashlytics para Android.
- El estado offline solo se evidencia como sincronización pendiente.
- Falta mejorar mensajes cuando Firebase rechaza permisos.
- Falta validar comportamiento con muchos registros.

---

## Evidencia usada para la decisión

| Evidencia | Ubicación o descripción |
|---|---|
| Matriz de pruebas | `docs/matriz_pruebas.md` |
| Logs observados | Terminal / Flutter logs / DevTools |
| Build web generada | `build/web/` |
| APK generado | `build/app/outputs/flutter-apk/app-release.apk` |
| Capturas de pantalla | |
| Backlog de bugs | |

---

## Declaración final

Completar una de las siguientes frases:

### Si es RC

La build `__________` puede considerarse **RC-1** porque:

- 
- 
- 

### Si no es RC

La build `__________` **no puede considerarse RC-1 todavía** porque:

- 
- 
- 

---

## Próximos pasos

Listar las acciones necesarias después de esta evaluación.

Ejemplos:

- Corregir bugs P1.
- Reintentar sincronización con Firebase.
- Mejorar mensajes de error.
- Probar en Android físico.
- Generar APK release.
- Completar casos pendientes de la matriz.
- Actualizar README.