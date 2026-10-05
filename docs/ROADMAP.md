# Hoja de ruta de CMToolkit

## Visión

Un paquete de Wolfram Language que acompaña un curso de mecánica clásica de pregrado completo.
Le quita al estudiante el álgebra que no enseña nada nuevo (derivar, expandir, diagonalizar,
integrar numéricamente) sin quitarle la física: el estudiante sigue planteando el problema, y el
paquete muestra los pasos intermedios y visualiza el resultado.

## Principios que toda función cumple

1. **El estudiante plantea el problema.** La entrada es el lagrangiano, la fuerza o la geometría
   del sistema, no la respuesta ya digerida.
2. **Los pasos son visibles.** Las funciones de análisis devuelven una Association con "Steps",
   en el orden en que se harían a mano, y `ShowSteps` los muestra como tabla.
3. **Se puede ver.** Cada módulo trae al menos una visualización: gráfico, animación o
   `Manipulate`.
4. **Bilingüe.** Nombre canónico en inglés y alias en español; mensajes, pasos y etiquetas en el
   idioma de `$CMLanguage`.
5. **Verificado contra el material del curso.** Los tests salen de guías y ayudantías reales, o de
   casos con solución conocida documentados en la especificación.
6. **Genérico.** El paquete no menciona ningún curso, institución ni persona en particular.

## Módulos

Los temas siguen el orden habitual de un curso de mecánica clásica de pregrado. El estado es el
del módulo dentro del paquete.

| # | Tema | Módulo del paquete | Estado |
| --- | --- | --- | --- |
| — | Infraestructura | Estilo gráfico, idioma, alias, `ShowSteps` | Hecho |
| 1–2 | Mecánica newtoniana; ecuaciones de movimiento de una partícula | Trayectorias, fuerzas, retratos de fase simples | Por diseñar |
| 3 | Cálculo de variaciones | Funcionales y ecuación de Euler; braquistócrona y curvas extremales | Por diseñar |
| 4–7 | Dinámica lagrangiana, mínima acción, coordenadas generalizadas, conservación | **Núcleo lagrangiano**: ecuaciones de Euler-Lagrange, potencial efectivo, cantidades conservadas | Por diseñar (prioritario: lo usan casi todos los demás módulos) |
| 8 | Campo central | Potencial efectivo radial, órbitas, puntos de retorno | Por diseñar |
| 9–10 | Sistemas de partículas; colisiones y sección eficaz | Centro de masa, colisiones, sección eficaz | Por diseñar |
| **11** | **Oscilaciones lineales y forzadas** | **Ver detalle abajo** | **En curso** |
| 12 | Masa distribuida; masa variable | Por definir | Por diseñar |
| 13 | Trabajos virtuales | Por definir | Por diseñar |
| 14–15 | Ecuaciones de Hamilton; espacio de fase y teorema de Liouville | Flujo en el espacio de fase, conservación del área | Por diseñar |

### Detalle del tema 11: oscilaciones

| Bloque | Funciones | Estado |
| --- | --- | --- |
| Un grado de libertad | `HarmonicExpansion`, `ShowSteps` | Hecho |
| | `ClassifyEquilibrium`, `EquilibriumPoints`, `EnergyFunction`, `CompareHarmonic` | Siguiente |
| | `PotentialPlot`, `EquilibriumDiagram`, `PhasePortrait` | Pendiente |
| Modos normales en N dimensiones | `SmallOscillations` (M y K desde un lagrangiano de N coordenadas) | Pendiente |
| | `SpringNetwork` (redes de resortes en 2D y 3D) | Pendiente |
| | `NormalModes` (degeneración, base M-ortonormal), `NormalCoordinates`, `ModeResponse` | Pendiente |
| | `ModeGallery`, `AnimateMode` (2D y 3D), `AnimateMotion`, `SpectrumPlot`, `EnergySharesChart` | Pendiente |
| Amortiguadas y forzadas | `DampedOscillator`, `ResonanceCurve`, `TransientPlot` | Pendiente |
| Funciones de Green | `GreenFunction`, `GreenSolution`, `ConvolutionExplorer`, `ImpulseSuperposition`, `SolutionDecompositionPlot`, `InitialConditionExplorer` | Pendiente |
| Oscilaciones no lineales y perturbaciones | Poincaré–Lindstedt y similares | Fuera de alcance por ahora |

Notación del oscilador amortiguado y forzado: ẍ + 2γ ẋ + ω₀² x = F(t)/m.

## Versiones

| Versión | Contenido | Para estudiantes |
| --- | --- | --- |
| 0.1.0 | Un grado de libertad completo, con `Examples/` | No |
| 0.2.0 | Modos normales en N dimensiones, con animaciones | Primera versión publicada |
| 0.3.0 | Amortiguadas, forzadas y funciones de Green | Sí |
| 0.4.0 en adelante | Núcleo lagrangiano y los demás temas, según el calendario del curso | Sí |

El orden de los temas después de 0.3.0 se decide según lo que el curso esté viendo en cada
momento. El núcleo lagrangiano tiene prioridad porque los demás módulos lo reutilizan.

## Cómo se agrega un módulo

1. Especificación en `docs/specs/<módulo>/`, discutida y aprobada antes de escribir código.
2. Rama `feat/<nombre>`, tests primero, implementación, `RunTests.wls` en verde.
3. Pull request con revisión; el merge lo hace quien mantiene el repositorio.
4. Notebook de ejemplo en `Examples/`, guardado sin salidas.
5. Actualizar el estado en esta hoja de ruta.
