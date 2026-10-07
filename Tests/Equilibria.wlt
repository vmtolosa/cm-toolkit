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

(* --- Denominadores de U' (docs/specs/Ajustes1D.md, punto 1) --- *)

(* Masa en un riel unida a un resorte anclado a una altura h: U' tiene Sqrt[h^2 + x^2] en el
   denominador, que no da equilibrios *)
eqAsmRail = m > 0 && k > 0 && h > 0 && l0 > 0;
eqRailL = m/2 x'[t]^2 - k/2 (Sqrt[x[t]^2 + h^2] - l0)^2;
eqRailPts = EquilibriumPoints[eqRailL, {x, t}];

VerificationTest[
  Sort[eqRailPts["Factors"]],
  Sort[{x, Sqrt[h^2 + x^2] - l0}],
  TestID -> "puntos-riel-factores-sin-denominador"
]

VerificationTest[
  Module[{pts = eqRailPts["Points"]},
    pts[[All, "Point"]] === {0, -Sqrt[l0^2 - h^2], Sqrt[l0^2 - h^2]} &&
      pts[[1, "Condition"]] === True &&
      AllTrue[pts[[2 ;;, "Condition"]], eqEquivalentQ[#, h < l0, eqAsmRail, {h, l0}] &]],
  True,
  TestID -> "puntos-riel-puntos"
]

VerificationTest[
  MemberQ[eqRailPts["Steps"][[All, "Expression"]], Sqrt[h^2 + x^2]],
  True,
  TestID -> "puntos-riel-paso-del-denominador"
]

(* U'(y) = (y - 1)^2/y^2: el denominador se anula en y = 0, que no es un equilibrio *)
VerificationTest[
  Module[{res = EquilibriumPoints[m/2 y'[t]^2 - (y[t] - 2 Log[y[t]] - 1/y[t]), {y, t}]},
    {res["Factors"], res["Points"]}],
  {{-1 + y}, {<|"Point" -> 1, "Condition" -> True|>}},
  TestID -> "puntos-denominador-con-cero-real"
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

(* === ClassifyEquilibrium === *)

eqClassify[q0_, opts___] := ClassifyEquilibrium[eqRingL, {th, t}, q0, x, opts];
eqCriticalNote := CMToolkit`Private`tr["ClassifyEquilibrium:criticalnote"];

(* --- Anillo que rota (Problema 1) --- *)

VerificationTest[
  With[{res = eqClassify[0]},
    {res["Type"], res["Stable"], res["ExistenceCondition"], res["LeadingOrder"],
     Simplify[res["SecondDerivative"] + b m (g + b w^2), eqAsmRing]}],
  {"Maximum", False, True, 2, 0},
  TestID -> "clasificar-anillo-0-maximo-ec-11"
]

(* "Steps" muestra U''(0) = … < 0, con el signo dentro de la forma retenida *)
VerificationTest[
  With[{res = eqClassify[0]},
    SelectFirst[res["Steps"][[All, "Expression"]], !FreeQ[#, Derivative[2]] &] ===
      With[{s = res["SecondDerivative"]},
        HoldForm[Inequality[Derivative[2]["U"][0], Equal, s, Less, 0]]]],
  True,
  TestID -> "clasificar-anillo-0-pasos-signo-de-U2"
]

VerificationTest[
  With[{res = eqClassify[Pi]},
    {res["Type"], Keys[res["Conditions"]],
     eqEquivalentQ[res["Conditions"]["Minimum"], g > b w^2, eqAsmRing, {b, g, w}],
     eqEquivalentQ[res["Conditions"]["Maximum"], g < b w^2, eqAsmRing, {b, g, w}],
     eqEquivalentQ[res["Conditions"]["Critical"], g == b w^2, eqAsmRing, {b, g, w}],
     eqEquivalentQ[res["Stable"], g > b w^2, eqAsmRing, {b, g, w}],
     Simplify[res["SecondDerivative"] - b m (g - b w^2), eqAsmRing]}],
  {"Conditional", {"Minimum", "Maximum", "Critical"}, True, True, True, True, 0},
  TestID -> "clasificar-anillo-pi-condicional-ec-11"
]

VerificationTest[
  StringContainsQ[Last[eqClassify[Pi]["Steps"]]["Description"], eqCriticalNote],
  True,
  TestID -> "clasificar-anillo-pi-nota-caso-critico"
]

VerificationTest[
  With[{res = eqClassify[Pi, Assumptions -> eqAsmRing && b w^2 < g]},
    {res["Type"], res["Stable"], KeyExistsQ[res, "Conditions"]}],
  {"Minimum", True, False},
  TestID -> "clasificar-anillo-pi-suposiciones-minimo"
]

VerificationTest[
  With[{res = ClassifyEquilibrium[eqRingL /. w -> Sqrt[g/b], {th, t}, Pi, x]},
    {res["Type"], res["Stable"], res["LeadingOrder"],
     Simplify[res["LeadingCoefficient"] - b g m/8, b > 0 && g > 0 && m > 0]}],
  {"Minimum", True, 4, 0},
  TestID -> "clasificar-anillo-pi-critico-cuartico-ec-13"
]

VerificationTest[
  With[{res = eqClassify[eqTheta0]},
    {eqEquivalentQ[res["ExistenceCondition"], b w^2 >= g, eqAsmRing, {b, g, w}],
     res["Type"], Keys[res["Conditions"]],
     eqEquivalentQ[res["Conditions"]["Minimum"], b w^2 > g, eqAsmRing, {b, g, w}],
     eqEquivalentQ[res["Conditions"]["Critical"], b w^2 == g, eqAsmRing, {b, g, w}],
     Simplify[res["SecondDerivative"] - m (b^2 w^4 - g^2)/w^2, eqAsmRing]}],
  {True, "Conditional", {"Minimum", "Critical"}, True, True, 0},
  TestID -> "clasificar-anillo-theta0-condicional-ec-12"
]

VerificationTest[
  With[{res = eqClassify[eqTheta0, Assumptions -> eqAsmRing && b w^2 > g]},
    {res["Type"], res["Stable"]}],
  {"Minimum", True},
  TestID -> "clasificar-anillo-theta0-minimo-ec-12"
]

(* Solo queda la rama crítica (v1.3): con b w^2 <= g, θ0 existe solo si b w^2 = g *)
VerificationTest[
  With[{res = eqClassify[eqTheta0, Assumptions -> eqAsmRing && b w^2 <= g]},
    {res["Type"], Keys[res["Conditions"]], res["Stable"],
     StringContainsQ[Last[res["Steps"]]["Description"], eqCriticalNote]}],
  {"Conditional", {"Critical"}, Missing["Undetermined"], True},
  TestID -> "clasificar-anillo-theta0-solo-rama-critica"
]

(* --- Casos con solución conocida (no están en la ayudantía) --- *)

eqCubicL = m/2 y'[t]^2 - (y[t]^3/3 - c y[t]);

VerificationTest[
  {#["Type"], #["SecondDerivative"]} & /@
    {ClassifyEquilibrium[eqCubicL, {y, t}, Sqrt[c], x],
     ClassifyEquilibrium[eqCubicL, {y, t}, -Sqrt[c], x]},
  {{"Minimum", 2 Sqrt[c]}, {"Maximum", -2 Sqrt[c]}},
  TestID -> "clasificar-cubico"
]

VerificationTest[
  With[{res = ClassifyEquilibrium[m/2 y'[t]^2 - a y[t]^3, {y, t}, 0, x]},
    {res["Type"], res["LeadingOrder"], res["LeadingCoefficient"], res["Stable"]}],
  {"Inflection", 3, a, False},
  TestID -> "clasificar-inflexion-y3"
]

VerificationTest[
  With[{res = ClassifyEquilibrium[m/2 y'[t]^2 - a y[t]^4, {y, t}, 0, x]},
    {res["Type"], res["LeadingOrder"], res["LeadingCoefficient"], res["Stable"]}],
  {"Minimum", 4, a, True},
  TestID -> "clasificar-minimo-no-armonico-y4"
]

(* Signo de c4 sin fijar (v1.3) *)
VerificationTest[
  With[{res = ClassifyEquilibrium[m/2 y'[t]^2 - a y[t]^4, {y, t}, 0, x, Assumptions -> m > 0]},
    {res["Type"], res["LeadingOrder"], Keys[res["Conditions"]],
     eqEquivalentQ[res["Conditions"]["Minimum"], a > 0, m > 0, {a, m}],
     eqEquivalentQ[res["Conditions"]["Maximum"], a < 0, m > 0, {a, m}],
     eqEquivalentQ[res["Stable"], a > 0, m > 0, {a, m}]}],
  {"Conditional", 4, {"Minimum", "Maximum"}, True, True, True},
  TestID -> "clasificar-y4-signo-condicional"
]

VerificationTest[
  With[{res = ClassifyEquilibrium[m/2 y'[t]^2 - a y[t]^10, {y, t}, 0, x]},
    {res["Type"], res["LeadingOrder"], res["LeadingCoefficient"], res["Stable"]}],
  {"Undetermined", Missing["Undetermined"], Missing["Undetermined"], Missing["Undetermined"]},
  TestID -> "clasificar-indeterminado-hasta-orden-8"
]

(* --- Presentación de la serie retenida (docs/specs/Ajustes1D.md, puntos 2 y 3) --- *)

(* Riel en el caso crítico l0 = h: en x = 0, c0 = c2 = 0 y la serie tiene un solo término,
   k u^4/(8 h^2) *)
eqRailCritical = ClassifyEquilibrium[eqRailL /. l0 -> h, {x, t}, 0, u];

(* Un solo término se muestra sin Plus: HoldForm[Plus[t]] se ve como «+ t». Verbatim evita
   que el atributo Flat de Plus haga calzar también sumas de varios términos *)
VerificationTest[
  FreeQ[eqRailCritical["Steps"][[All, "Expression"]], Verbatim[Plus][_]],
  True,
  TestID -> "clasificar-serie-de-un-termino-sin-mas"
]

(* q0 = 0: el lado izquierdo es U(u), no U(0 + u), en la serie y en la conclusión *)
VerificationTest[
  With[{ex = eqRailCritical["Steps"][[All, "Expression"]]},
    {Count[ex, HoldForm["U"[u]], Infinity], FreeQ[ex, HoldPattern["U"[0 + u]]]}],
  {2, True},
  TestID -> "clasificar-q0-cero-muestra-U-de-u"
]

(* Con q0 distinto de 0 se sigue mostrando U(q0 + x) *)
VerificationTest[
  !FreeQ[eqClassify[Pi]["Steps"][[All, "Expression"]], HoldPattern["U"[Pi + x]]],
  True,
  TestID -> "clasificar-q0-no-nulo-muestra-U-de-q0-mas-x"
]

(* --- Errores, en el orden de validación --- *)

VerificationTest[
  ClassifyEquilibrium[eqRingL, {th, t}, Pi],
  $Failed,
  {ClassifyEquilibrium::args},
  TestID -> "clasificar-error-tres-argumentos"
]

VerificationTest[
  ClassifyEquilibrium[eqRingL, {th, t}, Pi, t],
  $Failed,
  {ClassifyEquilibrium::dev},
  TestID -> "clasificar-error-x-igual-a-t"
]

VerificationTest[
  ClassifyEquilibrium[eqRingL + t th[t], {th, t}, Pi, x],
  $Failed,
  {ClassifyEquilibrium::time},
  TestID -> "clasificar-error-L-depende-de-t"
]

VerificationTest[
  eqClassify[ArcCos[2]],
  $Failed,
  {ClassifyEquilibrium::notreal},
  TestID -> "clasificar-error-q0-no-real"
]

VerificationTest[
  eqClassify[Pi/2],
  $Failed,
  {ClassifyEquilibrium::noteq},
  TestID -> "clasificar-error-no-es-equilibrio"
]

VerificationTest[
  Module[{en},
    en = Block[{$CMLanguage = "English"},
      Quiet[eqClassify[Pi/2]];
      ClassifyEquilibrium::noteq];
    StringQ[en] && en === CMToolkit`Private`$texts["ClassifyEquilibrium::noteq"]["English"]],
  True,
  TestID -> "clasificar-mensaje-en-ingles"
]

(* --- Alias y ShowSteps --- *)

VerificationTest[
  ClasificarEquilibrio[eqRingL, {th, t}, Pi, x] === eqClassify[Pi],
  True,
  TestID -> "alias-ClasificarEquilibrio"
]

VerificationTest[
  Head[ShowSteps[#]] & /@ {eqClassify[Pi], eqClassify[0]},
  {Grid, Grid},
  TestID -> "clasificar-ShowSteps-devuelve-Grid"
]
