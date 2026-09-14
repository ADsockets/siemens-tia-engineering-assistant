# Ejemplo: arquitectura PLC

Este ejemplo es sintético. Sirve para mostrar cómo representar llamadas, instancias, datos y E/S sin convertir el diagrama en una lista genérica de archivos.

```mermaid
flowchart TB
    OB1[OB1 - ciclo principal]
    FC10[FC10 - adquisición y escalado]
    FB20[FB20 - control de tanque]
    DB20[(DB20 - instancia FB20)]
    DB100[(DB100 - señales de proceso)]
    UDT1[[UDT_Tanque]]
    IO[E/S físicas]

    OB1 --> FC10
    OB1 --> FB20
    FC10 --> DB100
    FB20 --> DB20
    UDT1 -. tipo .-> DB100
    IO --> FC10
    DB100 --> FB20
    FB20 --> IO
```

## Lectura esperada

- `OB1` determina el orden de ejecución observado.
- `FC10` transforma señales de campo y actualiza datos de proceso.
- `FB20` contiene la lógica con memoria y usa `DB20` como instancia.
- `UDT_Tanque` describe la estructura de datos, no la secuencia de control.
- La relación con E/S debe confirmarse con tags y configuración hardware.
