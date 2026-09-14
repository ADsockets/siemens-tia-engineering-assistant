# Ejemplo: máquina de estados para nivel de tanque

Ejemplo ilustrativo de una secuencia con llenado rápido, llenado reducido, paro y fallo.

```mermaid
stateDiagram-v2
    [*] --> Detenido
    Detenido --> LlenadoMaximo: nivel <= nivel_bajo y permiso
    LlenadoMaximo --> LlenadoReducido: nivel >= nivel_medio
    LlenadoReducido --> LlenadoMaximo: nivel < nivel_medio
    LlenadoReducido --> Detenido: nivel >= nivel_alto
    LlenadoMaximo --> Fallo: fallo_bomba o emergencia
    LlenadoReducido --> Fallo: fallo_bomba o emergencia
    Fallo --> Detenido: rearme_validado
```

La skill debe confirmar histéresis, prioridad entre condiciones, comportamiento al primer ciclo, rearme y qué ocurre si varias señales cambian en el mismo scan.
