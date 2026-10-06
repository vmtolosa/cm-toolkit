(* Tests de EnergyFunction, SolveMotion, CompareHarmonic y PhasePortrait.
   Especificación: docs/specs/Motion1D.md (versión 1.1, Parte A).
   Valores de referencia: Ayudantía 6, Problema 1, incisos (b) y (c); ecs. (23), (26), (27),
   Listados 4 y 5, Figura 3. *)

(* --- Anillo que rota (Problema 1) --- *)

moRingL = m b^2/2 (th'[t]^2 + w^2 Sin[th[t]]^2) - m g b Cos[th[t]];
moRing[r_] := moRingL /. {m -> 1, g -> 1, b -> 1, w -> r};

(* === EnergyFunction === *)

moRingE = EnergyFunction[moRingL, {th, t}];

VerificationTest[
  Simplify[moRingE["EnergyFunction"] -
    (m b^2/2 (th'[t]^2 - w^2 Sin[th[t]]^2) + m g b Cos[th[t]])],
  0,
  TestID -> "energia-anillo-ec-27"
]

VerificationTest[
  Simplify[moRingE["Momentum"] - m b^2 th'[t]],
  0,
  TestID -> "energia-anillo-momento"
]

VerificationTest[
  Simplify[EnergyFunction[m/2 y'[t]^2 - k/2 y[t]^2, {y, t}]["EnergyFunction"] -
    (m/2 y'[t]^2 + k/2 y[t]^2)],
  0,
  TestID -> "energia-oscilador-T-mas-V"
]

VerificationTest[
  Length[moRingE["Steps"]],
  4,
  TestID -> "energia-cuatro-pasos"
]

(* Paso 3: primero la parte cinética (con th'), luego la potencial (sin th') *)
VerificationTest[
  MatchQ[moRingE["Steps"][[3, "Expression"]],
    _ == HoldForm[Plus[kin_, pot_]] /; !FreeQ[kin, Derivative[1][th]] && FreeQ[pot, Derivative[1][th]]],
  True,
  TestID -> "energia-paso-3-cinetica-antes-que-potencial"
]

VerificationTest[
  EnergyFunction[moRingL + t th[t], {th, t}],
  $Failed,
  {EnergyFunction::time},
  TestID -> "energia-error-L-depende-de-t"
]

VerificationTest[
  EnergyFunction[moRingL],
  $Failed,
  {EnergyFunction::args},
  TestID -> "energia-error-un-argumento"
]

VerificationTest[
  Module[{en},
    en = Block[{$CMLanguage = "English"},
      Quiet[EnergyFunction[moRingL + t th[t], {th, t}]];
      EnergyFunction::time];
    StringQ[en] && en === CMToolkit`Private`$texts["EnergyFunction::time"]["English"]],
  True,
  TestID -> "energia-mensaje-en-ingles"
]

VerificationTest[
  FuncionEnergia[moRingL, {th, t}] === moRingE,
  True,
  TestID -> "alias-FuncionEnergia"
]

VerificationTest[
  Head[ShowSteps[moRingE]],
  Grid,
  TestID -> "energia-ShowSteps-devuelve-Grid"
]

(* === SolveMotion === *)

moSol95 = SolveMotion[moRing[0.95], {th, t}, {Pi + 0.6, 0}, 60];

VerificationTest[
  moSol95["EnergyDrift"] < 10^-6,
  True,
  TestID -> "movimiento-anillo-deriva-de-h-ec-27"
]

VerificationTest[
  With[{eom = moSol95["EquationOfMotion"]},
    eom[[1]] === th''[t] &&
      Chop[Simplify[eom[[2]] - Sin[th[t]] (1 + 0.95^2 Cos[th[t]])]] === 0],
  True,
  TestID -> "movimiento-anillo-ecuacion-exacta-ec-26"
]

VerificationTest[
  {moSol95["Domain"], moSol95["InitialConditions"]},
  {{0, 60}, {Pi + 0.6, 0}},
  TestID -> "movimiento-dominio-y-condiciones-iniciales"
]

VerificationTest[
  Chop[Simplify[moSol95["EnergyFunction"] -
    (th'[t]^2/2 - 0.95^2/2 Sin[th[t]]^2 + Cos[th[t]])]],
  0,
  TestID -> "movimiento-anillo-funcion-energia"
]

VerificationTest[
  Abs[SolveMotion[y'[t]^2/2 - y[t]^2/2, {y, t}, {1, 0}, 10]["Solution"][Pi] + 1] < 10^-6,
  True,
  TestID -> "movimiento-oscilador-en-t-igual-pi"
]

(* Lejos del punto crítico el período armónico 2 Pi/Sqrt[1 - r^2] es bueno: ec. (23) *)
VerificationTest[
  Abs[SolveMotion[moRing[0.6], {th, t}, {Pi + 0.15, 0}, 40]["Solution"][2 Pi/Sqrt[1 - 0.6^2]] -
    (Pi + 0.15)] < 10^-3,
  True,
  TestID -> "movimiento-anillo-periodo-armonico-ec-23"
]

VerificationTest[
  SolveMotion[moRingL, {th, t}, {Pi + 0.6, 0}, 60],
  $Failed,
  {SolveMotion::numeric},
  TestID -> "movimiento-error-anillo-simbolico"
]

VerificationTest[
  SolveMotion[moRing[0.95], {th, t}, {Pi + 0.6, 0}, -1],
  $Failed,
  {SolveMotion::ic},
  TestID -> "movimiento-error-tmax-negativo"
]

VerificationTest[
  SolveMotion[moRing[0.95], {th, t}, {a, 0}, 60],
  $Failed,
  {SolveMotion::ic},
  TestID -> "movimiento-error-q0-simbolico"
]

VerificationTest[
  SolveMotion[moRing[0.95] + t th[t], {th, t}, {Pi + 0.6, 0}, 60],
  $Failed,
  {SolveMotion::time},
  TestID -> "movimiento-error-L-depende-de-t"
]

VerificationTest[
  SolveMotion[moRing[0.95], {th, t}, {Pi + 0.6, 0}],
  $Failed,
  {SolveMotion::args},
  TestID -> "movimiento-error-tres-argumentos"
]

(* Sin término cinético: ∂²L/∂q̇² es idénticamente 0 *)
VerificationTest[
  SolveMotion[y[t] y'[t] - y[t]^2/2, {y, t}, {1, 0}, 10],
  $Failed,
  {SolveMotion::mass},
  TestID -> "movimiento-error-masa-nula"
]

(* ∂²L/∂q̇² = y² se anula en la condición inicial y = 0 *)
VerificationTest[
  SolveMotion[y[t]^2 y'[t]^2/2 - y[t]^2/2, {y, t}, {0, 1}, 10],
  $Failed,
  {SolveMotion::mass},
  TestID -> "movimiento-error-masa-nula-en-t-0"
]

(* U = −y⁴/4: la solución diverge en tiempo finito, antes de tmax *)
VerificationTest[
  SolveMotion[y'[t]^2/2 + y[t]^4/4, {y, t}, {1, 0}, 10],
  $Failed,
  {SolveMotion::ndsolve},
  TestID -> "movimiento-error-ndsolve-divergencia"
]

VerificationTest[
  Module[{en},
    en = Block[{$CMLanguage = "English"},
      Quiet[SolveMotion[moRingL, {th, t}, {Pi + 0.6, 0}, 60]];
      SolveMotion::numeric];
    StringQ[en] && en === CMToolkit`Private`$texts["SolveMotion::numeric"]["English"]],
  True,
  TestID -> "movimiento-mensaje-en-ingles"
]

VerificationTest[
  ResolverMovimiento[moRing[0.95], {th, t}, {Pi + 0.6, 0}, 60] === moSol95,
  True,
  TestID -> "alias-ResolverMovimiento"
]
