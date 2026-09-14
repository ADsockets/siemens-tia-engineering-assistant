# Fuentes y evidencia

## Orden de prioridad

1. TIA Help Viewer local asociado a la instalación activa.
2. Documentación oficial Siemens web de la misma versión o de una versión compatible verificada.
3. Estándar documentado del proyecto.
4. Evidencia de exportaciones y código del proyecto.
5. Fuentes de terceros solo como orientación secundaria.

## Help Viewer local

Usa `https://localhost:5112` cuando esté disponible. Registra URL, ruta, título, idioma, versión, fecha de consulta y fragmento relevante. Puedes leer HTML, estructura de navegación y recursos expuestos por el servicio. No presupongas que una ruta, endpoint o API existe: comprueba respuesta, código y contenido.

No clones la aplicación, no modifiques sus archivos y no redistribuyas contenido protegido. Un índice local solo puede guardar metadatos y el contenido cuyo uso esté permitido y sea necesario para búsqueda y trazabilidad.

## Clasificación

Etiqueta cada hallazgo con una de estas clases: `oficial_siemens`, `estandar_proyecto`, `restriccion_verificada`, `fallo_conocido`, `dependiente_version`, `evidencia_proyecto` o `inferencia`.

## Fallback

Cuando el origen local no responda, usa la documentación Siemens web. Si tampoco es posible verificar la afirmación, indícalo y limita la respuesta a una propuesta que requiera validación en TIA Portal.

## Enlaces y redirecciones

Los enlaces oficiales mantenidos están en [enlaces-oficiales.md](enlaces-oficiales.md). La skill debe dirigir al usuario a esos destinos cuando necesite documentación pública, soporte, manuales, notas de versión o formación. No sustituyas un enlace oficial por un buscador genérico ni por una copia de terceros.

Para enlaces internos del Help Viewer conserva la ruta completa, el idioma y el parámetro de versión, por ejemplo `https://localhost:5112/en-us/tiaportal/ProgBlockKOPenUS/...?...api=V20`. No fabriques el identificador numérico de una página: obtén la URL desde el árbol, el enlace visible o la navegación observada.
