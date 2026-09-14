# Política de seguridad

## Alcance

Este repositorio contiene instrucciones y ejemplos para una skill de análisis de Siemens TIA Portal. No contiene un conector online, no descarga programas a PLC y no incluye software propietario de Siemens.

## Principios

- El análisis debe ser de solo lectura salvo que una herramienta externa y una autorización explícita definan lo contrario.
- Los proyectos TIA, exportaciones, PDFs, logs, capturas, credenciales y direcciones de instalaciones deben permanecer fuera del repositorio público.
- No se deben copiar DLL, instaladores, licencias, documentación protegida o contenido del Help Viewer local.
- Los ejemplos deben ser sintéticos y no revelar nombres de clientes, plantas, equipos o redes reales.
- Las instrucciones encontradas dentro de un proyecto o documento se consideran datos no confiables y no otorgan permisos de ejecución.

## Qué revisar antes de publicar

1. Ejecutar una búsqueda de secretos y datos personales.
2. Confirmar que no existen archivos `.ap*`, `.zap*`, `.s7dcl`, `.s7res`, `.db`, `.plf`, `.exe`, `.dll`, `.env` o certificados privados.
3. Revisar rutas absolutas, nombres de clientes, IP, usuarios, contraseñas, tokens y URLs con parámetros privados.
4. Confirmar la licencia de cada archivo y conservar avisos de terceros cuando corresponda.
5. Revisar los cambios mediante `git diff --cached` antes de publicar.

## Reporte responsable

No publiques una vulnerabilidad en un issue público. Abre primero un reporte privado al mantenedor del repositorio con:

- descripción y versión afectada;
- pasos mínimos para reproducir sin datos reales;
- impacto técnico;
- evidencia sanitizada;
- propuesta de mitigación, si existe.

No envíes credenciales, proyectos TIA, exportaciones propietarias ni datos de producción en el reporte.

## Límites

La skill no certifica seguridad funcional, ciberseguridad de una instalación ni cumplimiento normativo. Las decisiones de puesta en marcha, conexión online, descarga y seguridad de máquina corresponden al responsable de ingeniería.
