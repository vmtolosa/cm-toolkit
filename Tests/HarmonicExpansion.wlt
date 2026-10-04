(* Tests de HarmonicExpansion / ShowSteps y de la infraestructura bilingüe.
   Especificación: docs/specs/HarmonicExpansion.md (versión 2).
   Valores de referencia: Ayudantía 6, Problema 1. *)

(* --- Infraestructura bilingüe: tr y cmMessage (privadas) --- *)

VerificationTest[
  Module[{es, en},
    es = Block[{$CMLanguage = "Spanish"}, CMToolkit`Private`tr["ShowSteps:description"]];
    en = Block[{$CMLanguage = "English"}, CMToolkit`Private`tr["ShowSteps:description"]];
    StringQ[es] && StringQ[en] && es =!= en],
  True,
  TestID -> "tr-espanol-e-ingles-distintos"
]

VerificationTest[
  CMToolkit`Private`tr["clave-que-no-existe"],
  "clave-que-no-existe",
  TestID -> "tr-clave-inexistente-devuelve-la-clave"
]

VerificationTest[
  CMToolkit`Private`cmMessage[cmTestSymbol, "prueba"],
  Null,
  {cmTestSymbol::prueba},
  TestID -> "cmMessage-emite-el-mensaje"
]

(* --- HarmonicExpansion: anillo que rota (Problema 1) --- *)

asmRing = m > 0 && b > 0 && g > 0 && w > 0;
ringL = m b^2/2 (th'[t]^2 + w^2 Sin[th[t]]^2) - m g b Cos[th[t]];
ringPi = HarmonicExpansion[ringL, {th, t}, Pi, x];

(* Cota de amplitud con g = b = m = 1 y w numérico *)
ringBound[wv_] := HarmonicExpansion[ringL /. {g -> 1, b -> 1, m -> 1, w -> wv},
  {th, t}, Pi, x]["AmplitudeBound"]["Bound"];

VerificationTest[
  Simplify[ringPi["EffectiveMass"] - m b^2, asmRing] === 0,
  True,
  TestID -> "anillo-pi-masa-efectiva"
]

VerificationTest[
  Simplify[ringPi["EffectiveStiffness"] - b m (g - b w^2), asmRing] === 0,
  True,
  TestID -> "anillo-pi-constante-efectiva"
]

VerificationTest[
  Simplify[ringPi["Omega2"] - (g/b - w^2), asmRing] === 0,
  True,
  TestID -> "anillo-pi-omega2"
]

VerificationTest[
  With[{ab = ringPi["AmplitudeBound"]},
    ab["Order"] === 4 &&
    Simplify[ab["Bound"] - Abs[12 (g/b - w^2)/(4 w^2 - g/b)], asmRing] === 0 &&
    Head[ab["Condition"]] === LessLess &&
    ab["Condition"] === LessLess[Abs[x]^2, ab["Bound"]]],
  True,
  TestID -> "anillo-pi-cota-orden-4"
]

VerificationTest[
  ringBound[0],
  12,
  TestID -> "anillo-pi-cota-w-0"
]

VerificationTest[
  Abs[ringBound[0.6] - 17.4545] < 10^-3,
  True,
  TestID -> "anillo-pi-cota-w-0.6"
]

VerificationTest[
  Abs[ringBound[0.9] - 1.0179] < 10^-3,
  True,
  TestID -> "anillo-pi-cota-w-0.9"
]

VerificationTest[
  Abs[ringBound[0.95] - 0.4483] < 10^-3,
  True,
  TestID -> "anillo-pi-cota-w-0.95"
]

VerificationTest[
  Abs[ringBound[0.99] - 0.0818] < 10^-3,
  True,
  TestID -> "anillo-pi-cota-w-0.99"
]

VerificationTest[
  With[{ab = HarmonicExpansion[ringL /. w -> Sqrt[g/b]/2, {th, t}, Pi, x]["AmplitudeBound"]},
    ab["Order"] === 6 && Simplify[ab["Bound"] - 90, asmRing] === 0],
  True,
  TestID -> "anillo-pi-cota-orden-6-en-wc-medios"
]

VerificationTest[
  With[{res = HarmonicExpansion[ringL /. w -> Sqrt[g/b], {th, t}, Pi, x]},
    {res["Omega2"], res["AmplitudeBound"],
     Simplify[Coefficient[res["PotentialSeries"], x, 4] - m g b/8, asmRing] === 0}],
  {0, Missing["CriticalPoint"], True},
  {HarmonicExpansion::critical},
  TestID -> "anillo-pi-caso-critico"
]

VerificationTest[
  Simplify[HarmonicExpansion[ringL, {th, t}, ArcCos[-g/(b w^2)], x]["Omega2"] -
    (w^2 - g^2/(b^2 w^2)), asmRing] === 0,
  True,
  TestID -> "anillo-theta0-omega2"
]

VerificationTest[
  Simplify[HarmonicExpansion[ringL /. w -> 0, {th, t}, Pi, x]["Omega2"] - g/b, asmRing] === 0,
  True,
  TestID -> "anillo-pendulo-omega2"
]

VerificationTest[
  With[{steps = ringPi["Steps"]},
    Length[steps] === 10 &&
    AllTrue[steps, AssociationQ[#] && StringQ[#["Description"]] && KeyExistsQ[#, "Expression"] &]],
  True,
  TestID -> "anillo-pi-steps"
]

(* v3.2: la serie y la ecuación de movimiento se guardan retenidas en "Steps", en el orden
   en que se escriben a mano; las claves principales siguen sin retener *)
VerificationTest[
  With[{steps = ringPi["Steps"]},
    {!FreeQ[steps[[5]]["Expression"], HoldForm],
     !FreeQ[steps[[9]]["Expression"], HoldForm],
     FreeQ[{ringPi["PotentialSeries"], ringPi["EquationOfMotion"]}, HoldForm],
     ReleaseHold[steps[[5]]["Expression"]] === ("U"[Pi + x] == ringPi["PotentialSeries"]),
     ReleaseHold[steps[[9]]["Expression"]] === ringPi["EquationOfMotion"]}],
  {True, True, True, True, True},
  TestID -> "steps-orden-de-presentacion"
]

VerificationTest[
  ExpansionArmonica[ringL, {th, t}, Pi, x] === ringPi,
  True,
  TestID -> "alias-ExpansionArmonica"
]

(* --- Criterio de cero con números inexactos (g = b = m = 1, w = 0.6) --- *)

VerificationTest[
  HarmonicExpansion[ringL /. {g -> 1, b -> 1, m -> 1, w -> 0.6}, {th, t}, N[Pi], x][
    "AmplitudeBound"]["Order"],
  4,
  {},
  TestID -> "q0-N-Pi-es-equilibrio"
]

VerificationTest[
  With[{ser = HarmonicExpansion[ringL /. {g -> 1, b -> 1, m -> 1, w -> 0.6}, {th, t}, N[Pi], x][
      "PotentialSeries"]},
    {Coefficient[ser, x, 1], Coefficient[ser, x, 3]}],
  {0, 0},
  {},
  TestID -> "q0-N-Pi-serie-sin-ruido"
]

VerificationTest[
  HarmonicExpansion[ringL /. {g -> 1, b -> 1, m -> 1, w -> 0.6}, {th, t}, 3.14159, x],
  $Failed,
  {HarmonicExpansion::noteq},
  TestID -> "q0-3.14159-no-es-equilibrio"
]

(* --- HarmonicExpansion: errores --- *)

VerificationTest[
  HarmonicExpansion[ringL, {th, t}, Pi/2, x],
  $Failed,
  {HarmonicExpansion::noteq},
  TestID -> "error-no-es-equilibrio"
]

VerificationTest[
  HarmonicExpansion[ringL, {th, t}, Pi],
  $Failed,
  {HarmonicExpansion::args},
  TestID -> "error-tres-argumentos"
]

VerificationTest[
  HarmonicExpansion[ringL, {th, t}, Pi, Assumptions -> {}],
  $Failed,
  {HarmonicExpansion::args},
  TestID -> "error-opcion-en-lugar-de-x"
]

VerificationTest[
  HarmonicExpansion[ringL, {th, t}, Pi, t],
  $Failed,
  {HarmonicExpansion::dev},
  TestID -> "error-x-igual-a-t"
]

VerificationTest[
  HarmonicExpansion[ringL /. m -> x, {th, t}, Pi, x],
  $Failed,
  {HarmonicExpansion::dev},
  TestID -> "error-x-aparece-en-L"
]

VerificationTest[
  HarmonicExpansion[ringL + t th[t], {th, t}, Pi, x],
  $Failed,
  {HarmonicExpansion::time},
  TestID -> "error-L-depende-de-t"
]

VerificationTest[
  HarmonicExpansion[-k/2 th[t]^2, {th, t}, 0, x],
  $Failed,
  {HarmonicExpansion::mass},
  TestID -> "error-masa-efectiva-nula"
]

VerificationTest[
  Module[{en},
    en = Block[{$CMLanguage = "English"},
      Quiet[HarmonicExpansion[ringL, {th, t}, Pi]];
      HarmonicExpansion::args];
    StringQ[en] && en === CMToolkit`Private`$texts["HarmonicExpansion::args"]["English"]],
  True,
  TestID -> "mensaje-en-ingles"
]

(* --- Resorte vertical: solución conocida, no está en la ayudantía --- *)

VerificationTest[
  With[{res = HarmonicExpansion[m/2 y'[t]^2 - k/2 y[t]^2 + m g y[t], {y, t}, m g/k, x]},
    {Simplify[res["Omega2"] - k/m, m > 0 && k > 0 && g > 0] === 0, res["AmplitudeBound"]}],
  {True, Missing["ExactlyQuadratic"]},
  TestID -> "resorte-vertical"
]

(* --- ShowSteps / MostrarPasos --- *)

VerificationTest[
  Head[ShowSteps[ringPi]],
  Grid,
  TestID -> "ShowSteps-devuelve-Grid"
]

VerificationTest[
  ShowSteps[$Failed],
  $Failed,
  {},
  TestID -> "ShowSteps-Failed-sin-mensajes"
]

VerificationTest[
  ShowSteps[<|"a" -> 1|>],
  $Failed,
  {ShowSteps::nosteps},
  TestID -> "ShowSteps-sin-Steps"
]

VerificationTest[
  MostrarPasos[ringPi] === ShowSteps[ringPi],
  True,
  TestID -> "alias-MostrarPasos"
]
