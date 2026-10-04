(* ::Package:: *)
(* CMToolkit: herramientas para mecánica clásica de pregrado *)

BeginPackage["CMToolkit`"];

(* --- Símbolos públicos: solo los declarados aquí los ve el usuario --- *)

CMToolkitVersion::usage =
  "CMToolkitVersion[] entrega la versión instalada del paquete.";

$CMPlotStyle::usage =
  "$CMPlotStyle es la lista de opciones gráficas que usan las funciones del paquete.";

CMPlot::usage =
  "CMPlot[f, {x, xmin, xmax}, opts] es Plot con el estilo del paquete. Las opciones que entregues tienen prioridad.";

Begin["`Private`"];

(* --- Implementación: todo lo que se define aquí queda oculto --- *)

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

End[];
EndPackage[];
