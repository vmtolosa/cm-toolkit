# CMToolkit

Herramientas de Wolfram Language para mecánica clásica de pregrado:
pequeñas oscilaciones, modos normales, oscilaciones amortiguadas y forzadas,
y correcciones anarmónicas. Pensado para el curso FIS210.

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

## Licencia

MIT
