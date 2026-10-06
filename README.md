<h1 align="center">CMToolkit</h1>

<p align="center">
  <b>Mecánica clásica en Wolfram Language: tú planteas la física, el paquete muestra los pasos y dibuja el resultado.</b>
</p>

<p align="center">
  <a href="LICENSE"><img alt="Licencia MIT" src="https://img.shields.io/badge/licencia-MIT-blue"></a>
  <img alt="Wolfram Language 15 o superior" src="https://img.shields.io/badge/Wolfram%20Language-15%2B-red">
  <img alt="Estado: en desarrollo" src="https://img.shields.io/badge/estado-en%20desarrollo-orange">
  <a href="https://github.com/vmtolosa/cm-toolkit/actions/workflows/check-repo.yml"><img alt="Revisión del repositorio" src="https://github.com/vmtolosa/cm-toolkit/actions/workflows/check-repo.yml/badge.svg"></a>
</p>

<p align="center">
  <img src="docs/img/comparar-armonica.png" width="640" alt="Solución exacta contra la aproximación armónica: la exacta, en línea continua, se va atrasando respecto a la armónica, en línea punteada">
</p>

CMToolkit es un paquete para cursos de mecánica clásica de pregrado. Está pensado para
estudiantes que recién aprenden Mathematica: les quita el álgebra que no enseña nada nuevo
(derivar, expandir, factorizar, integrar numéricamente) sin quitarles la física.

- **Tú planteas el problema.** La entrada es el lagrangiano, no la respuesta.
- **Los pasos quedan a la vista.** Cada resultado trae sus pasos intermedios, en el orden en que
  se harían a mano, y `ShowSteps` los muestra como tabla.
- **Se puede ver.** Cada bloque trae gráficos con un estilo común: línea continua para lo exacto,
  punteada para lo aproximado.
- **En español y en inglés.** Cada función tiene los dos nombres (`HarmonicExpansion` y
  `ExpansionArmonica`), y los mensajes y pasos salen en el idioma que elijas.

## Un ejemplo

Una masa desliza por un riel horizontal, unida a un resorte de largo natural `l0` cuyo otro
extremo está fijo a una altura `h` sobre el riel. Si el resorte es más largo que esa altura, el
centro deja de ser estable y aparecen dos equilibrios a los lados.

```wolfram
Needs["CMToolkit`"]

L = m/2 x'[t]^2 - k/2 (Sqrt[x[t]^2 + h^2] - l0)^2;

EquilibriumPoints[L, {x, t}]["Points"]
(* x = 0 siempre; x = ±Sqrt[l0^2 - h^2] si h < l0 *)

ClassifyEquilibrium[L, {x, t}, 0, u]["Conditions"]
(* mínimo si l0 < h, máximo si l0 > h, crítico si h == l0 *)

res = HarmonicExpansion[L, {x, t}, 0, u];
res["Omega2"]
(* k (h - l0)/(h m) *)

ShowSteps[res]
(* la tabla con los diez pasos: potencial efectivo, masa efectiva, serie de Taylor,
   lagrangiano armónico, cota de amplitud, ecuación de movimiento y frecuencia *)
```

Con números, se compara la solución exacta con la aproximación armónica (la figura de arriba,
con una desviación inicial grande para que se note la diferencia) y se integra el movimiento
desde cualquier condición inicial:

```wolfram
Lnum = L /. {m -> 1, k -> 1, h -> 1, l0 -> 1.6};

CompareHarmonic[Lnum, {x, t}, Sqrt[1.6^2 - 1], 0.5, 40]

solA = SolveMotion[Lnum, {x, t}, {0.05, 0}, 40];     (* desde el reposo: queda en un pozo *)
solB = SolveMotion[Lnum, {x, t}, {0.05, 0.3}, 40];   (* con un empujón: recorre los dos *)
```

<p align="center">
  <img src="docs/img/dos-movimientos.png" width="640" alt="Dos movimientos desde cerca del centro inestable: sin empujón la masa queda en un pozo; con empujón recorre los dos">
</p>

## Qué incluye

| Bloque | Funciones | Estado |
| --- | --- | --- |
| Equilibrios | `EquilibriumPoints`, `ClassifyEquilibrium` | Disponible |
| Pequeñas oscilaciones | `HarmonicExpansion`, `ShowSteps` | Disponible |
| Movimiento exacto | `EnergyFunction`, `SolveMotion`, `CompareHarmonic`, `PhasePortrait` | Disponible |
| Gráficos de un grado de libertad | `PotentialPlot`, `EquilibriumDiagram` | En desarrollo |
| Modos normales en 1, 2 y 3 dimensiones | `SpringNetwork`, `NormalModes`, `ModeResponse`, animaciones | Especificado |
| Oscilador amortiguado y forzado, funciones de Green | `DampedOscillator`, `GreenFunction`, `GreenSolution`, exploradores interactivos | Especificado |

Los nombres en español de cada función están en su ayuda: `?HarmonicExpansion`.
El plan completo, con los demás temas de un curso de mecánica clásica, está en la
[hoja de ruta](docs/ROADMAP.md).

## Instalación

Todavía no hay una versión publicada. Para probar la versión en desarrollo, clona el repositorio
y carga el paquete desde su carpeta:

```wolfram
PacletDirectoryLoad["ruta/al/repositorio/CMToolkit"];
Needs["CMToolkit`"]
```

Requiere Mathematica o Wolfram Engine 15.0 o superior.

## Cómo está hecho

- Cada función parte de una especificación escrita en [`docs/specs`](docs/specs), con los casos
  de prueba tomados de problemas de curso y de sistemas con solución conocida.
- Los tests corren con `wolframscript -file Tests/RunTests.wls`.
- El código se escribe con ayuda de Claude y se revisa en un pull request antes de entrar a `main`.

## Para contribuir

Activa una vez, en tu copia del repositorio, la revisión automática antes de cada commit:

```bash
git config core.hooksPath .githooks
```

La revisión (`scripts/check-repo.sh`) rechaza claves, rutas personales, notebooks con salidas y
archivos que no se publican. La misma revisión corre en cada pull request.

## In English

CMToolkit is a Wolfram Language package for undergraduate classical mechanics. You write the
Lagrangian; the package finds and classifies equilibria, expands around them, integrates the exact
motion and compares it with the harmonic approximation, showing every intermediate step along the
way. Every function has an English and a Spanish name, and messages and steps follow
`$CMLanguage` (`"Spanish"` by default, or `"English"`). It is under active development.

## Licencia

[MIT](LICENSE)
