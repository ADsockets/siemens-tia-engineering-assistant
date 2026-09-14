# Contribuir

Gracias por contribuir a una skill Siemens independiente y centrada en TIA Portal.

## Antes de abrir un cambio

- Mantén el alcance en Siemens TIA Portal V18, V19 y V20.
- No mezcles reglas de otros fabricantes o lenguajes.
- Usa ejemplos sintéticos, sin proyectos ni datos reales.
- Cita documentación oficial Siemens cuando una regla dependa de una versión.
- Conserva la distinción entre regla oficial, estándar del proyecto, restricción histórica, fallo conocido e inferencia.

## Cambios de la skill

Los cambios de comportamiento deben incluir:

1. descripción del problema;
2. decisión funcional;
3. impacto sobre el flujo de análisis y validación;
4. ejemplo o prueba reproducible;
5. revisión de seguridad y privacidad.

No generes SCL integrable como sustituto de la validación con el usuario. La pregunta **“¿Esto es exactamente lo que necesitas?”** forma parte del contrato de la skill.

## Pull requests

- Usa una rama descriptiva.
- Mantén `main` protegido.
- No incluyas secretos, binarios de Siemens ni archivos de proyectos TIA.
- Describe las validaciones realmente ejecutadas.
- No marques una compatibilidad V21 sin una validación independiente.
