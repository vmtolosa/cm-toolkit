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

(* Paso 3: primero la parte cinética (con th'), luego la potencial (sin th'), esta última
   expandida y término a término (docs/specs/Ajustes1D.md, punto 6). Verbatim evita que el
   atributo Flat de Plus agrupe los sumandos de otra forma *)
VerificationTest[
  MatchQ[moRingE["Steps"][[3, "Expression"]],
    _ == HoldForm[Verbatim[Plus][kin_, pots__]] /;
      !FreeQ[kin, Derivative[1][th]] && FreeQ[{pots}, Derivative[1][th]] &&
      Sort[{pots}] === Sort[{b g m Cos[th[t]], -(1/2) b^2 m w^2 Sin[th[t]]^2}]],
  True,
  TestID -> "energia-paso-3-cinetica-antes-que-potencial"
]

(* La clave "EnergyFunction" no cambia: parte cinética simplificada más potencial simplificada *)
VerificationTest[
  moRingE["EnergyFunction"] ===
    Simplify[m b^2/2 th'[t]^2] + Simplify[m g b Cos[th[t]] - m b^2 w^2/2 Sin[th[t]]^2],
  True,
  TestID -> "energia-clave-sin-cambios"
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

(* Descripciones con los símbolos del usuario (docs/specs/Ajustes1D.md, punto 5): una
   coordenada de una letra lleva el punto encima; una de varias, la prima *)
VerificationTest[
  Module[{ds = EnergyFunction[m/2 x'[t]^2 - k/2 (Sqrt[x[t]^2 + h^2] - l0)^2, {x, t}][
      "Steps"][[All, "Description"]]},
    {NoneTrue[ds, StringContainsQ[#, RegularExpression["\\bq\\b"]] &],
     StringContainsQ[First[ds], "x\:0307"]}],
  {True, True},
  TestID -> "energia-riel-descripciones-con-x-punto"
]

VerificationTest[
  StringContainsQ[moRingE["Steps"][[1, "Description"]], "th'"],
  True,
  TestID -> "energia-anillo-descripciones-con-th-prima"
]

(* El tiempo también es un marcador: con tiempo s, la conclusión no dice «t» *)
VerificationTest[
  Module[{d = Last[EnergyFunction[m/2 y'[s]^2 - k/2 y[s]^2, {y, s}]["Steps"]]["Description"]},
    {StringEndsQ[d, "de s."], StringContainsQ[d, RegularExpression["\\bt\\b"]]}],
  {True, False},
  TestID -> "energia-marcador-de-tiempo"
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

(* === CompareHarmonic === *)

(* ImageSize de un gráfico, con o sin leyenda *)
moImageSize[g_] := Lookup[Options[If[Head[g] === Legended, First[g], g]], ImageSize];

VerificationTest[
  MatchQ[CompareHarmonic[moRing[0.6], {th, t}, Pi, 0.15, 40], _Graphics | _Legended],
  True,
  TestID -> "comparar-anillo-0.6-figura-3-i"
]

VerificationTest[
  MatchQ[CompareHarmonic[moRing[0.95], {th, t}, Pi, 0.15, 60], _Graphics | _Legended],
  True,
  TestID -> "comparar-anillo-0.95-figura-3-ii"
]

VerificationTest[
  MatchQ[CompareHarmonic[moRing[1.5], {th, t}, ArcCos[-1/1.5^2], 0.1, 30], _Graphics | _Legended],
  True,
  TestID -> "comparar-anillo-1.5-listado-5"
]

VerificationTest[
  MatchQ[CompareHarmonic[moRing[0.6], {th, t}, Pi, 0.15, 40, "InitialVelocity" -> 0.05],
    _Graphics | _Legended],
  True,
  TestID -> "comparar-velocidad-inicial"
]

VerificationTest[
  moImageSize[CompareHarmonic[moRing[0.6], {th, t}, Pi, 0.15, 40, ImageSize -> 200]],
  200,
  TestID -> "comparar-opcion-del-usuario-gana"
]

VerificationTest[
  CompareHarmonic[moRing[0.6], {th, t}, 0, 0.15, 40],
  $Failed,
  {CompareHarmonic::notmin},
  TestID -> "comparar-error-maximo"
]

VerificationTest[
  CompareHarmonic[moRing[0.6], {th, t}, Pi/2, 0.15, 40],
  $Failed,
  {CompareHarmonic::noteq},
  TestID -> "comparar-error-no-es-equilibrio"
]

VerificationTest[
  CompareHarmonic[moRingL, {th, t}, Pi, 0.15, 40],
  $Failed,
  {CompareHarmonic::numeric},
  TestID -> "comparar-error-anillo-simbolico"
]

VerificationTest[
  CompareHarmonic[moRing[0.6], {th, t}, Pi, a, 40],
  $Failed,
  {CompareHarmonic::ic},
  TestID -> "comparar-error-x0-simbolico"
]

VerificationTest[
  CompareHarmonic[moRing[0.6], {th, t}, Pi, 0.15, 40, "InitialVelocity" -> v],
  $Failed,
  {CompareHarmonic::ic},
  TestID -> "comparar-error-velocidad-simbolica"
]

VerificationTest[
  CompareHarmonic[y[t] y'[t] - y[t]^2/2, {y, t}, 0, 0.1, 10],
  $Failed,
  {CompareHarmonic::mass},
  TestID -> "comparar-error-masa-nula"
]

VerificationTest[
  CompareHarmonic[moRing[0.6] + t th[t], {th, t}, Pi, 0.15, 40],
  $Failed,
  {CompareHarmonic::time},
  TestID -> "comparar-error-L-depende-de-t"
]

VerificationTest[
  CompareHarmonic[moRing[0.6], {th, t}, Pi, 0.15],
  $Failed,
  {CompareHarmonic::args},
  TestID -> "comparar-error-cuatro-argumentos"
]

VerificationTest[
  Module[{en},
    en = Block[{$CMLanguage = "English"},
      Quiet[CompareHarmonic[moRing[0.6], {th, t}, 0, 0.15, 40]];
      CompareHarmonic::notmin];
    StringQ[en] && en === CMToolkit`Private`$texts["CompareHarmonic::notmin"]["English"]],
  True,
  TestID -> "comparar-mensaje-en-ingles"
]

(* Alias de una función gráfica: mismo Head y sin mensajes *)
VerificationTest[
  Head[CompararArmonica[moRing[0.6], {th, t}, Pi, 0.15, 40]] ===
    Head[CompareHarmonic[moRing[0.6], {th, t}, Pi, 0.15, 40]],
  True,
  TestID -> "alias-CompararArmonica"
]

(* === PhasePortrait === *)

moPhase = PhasePortrait[moRing[0.6], {th, t}, {Pi + 0.15, 0}, 40];

VerificationTest[
  MatchQ[moPhase, _Graphics | _Legended],
  True,
  TestID -> "fase-anillo-una-trayectoria"
]

VerificationTest[
  MatchQ[PhasePortrait[moRing[0.6], {th, t}, {{Pi + 0.15, 0}, {Pi + 0.5, 0}, {Pi, 0.6}}, 40],
    _Graphics | _Legended],
  True,
  TestID -> "fase-anillo-tres-trayectorias"
]

VerificationTest[
  Lookup[Options[moPhase], AspectRatio],
  1,
  TestID -> "fase-AspectRatio-1-por-defecto"
]

(* Todas las trayectorias son exactas: ninguna punteada *)
VerificationTest[
  FreeQ[PhasePortrait[moRing[0.6], {th, t}, {{Pi + 0.15, 0}, {Pi + 0.5, 0}}, 40], _Dashing],
  True,
  TestID -> "fase-trayectorias-continuas"
]

(* Una sola trayectoria: el primer estilo (azul, continuo), sin mezclar la lista de PlotStyle
   de $CMPlotStyle (ver docs/specs/Ajustes1D.md, punto 7) *)
VerificationTest[
  !FreeQ[moPhase, RGBColor[0.12, 0.35, 0.65]] && FreeQ[moPhase, _Dashing],
  True,
  TestID -> "fase-una-trayectoria-primer-estilo"
]

VerificationTest[
  moImageSize[PhasePortrait[moRing[0.6], {th, t}, {Pi + 0.15, 0}, 40, ImageSize -> 200]],
  200,
  TestID -> "fase-opcion-del-usuario-gana"
]

(* Una trayectoria que falla: su mensaje y el gráfico con las demás *)
VerificationTest[
  MatchQ[PhasePortrait[moRing[0.6], {th, t}, {{Pi + 0.15, 0}, {a, 0}}, 40], _Graphics | _Legended],
  True,
  {PhasePortrait::ic},
  TestID -> "fase-una-trayectoria-falla"
]

(* U = y²/2 − y⁴/4: desde 0.5 queda en el pozo; desde 2, fuera de la barrera, diverge *)
VerificationTest[
  MatchQ[PhasePortrait[y'[t]^2/2 - y[t]^2/2 + y[t]^4/4, {y, t}, {{0.5, 0}, {2, 0}}, 10],
    _Graphics | _Legended],
  True,
  {PhasePortrait::ndsolve},
  TestID -> "fase-una-trayectoria-diverge"
]

VerificationTest[
  PhasePortrait[moRing[0.6], {th, t}, {a, 0}, 40],
  $Failed,
  {PhasePortrait::ic},
  TestID -> "fase-error-todas-fallan"
]

VerificationTest[
  PhasePortrait[moRingL, {th, t}, {Pi + 0.15, 0}, 40],
  $Failed,
  {PhasePortrait::numeric},
  TestID -> "fase-error-anillo-simbolico"
]

VerificationTest[
  PhasePortrait[moRing[0.6] + t th[t], {th, t}, {Pi + 0.15, 0}, 40],
  $Failed,
  {PhasePortrait::time},
  TestID -> "fase-error-L-depende-de-t"
]

VerificationTest[
  PhasePortrait[moRing[0.6], {th, t}, {{Pi + 0.15}}, 40],
  $Failed,
  {PhasePortrait::args},
  TestID -> "fase-error-condiciones-mal-formadas"
]

VerificationTest[
  Module[{en},
    en = Block[{$CMLanguage = "English"},
      Quiet[PhasePortrait[moRingL, {th, t}, {Pi + 0.15, 0}, 40]];
      PhasePortrait::numeric];
    StringQ[en] && en === CMToolkit`Private`$texts["PhasePortrait::numeric"]["English"]],
  True,
  TestID -> "fase-mensaje-en-ingles"
]

VerificationTest[
  Head[RetratoDeFase[moRing[0.6], {th, t}, {Pi + 0.15, 0}, 40]] === Head[moPhase],
  True,
  TestID -> "alias-RetratoDeFase"
]
