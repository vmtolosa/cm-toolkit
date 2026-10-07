<p align="center"><b>Español</b> · <a href="README.en.md">English</a></p>

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

## Motivación

En un curso de mecánica clásica, el álgebra suele tapar la física. Este paquete nació en las
ayudantías de un curso de pregrado para que quien recién aprende Mathematica pueda calcular y,
sobre todo, ver lo que está pasando: el potencial, los equilibrios, los modos, la respuesta a una
fuerza. Cada función muestra los pasos intermedios en el orden en que se harían a mano, para
acompañar el desarrollo y no reemplazarlo.

## Por qué en dos idiomas

Los nombres canónicos de las funciones están en inglés, como el resto de Wolfram Language y la
bibliografía. Cada función tiene además un alias en español, para que un estudiante
hispanohablante pueda leer su código en su idioma. Los mensajes, los pasos y las etiquetas de los
gráficos salen en el idioma que elija el usuario con `$CMLanguage` (`"Spanish"`, por defecto, o
`"English"`).

```wolfram
res = HarmonicExpansion[L, {x, t}, 0, u];   (* nombre canónico *)
ExpansionArmonica[L, {x, t}, 0, u] === res  (* alias en español: mismo resultado *)
(* True *)

$CMLanguage = "English";   (* desde aquí, mensajes, pasos y etiquetas en inglés *)
```

Los mensajes de error siempre llevan el nombre canónico, aunque se llame al alias. El alias de
cada función aparece en su ayuda: `?HarmonicExpansion`.

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

## Qué puede hacer hoy

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

## Hoja de ruta

Fuente: [docs/ROADMAP.md](docs/ROADMAP.md). Los temas siguen el orden habitual de un curso de
mecánica clásica de pregrado. Estados:

- **Disponible**: ya está en `main`.
- **En desarrollo**: se está implementando.
- **Especificado**: tiene una especificación aprobada en [`docs/specs`](docs/specs), todavía sin código.
- **Por diseñar**: aún no tiene especificación.

### Todos los temas

| # | Tema | Módulo del paquete | Estado |
| --- | --- | --- | --- |
| — | Infraestructura | Estilo gráfico, idioma, alias, `ShowSteps` | Disponible |
| 1–2 | Mecánica newtoniana; ecuaciones de movimiento de una partícula | Trayectorias, fuerzas, retratos de fase simples | Por diseñar |
| 3 | Cálculo de variaciones | Funcionales y ecuación de Euler; braquistócrona y curvas extremales | Por diseñar |
| 4–7 | Dinámica lagrangiana, mínima acción, coordenadas generalizadas, conservación | Núcleo lagrangiano: ecuaciones de Euler-Lagrange, potencial efectivo, cantidades conservadas. Prioritario: lo usan casi todos los demás módulos | Por diseñar |
| 8 | Campo central | Potencial efectivo radial, órbitas, puntos de retorno | Por diseñar |
| 9–10 | Sistemas de partículas; colisiones y sección eficaz | Centro de masa, colisiones, sección eficaz | Por diseñar |
| 11 | Oscilaciones lineales y forzadas | Ver el detalle por versión, abajo | En desarrollo |
| 12 | Masa distribuida; masa variable | Por definir | Por diseñar |
| 13 | Trabajos virtuales | Por definir | Por diseñar |
| 14–15 | Ecuaciones de Hamilton; espacio de fase y teorema de Liouville | Flujo en el espacio de fase, conservación del área | Por diseñar |

Dos especificaciones más tratan la organización interna y no agregan funciones nuevas:
[Modulos.md](docs/specs/Modulos.md) (división del paquete en módulos) y
[Ajustes1D.md](docs/specs/Ajustes1D.md) (correcciones y mejoras de presentación del bloque de un
grado de libertad).

### Detalle del tema 11: oscilaciones

**Versión 0.1.0: un grado de libertad.** Encontrar y clasificar los equilibrios de un lagrangiano,
expandir en torno a ellos, integrar el movimiento exacto y compararlo con la aproximación
armónica, y dibujar el potencial y el diagrama de equilibrios en función de un parámetro.

| Funciones | Qué permite hacer | Especificación | Estado |
| --- | --- | --- | --- |
| `EquilibriumPoints`, `ClassifyEquilibrium` | Puntos de equilibrio con su condición de existencia; mínimo, máximo, punto de inflexión o caso que depende de los parámetros | [Equilibria.md](docs/specs/Equilibria.md) | Disponible |
| `HarmonicExpansion`, `ShowSteps` | Masa efectiva, serie del potencial, lagrangiano armónico, cota de amplitud y frecuencia, con los pasos en una tabla | [HarmonicExpansion.md](docs/specs/HarmonicExpansion.md) | Disponible |
| `EnergyFunction`, `SolveMotion`, `CompareHarmonic`, `PhasePortrait` | Función energía conservada, integración numérica de la ecuación exacta, comparación con la armónica y retrato de fase | [Motion1D.md](docs/specs/Motion1D.md) (parte A) | Disponible |
| `PotentialPlot`, `EquilibriumDiagram` | Potencial efectivo con una curva por valor de un parámetro y sus mínimos marcados; diagrama de equilibrios estables e inestables en función de un parámetro; notebook de ejemplo | [Motion1D.md](docs/specs/Motion1D.md) (parte B) | En desarrollo |

**Versión 0.2.0: modos normales en N dimensiones.** Construir redes de masas y resortes en 1, 2 y
3 dimensiones (o partir de cualquier lagrangiano de N coordenadas), obtener sus modos normales,
también en subespacios degenerados, pasar a coordenadas normales y seguir el movimiento a partir de
condiciones iniciales, con la energía de cada modo. Galería de modos, animaciones de cada modo y
del movimiento completo, y espectro en función de un parámetro. Según la hoja de ruta, será la
primera versión publicada.

| Funciones | Qué permite hacer | Especificación | Estado |
| --- | --- | --- | --- |
| `SpringNetwork`, `SmallOscillations`, `NormalModes`, `NormalCoordinates`, `ModeResponse` | Matrices de masas y de constantes elásticas; frecuencias y modos Mmat-ortonormales, con una base elegida por el usuario si se quiere; coordenadas normales y lagrangiano diagonal; respuesta a condiciones iniciales y fracción de energía en cada modo | [NormalModes.md](docs/specs/NormalModes.md) (parte A) | Especificado |
| `ModeGallery`, `AnimateMode`, `AnimateMotion`, `SpectrumPlot`, `EnergySharesChart` | Todos los modos en una grilla, animación de un modo o del movimiento completo (en 1D, 2D y 3D), ω² en función de un parámetro y barras con la energía de cada modo; notebook de ejemplo | [NormalModes.md](docs/specs/NormalModes.md) (parte B) | Especificado |

**Versión 0.3.0: oscilador amortiguado y forzado, funciones de Green.** Clasificar el régimen del
oscilador ẍ + 2γ ẋ + ω₀² x = F(t)/m, obtener su función de Green y construir con ella la
respuesta a cualquier fuerza, separando la parte homogénea (que depende de las condiciones
iniciales) de la particular (que depende de la fuerza). Curva de resonancia y exploradores
interactivos.

| Funciones | Qué permite hacer | Especificación | Estado |
| --- | --- | --- | --- |
| `DampedOscillator`, `GreenFunction`, `GreenSolution`, `SteadyState` | Régimen, raíces características, factor de calidad; función de Green causal en los cuatro regímenes; solución por convolución para fuerzas constantes, sinusoidales, escalones, pulsos o golpes; amplitud y fase estacionarias y frecuencia de resonancia | [DrivenOscillator.md](docs/specs/DrivenOscillator.md) (parte A) | Especificado |
| `ResonanceCurve`, `SolutionDecompositionPlot`, `InitialConditionExplorer`, `ConvolutionExplorer`, `ImpulseSuperposition` | Curva de resonancia; descomposición en homogénea, particular y total; exploradores con deslizadores para las condiciones iniciales y para la convolución; la fuerza como suma de golpes; notebook de ejemplo | [DrivenOscillator.md](docs/specs/DrivenOscillator.md) (parte B) | Especificado |

**Oscilaciones no lineales y perturbaciones** (Poincaré–Lindstedt y similares): por diseñar; la
hoja de ruta las deja fuera de alcance por ahora.

**Versión 0.4.0 en adelante:** el núcleo lagrangiano y los demás temas de la tabla. Por diseñar.
El orden se decide según lo que el curso esté viendo en cada momento; el núcleo lagrangiano tiene
prioridad porque los demás módulos lo reutilizan.

## Principios de diseño

1. **El estudiante plantea el problema.** La entrada es el lagrangiano, la fuerza o la geometría
   del sistema, no la respuesta ya digerida.
2. **Los pasos son visibles.** Las funciones de análisis devuelven sus pasos intermedios, en el
   orden en que se harían a mano, y `ShowSteps` los muestra como tabla.
3. **Se puede ver.** Cada módulo trae al menos una visualización: gráfico, animación o
   `Manipulate`.
4. **Bilingüe.** Nombre canónico en inglés y alias en español; mensajes, pasos y etiquetas en el
   idioma de `$CMLanguage`.
5. **Verificado.** Los tests salen de problemas de curso o de casos con solución conocida
   documentados en la especificación.
6. **Genérico.** El paquete no menciona ningún curso, institución ni persona en particular.

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

## Licencia

[MIT](LICENSE)
