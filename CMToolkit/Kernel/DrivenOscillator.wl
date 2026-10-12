(* ::Package:: *)
(* CMToolkit, módulo DrivenOscillator: oscilador amortiguado y forzado, y funciones de Green
   (especificación en docs/specs/DrivenOscillator.md, Parte A).
   Notación: ẍ + 2γ ẋ + ω0² x = F(t)/m, con γ el coeficiente de amortiguamiento y ω0 la
   frecuencia natural.
   Lo carga CMToolkit.wl dentro de BeginPackage, después de NormalModes.wl. *)

DampedOscillator::usage =
  "DampedOscillator[m, \[Gamma], \[Omega]0] describe el oscilador amortiguado m(x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x) = F(t), con \[Gamma] el coeficiente de amortiguamiento y \[Omega]0 la frecuencia natural. Entrega una Association con el régimen (\"Undamped\", \"Underdamped\", \"Critical\" u \"Overdamped\"), las raíces características, \[Omega]_d o \[CapitalGamma], el factor de calidad, el tiempo de decaimiento y los pasos intermedios (\"Steps\"). Es el objeto que reciben GreenFunction, GreenSolution y SteadyState. DampedOscillator[m, b, k, \"Form\" -> \"MBK\"] usa la forma m x\:0308 + b x\:0307 + k x = F. Opciones: Assumptions (Automatic: los parámetros son reales positivos) y \"Regime\" (declara el régimen cuando las suposiciones no lo deciden). Alias: OsciladorAmortiguado.\n\
DampedOscillator[m, \[Gamma], \[Omega]0] describes the damped oscillator m(x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x) = F(t), with \[Gamma] the damping coefficient and \[Omega]0 the natural frequency. It returns an Association with the regime (\"Undamped\", \"Underdamped\", \"Critical\" or \"Overdamped\"), the characteristic roots, \[Omega]_d or \[CapitalGamma], the quality factor, the decay time and the intermediate steps (\"Steps\"). It is the object taken by GreenFunction, GreenSolution and SteadyState. DampedOscillator[m, b, k, \"Form\" -> \"MBK\"] uses the form m x\:0308 + b x\:0307 + k x = F. Options: Assumptions (Automatic: parameters are positive reals) and \"Regime\" (declares the regime when the assumptions do not decide it).";
OsciladorAmortiguado::usage =
  "OsciladorAmortiguado[m, \[Gamma], \[Omega]0] es el alias en español de DampedOscillator. Los mensajes de error aparecen con el nombre DampedOscillator.\n\
OsciladorAmortiguado[m, \[Gamma], \[Omega]0] is the Spanish alias of DampedOscillator. Error messages appear under the name DampedOscillator.";

GreenFunction::usage =
  "GreenFunction[osc, \[Tau]] entrega la función de Green causal del oscilador osc de DampedOscillator: la respuesta G(\[Tau]) a un golpe unitario, solución de G'' + 2\[Gamma] G' + \[Omega]0\.b2 G = \[Delta](\[Tau])/m con G = 0 para \[Tau] < 0. Entrega una Association con G completa, con el factor HeavisideTheta[\[Tau]] (\"GreenFunction\"), la expresión para \[Tau] > 0 (\"Causal\") y los pasos intermedios (\"Steps\"). Alias: FuncionDeGreen.\n\
GreenFunction[osc, \[Tau]] gives the causal Green's function of the oscillator osc from DampedOscillator: the response G(\[Tau]) to a unit impulse, solution of G'' + 2\[Gamma] G' + \[Omega]0\.b2 G = \[Delta](\[Tau])/m with G = 0 for \[Tau] < 0. It returns an Association with the full G, with the factor HeavisideTheta[\[Tau]] (\"GreenFunction\"), the expression for \[Tau] > 0 (\"Causal\") and the intermediate steps (\"Steps\").";
FuncionDeGreen::usage =
  "FuncionDeGreen[osc, \[Tau]] es el alias en español de GreenFunction. Los mensajes de error aparecen con el nombre GreenFunction.\n\
FuncionDeGreen[osc, \[Tau]] is the Spanish alias of GreenFunction. Error messages appear under the name GreenFunction.";

GreenSolution::usage =
  "GreenSolution[osc, F, {t, t0}, {x0, v0}] resuelve m(x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x) = F(t) para t \[GreaterEqual] t0 con x(t0) = x0 y x\:0307(t0) = v0, para el oscilador osc de DampedOscillator y una fuerza F escrita en t. La solución particular sale de la integral de convolución con la función de Green y parte en reposo; la homogénea lleva las condiciones iniciales. Entrega una Association con las soluciones homogénea, particular y total, la integral de convolución, el método (\"Symbolic\" o \"Numeric\") y los pasos intermedios (\"Steps\"). Opción: \"MaxTime\" -> 50 (solo si la integral se calcula numéricamente). Alias: SolucionDeGreen.\n\
GreenSolution[osc, F, {t, t0}, {x0, v0}] solves m(x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x) = F(t) for t \[GreaterEqual] t0 with x(t0) = x0 and x\:0307(t0) = v0, for the oscillator osc from DampedOscillator and a force F written in t. The particular solution comes from the convolution integral with the Green's function and starts at rest; the homogeneous one carries the initial conditions. It returns an Association with the homogeneous, particular and total solutions, the convolution integral, the method (\"Symbolic\" or \"Numeric\") and the intermediate steps (\"Steps\"). Option: \"MaxTime\" -> 50 (used only when the integral is computed numerically).";
SolucionDeGreen::usage =
  "SolucionDeGreen[osc, F, {t, t0}, {x0, v0}] es el alias en español de GreenSolution. Los mensajes de error aparecen con el nombre GreenSolution.\n\
SolucionDeGreen[osc, F, {t, t0}, {x0, v0}] is the Spanish alias of GreenSolution. Error messages appear under the name GreenSolution.";

SteadyState::usage =
  "SteadyState[osc, F0, \[Omega]] entrega la respuesta estacionaria del oscilador osc de DampedOscillator a la fuerza F0 Cos[\[Omega] t]: x(t) = A Cos[\[Omega] t \[Minus] \[Delta]]. Entrega una Association con la amplitud A, la fase \[Delta], la susceptibilidad \[Chi](\[Omega]), la frecuencia de resonancia, la amplitud máxima, la solución y los pasos intermedios (\"Steps\"). Alias: EstadoEstacionario.\n\
SteadyState[osc, F0, \[Omega]] gives the steady-state response of the oscillator osc from DampedOscillator to the force F0 Cos[\[Omega] t]: x(t) = A Cos[\[Omega] t \[Minus] \[Delta]]. It returns an Association with the amplitude A, the phase \[Delta], the susceptibility \[Chi](\[Omega]), the resonance frequency, the maximum amplitude, the solution and the intermediate steps (\"Steps\").";
EstadoEstacionario::usage =
  "EstadoEstacionario[osc, F0, \[Omega]] es el alias en español de SteadyState. Los mensajes de error aparecen con el nombre SteadyState.\n\
EstadoEstacionario[osc, F0, \[Omega]] is the Spanish alias of SteadyState. Error messages appear under the name SteadyState.";

Begin["`Private`"];

(* Textos de este módulo: se agregan a la tabla $texts de Core.wl *)
AssociateTo[$texts, <|
  "DampedOscillator::args" -> <|
    "Spanish" -> "DampedOscillator se llama con tres argumentos: DampedOscillator[m, \[Gamma], \[Omega]0], para m(x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x) = F, o DampedOscillator[m, b, k, \"Form\" -> \"MBK\"], para m x\:0308 + b x\:0307 + k x = F.",
    "English" -> "DampedOscillator takes three arguments: DampedOscillator[m, \[Gamma], \[Omega]0], for m(x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x) = F, or DampedOscillator[m, b, k, \"Form\" -> \"MBK\"], for m x\:0308 + b x\:0307 + k x = F."|>,
  "DampedOscillator::params" -> <|
    "Spanish" -> "La masa y la frecuencia natural (o la constante k) deben ser positivas, y el amortiguamiento no puede ser negativo. Revisa los parámetros `1`.",
    "English" -> "The mass and the natural frequency (or the constant k) must be positive, and the damping cannot be negative. Check the parameters `1`."|>,
  "DampedOscillator::regime" -> <|
    "Spanish" -> "No se puede fijar el régimen con \[Gamma] = `1` y \[Omega]0 = `2`: depende de si \[Gamma] es menor, igual o mayor que \[Omega]0. Decláralo con las suposiciones, por ejemplo Assumptions -> 0 < \[Gamma] < \[Omega]0, o con la opción \"Regime\" -> \"Underdamped\" (también \"Undamped\", \"Critical\" u \"Overdamped\"). Si ya declaraste un régimen, revisa que no contradiga los valores de los parámetros.",
    "English" -> "The regime cannot be determined with \[Gamma] = `1` and \[Omega]0 = `2`: it depends on whether \[Gamma] is less than, equal to or greater than \[Omega]0. Declare it with the assumptions, for example Assumptions -> 0 < \[Gamma] < \[Omega]0, or with the option \"Regime\" -> \"Underdamped\" (also \"Undamped\", \"Critical\" or \"Overdamped\"). If you already declared a regime, check that it does not contradict the values of the parameters."|>,
  (* DampedOscillator: textos de "Steps", en el orden en que se haría a mano *)
  "DampedOscillator:equation" -> <|
    "Spanish" -> "Ecuación del oscilador sin fuerza: x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x = 0, con \[Gamma] el coeficiente de amortiguamiento y \[Omega]0 la frecuencia natural.",
    "English" -> "Equation of the oscillator with no force: x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x = 0, with \[Gamma] the damping coefficient and \[Omega]0 the natural frequency."|>,
  "DampedOscillator:trial" -> <|
    "Spanish" -> "Ensayo x = e^(r t): cada término queda multiplicado por e^(r t), que nunca se anula, y queda la ecuación característica.",
    "English" -> "Trial x = e^(r t): every term gets multiplied by e^(r t), which never vanishes, and the characteristic equation remains."|>,
  "DampedOscillator:roots" -> <|
    "Spanish" -> "Raíces de la ecuación característica: r = \[Minus]\[Gamma] \[PlusMinus] \[Sqrt](\[Gamma]\.b2 \[Minus] \[Omega]0\.b2).",
    "English" -> "Roots of the characteristic equation: r = \[Minus]\[Gamma] \[PlusMinus] \[Sqrt](\[Gamma]\.b2 \[Minus] \[Omega]0\.b2)."|>,
  "DampedOscillator:Undamped" -> <|
    "Spanish" -> "Sin amortiguamiento (\[Gamma] = 0): las raíces son \[PlusMinus]i \[Omega]0 y el sistema oscila para siempre con frecuencia \[Omega]0.",
    "English" -> "Undamped (\[Gamma] = 0): the roots are \[PlusMinus]i \[Omega]0 and the system oscillates forever with frequency \[Omega]0."|>,
  "DampedOscillator:Underdamped" -> <|
    "Spanish" -> "Régimen subamortiguado (\[Gamma] < \[Omega]0): las raíces son complejas, \[Minus]\[Gamma] \[PlusMinus] i \[Omega]_d. El sistema oscila con frecuencia \[Omega]_d = \[Sqrt](\[Omega]0\.b2 \[Minus] \[Gamma]\.b2), menor que \[Omega]0, y la amplitud decae como e^(\[Minus]\[Gamma] t).",
    "English" -> "Underdamped regime (\[Gamma] < \[Omega]0): the roots are complex, \[Minus]\[Gamma] \[PlusMinus] i \[Omega]_d. The system oscillates with frequency \[Omega]_d = \[Sqrt](\[Omega]0\.b2 \[Minus] \[Gamma]\.b2), lower than \[Omega]0, and the amplitude decays as e^(\[Minus]\[Gamma] t)."|>,
  "DampedOscillator:Critical" -> <|
    "Spanish" -> "Amortiguamiento crítico (\[Gamma] = \[Omega]0): una raíz doble, \[Minus]\[Gamma]. El sistema vuelve al equilibrio sin oscilar, lo más rápido posible: x = (A + B t) e^(\[Minus]\[Gamma] t).",
    "English" -> "Critical damping (\[Gamma] = \[Omega]0): a double root, \[Minus]\[Gamma]. The system returns to equilibrium without oscillating, as fast as possible: x = (A + B t) e^(\[Minus]\[Gamma] t)."|>,
  "DampedOscillator:Overdamped" -> <|
    "Spanish" -> "Régimen sobreamortiguado (\[Gamma] > \[Omega]0): dos raíces reales negativas, \[Minus]\[Gamma] \[PlusMinus] \[CapitalGamma], con \[CapitalGamma] = \[Sqrt](\[Gamma]\.b2 \[Minus] \[Omega]0\.b2). El sistema vuelve al equilibrio sin oscilar, más lento que con amortiguamiento crítico.",
    "English" -> "Overdamped regime (\[Gamma] > \[Omega]0): two negative real roots, \[Minus]\[Gamma] \[PlusMinus] \[CapitalGamma], with \[CapitalGamma] = \[Sqrt](\[Gamma]\.b2 \[Minus] \[Omega]0\.b2). The system returns to equilibrium without oscillating, more slowly than with critical damping."|>,
  "GreenFunction::args" -> <|
    "Spanish" -> "GreenFunction se llama con un oscilador de DampedOscillator y el símbolo de la variable: GreenFunction[osc, \[Tau]].",
    "English" -> "GreenFunction takes an oscillator from DampedOscillator and the symbol of the variable: GreenFunction[osc, \[Tau]]."|>,
  "GreenFunction::var" -> <|
    "Spanish" -> "La variable de la función de Green debe ser un símbolo sin valor asignado que no aparezca en el oscilador; `1` no cumple.",
    "English" -> "The variable of the Green's function must be a symbol with no assigned value that does not appear in the oscillator; `1` does not qualify."|>,
  (* GreenFunction: textos de "Steps", los cinco pasos de la especificación *)
  "GreenFunction:equation" -> <|
    "Spanish" -> "La función de Green es la respuesta a un golpe unitario en \[Tau] = 0: G'' + 2\[Gamma] G' + \[Omega]0\.b2 G = \[Delta](\[Tau])/m.",
    "English" -> "The Green's function is the response to a unit impulse at \[Tau] = 0: G'' + 2\[Gamma] G' + \[Omega]0\.b2 G = \[Delta](\[Tau])/m."|>,
  "GreenFunction:causal" -> <|
    "Spanish" -> "Causalidad: antes del golpe el oscilador está en reposo, así que G = 0 para \[Tau] < 0.",
    "English" -> "Causality: before the impulse the oscillator is at rest, so G = 0 for \[Tau] < 0."|>,
  "GreenFunction:homogeneous" -> <|
    "Spanish" -> "Después del golpe no hay fuerza: para \[Tau] > 0, G cumple la ecuación homogénea.",
    "English" -> "After the impulse there is no force: for \[Tau] > 0, G satisfies the homogeneous equation."|>,
  "GreenFunction:jump" -> <|
    "Spanish" -> "Condiciones en \[Tau] = 0: G es continua (vale 0 justo después del golpe) y, al integrar la ecuación en un intervalo pequeño en torno a 0, G' salta en 1/m.",
    "English" -> "Conditions at \[Tau] = 0: G is continuous (it is 0 just after the impulse) and, integrating the equation over a small interval around 0, G' jumps by 1/m."|>,
  "GreenFunction:result" -> <|
    "Spanish" -> "Resultado: la solución homogénea que cumple esas condiciones, multiplicada por el escalón HeavisideTheta[\[Tau]].",
    "English" -> "Result: the homogeneous solution that satisfies those conditions, multiplied by the step HeavisideTheta[\[Tau]]."|>,
  "GreenSolution::args" -> <|
    "Spanish" -> "GreenSolution se llama con cuatro argumentos: GreenSolution[osc, F, {t, t0}, {x0, v0}], con osc de DampedOscillator, la fuerza F escrita en t, el instante inicial t0 y las condiciones iniciales x(t0) = x0 y x\:0307(t0) = v0. Por ejemplo: GreenSolution[osc, F0 Cos[\[Omega] t], {t, 0}, {0, 0}].",
    "English" -> "GreenSolution takes four arguments: GreenSolution[osc, F, {t, t0}, {x0, v0}], with osc from DampedOscillator, the force F written in t, the initial time t0 and the initial conditions x(t0) = x0 and x\:0307(t0) = v0. For example: GreenSolution[osc, F0 Cos[\[Omega] t], {t, 0}, {0, 0}]."|>,
  "GreenSolution::var" -> <|
    "Spanish" -> "El tiempo debe ser un símbolo sin valor asignado que no aparezca en el oscilador; `1` no cumple.",
    "English" -> "The time must be a symbol with no assigned value that does not appear in the oscillator; `1` does not qualify."|>,
  "GreenSolution::ic" -> <|
    "Spanish" -> "El instante inicial y las condiciones iniciales no pueden depender del tiempo `1`: `2`.",
    "English" -> "The initial time and the initial conditions cannot depend on the time `1`: `2`."|>,
  "GreenSolution::integral" -> <|
    "Spanish" -> "La integral de convolución no tiene forma cerrada (o no salió en 20 s), y con parámetros simbólicos no se puede calcular numéricamente. \"Particular\" queda como la integral sin evaluar. Da valores numéricos a los parámetros para obtener la solución numérica.",
    "English" -> "The convolution integral has no closed form (or did not come out within 20 s), and with symbolic parameters it cannot be computed numerically. \"Particular\" is left as the unevaluated integral. Give numeric values to the parameters to get the numerical solution."|>,
  (* GreenSolution: textos de "Steps", los siete pasos de la especificación *)
  "GreenSolution:equation" -> <|
    "Spanish" -> "Ecuación del oscilador forzado: x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x = F(t)/m.",
    "English" -> "Equation of the driven oscillator: x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x = F(t)/m."|>,
  "GreenSolution:green" -> <|
    "Spanish" -> "Función de Green del oscilador: la respuesta a un golpe unitario.",
    "English" -> "Green's function of the oscillator: the response to a unit impulse."|>,
  "GreenSolution:convolution" -> <|
    "Spanish" -> "La fuerza es una suma de golpes F(t\[Prime]) dt\[Prime], y cada uno produce la respuesta G(t \[Minus] t\[Prime]) F(t\[Prime]) dt\[Prime]. Al sumarlas queda la integral de convolución, que parte en reposo en t0.",
    "English" -> "The force is a sum of impulses F(t\[Prime]) dt\[Prime], and each one produces the response G(t \[Minus] t\[Prime]) F(t\[Prime]) dt\[Prime]. Adding them up gives the convolution integral, which starts at rest at t0."|>,
  "GreenSolution:particular" -> <|
    "Spanish" -> "Solución particular: la integral calculada. Cumple x_p(t0) = 0 y x\:0307_p(t0) = 0.",
    "English" -> "Particular solution: the computed integral. It satisfies x_p(t0) = 0 and x\:0307_p(t0) = 0."|>,
  "GreenSolution:particularNumeric" -> <|
    "Spanish" -> "Solución particular: la integral no tiene forma cerrada, así que se calcula numéricamente (función de interpolación), partiendo en reposo en t0.",
    "English" -> "Particular solution: the integral has no closed form, so it is computed numerically (interpolating function), starting at rest at t0."|>,
  "GreenSolution:particularOpen" -> <|
    "Spanish" -> "Solución particular: la integral no tiene forma cerrada y queda sin evaluar.",
    "English" -> "Particular solution: the integral has no closed form and is left unevaluated."|>,
  "GreenSolution:homogeneous" -> <|
    "Spanish" -> "Solución homogénea con las condiciones iniciales: x_h(t) = m [v0 G(t \[Minus] t0) + x0 (G\[Prime](t \[Minus] t0) + 2\[Gamma] G(t \[Minus] t0))], que cumple x_h(t0) = x0 y x\:0307_h(t0) = v0.",
    "English" -> "Homogeneous solution with the initial conditions: x_h(t) = m [v0 G(t \[Minus] t0) + x0 (G\[Prime](t \[Minus] t0) + 2\[Gamma] G(t \[Minus] t0))], which satisfies x_h(t0) = x0 and x\:0307_h(t0) = v0."|>,
  "GreenSolution:total" -> <|
    "Spanish" -> "Solución total: x = x_h + x_p.",
    "English" -> "Total solution: x = x_h + x_p."|>,
  "GreenSolution:note" -> <|
    "Spanish" -> "Las condiciones iniciales entran solo en la parte homogénea, y la fuerza solo en la particular: cambiar x0 o v0 no cambia x_p, y cambiar F no cambia x_h.",
    "English" -> "The initial conditions enter only the homogeneous part, and the force only the particular one: changing x0 or v0 does not change x_p, and changing F does not change x_h."|>,
  "SteadyState::args" -> <|
    "Spanish" -> "SteadyState se llama con un oscilador de DampedOscillator, la amplitud de la fuerza y su frecuencia: SteadyState[osc, F0, \[Omega]], para F(t) = F0 Cos[\[Omega] t].",
    "English" -> "SteadyState takes an oscillator from DampedOscillator, the amplitude of the force and its frequency: SteadyState[osc, F0, \[Omega]], for F(t) = F0 Cos[\[Omega] t]."|>,
  "SteadyState::resonance" -> <|
    "Spanish" -> "Sin amortiguamiento y con \[Omega] = \[Omega]0 no hay respuesta estacionaria: la amplitud crece linealmente con el tiempo. Usa GreenSolution para ver ese crecimiento.",
    "English" -> "With no damping and \[Omega] = \[Omega]0 there is no steady-state response: the amplitude grows linearly with time. Use GreenSolution to see that growth."|>,
  (* SteadyState: textos de "Steps", los cinco pasos de la especificación *)
  "SteadyState:trial" -> <|
    "Spanish" -> "Ensayo complejo: F0 Cos[\[Omega] t] es la parte real de F0 e^(i\[Omega] t). Se busca x = Re(X e^(i\[Omega] t)): al reemplazarlo, la ecuación queda algebraica para X.",
    "English" -> "Complex trial: F0 Cos[\[Omega] t] is the real part of F0 e^(i\[Omega] t). One looks for x = Re(X e^(i\[Omega] t)): substituting it, the equation becomes algebraic for X."|>,
  "SteadyState:susceptibility" -> <|
    "Spanish" -> "Susceptibilidad: X = \[Chi](\[Omega]) F0, con \[Chi](\[Omega]) = 1/(m (\[Omega]0\.b2 \[Minus] \[Omega]\.b2 + 2i\[Gamma]\[Omega])).",
    "English" -> "Susceptibility: X = \[Chi](\[Omega]) F0, with \[Chi](\[Omega]) = 1/(m (\[Omega]0\.b2 \[Minus] \[Omega]\.b2 + 2i\[Gamma]\[Omega]))."|>,
  "SteadyState:amplitude" -> <|
    "Spanish" -> "Amplitud y fase: A = F0 |\[Chi]| y \[Delta] es el ángulo de 1/\[Chi], entre 0 y \[Pi]: la respuesta se atrasa respecto a la fuerza, poco por debajo de \[Omega]0 y casi \[Pi] por encima.",
    "English" -> "Amplitude and phase: A = F0 |\[Chi]| and \[Delta] is the angle of 1/\[Chi], between 0 and \[Pi]: the response lags behind the force, a little below \[Omega]0 and almost \[Pi] above it."|>,
  "SteadyState:resonance" -> <|
    "Spanish" -> "Resonancia: A(\[Omega]) es máxima en \[Omega]_r = \[Sqrt](\[Omega]0\.b2 \[Minus] 2\[Gamma]\.b2) si \[Omega]0\.b2 > 2\[Gamma]\.b2, con A_max = F0/(2m\[Gamma]\[Omega]_d). Si no, A(\[Omega]) decrece desde \[Omega] = 0, donde vale F0/(m \[Omega]0\.b2), y \[Omega]_r = 0.",
    "English" -> "Resonance: A(\[Omega]) is maximal at \[Omega]_r = \[Sqrt](\[Omega]0\.b2 \[Minus] 2\[Gamma]\.b2) if \[Omega]0\.b2 > 2\[Gamma]\.b2, with A_max = F0/(2m\[Gamma]\[Omega]_d). Otherwise A(\[Omega]) decreases from \[Omega] = 0, where it equals F0/(m \[Omega]0\.b2), and \[Omega]_r = 0."|>,
  "SteadyState:green" -> <|
    "Spanish" -> "Relación con la función de Green: \[Chi](\[Omega]) es su transformada de Fourier. La respuesta a e^(i\[Omega] t) es la suma de las respuestas a los golpes de los que está hecha.",
    "English" -> "Relation to the Green's function: \[Chi](\[Omega]) is its Fourier transform. The response to e^(i\[Omega] t) is the sum of the responses to the impulses it is made of."|>
|>];

(* --- Funciones privadas de este módulo --- *)

(* Un oscilador: el resultado de DampedOscillator *)
oscillatorQ[osc_Association] :=
  AllTrue[{"Mass", "Gamma", "Omega0", "Regime", "Assumptions"}, KeyExistsQ[osc, #] &];
oscillatorQ[_] := False;

(* Un parámetro simbólico pasa; uno numérico debe ser real y positivo (o no negativo) *)
positiveParamQ[x_] := !NumericQ[x] || (realNumberQ[x] && TrueQ[N[x] > 0]);
nonNegativeParamQ[x_] := !NumericQ[x] || (realNumberQ[x] && TrueQ[N[x] >= 0]);

dampedRegimes = {"Undamped", "Underdamped", "Critical", "Overdamped"};

(* Condición que define cada régimen *)
regimeCondition[reg_, g_, w_] := Switch[reg,
  "Undamped", g == 0, "Underdamped", 0 < g < w, "Critical", g == w, "Overdamped", g > w];

(* Régimen que deciden las suposiciones, o None si no lo deciden *)
decideRegime[g_, w_, asm_] := Which[
  zeroQ[g, asm], "Undamped",
  zeroQ[w - g, asm], "Critical",
  TrueQ[Simplify[g < w, asm]], "Underdamped",
  TrueQ[Simplify[g > w, asm]], "Overdamped",
  True, None];

(* Término c·s de una suma retenida: se omite si c es 0 y se escribe solo s si c es 1 *)
coefTerm[c_, s_] := Which[zeroQ[c, True], Nothing, c === 1, s, True, HoldForm[c s]];

(* Una variable libre: un símbolo sin valor, no protegido, que no aparece en data *)
freeVariableQ[v_, data_] := MatchQ[v, _Symbol] && !MemberQ[Attributes[v], Protected] &&
  FreeQ[data, v];

(* Datos de un oscilador en los que no puede aparecer la variable de G ni el tiempo *)
oscillatorData[osc_] := Lookup[osc, {"Mass", "Gamma", "Omega0", "Assumptions"}];

(* G(τ) para τ > 0, según el régimen (tabla de la especificación) *)
greenCausal[osc_, tau_] := With[{m = osc["Mass"], g = osc["Gamma"], w = osc["Omega0"]},
  Switch[osc["Regime"],
    "Undamped", Sin[w tau]/(m w),
    "Underdamped", Exp[-g tau] Sin[osc["OmegaD"] tau]/(m osc["OmegaD"]),
    "Critical", tau Exp[-g tau]/m,
    "Overdamped", Exp[-g tau] Sinh[osc["GammaD"] tau]/(m osc["GammaD"])]];

(* Lado izquierdo y'' + 2γ y' + ω0² y retenido, con y el nombre dado (una cadena) *)
heldOperator[y_String, var_, g_, w_] := heldSum[{HoldForm[Derivative[2][y][var]],
  coefTerm[2 g, HoldForm[Derivative[1][y][var]]], coefTerm[w^2, HoldForm[y[var]]]}];

(* Simplify con límite de tiempo: si tarda más de 10 s, la expresión queda como está *)
timedSimplify[e_, asm_] := TimeConstrained[Simplify[e, asm], 10, e];

(* En "Steps", la variable de integración \[FormalS] se muestra como t′ y \[FormalTau] como τ *)
greenDisplay[e_] := e /. {\[FormalS] -> "t\[Prime]", \[FormalTau] -> "\[Tau]"};

(* --- DampedOscillator: especificación en docs/specs/DrivenOscillator.md --- *)

Options[DampedOscillator] = {"Form" -> Automatic, "Regime" -> Automatic, Assumptions -> Automatic};

DampedOscillator[m_, a2_, a3_, opts : OptionsPattern[]] /; !OptionQ[a3] :=
  Module[{form, g, w, asm, decl, base, reg, wd, gd, roots, q, decay, steps},
    form = OptionValue["Form"];
    If[!MemberQ[{Automatic, "MBK"}, form], cmMessage[DampedOscillator, "args"]; Return[$Failed]];

    (* Parámetros numéricos: m > 0 primero (la forma MBK divide por m), después γ ≥ 0 y ω0 > 0
       (en la forma MBK, b ≥ 0 y k > 0) *)
    If[!positiveParamQ[m] ||
        If[form === "MBK", !nonNegativeParamQ[a2] || !positiveParamQ[a3], False],
      cmMessage[DampedOscillator, "params", {m, a2, a3}]; Return[$Failed]];
    asm = OptionValue[Assumptions];
    If[asm === Automatic, asm = positiveAssumptions[{m, a2, a3}, {}]];
    {g, w} = If[form === "MBK", Simplify[{a2/(2 m), Sqrt[a3/m]}, asm], {a2, a3}];
    If[!nonNegativeParamQ[g] || !positiveParamQ[w],
      cmMessage[DampedOscillator, "params", {m, a2, a3}]; Return[$Failed]];

    (* Régimen: el que deciden las suposiciones o el declarado con "Regime", que agrega su
       condición a las suposiciones. Un régimen declarado que contradice los valores es error *)
    decl = OptionValue["Regime"];
    base = decideRegime[g, w, asm];
    Which[
      decl === Automatic && base === None,
        cmMessage[DampedOscillator, "regime", g, w]; Return[$Failed],
      decl === Automatic,
        reg = base,
      !MemberQ[dampedRegimes, decl] || (base =!= None && base =!= decl) ||
          Simplify[asm && regimeCondition[decl, g, w]] === False,
        cmMessage[DampedOscillator, "regime", g, w]; Return[$Failed],
      True,
        asm = Simplify[asm && regimeCondition[decl, g, w]]; reg = decl];

    wd = If[reg === "Underdamped", Simplify[Sqrt[w^2 - g^2], asm], Missing["NotApplicable"]];
    gd = If[reg === "Overdamped", Simplify[Sqrt[g^2 - w^2], asm], Missing["NotApplicable"]];
    roots = Switch[reg,
      "Undamped", {I w, -I w},
      "Underdamped", {-g + I wd, -g - I wd},
      "Critical", {-g, -g},
      "Overdamped", {-g + gd, -g - gd}];
    {q, decay} = If[reg === "Undamped", {Infinity, Infinity},
      Simplify[{w/(2 g), 1/g}, asm]];

    steps = {
      {"equation", heldSum[{"x\:0308", coefTerm[2 g, "x\:0307"], coefTerm[w^2, "x"]}] == 0},
      {"trial", heldSum[{HoldForm["r"^2], coefTerm[2 g, "r"], If[zeroQ[w^2, True], Nothing, w^2]}] == 0},
      {"roots", Column[{Subscript["r", 1] == roots[[1]], Subscript["r", 2] == roots[[2]]}]},
      {reg, Switch[reg,
        "Undamped", Row[{"\[Gamma] = 0,   \[Omega]\:2080 = ", w}],
        "Underdamped", Subscript["\[Omega]", "d"] == wd,
        "Critical", Row[{"\[Gamma] = \[Omega]\:2080 = ", w}],
        "Overdamped", "\[CapitalGamma]" == gd]}};
    steps = <|"Description" -> tr["DampedOscillator:" <> #[[1]]], "Expression" -> #[[2]]|> & /@
      steps;

    <|"Mass" -> m, "Gamma" -> g, "Omega0" -> w, "Regime" -> reg, "Assumptions" -> asm,
      "Equation" -> \[FormalX]''[\[FormalT]] + 2 g \[FormalX]'[\[FormalT]] + w^2 \[FormalX][\[FormalT]] == 0,
      "CharacteristicRoots" -> roots, "OmegaD" -> wd, "GammaD" -> gd, "QualityFactor" -> q,
      "DecayTime" -> decay, "Steps" -> steps|>
  ];

DampedOscillator[___] := (cmMessage[DampedOscillator, "args"]; $Failed);

(* --- GreenFunction: especificación en docs/specs/DrivenOscillator.md --- *)

GreenFunction[osc_Association?oscillatorQ, tau_] :=
  Module[{m, g, w, causal, steps},
    If[!freeVariableQ[tau, oscillatorData[osc]],
      cmMessage[GreenFunction, "var", tau]; Return[$Failed]];
    m = osc["Mass"]; g = osc["Gamma"]; w = osc["Omega0"];
    causal = greenCausal[osc, tau];

    steps = With[{mm = m, gg = HeavisideTheta[tau] causal},
      {{"equation", heldOperator["G", tau, g, w] == DiracDelta[tau]/m},
       {"causal", Row[{HoldForm["G"[tau] == 0], "     (", tau, " < 0)"}]},
       {"homogeneous", Row[{heldOperator["G", tau, g, w] == 0, "     (", tau, " > 0)"}]},
       {"jump", Row[{HoldForm["G"[Superscript[0, "+"]] == 0], ",     ",
         HoldForm[Derivative[1]["G"][Superscript[0, "+"]] == 1/mm]}]},
       {"result", HoldForm["G"[tau] == gg]}}];
    steps = <|"Description" -> tr["GreenFunction:" <> #[[1]]], "Expression" -> #[[2]]|> & /@
      steps;

    <|"GreenFunction" -> HeavisideTheta[tau] causal, "Causal" -> causal, "Variable" -> tau,
      "Steps" -> steps|>
  ];

GreenFunction[___] := (cmMessage[GreenFunction, "args"]; $Failed);

(* --- GreenSolution: especificación en docs/specs/DrivenOscillator.md --- *)

Options[GreenSolution] = {"MaxTime" -> 50};

GreenSolution[osc_Association?oscillatorQ, F_, {t_, t0_}, {x0_, v0_}, opts : OptionsPattern[]] :=
  Module[{m, g, w, asm, s = \[FormalS], tau = \[FormalTau], gt, integrand, conv, xp, xh, method,
      kind, tmax, steps},
    If[!freeVariableQ[t, oscillatorData[osc]],
      cmMessage[GreenSolution, "var", t]; Return[$Failed]];
    If[!FreeQ[{t0, x0, v0}, t],
      cmMessage[GreenSolution, "ic", t, {t0, x0, v0}]; Return[$Failed]];
    m = osc["Mass"]; g = osc["Gamma"]; w = osc["Omega0"];
    (* Las del oscilador, los parámetros de la fuerza y t0 reales positivos (como en todo el
       paquete) y t > t0 *)
    asm = osc["Assumptions"] && positiveAssumptions[{F, t0}, {t}] && t > t0;
    gt = greenCausal[osc, tau];

    (* Particular: ∫ G(t − t′) F(t′) dt′ desde t0 hasta t, simbólica en 20 s *)
    integrand = (gt /. tau -> t - s) (F /. t -> s);
    conv = Inactive[Integrate][integrand, {s, t0, t}];
    xp = Quiet[TimeConstrained[Integrate[integrand, {s, t0, t}, Assumptions -> asm], 20, $Failed]];
    Which[
      xp =!= $Failed && FreeQ[xp, Integrate],
        xp = timedSimplify[xp /. ConditionalExpression[e_, _] :> e, asm];
        method = "Symbolic"; kind = "particular",
      (* Sin forma cerrada y todo numérico: la ecuación con reposo en t0, integrada hasta
         "MaxTime" *)
      freeSymbols[{m, g, w, F, t0}, {t}] === {},
        tmax = OptionValue["MaxTime"];
        xp = Module[{y, u},
          NDSolveValue[{y''[u] + 2 g y'[u] + w^2 y[u] == (F /. t -> u)/m, y[t0] == 0, y'[t0] == 0},
            y, {u, t0, tmax}, AccuracyGoal -> 12, PrecisionGoal -> 12, MaxSteps -> Infinity]][t];
        method = "Numeric"; kind = "particularNumeric",
      True,
        cmMessage[GreenSolution, "integral"];
        xp = conv; method = "Symbolic"; kind = "particularOpen"];

    (* Homogénea: x_h = m [v0 G(t − t0) + x0 (G′(t − t0) + 2γ G(t − t0))] *)
    xh = timedSimplify[m (v0 gt + x0 (D[gt, tau] + 2 g gt)) /. tau -> t - t0,
      osc["Assumptions"] && t > t0];

    (* With inserta los valores en las formas retenidas (HoldForm no evalúa los símbolos) *)
    steps = With[{xx = Subscript["x", "h"][t] + Subscript["x", "p"][t], tt0 = t0, xx0 = x0,
        vv0 = v0, ta = tau, gg = HeavisideTheta[tau] gt},
      {{"equation", heldOperator["x", t, g, w] == F/m},
       {"green", HoldForm["G"[ta] == gg]},
       {"convolution", Subscript["x", "p"][t] == conv},
       {kind, Subscript["x", "p"][t] == xp},
       {"homogeneous", Column[{Subscript["x", "h"][t] == xh,
         Row[{HoldForm["x"[tt0] == xx0], ",     ", HoldForm[Derivative[1]["x"][tt0] == vv0]}]}]},
       {"total", Row[{HoldForm["x"[t] == xx], " = ", xh + xp}]},
       {"note", Row[{Subscript["x", "h"], " \[LeftArrow] {", x0, ", ", v0, "},     ",
         Subscript["x", "p"], " \[LeftArrow] F"}]}}];
    steps = <|"Description" -> tr["GreenSolution:" <> #[[1]]],
      "Expression" -> greenDisplay[#[[2]]]|> & /@ steps;

    <|"Homogeneous" -> xh, "Particular" -> xp, "Total" -> xh + xp, "ConvolutionIntegral" -> conv,
      "GreenFunction" -> gt, "Force" -> F, "Time" -> t, "InitialTime" -> t0,
      "InitialConditions" -> {x0, v0}, "Method" -> method, "Oscillator" -> osc, "Steps" -> steps|>
  ];

GreenSolution[___] := (cmMessage[GreenSolution, "args"]; $Failed);

(* --- SteadyState: especificación en docs/specs/DrivenOscillator.md --- *)

SteadyState[osc_Association?oscillatorQ, F0_, om_] :=
  Module[{m, g, w, asm, chi, amp, phase, cond, decided, rfYes, maxYes, maxNo, rf, maxA, steps},
    m = osc["Mass"]; g = osc["Gamma"]; w = osc["Omega0"];
    asm = osc["Assumptions"] && positiveAssumptions[{F0, om}, {}];
    If[zeroQ[g, asm] && zeroQ[om - w, asm],
      cmMessage[SteadyState, "resonance"]; Return[$Failed]];

    chi = Simplify[1/(m (w^2 - om^2 + 2 I g om)), asm];
    amp = tidySimplify[(F0/m)/Sqrt[(w^2 - om^2)^2 + 4 g^2 om^2], asm];
    phase = ArcTan[w^2 - om^2, 2 g om];

    (* Resonancia si ω0² > 2γ²; si no, el máximo está en ω = 0 (v1.1, precisión 4). Si las
       suposiciones no lo deciden, Piecewise con esa condición *)
    cond = w^2 > 2 g^2;
    rfYes = tidySimplify[Sqrt[w^2 - 2 g^2], asm];
    maxYes = If[zeroQ[g, asm], Infinity, tidySimplify[F0/(2 m g Sqrt[w^2 - g^2]), asm]];
    maxNo = tidySimplify[F0/(m w^2), asm];
    decided = Simplify[cond, asm];
    {rf, maxA} = Which[
      TrueQ[decided], {rfYes, maxYes},
      decided === False, {0, maxNo},
      True, {Piecewise[{{rfYes, cond}}, 0], Piecewise[{{maxYes, cond}}, maxNo]}];

    steps = With[{oo = om, cc = chi},
      {{"trial", HoldForm["x"["t"] == Re["X" Exp[I oo "t"]]]},
       {"susceptibility", HoldForm["\[Chi]"[oo] == cc]},
       {"amplitude", Column[{"A" == amp, "\[Delta]" == phase}]},
       {"resonance", Column[{Subscript["\[Omega]", "r"] == rf, Subscript["A", "max"] == maxA}]},
       {"green", HoldForm["\[Chi]"[oo] ==
         Integrate["G"["\[Tau]"] Exp[-I oo "\[Tau]"], {"\[Tau]", 0, Infinity}]]}}];
    steps = <|"Description" -> tr["SteadyState:" <> #[[1]]], "Expression" -> #[[2]]|> & /@
      steps;

    <|"Amplitude" -> amp, "Phase" -> phase, "Susceptibility" -> chi, "ResonanceFrequency" -> rf,
      "MaxAmplitude" -> maxA, "Solution" -> amp Cos[om \[FormalT] - phase], "Steps" -> steps|>
  ];

SteadyState[___] := (cmMessage[SteadyState, "args"]; $Failed);

(* --- Alias en español (al final, cuando las funciones ya tienen sus atributos) --- *)
defineAlias[OsciladorAmortiguado, DampedOscillator];
defineAlias[FuncionDeGreen, GreenFunction];
defineAlias[SolucionDeGreen, GreenSolution];
defineAlias[EstadoEstacionario, SteadyState];

End[];
