# Diagramas contextuales Siemens

## Selección de la vista

No mezcles todas las capas en un único diagrama ilegible. Elige una vista principal y, solo si es necesario, una vista secundaria:

| Pregunta | Vista principal |
|---|---|
| ¿Cómo funciona el proceso? | Proceso físico y señales |
| ¿Qué llama a qué? | Arquitectura PLC |
| ¿Dónde se escribe una señal? | Referencias cruzadas |
| ¿Por qué cambia una salida? | Flujo interno o estados |
| ¿Qué ocurre ante un fallo? | Diagnóstico y recuperación |

## Reglas de legibilidad

- Mantén una dirección de lectura coherente.
- Agrupa sensores, lógica PLC, actuadores y realimentación.
- Diferencia orden, realimentación, alarma y condición de permiso mediante etiquetas, no solo colores.
- No representes una inferencia como una relación confirmada.
- Conserva el nombre real de bloques y señales; usa alias descriptivos solo como apoyo.
- Divide el diagrama cuando una capa tenga demasiados nodos.
- En diagramas de estados, muestra las condiciones de transición y las prioridades que cambien el resultado.

## Trazabilidad

Cada nodo o relación relevante debe poder vincularse con el bloque, página, ruta, exportación o fragmento que la respalda. Si no existe evidencia suficiente, marca `pendiente`, `inferido` o `no observable`.

## Uso antes de programar

Para una idea nueva, el diagrama representa una hipótesis de funcionamiento y debe revisarse con el usuario. No es autorización para generar SCL. Para un programa existente, el diagrama representa el comportamiento observado y debe distinguir las diferencias frente a la intención declarada.
