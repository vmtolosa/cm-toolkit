(* ::Package:: *)
(* CMToolkit: herramientas para mecánica clásica de pregrado *)

BeginPackage["CMToolkit`"];

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

Begin["`Private`"];

(* --- Implementación: todo lo que se define aquí queda oculto --- *)

$CMLanguage = "Spanish";

(* Idioma vigente; cualquier valor no reconocido vuelve al español *)
cmLanguage[] := If[MemberQ[{"Spanish", "English"}, $CMLanguage], $CMLanguage, "Spanish"];

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

(* Las opciones del usuario van primero: Plot usa la primera que encuentra *)
SetAttributes[CMPlot, HoldAll];
CMPlot[f_, dom_, opts : OptionsPattern[Plot]] :=
  Plot[f, dom, opts, Evaluate[Sequence @@ $CMPlotStyle]];

(* --- Alias en español (al final, cuando las funciones ya tienen sus atributos) --- *)
defineAlias[VersionCMToolkit, CMToolkitVersion];
defineAlias[GraficoCM, CMPlot];

End[];
EndPackage[];
