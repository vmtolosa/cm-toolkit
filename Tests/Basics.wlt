(* Tests básicos: el paquete carga y el estilo gráfico funciona *)

VerificationTest[
  StringQ[CMToolkitVersion[]],
  True,
  TestID -> "version-es-texto"
]

VerificationTest[
  Head[CMPlot[Sin[x], {x, 0, 2 Pi}]],
  Graphics,
  TestID -> "CMPlot-devuelve-Graphics"
]

VerificationTest[
  MemberQ[$ContextPath, "CMToolkit`Private`"],
  False,
  TestID -> "contexto-privado-oculto"
]

(* --- Esquema bilingüe --- *)

VerificationTest[
  $CMLanguage,
  "Spanish",
  TestID -> "idioma-por-defecto"
]

VerificationTest[
  VersionCMToolkit[] === CMToolkitVersion[],
  True,
  TestID -> "alias-VersionCMToolkit"
]

VerificationTest[
  Head[GraficoCM[Sin[x], {x, 0, 2 Pi}]],
  Graphics,
  TestID -> "alias-GraficoCM-devuelve-Graphics"
]

VerificationTest[
  MemberQ[Attributes[GraficoCM], HoldAll],
  True,
  TestID -> "alias-hereda-atributos"
]

VerificationTest[
  StringContainsQ[CMPlot::usage, "Alias"] && StringContainsQ[GraficoCM::usage, "Spanish alias"],
  True,
  TestID -> "ayuda-bilingue"
]

(* --- Prioridad de las opciones del usuario en CMPlot --- *)

VerificationTest[
  Options[CMPlot[Sin[x], {x, 0, 2 Pi}], ImageSize],
  {ImageSize -> 420},
  TestID -> "CMPlot-usa-estilo-por-defecto"
]

VerificationTest[
  Options[CMPlot[Sin[x], {x, 0, 2 Pi}, ImageSize -> 200], ImageSize],
  {ImageSize -> 200},
  TestID -> "CMPlot-opcion-usuario-tiene-prioridad"
]

VerificationTest[
  Options[GraficoCM[Sin[x], {x, 0, 2 Pi}, ImageSize -> 200], ImageSize],
  {ImageSize -> 200},
  TestID -> "alias-GraficoCM-opcion-usuario-tiene-prioridad"
]

(* --- Estilos de CMPlot según el número de curvas (docs/specs/Ajustes1D.md, punto 7) --- *)

(* Una curva: el primer estilo (azul, continuo), sin Dashing *)
bsOneCurveQ[g_] := !FreeQ[g, RGBColor[0.12, 0.35, 0.65]] && FreeQ[g, _Dashing];

(* Dos curvas: los dos primeros colores y un solo Dashing entre las primitivas dibujadas.
   Plot guarda además una copia de los estilos en una Association de metadatos dentro de las
   primitivas; se quita antes de contar *)
bsDrawn[g_] := First[g] /. _Association -> Nothing;
bsTwoCurvesQ[g_] := !FreeQ[bsDrawn[g], RGBColor[0.12, 0.35, 0.65]] &&
  !FreeQ[bsDrawn[g], RGBColor[0.85, 0.37, 0.01]] && Count[bsDrawn[g], _Dashing, Infinity] === 1;

VerificationTest[
  bsOneCurveQ[CMPlot[Sin[x], {x, 0, 2 Pi}]],
  True,
  TestID -> "CMPlot-una-curva-primer-estilo"
]

VerificationTest[
  bsTwoCurvesQ[CMPlot[{Sin[x], Cos[x]}, {x, 0, 2 Pi}]],
  True,
  TestID -> "CMPlot-dos-curvas-estilos-en-orden"
]

(* HoldAll: la variable del gráfico tiene un valor asignado *)
VerificationTest[
  Module[{g}, bsVar = 3; g = CMPlot[Sin[bsVar], {bsVar, 0, 2 Pi}]; Clear[bsVar]; bsOneCurveQ[g]],
  True,
  TestID -> "CMPlot-una-curva-variable-con-valor"
]

(* Una expresión que no es una lista a simple vista *)
VerificationTest[
  Module[{sol = <|"Solution" -> NDSolveValue[{bsY'[s] == -bsY[s], bsY[0] == 1}, bsY, {s, 0, 6}]|>},
    bsOneCurveQ[CMPlot[sol["Solution"][tt], {tt, 0, 6}]]],
  True,
  TestID -> "CMPlot-una-curva-interpolacion"
]

(* Un símbolo cuyo valor es una lista de funciones *)
VerificationTest[
  Module[{g}, bsFuns = {Sin[x], Cos[x]}; g = CMPlot[bsFuns, {x, 0, 2 Pi}]; Clear[bsFuns];
    bsTwoCurvesQ[g]],
  True,
  TestID -> "CMPlot-simbolo-con-lista"
]

(* Una función definida solo para argumentos numéricos: una curva azul, sin mensajes *)
VerificationTest[
  Module[{g}, bsNum[s_?NumericQ] := NIntegrate[Cos[u], {u, 0, s}];
    g = CMPlot[bsNum[x], {x, 0, 2 Pi}]; Clear[bsNum]; bsOneCurveQ[g]],
  True,
  TestID -> "CMPlot-una-curva-funcion-numerica"
]

(* Sin ?NumericQ, NIntegrate emite NIntegrate::nlim con la variable simbólica: la evaluación que
   decide el estilo va en Quiet, así que CMPlot no emite mensajes (Plot solo, tampoco) *)
VerificationTest[
  Module[{g}, bsInt[s_] := NIntegrate[Cos[u], {u, 0, s}];
    g = CMPlot[bsInt[x], {x, 0, 2 Pi}]; Clear[bsInt];
    {bsOneCurveQ[g], Head[g]}],
  {True, Graphics},
  TestID -> "CMPlot-una-curva-evaluacion-silenciada"
]

VerificationTest[
  Module[{g = CMPlot[Sin[x], {x, 0, 2 Pi}, PlotStyle -> Red]},
    !FreeQ[g, RGBColor[1, 0, 0]] && FreeQ[g, RGBColor[0.12, 0.35, 0.65]]],
  True,
  TestID -> "CMPlot-PlotStyle-del-usuario-gana"
]

(* --- cmLanguage[] (privada, se llama por su nombre completo) --- *)

VerificationTest[
  Block[{$CMLanguage = "English"}, CMToolkit`Private`cmLanguage[]],
  "English",
  TestID -> "cmLanguage-ingles"
]

VerificationTest[
  Block[{$CMLanguage = "Klingon"}, CMToolkit`Private`cmLanguage[]],
  "Spanish",
  TestID -> "cmLanguage-valor-invalido-vuelve-a-espanol"
]
