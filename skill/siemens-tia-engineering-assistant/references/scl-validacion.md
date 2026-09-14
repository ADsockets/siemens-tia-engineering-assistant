# Validación SCL

## Tipos y tiempo

Verifica tipos de entrada y salida, conversiones permitidas por la versión, unidades, rango, overflow y límites. No inventes conversiones directas entre tipos de tiempo. Si la documentación no confirma una conversión, propone una ruta compatible y exige validación en TIA.

## Timers y scan

Comprueba que cada IEC Timer se evalúe de forma coherente con el scan, que su instancia tenga ubicación válida, que el reset sea explícito y que no se use una llamada ficticia como sustituto de una evaluación de bloque. Documenta el efecto de la duración, el primer ciclo y el rearme.

## Estados, prioridades y reset

Explica estados mutuamente excluyentes, prioridades y condiciones de transición. Un reset global necesita evento, autorización, prioridad, alcance y comportamiento si coinciden dos condiciones. Prueba simultaneidad, rebote, pérdida de señal, recuperación y repetición del evento.

## Pruebas mínimas

Incluye casos nominales, límites, cero, máximo, señal ausente, error de tipo, estados simultáneos, reinicio, primer ciclo, timeout, paro, cambio de modo y rearme. Da el resultado esperado y qué debe observarse en TIA Portal.
