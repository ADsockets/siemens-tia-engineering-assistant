# Lista de verificación antes de publicar

## Contenido

- [x] El README explica propósito, alcance, límites y compatibilidad.
- [x] Los diagramas actuales son ilustrativos y no contienen nombres de clientes o plantas; se revisó también el archivo SCL retirado del historial.
- [x] Las referencias apuntan a documentación oficial y no se incluyen copias documentales de terceros.
- [x] V21 no se presenta como compatible.

## Privacidad y seguridad

- [x] No se encontraron proyectos `.ap*`, `.zap*`, `.als*` ni exportaciones TIA reales.
- [x] No se encontraron DLL, EXE, instaladores binarios, certificados, tokens ni archivos `.env`.
- [x] No se encontraron rutas personales, IP privadas ni credenciales; se conservan autor y correo GitHub noreply en commits.
- [x] No se encontró contenido del Help Viewer ni documentación propietaria redistribuida.
- [x] `SECURITY.md` describe el reporte responsable.

## Git y release

- [x] El `git diff` fue revisado manualmente.
- [x] El árbol de trabajo no contiene archivos no rastreados inesperados.
- [ ] Recomendación de mantenimiento: definir protección de `main`; esta release no cambia la política de ramas.
- [x] `LICENSE` contiene la licencia MIT aprobada, también dentro del paquete instalable.
- [x] El changelog y los metadatos identifican 1.0.0; las notas de la release verifican la etiqueta publicada.

## Validación

Ejecuta el detector local antes de publicar:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\validate-public-repo.ps1
```

El detector es una barrera adicional, no un sustituto de la revisión humana.

La evidencia y límites de 1.0.0 están en [release-1.0.0.md](release-1.0.0.md). Las notas de GitHub Release identifican el commit y los resultados finales.
