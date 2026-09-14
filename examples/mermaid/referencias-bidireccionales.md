# Ejemplo: referencias bidireccionales

```mermaid
flowchart LR
    Sensor[Nivel_Tanque]
    FC[FC_Escalado]
    DB[(DB_Proceso)]
    FB[FB_ControlNivel]
    OB[OB1]
    Bomba[Salida_Bomba]

    Sensor -->|escribe| FC
    FC -->|escribe| DB
    DB -->|lee| FB
    OB -->|llama| FB
    FB -->|escribe| Bomba
```

La dirección de cada relación debe provenir de una exportación, una referencia cruzada o una observación explícita. Si se infiere, debe marcarse como inferida.
