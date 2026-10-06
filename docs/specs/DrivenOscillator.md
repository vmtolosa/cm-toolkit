# Especificación: oscilador amortiguado y forzado, y funciones de Green

Estado: aprobada para implementar. Versión 1 (6 de octubre de 2026).
Módulo nuevo: `CMToolkit/Kernel/DrivenOscillator.wl` (se agrega al cargador).
Versión del paquete al terminar: 0.3.0.

Notación (la de `CLAUDE.md`): ẍ + 2γ ẋ + ω₀² x = F(t)/m, con γ ≥ 0 el coeficiente de
amortiguamiento y ω₀ > 0 la frecuencia natural.

Va en **dos ramas**, cada una con su PR:

- Parte A, rama `feat/driven`: cálculo. `DampedOscillator`, `GreenFunction`, `GreenSolution`,
  `SteadyState`.
- Parte B, rama `feat/driven-plots`: visualización. `ResonanceCurve`,
  `SolutionDecompositionPlot`, `ConvolutionExplorer`, `ImpulseSuperposition`,
  `InitialConditionExplorer`, notebook de ejemplo y versión 0.3.0.

Vale todo lo común de las especificaciones anteriores (bilingüe, `$texts`, `cmMessage`, `zeroQ`,
"Steps", límites de tiempo, reglas de gráficos de `Motion1D.md`).

## Idea pedagógica

La función de Green G(τ) es la respuesta del oscilador a un golpe unitario. Con ella se
construye todo: la solución particular es la suma de las respuestas a los golpes en que se
descompone la fuerza (convolución), y la solución homogénea es la respuesta a los «golpes» que
fijan las condiciones iniciales. Las condiciones iniciales afectan solo a la parte homogénea;
la fuerza, solo a la particular. Cada función y cada gráfico de este módulo muestra una cara de
esa idea.

---

# Parte A — rama `feat/driven`

## DampedOscillator / OsciladorAmortiguado

    DampedOscillator[m, γ, ω0]
    DampedOscillator[m, b, k, "Form" -> "MBK"]      (m ẍ + b ẋ + k x = F: γ = b/(2m), ω0² = k/m)

Describe el sistema. Es el objeto que reciben las demás funciones.

Régimen, según el signo de ω₀² − γ² bajo las suposiciones (`Assumptions -> Automatic`: los
parámetros simbólicos son reales positivos):

| Caso | "Regime" |
| --- | --- |
| γ = 0 | "Undamped" |
| 0 < γ < ω0 | "Underdamped" |
| γ = ω0 | "Critical" |
| γ > ω0 | "Overdamped" |

Si el régimen no se puede decidir (γ y ω0 simbólicos sin relación entre ellos): mensaje
`regime`, que pide dar `Assumptions -> γ < ω0` (por ejemplo) o `"Regime" -> "Underdamped"`, y
`$Failed`. La opción `"Regime"` declara el régimen y agrega la suposición correspondiente; si
contradice a los valores numéricos, mensaje `regime` y `$Failed`. No se adivina.

Devuelve:

| Clave | Contenido |
| --- | --- |
| "Mass", "Gamma", "Omega0" | m, γ, ω0 |
| "Regime", "Assumptions" | régimen y suposiciones usadas (incluida la del régimen) |
| "Equation" | la ecuación homogénea con \[FormalX] y \[FormalT] |
| "CharacteristicRoots" | raíces de r² + 2γ r + ω0² = 0 |
| "OmegaD" | Sqrt[ω0² − γ²] en el régimen subamortiguado; Γ = Sqrt[γ² − ω0²] en el sobreamortiguado (clave "GammaD"); la que no aplica, Missing["NotApplicable"] |
| "QualityFactor" | ω0/(2γ); Infinity si γ = 0 |
| "DecayTime" | 1/γ; Infinity si γ = 0 |
| "Steps" | ecuación; ensayo e^{r t} y ecuación característica; raíces; régimen y qué significa físicamente |

Validación: `args`; `params` (m y ω0 deben ser positivos, γ no negativo, cuando son numéricos).

## GreenFunction / FuncionDeGreen

    GreenFunction[osc, τ]

Función de Green causal: solución de G'' + 2γ G' + ω0² G = δ(τ)/m con G = 0 para τ < 0.

| Régimen | G(τ) para τ > 0 |
| --- | --- |
| "Undamped" | Sin[ω0 τ]/(m ω0) |
| "Underdamped" | e^{−γτ} Sin[ω_d τ]/(m ω_d) |
| "Critical" | τ e^{−γτ}/m |
| "Overdamped" | e^{−γτ} Sinh[Γ τ]/(m Γ) |

Devuelve:

| Clave | Contenido |
| --- | --- |
| "GreenFunction" | G(τ) completa, con el factor `HeavisideTheta[τ]` |
| "Causal" | la expresión para τ > 0, sin el escalón (la que se usa para calcular) |
| "Variable" | τ |
| "Steps" | 1. ecuación con δ; 2. para τ < 0, G = 0 (causalidad); 3. para τ > 0, ecuación homogénea; 4. condiciones en τ = 0: G continua y salto de G' igual a 1/m; 5. resultado |

Validación: `args`; `var` (τ debe ser un símbolo sin valor que no aparezca en el oscilador).

## GreenSolution / SolucionDeGreen

    GreenSolution[osc, F, {t, t0}, {x0, v0}]

Solución de m(ẍ + 2γ ẋ + ω0² x) = F(t) para t ≥ t0 con x(t0) = x0 y ẋ(t0) = v0.
`F` es cualquier expresión en t: constante, `Sin`, exponencial, `UnitStep`/`HeavisideTheta`,
`Piecewise`, `DiracDelta`. Los cuatro argumentos son obligatorios.

- Particular: x_p(t) = ∫ G(t − t′) F(t′) dt′ desde t0 hasta t. Parte en reposo:
  x_p(t0) = 0 y ẋ_p(t0) = 0, cualquiera sea la fuerza.
- Homogénea: x_h(t) = m [ v0 G(t − t0) + x0 ( G′(t − t0) + 2γ G(t − t0) ) ].
  Cumple x_h(t0) = x0 y ẋ_h(t0) = v0.
- Total: x = x_h + x_p.

La integral se intenta de forma simbólica (`Integrate` con las suposiciones y t > t0, dentro de
`TimeConstrained` de 20 s). Si no da forma cerrada o se agota el tiempo y todo es numérico,
se calcula numéricamente: "Particular" es entonces una función de interpolación en t ∈ [t0, tmax]
(opción `"MaxTime" -> 50`, usada solo en ese caso) y "Method" -> "Numeric". Si no hay forma
cerrada y quedan parámetros simbólicos: mensaje `integral`; se devuelve igual la Association, con
"Particular" como la integral sin evaluar.

Devuelve:

| Clave | Contenido |
| --- | --- |
| "Homogeneous", "Particular", "Total" | expresiones en t (válidas para t ≥ t0) |
| "ConvolutionIntegral" | la integral escrita sin evaluar (`Inactive[Integrate]`), para que se vea de dónde sale x_p |
| "GreenFunction" | la expresión causal usada |
| "Force", "Time", "InitialTime", "InitialConditions" | F, t, t0, {x0, v0} |
| "Method" | "Symbolic" o "Numeric" |
| "Oscillator" | el objeto `osc` |
| "Steps" | 1. ecuación; 2. función de Green; 3. integral de convolución; 4. solución particular; 5. solución homogénea con las condiciones iniciales; 6. solución total; 7. nota: las condiciones iniciales solo entran en x_h |

Validación: `args`; `var`; `ic` (t0, x0, v0 no pueden contener t).

## SteadyState / EstadoEstacionario

    SteadyState[osc, F0, ω]

Respuesta estacionaria a F(t) = F0 Cos[ω t]: x(t) = A Cos[ω t − δ].

| Clave | Contenido |
| --- | --- |
| "Amplitude" | A = (F0/m)/Sqrt[(ω0² − ω²)² + 4γ² ω²] |
| "Phase" | δ = ArcTan[ω0² − ω², 2γ ω] (entre 0 y π) |
| "Susceptibility" | χ(ω) = 1/(m (ω0² − ω² + 2 i γ ω)); la amplitud es F0 \|χ\| |
| "ResonanceFrequency" | Sqrt[ω0² − 2γ²] si ω0² > 2γ²; si no, 0 (no hay máximo fuera de ω = 0) |
| "MaxAmplitude" | F0/(2 m γ Sqrt[ω0² − γ²]) en ese caso |
| "Solution" | A Cos[ω \[FormalT] − δ] |
| "Steps" | ensayo complejo; χ(ω); amplitud y fase; frecuencia de resonancia; relación con la función de Green (χ es su transformada de Fourier) |

Con γ = 0 y ω = ω0 simbólicamente iguales: mensaje `resonance` (la amplitud estacionaria no
existe; crece linealmente: usar GreenSolution) y `$Failed`.

## Tests de la Parte A (Tests/DrivenOscillator.wlt)

Con `osc = DampedOscillator[m, γ, ω0, Assumptions -> m > 0 && 0 < γ < ω0]` salvo que se indique.

| Caso | Esperado |
| --- | --- |
| DampedOscillator[m, γ, ω0] sin suposiciones | $Failed, mensaje regime |
| Con "Regime" -> "Underdamped" | "Regime" "Underdamped"; "OmegaD" Sqrt[ω0² − γ²]; "QualityFactor" ω0/(2γ) |
| DampedOscillator[1, 0.1, 1] | "Underdamped"; OmegaD 0.994987; Q = 5 |
| DampedOscillator[1, 1, 1], [1, 2, 1] y [1, 0, 1] | "Critical", "Overdamped", "Undamped" |
| "Form" -> "MBK" con {m, b, k} = {2, 4, 8} | γ = 1, ω0 = 2 |
| "Regime" -> "Overdamped" con valores subamortiguados | $Failed, mensaje regime |
| GreenFunction, los cuatro regímenes | las expresiones de la tabla |
| G cumple la ecuación homogénea para τ > 0 | residuo 0, en los cuatro regímenes |
| Condiciones en τ = 0 | G(0⁺) = 0 y G′(0⁺) = 1/m, en los cuatro regímenes |
| Límite γ → ω0 de la G subamortiguada | τ e^{−γτ}/m |
| GreenSolution con F = 0: "Total" | e^{−γ t} (x0 Cos[ω_d t] + ((v0 + γ x0)/ω_d) Sin[ω_d t]), con t0 = 0 |
| GreenSolution, escalón F0 desde el reposo (t0 = 0) | (F0/(m ω0²)) (1 − e^{−γ t} (Cos[ω_d t] + (γ/ω_d) Sin[ω_d t])) |
| Golpe F = P DiracDelta[t − t1], t1 > 0, desde el reposo | P G(t − t1) (con su escalón) |
| Sin amortiguamiento, F0 Cos[ω0 t] desde el reposo | F0 t Sin[ω0 t]/(2 m ω0): amplitud que crece linealmente |
| Para F0 Cos[ω t], F0 e^{−a t} y un pulso `F0 (UnitStep[t] − UnitStep[t − T])`, con condiciones iniciales generales | "Total" cumple la ecuación (residuo 0 donde F es continua) y las condiciones iniciales; "Particular" parte en reposo |
| F0 Cos[ω t]: a tiempos largos | la parte no transitoria de "Particular" tiene la amplitud de SteadyState |
| "Homogeneous" no depende de F y "Particular" no depende de {x0, v0} | comparar dos llamadas |
| Fuerza sin primitiva cerrada, numérica: DampedOscillator[1, 0.1, 1], F = Exp[−Sin[t]^2 t] | "Method" "Numeric"; coincide con NDSolve con tolerancia 10⁻⁶ en t ∈ [0, 20] |
| GreenSolution coincide con DSolve | para el escalón y para F0 Cos[ω t], con m = 1, γ = 1/10, ω0 = 1 exactos |
| SteadyState: amplitud y fase | las fórmulas de la tabla |
| SteadyState numérico: m = 1, γ = 0.1, ω0 = 1, F0 = 1 | ResonanceFrequency 0.989949; MaxAmplitude 5.02519; amplitud en ω = 1 igual a 5 |
| SteadyState con ω0² < 2γ² | "ResonanceFrequency" 0 |
| SteadyState con γ = 0 y ω = ω0 | $Failed, mensaje resonance |
| Cuatro alias; mensaje en inglés; ShowSteps de cada resultado | como en los demás módulos |

---

# Parte B — rama `feat/driven-plots`

Todas necesitan valores numéricos (mensaje `numeric` si faltan). Estilo de `$CMPlotStyle`;
punteado para lo que es aproximación o referencia; opciones del usuario con prioridad.

## ResonanceCurve / CurvaDeResonancia

    ResonanceCurve[osc, {ω, ωmin, ωmax}]
    ResonanceCurve[{osc1, osc2, …}, {ω, ωmin, ωmax}]

Amplitud estacionaria por unidad de fuerza, |χ(ω)|, en función de ω. Marca el máximo y la
línea ω = ω0. Con varios osciladores, una curva por cada uno, con leyenda «γ = valor».
Opción `"Phase" -> True`: agrega debajo un segundo gráfico con la fase δ(ω).

## SolutionDecompositionPlot / GraficoDeDescomposicion

    SolutionDecompositionPlot[sol, {tmin, tmax}]

`sol` es el resultado de `GreenSolution`. Dibuja x_h (punteada), x_p (punteada) y x total
(continua), con leyenda «homogénea», «particular», «total». Marca la condición inicial: un punto
en (t0, x0) y una flecha tangente de pendiente v0. Opción `"Force" -> True`: agrega debajo F(t)
con el mismo eje de tiempo.

## InitialConditionExplorer / ExploradorDeCondicionesIniciales

    InitialConditionExplorer[osc, F, {t, t0, tmax}]

`Manipulate` con deslizadores para x0 y v0 (rangos por opción `"Ranges" -> {{-1, 1}, {-1, 1}}`).
Muestra el gráfico de descomposición. Al mover los deslizadores cambia x_h; x_p queda quieta:
es la lección central del módulo. El título lo dice.

## ConvolutionExplorer / ExploradorDeConvolucion

    ConvolutionExplorer[osc, F, {t, t0, tmax}]

`Manipulate` con un deslizador en t. Dos paneles:
- arriba: F(t′), la función de Green invertida y desplazada G(t − t′), y su producto con el
  área sombreada, en función de t′;
- abajo: x_p(t′) dibujada hasta el valor actual de t, con un punto en (t, x_p(t)).
El valor del área es x_p(t).

## ImpulseSuperposition / SuperposicionDeImpulsos

    ImpulseSuperposition[osc, F, {t, t0, tmax}, n]

Corta la fuerza en n golpes de duración Δ = (tmax − t0)/n. Dibuja la respuesta de cada golpe,
F(t_i) Δ G(t − t_i), en trazo tenue; su suma, en continuo; y la solución exacta x_p, punteada.
Al aumentar n la suma tiende a la integral. Devuelve un gráfico; con `"Controls" -> True`,
un `Manipulate` con deslizador para n.

## Notebook de ejemplo y cierre de la versión 0.3.0

`Examples/OsciladorForzadoYGreen.nb`: los tres regímenes; la función de Green y sus condiciones de
salto; respuesta a un escalón, a un pulso y a una fuerza sinusoidal; resonancia; los tres
exploradores. Mismas reglas que los notebooks anteriores. Al cierre: versión 0.3.0, README,
ROADMAP y CLAUDE.md.

## Tests de la Parte B (Tests/DrivenPlots.wlt)

Con `osc = DampedOscillator[1, 0.1, 1]`:

| Caso | Esperado |
| --- | --- |
| ResonanceCurve[osc, {ω, 0, 3}] | gráfico, sin mensajes |
| ResonanceCurve con tres osciladores (γ = 0.05, 0.1, 0.3) y con "Phase" -> True | gráfico |
| SolutionDecompositionPlot para Cos[1.2 t], {x0, v0} = {1, 0}, {0, 60} | gráfico, sin mensajes |
| ídem con "Force" -> True | gráfico |
| InitialConditionExplorer y ConvolutionExplorer | Head Manipulate |
| ImpulseSuperposition con n = 20 | gráfico; con "Controls" -> True, Manipulate |
| ImpulseSuperposition: la suma con n = 400 difiere de la exacta en menos del 2 % del máximo | función privada que calcula la suma, probada sin gráfico |
| Oscilador simbólico en cualquiera | $Failed, mensaje numeric |
| Cinco alias | iguales a las canónicas |

Revisión visual (PNG; para los Manipulate, tres cuadros con valores distintos del control):
- curva de resonancia: máximo cerca de ω0, más alto y angosto al bajar γ;
- descomposición con fuerza sinusoidal: la homogénea decae y la total converge a la particular;
- explorador de condiciones iniciales: tres cuadros con la misma particular;
- convolución: el área sombreada coincide en signo con x_p(t);
- superposición con n = 5, 20 y 80: la suma se acerca a la exacta.

## Fuera de alcance

Respuesta forzada de sistemas de N grados de libertad (un pico de resonancia por modo), fuerzas
periódicas por series de Fourier y oscilaciones no lineales. Quedan para una especificación posterior.
