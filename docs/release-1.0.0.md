# Revisión de la distribución 1.0.0

Fecha de preparación: 2026-11-08. Titular y licencia aprobada: ADsockets, MIT.

## Origen y comparación

El baseline local y remoto fue `7918bb1aace9a0ee2f2498bcc2b631b22f957867`, rama `main`, con árbol limpio. Se reutilizó el checkout existente; no se creó otro repositorio ni se reescribió el historial.

Se compararon por SHA-256 los 11 archivos de la instalación personal con `skill/siemens-tia-engineering-assistant`. Nueve coincidían. Las dos diferencias fueron:

- `references/scl-validacion.md`: se incorporó la sección local sobre entrega de fuentes `.scl`.
- `references/ingestion-artefactos.md`: se conservó la redacción genérica del repositorio. El nombre particular de reporte de la instalación personal no aporta una regla reutilizable.

Esta tarea prepara el paquete público y conserva la instalación personal existente. La instalación local puede actualizarse posteriormente desde la release; no se afirma que ya sea idéntica al paquete.

## Licencia, privacidad y alcance

Se revisaron los 5 commits del baseline y 30 blobs de texto únicos, incluidos archivos retirados, además del árbol candidato. No se encontraron credenciales, claves privadas, rutas personales, IP privadas, proyectos TIA, binarios Siemens ni contenido del Help Viewer. La revisión combinó lectura y búsqueda de patrones; no demuestra ausencia absoluta de secretos ni certifica la autoría de cada contribución.

Los commits históricos exponen el nombre del autor y su dirección GitHub `noreply`. El historial conserva `examples/scl/FB_SistemaAdaptativo.scl` en `58365cb72f07ead611a0be6066459515687e7e31`, eliminado en el commit posterior. No se observaron en ese archivo identificadores de clientes o plantas, direcciones de E/S, IP ni credenciales. No forma parte del paquete actual, pero seguirá siendo accesible en el historial público. No se justificó alterar ese historial.

La licencia MIT acompaña tanto al repositorio como a la carpeta instalable. Las marcas y documentos externos conservan los derechos de sus titulares. El proyecto es independiente de Siemens AG.

Se mantiene el alcance V18–V20 y la exclusión de V21. La ruta textual SIMATIC SD documentada se limita a V20. Se consultó la [documentación oficial V20](https://docs.tia.siemens.cloud/r/en-us/v20/creating-and-managing-blocks/exporting-and-importing-blocks-in-simatic-sd-format-s7-1200-s7-1500/exporting-and-importing-blocks-in-simatic-sd-format-s7-1200-s7-1500). El acceso directo a la referencia Update 4 devolvió 401 durante esta revisión; el índice de búsqueda oficial confirmó la incorporación de redes SCL en LAD/FBD con Update 4. No se comprobó toda la documentación técnica Siemens ni todos los enlaces.

## Cambios de distribución

- Primera versión etiquetada `v1.0.0`, metadatos `version: 1.0.0` y `license: MIT`, y nombre visible completo.
- Instalador con `CODEX_HOME`, simulación sin efectos, comprobación de rutas, copia preparada y verificada, respaldo fuera de skills, recuperación ante fallo de activación y exclusión entre procesos del mismo destino y sesión.
- Probe HTTP que no registra query, fragment ni mensajes de excepción con URLs. Rechaza credenciales en la URI y distingue un error HTTP de un servicio inaccesible. No identifica por sí mismo el software que responde.
- Regla de fuentes sin autoridad incluida en el paquete instalable. Un documento no puede conceder permisos de operación ni saltar confirmaciones.
- Detector de publicación y pruebas negativas de artefactos y patrones sensibles. Sus firmas son una comprobación adicional y no sustituyen la revisión de contenidos y procedencia.

El detector busca secretos en las extensiones de texto declaradas en `$textExtensions`, archivos sin extensión y dotfiles. Otros tipos se comprueban por acceso y por las reglas de artefactos, pero no tienen búsqueda de secretos en su contenido. La revisión de todos los blobs históricos se realizó aparte; no es una función del script.

## Validación reproducible

Los comandos están en [README.md](../README.md#validación-del-paquete). Las pruebas usan recursos de desarrollo desechables: directorios propios bajo el temporal del sistema y un servidor HTTP de loopback. Python 3 solo se necesita para la prueba del probe; no es dependencia de la skill instalada.

La preparación incluye validación de frontmatter, referencias internas, sintaxis PowerShell, detector público, pruebas de instalación y diagnóstico HTTP, revisión independiente de cinco escenarios de decisión y revisión del diff. Los resultados definitivos y el SHA publicado se registran en las notas de la release.

Resultados locales: 10 casos del instalador, 11 del detector y 5 del probe pasaron en cada entorno, Windows PowerShell 5.1.26100.9818 y PowerShell 7.6.9 (52 ejecuciones de casos). El detector sobre el árbol completo y la validación de frontmatter también pasaron. Los fallos de instalación se inyectaron en las operaciones de filesystem del test; no se modificó el código del instalador para simularlos. Se comprobó recuperación ante fallo de activación, no una falla simultánea adicional del propio rollback.

No se ejecutó TIA Portal, no se importaron ni compilaron fuentes y no hubo conexión ni descarga al PLC. La evaluación de instrucciones no demuestra comportamiento determinista por todos los modelos o clientes.

## Publicación y controles remotos

El repositorio no contenía workflows, ejecuciones de Actions, artefactos de Actions, releases ni etiquetas. Solo existía la rama remota `main`; no había Issues abiertas, wiki ni discusiones. No se añadieron workflows como parte de esta distribución. El cambio no declara ninguna validación CI.

La rama `main` no figuraba protegida en el inventario de ramas. Las APIs de protección/rulesets devolvían 403 con el repositorio privado y el plan actual; esto no permite inferir una configuración completa de reglas. Esta tarea no cambia la política de contribución o protección de ramas.

La release publica un ZIP del árbol etiquetado y `SHA256SUMS.txt`. La comprobación remota de visibilidad, etiqueta, commit y archivos descargables se registra al publicarla; este documento no sustituye esa lectura del destino.
