# Análisis de proyecto y referencias cruzadas

## Inventario mínimo

Captura nombre, tipo, versión, interfaz, instancia, llamadas, ubicación y fuente de cada OB, FC, FB, DB y UDT. Para cada tag o señal registra tipo, ámbito, productor, consumidores, condición de escritura, condición de lectura y relación con E/S física si está disponible.

## Referencias bidireccionales

- Señal → bloques que leen, bloques que escriben, DB/tag de origen, E/S relacionada.
- Bloque → callers, callees, entradas, salidas, instancia, señales leídas/escritas.

Marca como conflicto los múltiples escritores, como hueco las señales sin escritor conocido y como pendiente las relaciones cuyo origen no sea observable.

## Flujo interno

Separa estados, condiciones, transiciones y acciones. Identifica timers y su ciclo de evaluación. Registra prioridades, interlocks, modos, alarmas, reset, primer ciclo, estados inválidos y recuperación.

## Diagramas

El grafo de arquitectura debe mostrar bloques y dependencias; el flujo interno debe mostrar condiciones, transiciones y acciones. Usa enlaces o identificadores estables hacia el origen del dato. No conviertas una inferencia en una flecha confirmada.
