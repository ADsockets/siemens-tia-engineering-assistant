# SIMATIC SD para LAD/KOP

## Cuándo usarlo

Usa SIMATIC SD únicamente cuando el usuario seleccione LAD/KOP como formato de entrega o entregue un bloque existente `.s7dcl`. Para proyectos nuevos, la selección explícita prevalece. Para proyectos existentes, detecta `.s7dcl`, revisa los pragmas del bloque y asocia un `.s7res` con el mismo nombre base si existe.

## Alcance y versión

- La representación textual SIMATIC SD para LAD corresponde a STEP 7/TIA Portal V20 y CPUs S7-1200/S7-1500.
- Un `.s7dcl` contiene propiedades, interfaz y redes; un `.s7res` contiene comentarios y textos por idioma. El `.s7res` es opcional si no hay textos que conservar.
- Los bloques LAD puros se exportan e importan como SIMATIC SD. No afirmes compatibilidad de bloques mixtos LAD/FBD/SCL sin confirmar TIA Portal V20 Update 4 o una versión posterior compatible.
- No uses el mecanismo de `External source files` de `.scl` como si fuera importación LAD. Son rutas distintas de TIA Portal.

## Lectura y generación

Un bloque LAD usa un pragma que identifica el lenguaje, una declaración de bloque y redes. Cada red utiliza `NETWORK`; cada línea de corriente utiliza `RUNG` y `END_RUNG`. Las ramas se identifican con `wire#powerrail` o `wire#<identificador>`. Lee contactos, bobinas, cajas, ramas y llamadas respetando el orden de red y la asociación de cada `wire`.

Antes de generar un `.s7dcl`, confirma CPU, versión/Update, bloque, interfaz, dependencias y semántica de cada red. Mantén el archivo como texto SIMATIC SD puro, sin Markdown ni explicaciones externas. No inventes ramas, instrucciones gráficas o pragmas a partir de una equivalencia SCL no verificada. Si la topología Ladder exacta importa, solicita primero un `.s7dcl` exportado de la misma versión como muestra de referencia.

## Validación y límites

Comprueba pragmas, `FUNCTION` o `FUNCTION_BLOCK`, declaraciones, balance de `NETWORK`/`END_NETWORK` y `RUNG`/`END_RUNG`, referencias `wire`, llamadas y dependencias. Un análisis estructural no sustituye la importación y compilación en TIA Portal.

Advierte antes de usar el comando de TIA Portal que genera bloques desde la fuente: si existe un bloque o tipo con el mismo nombre, TIA Portal puede sobrescribirlo. La generación/importación no está autorizada por el solo hecho de crear o revisar el archivo.

## Fuentes oficiales Siemens

- [Exporting and importing blocks in SIMATIC SD format](https://docs.tia.siemens.cloud/r/en-us/v20/creating-and-managing-blocks/exporting-and-importing-blocks-in-simatic-sd-format-s7-1200-s7-1500/exporting-and-importing-blocks-in-simatic-sd-format-s7-1200-s7-1500)
- [Representation of LAD program code in SIMATIC SD format](https://docs.tia.siemens.cloud/r/en-us/v20/creating-and-managing-blocks/exporting-and-importing-blocks-in-simatic-sd-format-s7-1200-s7-1500/representation-of-lad-program-code-in-simatic-sd-format-s7-1200-s7-1500)
- [TIA Portal V20 Update 4 improvements](https://docs.tia.siemens.cloud/r/en-us/v20-updates/tia-portal-updates-readme/improvements-in-step-7/improvements-in-update-4)
