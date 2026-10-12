(* Tests de DampedOscillator, GreenFunction, GreenSolution y SteadyState.
   Especificación: docs/specs/DrivenOscillator.md (versión 1.1, Parte A).
   Notación: ẍ + 2γ ẋ + ω0² x = F(t)/m. En el código, gam = γ y w0 = ω0.
   Valores de referencia: casos con solución conocida documentados en la especificación. *)

drAsm = m > 0 && 0 < gam < w0;
drOsc = DampedOscillator[m, gam, w0, Assumptions -> drAsm];
drWd = Sqrt[w0^2 - gam^2];

(* Valor de una solución en t = s0, sea una expresión en t o una InterpolatingFunction *)
drAt[sol_InterpolatingFunction, _, s0_] := sol[s0];
drAt[sol_, tt_, s0_] := sol /. tt -> s0;

drZeroQ[e_, asm_] := Simplify[e, asm] === 0;

(* La función de Green de la tabla de la especificación, para τ > 0 *)
drCausal["Undamped"][tt_] := Sin[w0 tt]/(m w0);
drCausal["Underdamped"][tt_] := Exp[-gam tt] Sin[drWd tt]/(m drWd);
drCausal["Critical"][tt_] := tt Exp[-gam tt]/m;
drCausal["Overdamped"][tt_] := Exp[-gam tt] Sinh[Sqrt[gam^2 - w0^2] tt]/(m Sqrt[gam^2 - w0^2]);

(* Un oscilador simbólico por régimen, con las suposiciones que lo deciden *)
drRegimes = <|
  "Undamped" -> {DampedOscillator[m, 0, w0], m > 0 && w0 > 0},
  "Underdamped" -> {drOsc, drAsm},
  "Critical" -> {DampedOscillator[m, w0, w0], m > 0 && w0 > 0},
  "Overdamped" -> {DampedOscillator[m, gam, w0, Assumptions -> m > 0 && 0 < w0 < gam],
    m > 0 && 0 < w0 < gam}|>;

(* En el crítico, γ = ω0 *)
drCausalIn[reg_][tt_] := If[reg === "Critical", drCausal[reg][tt] /. gam -> w0, drCausal[reg][tt]];

(* === DampedOscillator === *)

VerificationTest[
  DampedOscillator[m, gam, w0],
  $Failed,
  {DampedOscillator::regime},
  TestID -> "oscilador-regimen-indecidible-regime"
]

VerificationTest[
  Module[{osc = DampedOscillator[m, gam, w0, "Regime" -> "Underdamped"]},
    {osc["Regime"], drZeroQ[osc["OmegaD"] - drWd, drAsm],
     drZeroQ[osc["QualityFactor"] - w0/(2 gam), drAsm], osc["GammaD"]}],
  {"Underdamped", True, True, Missing["NotApplicable"]},
  TestID -> "oscilador-regimen-declarado-subamortiguado"
]

VerificationTest[
  Module[{osc = DampedOscillator[1, 0.1, 1]},
    {osc["Regime"], Abs[osc["OmegaD"] - 0.994987] < 10^-6, Abs[osc["QualityFactor"] - 5] < 10^-10}],
  {"Underdamped", True, True},
  TestID -> "oscilador-numerico-subamortiguado"
]

VerificationTest[
  #["Regime"] & /@ {DampedOscillator[1, 1, 1], DampedOscillator[1, 2, 1], DampedOscillator[1, 0, 1]},
  {"Critical", "Overdamped", "Undamped"},
  TestID -> "oscilador-numerico-tres-regimenes"
]

(* Sin amortiguamiento: Q y el tiempo de decaimiento son infinitos *)
VerificationTest[
  Module[{osc = DampedOscillator[1, 0, 1]},
    {osc["QualityFactor"], osc["DecayTime"]}],
  {Infinity, Infinity},
  TestID -> "oscilador-sin-amortiguamiento-Q-infinito"
]

VerificationTest[
  Module[{osc = DampedOscillator[1, 2, 1]},
    {osc["OmegaD"], Simplify[osc["GammaD"] - Sqrt[3]]}],
  {Missing["NotApplicable"], 0},
  TestID -> "oscilador-sobreamortiguado-GammaD"
]

VerificationTest[
  Module[{osc = DampedOscillator[2, 4, 8, "Form" -> "MBK"]},
    {osc["Mass"], osc["Gamma"], osc["Omega0"]}],
  {2, 1, 2},
  TestID -> "oscilador-forma-MBK"
]

(* Raíces de r² + 2γ r + ω0² = 0: suman −2γ y su producto es ω0² *)
VerificationTest[
  Module[{rts = drOsc["CharacteristicRoots"]},
    {Length[rts], drZeroQ[Total[rts] + 2 gam, drAsm], drZeroQ[Times @@ rts - w0^2, drAsm]}],
  {2, True, True},
  TestID -> "oscilador-raices-caracteristicas"
]

VerificationTest[
  DampedOscillator[1, 0.1, 1, "Regime" -> "Overdamped"],
  $Failed,
  {DampedOscillator::regime},
  TestID -> "oscilador-regimen-contradice-valores-regime"
]

VerificationTest[
  DampedOscillator[1, 0.1],
  $Failed,
  {DampedOscillator::args},
  TestID -> "oscilador-error-dos-argumentos-args"
]

VerificationTest[
  DampedOscillator[1, -0.1, 1],
  $Failed,
  {DampedOscillator::params},
  TestID -> "oscilador-error-gamma-negativo-params"
]

VerificationTest[
  DampedOscillator[-1, 0.1, 1],
  $Failed,
  {DampedOscillator::params},
  TestID -> "oscilador-error-masa-negativa-params"
]

VerificationTest[
  DampedOscillator[1, 0.1, 0],
  $Failed,
  {DampedOscillator::params},
  TestID -> "oscilador-error-omega0-cero-params"
]

(* === GreenFunction === *)

VerificationTest[
  KeyValueMap[
    Function[{reg, pair},
      Module[{res = GreenFunction[First[pair], tau], asm = Last[pair] && tau > 0},
        {reg, drZeroQ[res["Causal"] - drCausalIn[reg][tau], asm],
         drZeroQ[res["GreenFunction"] - HeavisideTheta[tau] drCausalIn[reg][tau], asm],
         res["Variable"]}]],
    drRegimes],
  {{"Undamped", True, True, tau}, {"Underdamped", True, True, tau},
   {"Critical", True, True, tau}, {"Overdamped", True, True, tau}},
  TestID -> "green-cuatro-regimenes"
]

VerificationTest[
  KeyValueMap[
    Function[{reg, pair},
      Module[{c = GreenFunction[First[pair], tau]["Causal"], g, w},
        {g, w} = {First[pair]["Gamma"], First[pair]["Omega0"]};
        drZeroQ[D[c, {tau, 2}] + 2 g D[c, tau] + w^2 c, Last[pair] && tau > 0]]],
    drRegimes],
  {True, True, True, True},
  TestID -> "green-cumple-ecuacion-homogenea"
]

(* G continua y salto de G' igual a 1/m *)
VerificationTest[
  KeyValueMap[
    Function[{reg, pair},
      Module[{c = GreenFunction[First[pair], tau]["Causal"]},
        {drZeroQ[c /. tau -> 0, Last[pair]], drZeroQ[(D[c, tau] /. tau -> 0) - 1/m, Last[pair]]}]],
    drRegimes],
  ConstantArray[{True, True}, 4],
  TestID -> "green-condiciones-en-cero"
]

VerificationTest[
  Simplify[Limit[GreenFunction[drOsc, tau]["Causal"], gam -> w0,
      Assumptions -> m > 0 && w0 > 0 && tau > 0] - tau Exp[-w0 tau]/m,
    m > 0 && w0 > 0 && tau > 0],
  0,
  TestID -> "green-limite-critico"
]

VerificationTest[
  Module[{steps = GreenFunction[drOsc, tau]["Steps"]},
    {Length[steps], AllTrue[steps, StringQ[#["Description"]] && KeyExistsQ[#, "Expression"] &]}],
  {5, True},
  TestID -> "green-steps"
]

VerificationTest[
  GreenFunction[drOsc],
  $Failed,
  {GreenFunction::args},
  TestID -> "green-error-un-argumento-args"
]

(* τ no puede ser un símbolo del oscilador *)
VerificationTest[
  GreenFunction[drOsc, gam],
  $Failed,
  {GreenFunction::var},
  TestID -> "green-error-variable-del-oscilador-var"
]

(* === GreenSolution === *)

drTotalAsm = drAsm && t > 0;

VerificationTest[
  drZeroQ[GreenSolution[drOsc, 0, {t, 0}, {x0, v0}]["Total"] -
    Exp[-gam t] (x0 Cos[drWd t] + (v0 + gam x0)/drWd Sin[drWd t]), drTotalAsm],
  True,
  TestID -> "solucion-fuerza-nula"
]

(* Escalón de altura F0 que empieza en t0 = 0: para t ≥ 0 la fuerza es la constante F0 *)
VerificationTest[
  drZeroQ[GreenSolution[drOsc, F0, {t, 0}, {0, 0}]["Total"] -
    F0/(m w0^2) (1 - Exp[-gam t] (Cos[drWd t] + gam/drWd Sin[drWd t])), drTotalAsm && F0 > 0],
  True,
  TestID -> "solucion-escalon-desde-el-reposo"
]

(* Escalón retardado (v1.1, precisión 6): reposo antes de t1 y, después, la respuesta al escalón
   desplazada en t1. Se compara a cada lado de t1 *)
VerificationTest[
  Module[{tot = GreenSolution[drOsc, F0 UnitStep[t - t1], {t, 0}, {0, 0}]["Total"],
      asm = drAsm && F0 > 0 && t1 > 0},
    {drZeroQ[tot, asm && 0 < t < t1],
     drZeroQ[tot - F0/(m w0^2) (1 - Exp[-gam (t - t1)] (Cos[drWd (t - t1)] +
       gam/drWd Sin[drWd (t - t1)])), asm && t > t1]}],
  {True, True},
  TestID -> "solucion-escalon-retardado"
]

(* Golpe en t1: P G(t − t1) con su escalón. Se compara antes y después de t1, para no depender
   de cómo se escriba el escalón (HeavisideTheta, UnitStep o Piecewise) *)
VerificationTest[
  Module[{part = GreenSolution[drOsc, P DiracDelta[t - t1], {t, 0}, {0, 0}]["Particular"],
      asm = drAsm && P > 0 && t1 > 0},
    {drZeroQ[part, asm && 0 < t < t1],
     drZeroQ[part - P drCausal["Underdamped"][t - t1], asm && t > t1]}],
  {True, True},
  TestID -> "solucion-golpe"
]

VerificationTest[
  drZeroQ[GreenSolution[DampedOscillator[m, 0, w0], F0 Cos[w0 t], {t, 0}, {0, 0}]["Total"] -
    F0 t Sin[w0 t]/(2 m w0), m > 0 && w0 > 0 && F0 > 0 && t > 0],
  True,
  TestID -> "solucion-resonancia-sin-amortiguamiento"
]

(* Tres fuerzas con condiciones iniciales generales. Para cada intervalo donde F es continua:
   la total cumple la ecuación; la total parte de {x0, v0} y la particular, del reposo *)
drForceAsm = drAsm && F0 > 0 && w > 0 && a > 0 && T > 0;
drForces = <|
  "coseno" -> {F0 Cos[w t], {t > 0}},
  "exponencial" -> {F0 Exp[-a t], {t > 0}},
  "pulso" -> {F0 (UnitStep[t] - UnitStep[t - T]), {0 < t < T, t > T}}|>;
drForceSols = GreenSolution[drOsc, First[#], {t, 0}, {x0, v0}] & /@ drForces;

VerificationTest[
  KeyValueMap[
    Function[{name, pair},
      Module[{sol = drForceSols[name], tot, part, first},
        first = drForceAsm && First[Last[pair]];
        tot = Simplify[sol["Total"], first];
        part = Simplify[sol["Particular"], first];
        {name,
         AllTrue[Last[pair], drZeroQ[
           m (D[sol["Total"], {t, 2}] + 2 gam D[sol["Total"], t] + w0^2 sol["Total"]) -
             First[pair], drForceAsm && #] &],
         drZeroQ[(tot /. t -> 0) - x0, drForceAsm], drZeroQ[(D[tot, t] /. t -> 0) - v0, drForceAsm],
         drZeroQ[part /. t -> 0, drForceAsm], drZeroQ[D[part, t] /. t -> 0, drForceAsm]}]],
    drForces],
  {{"coseno", True, True, True, True, True}, {"exponencial", True, True, True, True, True},
   {"pulso", True, True, True, True, True}},
  TestID -> "solucion-tres-fuerzas-ecuacion-y-condiciones-iniciales"
]

(* Las condiciones iniciales solo entran en la homogénea; la fuerza, solo en la particular *)
VerificationTest[
  Module[{other = GreenSolution[drOsc, F0 Cos[w t], {t, 0}, {x1, v1}]},
    {drZeroQ[drForceSols["coseno"]["Homogeneous"] - drForceSols["exponencial"]["Homogeneous"],
       drForceAsm && t > 0],
     drZeroQ[drForceSols["coseno"]["Particular"] - other["Particular"], drForceAsm && t > 0]}],
  {True, True},
  TestID -> "solucion-homogenea-sin-F-particular-sin-condiciones-iniciales"
]

(* A tiempos largos queda solo A Cos[ω t − δ], y Sqrt[x² + (x'/ω)²] = A. Con γ = 1/10,
   e^(−γ t) en t = 200 es 2·10⁻⁹ *)
VerificationTest[
  Module[{osc = DampedOscillator[1, 1/10, 1], part, amp},
    part = GreenSolution[osc, Cos[13/10 t], {t, 0}, {0, 0}]["Particular"];
    amp = N[Sqrt[part^2 + (D[part, t]/(13/10))^2] /. t -> 200, 20];
    Abs[amp - SteadyState[osc, 1, 13/10]["Amplitude"]] < 10^-6],
  True,
  TestID -> "solucion-coseno-tiempos-largos-amplitud-estacionaria"
]

VerificationTest[
  Module[{osc = DampedOscillator[1, 0.1, 1], res, y, s, nd},
    res = GreenSolution[osc, Exp[-Sin[t]^2 t], {t, 0}, {0, 0}];
    nd = First[NDSolve[{y''[s] + 0.2 y'[s] + y[s] == Exp[-Sin[s]^2 s], y[0] == 0, y'[0] == 0},
      y, {s, 0, 20}, PrecisionGoal -> 12, AccuracyGoal -> 14, MaxSteps -> Infinity]];
    {res["Method"],
     Max[Table[Abs[drAt[res["Particular"], t, s0] - (y[s0] /. nd)], {s0, 0, 20, 0.05}]] < 10^-6}],
  {"Numeric", True},
  TestID -> "solucion-fuerza-sin-primitiva-numerica"
]

(* m = 1, γ = 1/10, ω0 = 1 exactos: la misma solución que DSolve *)
VerificationTest[
  Module[{osc = DampedOscillator[1, 1/10, 1], y},
    Map[
      Function[force,
        drZeroQ[GreenSolution[osc, force, {t, 0}, {x0, v0}]["Total"] -
          (y[t] /. First[DSolve[{y''[t] + 1/5 y'[t] + y[t] == force, y[0] == x0, y'[0] == v0},
            y, t]]), F0 > 0 && w > 0 && t > 0]],
      {F0, F0 Cos[w t]}]],
  {True, True},
  TestID -> "solucion-igual-a-DSolve"
]

VerificationTest[
  Module[{steps = GreenSolution[drOsc, F0, {t, 0}, {x0, v0}]["Steps"]},
    {Length[steps], AllTrue[steps, StringQ[#["Description"]] && KeyExistsQ[#, "Expression"] &]}],
  {7, True},
  TestID -> "solucion-steps"
]

VerificationTest[
  GreenSolution[drOsc, F0, {t, 0}],
  $Failed,
  {GreenSolution::args},
  TestID -> "solucion-error-tres-argumentos-args"
]

(* El tiempo no puede ser un símbolo del oscilador *)
VerificationTest[
  GreenSolution[drOsc, F0, {gam, 0}, {0, 0}],
  $Failed,
  {GreenSolution::var},
  TestID -> "solucion-error-tiempo-del-oscilador-var"
]

VerificationTest[
  GreenSolution[drOsc, F0, {t, 0}, {t, 0}],
  $Failed,
  {GreenSolution::ic},
  TestID -> "solucion-error-condicion-inicial-con-t-ic"
]

(* Sin forma cerrada y con parámetros simbólicos: se devuelve la Association, con la integral
   sin evaluar en "Particular" *)
VerificationTest[
  Module[{res = GreenSolution[drOsc, Exp[-Sin[t]^2 t], {t, 0}, {0, 0}]},
    {AssociationQ[res], !FreeQ[res["Particular"], Integrate]}],
  {True, True},
  {GreenSolution::integral},
  TestID -> "solucion-integral-sin-forma-cerrada-integral"
]

(* === SteadyState === *)

drSSAsm = drAsm && F0 > 0 && w > 0;
drSS = SteadyState[drOsc, F0, w];
drDen = Sqrt[(w0^2 - w^2)^2 + 4 gam^2 w^2];

(* La fase se compara por su coseno y su seno, sin depender de cómo se escriba el ArcTan *)
VerificationTest[
  {drZeroQ[drSS["Amplitude"] - (F0/m)/drDen, drSSAsm],
   drZeroQ[Cos[drSS["Phase"]] - (w0^2 - w^2)/drDen, drSSAsm],
   drZeroQ[Sin[drSS["Phase"]] - 2 gam w/drDen, drSSAsm],
   drZeroQ[drSS["Susceptibility"] - 1/(m (w0^2 - w^2 + 2 I gam w)), drSSAsm]},
  {True, True, True, True},
  TestID -> "estacionario-amplitud-fase-susceptibilidad"
]

VerificationTest[
  Module[{ss = SteadyState[DampedOscillator[1, 0.1, 1], 1, 1]},
    {Abs[ss["ResonanceFrequency"] - 0.989949] < 10^-6, Abs[ss["MaxAmplitude"] - 5.02519] < 10^-5,
     Abs[ss["Amplitude"] - 5] < 10^-10}],
  {True, True, True},
  TestID -> "estacionario-numerico"
]

(* γ = 0.9 < ω0 = 1, pero ω0² < 2γ²: no hay máximo fuera de ω = 0, y la amplitud máxima es la
   de ω = 0, F0/(m ω0²) = 1 (v1.1, precisión 4) *)
VerificationTest[
  With[{ss = SteadyState[DampedOscillator[1, 0.9, 1], 1, 1]},
    {TrueQ[ss["ResonanceFrequency"] == 0], Abs[ss["MaxAmplitude"] - 1] < 10^-10}],
  {True, True},
  TestID -> "estacionario-sin-resonancia-frecuencia-cero"
]

VerificationTest[
  SteadyState[DampedOscillator[m, 0, w0], F0, w0],
  $Failed,
  {SteadyState::resonance},
  TestID -> "estacionario-resonancia-sin-amortiguamiento-resonance"
]

VerificationTest[
  SteadyState[drOsc, F0],
  $Failed,
  {SteadyState::args},
  TestID -> "estacionario-error-dos-argumentos-args"
]

(* --- "Steps" y ShowSteps --- *)

drStepsQ[res_] := MatchQ[res["Steps"], {__Association}] &&
  AllTrue[res["Steps"], StringQ[#["Description"]] && KeyExistsQ[#, "Expression"] &];

(* v1.1, precisión 1: 4 pasos en DampedOscillator y 5 en SteadyState *)
VerificationTest[
  {drStepsQ[drOsc], Length[drOsc["Steps"]], drStepsQ[drSS], Length[drSS["Steps"]]},
  {True, 4, True, 5},
  TestID -> "oscilador-y-estacionario-steps"
]

VerificationTest[
  Head[ShowSteps[#]] & /@
    {drOsc, GreenFunction[drOsc, tau], GreenSolution[drOsc, F0, {t, 0}, {x0, v0}], drSS},
  {Grid, Grid, Grid, Grid},
  TestID -> "ShowSteps-devuelve-Grid"
]

(* --- Mensaje en inglés --- *)

VerificationTest[
  Module[{en},
    en = Block[{$CMLanguage = "English"},
      Quiet[DampedOscillator[m, gam, w0]];
      DampedOscillator::regime];
    StringQ[en] && en === CMToolkit`Private`$texts["DampedOscillator::regime"]["English"]],
  True,
  TestID -> "oscilador-mensaje-en-ingles"
]

(* --- Alias --- *)

VerificationTest[
  OsciladorAmortiguado[m, gam, w0, Assumptions -> drAsm] === drOsc,
  True,
  TestID -> "alias-OsciladorAmortiguado"
]

VerificationTest[
  FuncionDeGreen[drOsc, tau] === GreenFunction[drOsc, tau],
  True,
  TestID -> "alias-FuncionDeGreen"
]

VerificationTest[
  SolucionDeGreen[drOsc, F0, {t, 0}, {x0, v0}] === GreenSolution[drOsc, F0, {t, 0}, {x0, v0}],
  True,
  TestID -> "alias-SolucionDeGreen"
]

VerificationTest[
  EstadoEstacionario[drOsc, F0, w] === drSS,
  True,
  TestID -> "alias-EstadoEstacionario"
]
