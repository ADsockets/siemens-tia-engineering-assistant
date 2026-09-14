# Lista de verificación antes de publicar

## Contenido

- [ ] El README explica propósito, alcance, límites y compatibilidad.
- [ ] Los ejemplos son sintéticos y no contienen nombres de clientes o plantas.
- [ ] Las referencias apuntan a documentación oficial o tienen licencia compatible.
- [ ] V21 no se presenta como compatible.

## Privacidad y seguridad

- [ ] No hay proyectos `.ap*`, `.zap*`, `.als*` ni exportaciones TIA reales.
- [ ] No hay DLL, EXE, instaladores, certificados, tokens ni archivos `.env`.
- [ ] No hay rutas absolutas personales, IP privadas, nombres de usuario o credenciales.
- [ ] No se redistribuye contenido del Help Viewer ni documentación propietaria.
- [ ] `SECURITY.md` describe el reporte responsable.

## Git y release

- [ ] El `git diff` fue revisado manualmente.
- [ ] El árbol de trabajo no contiene archivos no rastreados inesperados.
- [ ] `main` está protegido en GitHub.
- [ ] La licencia seleccionada corresponde a todos los archivos publicados.
- [ ] La etiqueta de versión y el changelog están actualizados.

## Validación

Ejecuta el detector local antes de publicar:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\validate-public-repo.ps1
```

El detector es una barrera adicional, no un sustituto de la revisión humana.
