# Especificación: movimiento y gráficos de un grado de libertad

Estado: aprobada para implementar. Versión 1.1 (6 de octubre de 2026).
- v1.1: corrige la condición inicial del retrato de fase de la revisión visual; estilo de las
  trayectorias; nombre de los mensajes de las funciones que usan el núcleo numérico; alcance de `mass`.
Requiere: `docs/specs/Equilibria.md` ya mergeado. Módulo: `Oscillations1D.wl`.
Referencia: Ayudantía 6, Problema 1, incisos (b) y (c) y sección final; Figuras 2, 3 y 4.

Con esto se cierra el bloque de un grado de libertad y la versión 0.1.0. Va en **dos ramas**,
cada una con su PR:

- Parte A, rama `feat/motion-1d`: `EnergyFunction`, `SolveMotion`, `CompareHarmonic`, `PhasePortrait`.
- Parte B, rama `feat/plots-1d`: `PotentialPlot`, `EquilibriumDiagram`, notebook de ejemplo y versión 0.1.0.

Vale todo lo común de las especificaciones anteriores: esquema bilingüe, textos en `$texts`,
mensajes con `cmMessage`, validación `time` con `autonomousForm`, criterio `zeroQ`, cálculos con
límite de tiempo y precisiones de `Equilibria.md` (v1.4).

## Reglas comunes de esta especificación

- **Lagrangiano numérico.** Las funciones que integran o grafican necesitan que todos los
  parámetros tengan valor. Si queda algún símbolo libre (aparte de la coordenada, el tiempo y,
  donde corresponda, el parámetro que se barre): mensaje `f::numeric`, que lista los símbolos que
  faltan y sugiere `L /. {m -> 1, …}`, y `$Failed`. Función privada compartida
  `numericLagrangianQ[f, Lr, permitidos]`.
- **Gráficos.** Usan `$CMPlotStyle`; las opciones del usuario tienen prioridad (se aceptan las
  opciones de la función gráfica subyacente). Etiquetas de ejes y leyendas en el idioma de
  `cmLanguage[]`, desde `$texts`. Primera curva continua, segunda punteada, como hoy. En este
  paquete, punteado significa «aproximación»: donde todas las curvas son exactas (las
  trayectorias de PhasePortrait) van todas continuas, con los colores de `$CMPlotStyle` repetidos
  de forma cíclica.
- **Tests de gráficos.** Se comprueba que el resultado es un gráfico
  (`MatchQ[g, _Graphics | _Legended]`), que no se emiten mensajes y que una opción del usuario
  (por ejemplo `ImageSize -> 200`) gana. El aspecto se revisa exportando a PNG y mirando la
  imagen; en el PR se dice qué casos se revisaron.

---

# Parte A — rama `feat/motion-1d`

## EnergyFunction / FuncionEnergia

    EnergyFunction[L, {q, t}]

La cantidad conservada de un lagrangiano que no depende explícitamente del tiempo:
h = q̇ ∂L/∂q̇ − L. Trabaja en forma simbólica.

Devuelve:

| Clave | Contenido |
| --- | --- |
| "Momentum" | p = ∂L/∂q̇, en términos de q[t] y q'[t] |
| "EnergyFunction" | h simplificada, en términos de q[t] y q'[t] |
| "Steps" | 1. momento conjugado; 2. h = q̇ p − L; 3. h simplificada; 4. conclusión: se conserva porque L no depende explícitamente de t |

Validación: `args`, `time` (un L con t explícito no tiene h conservada; el mensaje lo dice).
En "Steps", el paso 3 se muestra con los términos en el orden cinético, luego potencial.

## SolveMotion / ResolverMovimiento

    SolveMotion[L, {q, t}, {q0, v0}, tmax]

Integra numéricamente la ecuación de Euler-Lagrange exacta desde t = 0 hasta tmax, con
q(0) = q0 y q̇(0) = v0. Es el núcleo numérico que usan `CompareHarmonic` y `PhasePortrait`.

- Ecuación de movimiento: d/dt(∂L/∂q̇) − ∂L/∂q = 0, despejada para q''[t].
- `NDSolve` con `AccuracyGoal -> 10`, `PrecisionGoal -> 10` y `MaxSteps -> 10^6`, dentro de
  `TimeConstrained` (30 s).

Devuelve:

| Clave | Contenido |
| --- | --- |
| "EquationOfMotion" | q''[t] == expresión en q[t], q'[t] |
| "Solution" | la InterpolatingFunction de q, de modo que sol["Solution"][1.5] da q(1.5) |
| "Domain" | {0, tmax} |
| "InitialConditions" | {q0, v0} |
| "EnergyFunction" | h como expresión en q[t], q'[t] |
| "EnergyDrift" | máximo de \|h(t) − h(0)\| sobre una malla de 200 puntos: control de calidad de la integración |

El cálculo vive en una función privada `solveMotion1D[f, …]`, que recibe el símbolo de la función
que llama: si el estudiante llamó a PhasePortrait, el mensaje sale como `PhasePortrait::ndsolve`.
Cada función tiene sus propios textos en `$texts`.

Validación, en este orden: `args`; `time`; `numeric`; `ic` (q0, v0 y tmax deben ser números
reales, tmax > 0); `mass` (∂²L/∂q̇² es idénticamente 0, o vale 0 en la condición inicial, donde
q''(0) no queda definida; si se anula más adelante, lo informa `ndsolve`); `ndsolve` (NDSolve falla, no llega a tmax o se agota el
tiempo: el mensaje dice hasta qué t llegó).

## CompareHarmonic / CompararArmonica

    CompareHarmonic[L, {q, t}, qeq, x0, tmax]

Gráfico de la desviación exacta q(t) − qeq contra la solución armónica x0 Cos[Ω t], soltando
el sistema desde el reposo en qeq + x0. Reproduce la Figura 3.

- Ω² sale de `HarmonicExpansion` (se llama internamente con un símbolo local como desviación;
  sus mensajes se silencian y se traducen a los de esta función).
- La solución exacta sale de `SolveMotion`.
- Opción `"InitialVelocity" -> 0`: con v0 ≠ 0, la armónica es x0 Cos[Ω t] + (v0/Ω) Sin[Ω t].
- Curvas: exacta continua, armónica punteada. Leyenda «exacta» / «armónica». Ejes t y x.

Validación adicional: `noteq` (qeq no es equilibrio), `notmin` (Ω² ≤ 0: no hay oscilación
armónica que comparar; sugiere ClassifyEquilibrium).

Devuelve el gráfico. Para obtener los datos, el estudiante usa `SolveMotion` y `HarmonicExpansion`.

## PhasePortrait / RetratoDeFase

    PhasePortrait[L, {q, t}, {{q01, v01}, {q02, v02}, …}, tmax]
    PhasePortrait[L, {q, t}, {q0, v0}, tmax]        (una sola trayectoria)

Trayectorias en el plano (q, q̇), una por condición inicial, con el núcleo `solveMotion1D`.
Todas en línea continua; marca el punto inicial de cada una con el color de su trayectoria. Ejes q y q̇ (con el nombre de la coordenada). `AspectRatio -> 1` por defecto.
Si alguna trayectoria falla, se emite su mensaje y se dibujan las demás; si fallan todas, `$Failed`.

## Tests de la Parte A (Tests/Motion1D.wlt)

Anillo: `L = m b^2/2 (th'[t]^2 + w^2 Sin[th[t]]^2) - m g b Cos[th[t]]`;
anillo numérico: `ring[r_] := L /. {m -> 1, g -> 1, b -> 1, w -> r}` (así ωc = 1).

| Caso | Esperado | Fuente |
| --- | --- | --- |
| EnergyFunction del anillo | equivalente a m b^2/2 (th'[t]^2 − w^2 Sin[th[t]]^2) + m g b Cos[th[t]] | ec. (27) |
| EnergyFunction de `m/2 y'[t]^2 - k/2 y[t]^2` | m/2 y'[t]^2 + k/2 y[t]^2 (aquí h = T + V) | conocido |
| EnergyFunction con L dependiente de t | $Failed, mensaje time | |
| SolveMotion[ring[0.95], {th, t}, {Pi + 0.6, 0}, 60]: "EnergyDrift" | menor que 10⁻⁶ | ec. (27), Listado 4 |
| ídem: "EquationOfMotion" | equivalente a th''[t] == Sin[th[t]] (1 + 0.95^2 Cos[th[t]]) | ec. (26) |
| SolveMotion de `y'[t]^2/2 - y[t]^2/2` desde {1, 0}, tmax 10 | solución en t = Pi igual a −1 con tolerancia 10⁻⁶ | conocido |
| SolveMotion con el anillo simbólico | $Failed, mensaje numeric | |
| SolveMotion con tmax = −1, o q0 simbólico | $Failed, mensaje ic | |
| SolveMotion[ring[0.6], {th, t}, {Pi + 0.15, 0}, 40]: período | en t = 2 Pi/Sqrt[1 − 0.6^2] la solución vale Pi + 0.15 con tolerancia 10⁻³ (lejos del punto crítico, el período armónico es bueno) | ec. (23), Figura 3(i) |
| CompareHarmonic[ring[0.6], {th, t}, Pi, 0.15, 40] | gráfico, sin mensajes | Figura 3(i) |
| CompareHarmonic[ring[0.95], {th, t}, Pi, 0.15, 60] | gráfico, sin mensajes | Figura 3(ii) |
| CompareHarmonic[ring[1.5], {th, t}, ArcCos[-1/1.5^2], 0.1, 30] | gráfico, sin mensajes | Listado 5 |
| CompareHarmonic con qeq = 0 (máximo) | $Failed, mensaje notmin | |
| CompareHarmonic con qeq = Pi/2 | $Failed, mensaje noteq | |
| PhasePortrait[ring[0.6], {th, t}, {Pi + 0.15, 0}, 40] | gráfico, sin mensajes | «Para explorar» |
| PhasePortrait con tres condiciones iniciales | gráfico | |
| Opción del usuario en CompareHarmonic y PhasePortrait | ImageSize -> 200 gana | |
| Cuatro alias | iguales a las funciones canónicas (en los gráficos, comparar por Head y ausencia de mensajes) | |
| Mensaje en inglés | con $CMLanguage = "English" | |

Revisión visual (PNG): los dos paneles de la Figura 3 (en el segundo, la exacta debe adelantarse
a la armónica) y un retrato de fase con ring[1.3], tmax 60, con dos trayectorias en el mismo
gráfico: desde {Pi + 0.05, 0}, que queda atrapada en un pozo (h = −1.00086 < U(π) = −1), y desde
{Pi + 0.05, 0.3}, que recorre los dos (h = −0.956 > −1). Entre ambas se ve la separatriz.

---

# Parte B — rama `feat/plots-1d`

## PotentialPlot / GraficoPotencial

    PotentialPlot[L, {q, t}, {qmin, qmax}]
    PotentialPlot[L, {q, t}, {qmin, qmax}, {p, {v1, v2, …}}]

Grafica el potencial efectivo U(q) = −L con q̇ = 0. La segunda forma dibuja una curva por cada
valor del parámetro p, con leyenda «p = valor». Reproduce la Figura 2.

- Marca los mínimos de cada curva con un punto (opción `"MarkMinima" -> True`).
- Opción `"Energy" -> None`: con un número, dibuja una línea horizontal punteada en esa energía.
- Ejes: la coordenada y «U».
- Función privada `potentialMinima[U, qs, {qmin, qmax}]`: mínimos locales en el intervalo
  (muestreo en 400 puntos y refinamiento con `FindMinimum`), sin duplicados y sin los extremos
  del intervalo.

Validación: `args`, `time`, `range` (qmin, qmax reales con qmin < qmax), `param` (p no es un
símbolo que aparezca en L, o la lista de valores no es numérica), `numeric`.

## EquilibriumDiagram / DiagramaEquilibrios

    EquilibriumDiagram[L, {q, t}, {p, pmin, pmax}, {qmin, qmax}]

Posiciones de equilibrio en función de un parámetro: el diagrama de bifurcación de la Figura 4(i).
Estables en línea continua, inestables en línea punteada.

- Curvas U'(q; p) = 0 en el plano (p, q), con `ContourPlot`. La parte estable es la región
  U''(q; p) > 0 y la inestable U'' < 0 (dos gráficos con `RegionFunction`, combinados).
- Leyenda «estable» / «inestable». Ejes: el parámetro y la coordenada.
- Todos los demás parámetros deben ser numéricos.

Validación: `args`, `time`, `range` (para ambos intervalos), `param`, `numeric`.

## Notebook de ejemplo

`Examples/AnilloQueRota.nb`: el problema del anillo resuelto con el paquete, de principio a fin,
con los nombres en español:
lagrangiano, `PuntosDeEquilibrio`, `ClasificarEquilibrio` (en π y en θ0), `GraficoPotencial`,
`ExpansionArmonica` y `MostrarPasos`, `FuncionEnergia`, `CompararArmonica` (los dos casos de la
Figura 3), `DiagramaEquilibrios` y `RetratoDeFase`.

- Celdas de texto breves antes de cada paso, que digan qué pregunta física responde.
- Sin salidas, sin rutas personales y sin nombre de curso, institución ni persona.
- Empieza con `Needs["CMToolkit`"]` y una celda de texto que explica cómo cargar el paquete.
- Se genera como expresión `Notebook[{Cell[…], …}]`. Verificación: extraer las celdas "Input" y
  evaluarlas en orden con wolframscript, sin mensajes. `scripts/check-repo.sh --all` debe pasar.

## Cierre de la versión 0.1.0

- `PacletInfo.wl`: "Version" -> "0.1.0".
- `README.md`: estado actualizado y un ejemplo mínimo con los nombres en inglés.
- `docs/ROADMAP.md`: bloque de un grado de libertad completo como «Hecho».
- `CLAUDE.md`, sección Estructura: lista de funciones del módulo.

## Tests de la Parte B (Tests/Plots1D.wlt)

| Caso | Esperado | Fuente |
| --- | --- | --- |
| potentialMinima del anillo con r = 0.7 en {0, 2 Pi} | {Pi} (tolerancia 10⁻⁶) | Figura 2 |
| potentialMinima con r = 1.3 | {ArcCos[-1/1.3^2], 2 Pi − ArcCos[-1/1.3^2]} | ec. (10) |
| potentialMinima con r = 1 | {Pi} (mínimo cuártico) | ec. (13) |
| PotentialPlot[ring[0.7], {th, t}, {0, 2 Pi}] | gráfico, sin mensajes | Figura 2 |
| PotentialPlot con {w, {0, 0.7, 1, 1.3, 1.6}} y m = g = b = 1 | gráfico con leyenda | Figura 2 |
| PotentialPlot con "Energy" -> 0 | gráfico | |
| PotentialPlot con el anillo simbólico | $Failed, mensaje numeric | |
| PotentialPlot con {2 Pi, 0} | $Failed, mensaje range | |
| PotentialPlot con parámetro que no está en L | $Failed, mensaje param | |
| EquilibriumDiagram con m = g = b = 1, {w, 0, 2.5}, {-1, 7} | gráfico, sin mensajes | Figura 4(i) |
| EquilibriumDiagram con otro símbolo libre | $Failed, mensaje numeric | |
| Opción del usuario | ImageSize -> 200 gana en ambas | |
| Dos alias | iguales a las canónicas | |

Revisión visual (PNG): la Figura 2 (cinco curvas; un mínimo en π que se divide en dos al pasar
r = 1) y la Figura 4(i) (la rama π continua hasta w = 1 y punteada después; dos ramas continuas
que nacen en w = 1; las ramas 0 y 2π punteadas; se usa el intervalo {-1, 7} para que esas
ramas no queden en el borde del gráfico).
