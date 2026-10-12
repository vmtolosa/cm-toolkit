# Especificación: publicación de versiones para estudiantes

Estado: aprobada para implementar. Versión 1 (12 de octubre de 2026).
Rama: `chore/publicacion`. Primera versión que se publica: 0.2.0.

## Idea general

Un estudiante que recién aprende Mathematica no va a clonar un repositorio. Debe poder instalar el
paquete con una línea en un notebook, y actualizarlo o desinstalarlo con otra:

    PacletInstall["https://github.com/vmtolosa/cm-toolkit/releases/download/v0.2.0/CMToolkit-0.2.0.paclet"]
    Needs["CMToolkit`"]

Para eso, cada versión se publica como un archivo `.paclet` adjunto a un «release» de GitHub. El
archivo se construye en la computadora del autor (hace falta Mathematica); nunca se guarda en el
repositorio (`*.paclet` y `build/` están en `.gitignore`).

## Lo que se agrega al repositorio

### 1. `scripts/build-paclet.wls`

Script de wolframscript que se corre desde la raíz del repo:

    wolframscript -file scripts/build-paclet.wls

En orden:

1. Lee la versión de `CMToolkit/PacletInfo.wl` (`PacletObject[File[...]]["Version"]`).
2. Corre `Tests/RunTests.wls` como proceso aparte (`RunProcess`) y se detiene con código 1 si
   termina con un código distinto de 0: no se construye un paquete con tests fallando.
3. Construye el archivo con `CreatePacletArchive` en `build/`, con el nombre
   `CMToolkit-<versión>.paclet`. Si ya existe, lo reemplaza.
4. Comprueba el archivo: lo instala en un directorio temporal con `PacletInstall`, carga el paquete
   en un kernel nuevo (`RunProcess` de wolframscript con `Needs["CMToolkit`"]` y
   `CMToolkitVersion[]`) y verifica que la versión coincida. Después lo desinstala.
5. Imprime la ruta del archivo, su tamaño y los dos comandos para publicar (sección 3).

Mensajes del script en español. No escribe fuera de `build/` ni del directorio temporal.

### 2. `docs/INSTALACION.md` y `docs/INSTALL.en.md`

Guía de instalación para estudiantes, en español y en inglés (el mismo contenido):

- Requisito: Mathematica 15.0 o superior.
- Instalar: la línea de `PacletInstall` con la URL de la última versión, y `Needs`.
- Comprobar: `VersionCMToolkit[]` (en inglés, `CMToolkitVersion[]`).
- Actualizar: la misma línea con la URL de la versión nueva.
- Desinstalar: `PacletUninstall["CMToolkit"]`.
- Problemas comunes: sin conexión a internet (descargar el archivo y usar
  `PacletInstall["ruta/al/archivo.paclet"]`); una versión anterior que sigue cargada (reiniciar el
  kernel con Evaluación > Salir del kernel); mensajes en inglés (`$CMLanguage = "Spanish"`).
- Para desarrollo: la forma actual con `PacletDirectoryLoad`, al final.

La URL se escribe con la versión explícita (`v0.2.0`), no con «latest», para que una guía impresa
siga funcionando. El README enlaza a esta guía; eso lo hace el cierre de la versión 0.2.0, no esta
rama (para no chocar con ella).

### 3. `docs/PUBLICAR.md`

Procedimiento para el autor, paso a paso, en español:

1. En `main`, con todo mergeado: subir la versión en `PacletInfo.wl` (la sube el PR que cierra la
   versión) y correr `wolframscript -file scripts/build-paclet.wls`.
2. Crear la etiqueta y el release, adjuntando el archivo:

       git tag v0.2.0 && git push origin v0.2.0
       gh release create v0.2.0 build/CMToolkit-0.2.0.paclet --title "CMToolkit 0.2.0" --notes-file docs/releases/v0.2.0.md

3. Probar la instalación desde la URL en un notebook nuevo, en otra cuenta o computadora si se
   puede.
4. Actualizar la URL en `docs/INSTALACION.md` y `docs/INSTALL.en.md` para la versión siguiente.

Claude Code no crea etiquetas ni releases: lo hace el autor, como los commits y los PR.

### 4. `docs/releases/v0.2.0.md`

Notas de la versión, en español y luego en inglés (en el mismo archivo): qué incluye (un grado de
libertad y modos normales, con la lista de funciones por bloque y su alias), cómo instalarlo
(enlace a la guía) y qué viene en la versión siguiente (oscilador amortiguado y forzado). Solo
funciones que ya estén en `main` o en el PR que cierra la 0.2.0.

## Lo que no hace esta rama

- No cambia `README.md`, `README.en.md`, `CLAUDE.md`, `docs/ROADMAP.md` ni `PacletInfo.wl`:
  esos archivos los toca el cierre de la versión 0.2.0. En el PR se indica qué línea agregar a
  cada uno (enlace a la guía en el README; el comando del script en «Comandos» de CLAUDE.md).
- No publica nada ni sube archivos `.paclet`.
- No agrega GitHub Actions para construir el paquete: necesitarían una licencia de Wolfram en los
  servidores de GitHub.

## Revisión

Sin tests de VerificationTest: es un script de publicación. La prueba es correrlo en la
computadora del autor con la versión 0.2.0 y que el paso 4 del script pase. `scripts/check-repo.sh`
debe pasar sobre todos los archivos nuevos.
