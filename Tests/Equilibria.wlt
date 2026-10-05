(* Tests de EquilibriumPoints y ClassifyEquilibrium.
   Especificación: docs/specs/Equilibria.md (versión 1.2).
   Valores de referencia: Ayudantía 6, Problema 1, inciso (a), ecs. (7)–(13). *)

(* Dos condiciones son equivalentes si no hay valores de los parámetros, bajo las suposiciones,
   en que una se cumpla y la otra no *)
eqEquivalentQ[c1_, c2_, asm_, vars_List] := Reduce[Xor[c1, c2] && asm, vars, Reals] === False;

(* --- Anillo que rota (Problema 1) --- *)

eqAsmRing = m > 0 && b > 0 && g > 0 && w > 0;
eqRingL = m b^2/2 (th'[t]^2 + w^2 Sin[th[t]]^2) - m g b Cos[th[t]];
eqTheta0 = ArcCos[-g/(b w^2)];
eqRingPts = EquilibriumPoints[eqRingL, {th, t}, "Domain" -> {0, 2 Pi}];

VerificationTest[
  Simplify[eqRingPts["Potential"] - (m g b Cos[th] - m b^2 w^2/2 Sin[th]^2), eqAsmRing],
  0,
  TestID -> "puntos-anillo-potencial"
]

VerificationTest[
  Simplify[eqRingPts["Derivative"] - (-b m Sin[th] (g + b w^2 Cos[th])), eqAsmRing],
  0,
  TestID -> "puntos-anillo-derivada-ec-7"
]

VerificationTest[
  Sort[eqRingPts["Factors"]],
  Sort[{Sin[th], g + b w^2 Cos[th]}],
  TestID -> "puntos-anillo-factores"
]

(* Orden de "Points" (v1.2): primero los que existen siempre, después los dos de ArcCos *)
VerificationTest[
  Module[{pts = eqRingPts["Points"]},
    {Length[pts],
     pts[[1 ;; 2]],
     Sort[Simplify[pts[[3 ;; 4, "Point"]]]] === Sort[{eqTheta0, 2 Pi - eqTheta0}]}],
  {4,
   {<|"Point" -> 0, "Condition" -> True|>, <|"Point" -> Pi, "Condition" -> True|>},
   True},
  TestID -> "puntos-anillo-orden-y-valores-ecs-8-10"
]

(* Condición estricta: en b w^2 = g los dos de ArcCos coinciden con Pi, ya listado *)
VerificationTest[
  eqEquivalentQ[#["Condition"], b w^2 > g, eqAsmRing, {b, g, w}] & /@
    eqRingPts["Points"][[3 ;; 4]],
  {True, True},
  TestID -> "puntos-anillo-condicion-estricta"
]

VerificationTest[
  Length[eqRingPts["Steps"]],
  6,
  TestID -> "puntos-anillo-un-paso-por-factor"
]

(* Las suposiciones del usuario reemplazan las automáticas: con b w^2 < g no hay θ0 *)
VerificationTest[
  EquilibriumPoints[eqRingL, {th, t}, "Domain" -> {0, 2 Pi},
    Assumptions -> eqAsmRing && b w^2 < g]["Points"],
  {<|"Point" -> 0, "Condition" -> True|>, <|"Point" -> Pi, "Condition" -> True|>},
  TestID -> "puntos-anillo-suposiciones-del-usuario"
]

VerificationTest[
  EquilibriumPoints[eqRingL, {th, t}],
  $Failed,
  {EquilibriumPoints::periodic},
  TestID -> "puntos-anillo-sin-dominio-periodic"
]

(* --- Casos con solución conocida (no están en la ayudantía) --- *)

VerificationTest[
  EquilibriumPoints[m/2 y'[t]^2 - (y[t]^3/3 - c y[t]), {y, t}]["Points"],
  {<|"Point" -> -Sqrt[c], "Condition" -> True|>, <|"Point" -> Sqrt[c], "Condition" -> True|>},
  {},
  TestID -> "puntos-cubico"
]

VerificationTest[
  EquilibriumPoints[m/2 y'[t]^2 - k/2 y[t]^2 + m g y[t], {y, t}]["Points"],
  {<|"Point" -> g m/k, "Condition" -> True|>},
  {},
  TestID -> "puntos-resorte-vertical-sin-dominio"
]

VerificationTest[
  EquilibriumPoints[m/2 y'[t]^2 - a Exp[y[t]], {y, t}]["Points"],
  {},
  {EquilibriumPoints::none},
  TestID -> "puntos-ninguno"
]

(* U' = (y - 1)(Sin[y] - a y): Solve no resuelve el segundo factor; y = 1 se devuelve igual *)
VerificationTest[
  Module[{res},
    res = EquilibriumPoints[
      m/2 y'[t]^2 - Integrate[(u - 1) (Sin[u] - a u), {u, 0, y[t]}], {y, t}];
    {res["Points"], Length[res["Steps"]]}],
  {{<|"Point" -> 1, "Condition" -> True|>}, 6},
  {EquilibriumPoints::unsolved},
  TestID -> "puntos-factor-no-resuelto"
]

(* --- Errores --- *)

VerificationTest[
  EquilibriumPoints[eqRingL],
  $Failed,
  {EquilibriumPoints::args},
  TestID -> "puntos-error-un-argumento"
]

VerificationTest[
  EquilibriumPoints[eqRingL, {th, t}, Pi],
  $Failed,
  {EquilibriumPoints::args},
  TestID -> "puntos-error-tres-argumentos"
]

VerificationTest[
  EquilibriumPoints[eqRingL + t th[t], {th, t}, "Domain" -> {0, 2 Pi}],
  $Failed,
  {EquilibriumPoints::time},
  TestID -> "puntos-error-L-depende-de-t"
]

VerificationTest[
  EquilibriumPoints[eqRingL, {th, t}, "Domain" -> {2 Pi, 0}],
  $Failed,
  {EquilibriumPoints::domain},
  TestID -> "puntos-error-dominio-invertido"
]

VerificationTest[
  EquilibriumPoints[eqRingL, {th, t}, "Domain" -> {0, a}],
  $Failed,
  {EquilibriumPoints::domain},
  TestID -> "puntos-error-dominio-simbolico"
]

VerificationTest[
  Module[{en},
    en = Block[{$CMLanguage = "English"},
      Quiet[EquilibriumPoints[eqRingL, {th, t}, "Domain" -> {2 Pi, 0}]];
      EquilibriumPoints::domain];
    StringQ[en] && en === CMToolkit`Private`$texts["EquilibriumPoints::domain"]["English"]],
  True,
  TestID -> "puntos-mensaje-en-ingles"
]

(* --- Alias y ShowSteps --- *)

VerificationTest[
  PuntosDeEquilibrio[eqRingL, {th, t}, "Domain" -> {0, 2 Pi}] === eqRingPts,
  True,
  TestID -> "alias-PuntosDeEquilibrio"
]

VerificationTest[
  Head[ShowSteps[eqRingPts]],
  Grid,
  TestID -> "puntos-ShowSteps-devuelve-Grid"
]
