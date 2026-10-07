(* ::Package:: *)
(* CMToolkit, módulo Core: idioma, textos traducibles, mensajes, alias, estilo gráfico,
   CMPlot, ShowSteps y CMToolkitVersion. Lo carga CMToolkit.wl dentro de BeginPackage. *)

(* --- Símbolos públicos: solo los declarados aquí los ve el usuario ---
   Cada función tiene un nombre en inglés (canónico) y un alias en español.
   La ayuda de ambos nombres trae los dos idiomas, español primero. *)

$CMLanguage::usage =
  "$CMLanguage fija el idioma de los mensajes, los pasos intermedios y las etiquetas de los gráficos: \"Spanish\" (por defecto) o \"English\".\n\
$CMLanguage sets the language of messages, intermediate steps and plot labels: \"Spanish\" (default) or \"English\".";

$CMPlotStyle::usage =
  "$CMPlotStyle es la lista de opciones gráficas que usan las funciones del paquete.\n\
$CMPlotStyle is the list of graphics options used by the package's functions.";

CMToolkitVersion::usage =
  "CMToolkitVersion[] entrega la versión instalada del paquete. Alias: VersionCMToolkit.\n\
CMToolkitVersion[] gives the installed version of the package.";
VersionCMToolkit::usage =
  "VersionCMToolkit[] es el alias en español de CMToolkitVersion[].\n\
VersionCMToolkit[] is the Spanish alias of CMToolkitVersion[].";

CMPlot::usage =
  "CMPlot[f, {x, xmin, xmax}, opts] es Plot con el estilo del paquete; las opciones que entregues tienen prioridad. Alias: GraficoCM.\n\
CMPlot[f, {x, xmin, xmax}, opts] is Plot with the package style; options you give take precedence.";
GraficoCM::usage =
  "GraficoCM[f, {x, xmin, xmax}, opts] es el alias en español de CMPlot.\n\
GraficoCM[f, {x, xmin, xmax}, opts] is the Spanish alias of CMPlot.";

ShowSteps::usage =
  "ShowSteps[res] muestra como tabla los pasos intermedios (\"Steps\") del resultado res de una función de análisis, como HarmonicExpansion. Alias: MostrarPasos.\n\
ShowSteps[res] shows as a table the intermediate steps (\"Steps\") of the result res of an analysis function such as HarmonicExpansion.";
MostrarPasos::usage =
  "MostrarPasos[res] es el alias en español de ShowSteps. Los mensajes de error aparecen con el nombre ShowSteps.\n\
MostrarPasos[res] is the Spanish alias of ShowSteps. Error messages appear under the name ShowSteps.";

Begin["`Private`"];

(* --- Implementación: todo lo que se define aquí queda oculto --- *)

$CMLanguage = "Spanish";

(* Idioma vigente; cualquier valor no reconocido vuelve al español *)
cmLanguage[] := If[MemberQ[{"Spanish", "English"}, $CMLanguage], $CMLanguage, "Spanish"];

(* Textos traducibles: clave -> <|"Spanish" -> ..., "English" -> ...|>.
   Los mensajes usan la clave "Símbolo::etiqueta" *)
$texts = <|
  "ShowSteps:step" -> <|"Spanish" -> "Paso", "English" -> "Step"|>,
  "ShowSteps:description" -> <|"Spanish" -> "Descripción", "English" -> "Description"|>,
  "ShowSteps:expression" -> <|"Spanish" -> "Expresión", "English" -> "Expression"|>,
  "ShowSteps::nosteps" -> <|
    "Spanish" -> "ShowSteps espera el resultado de una función de análisis del paquete: una Association con la clave \"Steps\".",
    "English" -> "ShowSteps expects the result of one of the package's analysis functions: an Association with the key \"Steps\"."|>
|>;

(* Cada módulo agrega sus textos a $texts con AssociateTo *)

(* Texto en el idioma vigente; una clave inexistente se devuelve tal cual *)
tr[key_String] := Lookup[Lookup[$texts, key, <||>], cmLanguage[], key];

(* Texto con marcadores `q`, `x`, … sustituidos por los valores de vals (plantilla) *)
tr[key_String, vals_Association] := StringTemplate[tr[key]][vals];

(* Asigna el texto traducido al mensaje justo antes de emitirlo *)
cmMessage[sym_Symbol, tag_String, args___] := (
  MessageName[sym, tag] = tr[SymbolName[sym] <> "::" <> tag];
  Message[MessageName[sym, tag], args]
);

(* Alias en español: misma definición, atributos y opciones que la función en inglés *)
defineAlias[alias_Symbol, canonical_Symbol] := (
  SetAttributes[alias, Attributes[canonical]];
  Options[alias] = Options[canonical];
  alias[args___] := canonical[args]
);

CMToolkitVersion[] := PacletObject["CMToolkit"]["Version"];

$CMPlotStyle = {
  Frame -> True, Axes -> False,
  FrameStyle -> Directive[GrayLevel[0.25], FontSize -> 12],
  LabelStyle -> Directive[GrayLevel[0.15], FontSize -> 12],
  GridLines -> Automatic, GridLinesStyle -> Directive[GrayLevel[0.92]],
  PlotStyle -> {
    Directive[RGBColor[0.12, 0.35, 0.65], AbsoluteThickness[2]],
    Directive[RGBColor[0.85, 0.37, 0.01], AbsoluteThickness[2], Dashed],
    Directive[RGBColor[0.20, 0.55, 0.25], AbsoluteThickness[2]],
    Directive[RGBColor[0.55, 0.25, 0.60], AbsoluteThickness[2]]},
  ImageSize -> 420
};

(* Las opciones del usuario van primero: Plot usa la primera que encuentra.
   Con una sola curva, Plot combinaría la lista de PlotStyle de $CMPlotStyle en una sola
   directiva; por eso se le entrega solo el primer estilo. Para saber si f es una lista se
   evalúa con la variable sin valor (Block), en Quiet: algunas funciones emiten mensajes con
   argumentos simbólicos y esa evaluación solo sirve para decidir el estilo *)
SetAttributes[CMPlot, HoldAll];
CMPlot[f_, dom : {x_Symbol, __}, opts : OptionsPattern[Plot]] :=
  With[{style = If[TrueQ[Quiet[Block[{x}, ListQ[f]]]], {},
      {PlotStyle -> First[Lookup[$CMPlotStyle, PlotStyle]]}]},
    Plot[f, dom, opts, Evaluate[Sequence @@ style], Evaluate[Sequence @@ $CMPlotStyle]]];

(* Criterio de cero único: simbólicamente equivale a === 0; para números inexactos
   acepta 0. y ruido de máquina (Chop) *)
zeroQ[e_, asm_] := With[{s = Simplify[e, asm]},
  TrueQ[s == 0] || (InexactNumberQ[s] && Chop[s] == 0)];

(* --- ShowSteps: los pasos como tabla (número, descripción, expresión) --- *)

(* El error ya se informó en la función que devolvió $Failed *)
ShowSteps[$Failed] := $Failed;

ShowSteps[res_Association /; KeyExistsQ[res, "Steps"]] :=
  Module[{style = Lookup[$CMPlotStyle, LabelStyle, {}], size, margins},
    (* Descripciones y encabezados como texto: estilo "Text" del notebook (su familia, no la
       monoespaciada de las salidas) con el tamaño de LabelStyle *)
    size = FirstCase[style, (FontSize -> s_) :> s, 12, Infinity];
    (* Grid no dibuja el espaciado exterior; los Spacer dejan margen en los bordes
       para que la expresión más larga no quede pegada al borde *)
    margins = {Row[{Spacer[8], #1}], #2, Row[{#3, Spacer[16]}]} &;
    Grid[
      Prepend[
        MapIndexed[margins[First[#2], Style[#1["Description"], "Text", FontSize -> size],
            TraditionalForm[#1["Expression"]]] &,
          res["Steps"]],
        margins @@ (Style[tr[#], "Text", Bold, FontSize -> size] & /@
          {"ShowSteps:step", "ShowSteps:description", "ShowSteps:expression"})],
      Alignment -> {{Right, Left, Left}, Center},
      ItemSize -> {{Automatic, 32, Automatic}},
      Spacings -> {1.5, 0.8},
      Dividers -> {None, {{Directive[GrayLevel[0.8], AbsoluteThickness[0.5]]}}},
      BaseStyle -> If[Head[style] === Directive, List @@ style, style]]
  ];

ShowSteps[___] := (cmMessage[ShowSteps, "nosteps"]; $Failed);

(* --- Alias en español (al final, cuando las funciones ya tienen sus atributos) --- *)
defineAlias[VersionCMToolkit, CMToolkitVersion];
defineAlias[GraficoCM, CMPlot];
defineAlias[MostrarPasos, ShowSteps];

End[];
