# Especificación: reorganización en módulos

Estado: aprobada para implementar. Versión 1 (4 de octubre de 2026).
Tipo: refactorización. **No cambia ningún comportamiento público.** Va en su propia rama y su
propio PR (`refactor/modulos`), antes de las funciones nuevas de `docs/specs/Equilibria.md`.

## Por qué

`CMToolkit/Kernel/CMToolkit.wl` ya tiene unas 285 líneas y va a crecer con cada módulo de la hoja
de ruta. Además, el cálculo de los coeficientes de la serie del potencial dentro de
`HarmonicExpansion` es difícil de leer (un `SelectFirst` que agrega elementos mientras busca) y lo
van a necesitar también `ClassifyEquilibrium` y otras funciones.

## Estructura de archivos

    CMToolkit/Kernel/
      CMToolkit.wl        cargador: BeginPackage, carga los módulos en orden, EndPackage
      Core.wl             idioma, $texts, tr, cmMessage, defineAlias, zeroQ, $CMPlotStyle,
                          CMPlot, ShowSteps, CMToolkitVersion
      Oscillations1D.wl   HarmonicExpansion y, después, el resto del bloque de un grado de libertad

    Tests/
      Basics.wlt          sin cambios
      HarmonicExpansion.wlt  sin cambios en los tests

Requisitos de la carga:
- `Needs["CMToolkit`"]` sigue cargando todo, igual que hoy.
- Cada módulo declara sus símbolos públicos (con `::usage` bilingüe) en el contexto
  `CMToolkit``, y su implementación en `CMToolkit`Private``.
- Cada módulo agrega sus textos a `$texts` (por ejemplo con `AssociateTo` o `Join`), en vez de
  tener una sola tabla gigante. Los textos de Core quedan en Core.wl.
- Los `defineAlias` de cada módulo van al final de ese módulo.
- Ningún símbolo nuevo en `Global`` ni contexto nuevo en `$ContextPath` después de cargar.
- El orden de carga es explícito en `CMToolkit.wl` (Core primero).

## Funciones privadas compartidas (en Oscillations1D.wl)

Se extraen de `HarmonicExpansion` sin cambiar su resultado:

| Función privada | Qué hace |
| --- | --- |
| `validateDeviation1D[f, x, q, t, L, q0]` | El chequeo de `dev`; emite `f::dev` y devuelve False si falla. |
| `autonomousForm[f, L, q, t]` | Reemplaza q[t] y q'[t] por símbolos locales; emite `f::time` y devuelve $Failed si queda t. |
| `assumptions1D[opt, L, q, t, q0, x]` | Las suposiciones automáticas o las del usuario (hoy `heAssumptions`). |
| `potentialCoefficients[U, qs, q0, asm, nmax]` | Devuelve `<\|"Coefficients" -> {c0, …, c_m}, "FirstNonzero" -> n \| None\|>`: calcula c0, c1 y c2, y después c3, c4, … hasta encontrar el primer no nulo o llegar a nmax. Los coeficientes que `zeroQ` declara cero quedan como 0 exacto. Se escribe con un bucle simple y legible, no con efectos dentro de `SelectFirst`. |

`f` es el símbolo de la función que llama (`HarmonicExpansion`, más adelante `ClassifyEquilibrium`),
para que el mensaje salga con su nombre.

`zeroQ` pasa a Core.wl porque es de uso general.

## Criterio de aceptación

- Los 48 tests actuales (`Basics.wlt` 13, `HarmonicExpansion.wlt` 35) pasan **sin modificar
  ninguno**.
- `ShowSteps` del anillo produce la misma imagen que antes (comparar los PNG).
- `scripts/check-repo.sh --all` sin problemas.
- `CLAUDE.md`, sección Estructura, actualizada con los archivos nuevos.

Commits sugeridos: (1) separar en Core.wl y Oscillations1D.wl sin tocar el código;
(2) extraer las funciones privadas compartidas; (3) CLAUDE.md.
