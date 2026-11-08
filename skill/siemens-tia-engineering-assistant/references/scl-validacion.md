# Validación SCL

## Tipos y tiempo

Verifica tipos de entrada y salida, conversiones permitidas por la versión, unidades, rango, overflow y límites. No inventes conversiones directas entre tipos de tiempo. Si la documentación no confirma una conversión, propone una ruta compatible y exige validación en TIA.

## Timers y scan

Comprueba que cada IEC Timer se evalúe de forma coherente con el scan, que su instancia tenga ubicación válida, que el reset sea explícito y que no se use una llamada ficticia como sustituto de una evaluación de bloque. Documenta el efecto de la duración, el primer ciclo y el rearme.

## Estados, prioridades y reset

Explica estados mutuamente excluyentes, prioridades y condiciones de transición. Un reset global necesita evento, autorización, prioridad, alcance y comportamiento si coinciden dos condiciones. Prueba simultaneidad, rebote, pérdida de señal, recuperación y repetición del evento.

## Pruebas mínimas

Incluye casos nominales, límites, cero, máximo, señal ausente, error de tipo, estados simultáneos, reinicio, primer ciclo, timeout, paro, cambio de modo y rearme. Da el resultado esperado y qué debe observarse en TIA Portal.

## Entrega como fuente `.scl`

Cuando el usuario elija un archivo `.scl`, valida antes de escribirlo:

- versión objetivo de TIA Portal y familia de CPU cuando afecte a la sintaxis o a las instrucciones;
- tipo de bloque o fuente que se importará (FB, FC, DB, UDT o fuente externa);
- interfaz completa, tipos, instancias IEC Timer y dependencias externas;
- que el archivo contenga únicamente SCL y comentarios válidos, sin Markdown ni texto conversacional;
- nombre de archivo, codificación de texto y ruta de entrega;
- diferencia entre revisión estática realizada y compilación real en TIA Portal.

Si estos datos no están disponibles, entrega primero una lista breve de faltantes y no fabriques un archivo supuestamente importable. Un `.scl` creado por la skill debe enlazarse como archivo descargable y no solo copiarse en un bloque de chat.
