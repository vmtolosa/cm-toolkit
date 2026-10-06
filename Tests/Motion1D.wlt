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
