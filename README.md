# CMToolkit

Herramientas de Wolfram Language para cursos de mecánica clásica de pregrado.
Ayudan a calcular y, sobre todo, a visualizar la física: hoy cubren pequeñas
oscilaciones, y la [hoja de ruta](docs/ROADMAP.md) describe lo que viene.

## Estado

En desarrollo (versión 0.0.x). Todavía no está listo para usar en el curso.

## Instalación

Se completará con la primera versión publicada.

Para desarrollo, desde un notebook:

```wolfram
PacletDirectoryLoad[FileNameJoin[{$HomeDirectory, "proyectos", "cm-toolkit", "CMToolkit"}]];
Needs["CMToolkit`"]
```

## Tests

Desde la raíz del repo:

```bash
wolframscript -file Tests/RunTests.wls
```

## Para contribuir

Activa una vez, en tu copia del repo, la revisión automática antes de cada commit:

```bash
git config core.hooksPath .githooks
```

La revisión (`scripts/check-repo.sh`) rechaza claves, rutas personales, notebooks con salidas y
archivos que no se publican. La misma revisión corre en cada pull request.

## Licencia

MIT
