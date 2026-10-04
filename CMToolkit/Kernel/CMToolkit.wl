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

HarmonicExpansion::usage =
  "HarmonicExpansion[L, {q, t}, q0, x] expande el lagrangiano L de un grado de libertad en torno al equilibrio q0, con q = q0 + x, y entrega una Association con la masa y la constante elástica efectivas, Ω², el lagrangiano armónico, la ecuación de movimiento, la cota de amplitud y los pasos intermedios (\"Steps\"). Opción: Assumptions (Automatic: los parámetros son reales positivos). Alias: ExpansionArmonica.\n\
HarmonicExpansion[L, {q, t}, q0, x] expands the one-degree-of-freedom Lagrangian L about the equilibrium q0, with q = q0 + x, and returns an Association with the effective mass and stiffness, Ω², the harmonic Lagrangian, the equation of motion, the amplitude bound and the intermediate steps (\"Steps\"). Option: Assumptions (Automatic: parameters are positive reals).";
ExpansionArmonica::usage =
  "ExpansionArmonica[L, {q, t}, q0, x] es el alias en español de HarmonicExpansion. Los mensajes de error aparecen con el nombre HarmonicExpansion.\n\
ExpansionArmonica[L, {q, t}, q0, x] is the Spanish alias of HarmonicExpansion. Error messages appear under the name HarmonicExpansion.";

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
    "English" -> "ShowSteps expects the result of one of the package's analysis functions: an Association with the key \"Steps\"."|>,

  (* HarmonicExpansion: mensajes *)
  "HarmonicExpansion::args" -> <|
    "Spanish" -> "HarmonicExpansion se llama con cuatro argumentos: HarmonicExpansion[L, {q, t}, q0, x], donde x es el símbolo que eliges para la desviación q = q0 + x. Por ejemplo, para un péndulo: HarmonicExpansion[m b^2/2 th'[t]^2 + m g b Cos[th[t]], {th, t}, 0, x].",
    "English" -> "HarmonicExpansion takes four arguments: HarmonicExpansion[L, {q, t}, q0, x], where x is the symbol you choose for the deviation q = q0 + x. For example, for a pendulum: HarmonicExpansion[m b^2/2 th'[t]^2 + m g b Cos[th[t]], {th, t}, 0, x]."|>,
  "HarmonicExpansion::dev" -> <|
    "Spanish" -> "La desviación `1` debe ser un símbolo sin valor, distinto de `2` y de `3`, que no aparezca en el lagrangiano ni en q0.",
    "English" -> "The deviation `1` must be a symbol with no value, different from `2` and `3`, that does not appear in the Lagrangian or in q0."|>,
  "HarmonicExpansion::time" -> <|
    "Spanish" -> "HarmonicExpansion requiere un lagrangiano autónomo: solo puede depender de `1`[`2`] y `1`'[`2`], sin `2` explícito ni derivadas de orden superior.",
    "English" -> "HarmonicExpansion requires an autonomous Lagrangian: it may depend only on `1`[`2`] and `1`'[`2`], with no explicit `2` and no higher derivatives."|>,
  "HarmonicExpansion::mass" -> <|
    "Spanish" -> "La masa efectiva \[PartialD]\.b2L/\[PartialD]q\:0307\.b2 vale 0 en q0 = `1`: el lagrangiano no tiene término cinético y no hay oscilaciones que describir.",
    "English" -> "The effective mass \[PartialD]\.b2L/\[PartialD]q\:0307\.b2 is 0 at q0 = `1`: the Lagrangian has no kinetic term and there are no oscillations to describe."|>,
  "HarmonicExpansion::noteq" -> <|
    "Spanish" -> "No se pudo comprobar que q0 = `1` sea un equilibrio: U'(q0) se simplifica a `2`, no a 0. Revisa q0 o entrega con Assumptions las suposiciones que permiten comprobarlo.",
    "English" -> "Could not verify that q0 = `1` is an equilibrium: U'(q0) simplifies to `2`, not 0. Check q0, or give with Assumptions the assumptions that make it verifiable."|>,
  "HarmonicExpansion::critical" -> <|
    "Spanish" -> "k_ef = U''(q0) = 0 en q0 = `1`: es un punto crítico y la aproximación armónica no lo describe. Mira el primer término no nulo de \"PotentialSeries\" o usa ClassifyEquilibrium.",
    "English" -> "k_eff = U''(q0) = 0 at q0 = `1`: this is a critical point and the harmonic approximation does not describe it. Look at the first nonzero term of \"PotentialSeries\" or use ClassifyEquilibrium."|>,

  (* HarmonicExpansion: textos de "Steps", en el orden de la ayudantía *)
  "HarmonicExpansion:assumptions" -> <|
    "Spanish" -> "Suposiciones usadas.",
    "English" -> "Assumptions used."|>,
  "HarmonicExpansion:potential" -> <|
    "Spanish" -> "Potencial efectivo: U(q) = \[Minus]L con q\:0307 = 0 (incluye los términos centrífugos).",
    "English" -> "Effective potential: U(q) = \[Minus]L with q\:0307 = 0 (includes centrifugal terms)."|>,
  "HarmonicExpansion:mass" -> <|
    "Spanish" -> "Masa efectiva: m_ef = \[PartialD]\.b2L/\[PartialD]q\:0307\.b2 en q = q0, q\:0307 = 0.",
    "English" -> "Effective mass: m_eff = \[PartialD]\.b2L/\[PartialD]q\:0307\.b2 at q = q0, q\:0307 = 0."|>,
  "HarmonicExpansion:linear" -> <|
    "Spanish" -> " L tiene un término lineal en q\:0307: en 1D es una derivada total y no afecta la ecuación de movimiento.",
    "English" -> " L has a term linear in q\:0307: in 1D it is a total derivative and does not affect the equation of motion."|>,
  "HarmonicExpansion:equilibrium" -> <|
    "Spanish" -> "Comprobación de equilibrio: U'(q0) = 0.",
    "English" -> "Equilibrium check: U'(q0) = 0."|>,
  "HarmonicExpansion:series" -> <|
    "Spanish" -> "Serie de Taylor del potencial en torno a q0, con q = q0 + x.",
    "English" -> "Taylor series of the potential about q0, with q = q0 + x."|>,
  "HarmonicExpansion:stiffness" -> <|
    "Spanish" -> "Constante elástica efectiva: k_ef = U''(q0) = 2 c\:2082.",
    "English" -> "Effective stiffness: k_eff = U''(q0) = 2 c\:2082."|>,
  "HarmonicExpansion:lagrangian" -> <|
    "Spanish" -> "Lagrangiano armónico: se descarta la constante y se trunca en orden 2.",
    "English" -> "Harmonic Lagrangian: the constant is dropped and the series is truncated at order 2."|>,
  "HarmonicExpansion:bound" -> <|
    "Spanish" -> "Cota de amplitud: el primer término despreciado debe ser mucho menor que el cuadrático.",
    "English" -> "Amplitude bound: the first neglected term must be much smaller than the quadratic one."|>,
  "HarmonicExpansion:eom" -> <|
    "Spanish" -> "Ecuación de movimiento (Euler-Lagrange del lagrangiano armónico).",
    "English" -> "Equation of motion (Euler-Lagrange for the harmonic Lagrangian)."|>,
  "HarmonicExpansion:omega2" -> <|
    "Spanish" -> "Frecuencia de las pequeñas oscilaciones: \[CapitalOmega]\.b2 = k_ef/m_ef.",
    "English" -> "Frequency of small oscillations: \[CapitalOmega]\.b2 = k_eff/m_eff."|>
|>;

(* Texto en el idioma vigente; una clave inexistente se devuelve tal cual *)
tr[key_String] := Lookup[Lookup[$texts, key, <||>], cmLanguage[], key];

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

(* Las opciones del usuario van primero: Plot usa la primera que encuentra *)
SetAttributes[CMPlot, HoldAll];
CMPlot[f_, dom_, opts : OptionsPattern[Plot]] :=
  Plot[f, dom, opts, Evaluate[Sequence @@ $CMPlotStyle]];

(* --- HarmonicExpansion: especificación en docs/specs/HarmonicExpansion.md --- *)

Options[HarmonicExpansion] = {Assumptions -> Automatic};

(* Automatic: todos los símbolos libres de L y q0, salvo q, t y x, son reales positivos *)
heAssumptions[Automatic, L_, q_, t_, q0_, x_] :=
  And @@ Thread[
    DeleteCases[
      Union[Cases[{L, q0}, s_Symbol /; Context[s] =!= "System`", {0, Infinity}, Heads -> False]],
      q | t | x] > 0];
heAssumptions[asm_, ___] := asm;

(* Criterio de cero único: simbólicamente equivale a === 0; para números inexactos
   acepta 0. y ruido de máquina (Chop) *)
zeroQ[e_, asm_] := With[{s = Simplify[e, asm]},
  TrueQ[s == 0] || (InexactNumberQ[s] && Chop[s] == 0)];

HarmonicExpansion[L_, {q_Symbol, t_Symbol}, q0_, x_ /; !OptionQ[x], opts : OptionsPattern[]] :=
  Module[{asm, Lr, qs, qd, U, mef, lin, dU, derivs, coef, c, n, nmax, bound, series,
      kef, omega2, lagH, eom, steps},

    (* Validación, en el orden de la especificación *)
    If[!(MatchQ[x, _Symbol] && !MemberQ[Attributes[x], Protected] &&
         x =!= q && x =!= t && FreeQ[{L, q0}, x]),
      cmMessage[HarmonicExpansion, "dev", x, q, t]; Return[$Failed]];

    Lr = L /. {Derivative[1][q][t] -> qd, q[t] -> qs};
    If[!FreeQ[Lr, t], cmMessage[HarmonicExpansion, "time", q, t]; Return[$Failed]];

    asm = heAssumptions[OptionValue[Assumptions], L, q, t, q0, x];

    mef = Simplify[D[Lr, {qd, 2}] /. {qd -> 0, qs -> q0}, asm];
    If[zeroQ[mef, asm], cmMessage[HarmonicExpansion, "mass", q0]; Return[$Failed]];
    lin = D[Lr, qd] /. qd -> 0;

    U = -Lr /. qd -> 0;
    dU = D[U, qs] /. qs -> q0;
    If[!zeroQ[dU, asm] && !zeroQ[FullSimplify[dU, asm], asm],
      cmMessage[HarmonicExpansion, "noteq", q0, Simplify[dU, asm]]; Return[$Failed]];

    (* Coeficientes c_k = U^(k)(q0)/k!; las derivadas se calculan solo hasta donde hacen falta *)
    derivs = {U};
    coef[k_] := (
      While[Length[derivs] <= k, AppendTo[derivs, D[Last[derivs], qs]]];
      Simplify[(derivs[[k + 1]] /. qs -> q0)/k!, asm]);
    c = Table[coef[k], {k, 0, 2}];
    n = SelectFirst[Range[3, 8], (AppendTo[c, coef[#]]; !zeroQ[Last[c], asm]) &, None];
    nmax = If[n === None, 4, Max[4, n]];
    c = Join[Take[c, UpTo[nmax + 1]], Table[coef[k], {k, Length[c], nmax}]];
    (* Lo que zeroQ declara cero se escribe como 0 exacto: sin ruido de máquina en la serie *)
    c = If[zeroQ[#, asm], 0, #] & /@ c;
    series = c . x^Range[0, nmax];

    kef = Simplify[2 c[[3]], asm];
    omega2 = Simplify[kef/mef, asm];
    lagH = mef/2 x'[t]^2 - kef/2 x[t]^2;
    eom = x''[t] + omega2 x[t] == 0;

    bound = Which[
      zeroQ[c[[3]], asm], Missing["CriticalPoint"],
      n =!= None,
        With[{bd = Simplify[Abs[c[[3]]/c[[n + 1]]], asm]},
          <|"Order" -> n, "Bound" -> bd, "Condition" -> LessLess[Abs[x]^(n - 2), bd]|>],
      zeroQ[(U /. qs -> q0 + x) - c[[;; 3]] . x^Range[0, 2], asm],
        Missing["ExactlyQuadratic"],
      True, Missing["BeyondOrder8"]];

    steps = {
      {"assumptions", asm},
      {"potential", "U"[q] == (U /. qs -> q)},
      {"mass", Subscript["m", "ef"] == mef},
      {"equilibrium", Derivative[1]["U"][q0] == 0},
      {"series", "U"[q0 + x] == series},
      {"stiffness", Subscript["k", "ef"] == kef},
      {"lagrangian", "L" == lagH},
      {"bound", If[AssociationQ[bound], bound["Condition"], bound]},
      {"eom", eom},
      {"omega2", "\[CapitalOmega]"^2 == omega2}};
    steps = <|"Description" -> tr["HarmonicExpansion:" <> #[[1]]] <>
          If[#[[1]] === "mass" && !zeroQ[lin, asm], tr["HarmonicExpansion:linear"], ""],
        "Expression" -> #[[2]]|> & /@ steps;

    If[zeroQ[c[[3]], asm], cmMessage[HarmonicExpansion, "critical", q0]];

    <|"Coordinate" -> q, "Deviation" -> x, "Equilibrium" -> q0, "Assumptions" -> asm,
      "Potential" -> (U /. qs -> q), "EffectiveMass" -> mef, "EffectiveStiffness" -> kef,
      "Omega2" -> omega2, "PotentialSeries" -> series, "HarmonicLagrangian" -> lagH,
      "EquationOfMotion" -> eom, "AmplitudeBound" -> bound, "Steps" -> steps|>
  ];

HarmonicExpansion[___] := (cmMessage[HarmonicExpansion, "args"]; $Failed);

(* --- ShowSteps: los pasos como tabla (número, descripción, expresión) --- *)

(* El error ya se informó en la función que devolvió $Failed *)
ShowSteps[$Failed] := $Failed;

ShowSteps[res_Association /; KeyExistsQ[res, "Steps"]] :=
  Module[{style = Lookup[$CMPlotStyle, LabelStyle, {}]},
    Grid[
      Prepend[
        MapIndexed[{First[#2], #1["Description"], TraditionalForm[#1["Expression"]]} &,
          res["Steps"]],
        Style[tr[#], Bold] & /@ {"ShowSteps:step", "ShowSteps:description", "ShowSteps:expression"}],
      Alignment -> {{Right, Left, Left}, Center},
      ItemSize -> {{Automatic, 24, Automatic}},
      Spacings -> {1.5, 0.8},
      Dividers -> {None, {{Directive[GrayLevel[0.8], AbsoluteThickness[0.5]]}}},
      BaseStyle -> If[Head[style] === Directive, List @@ style, style]]
  ];

ShowSteps[___] := (cmMessage[ShowSteps, "nosteps"]; $Failed);

(* --- Alias en español (al final, cuando las funciones ya tienen sus atributos) --- *)
defineAlias[VersionCMToolkit, CMToolkitVersion];
defineAlias[GraficoCM, CMPlot];
defineAlias[ExpansionArmonica, HarmonicExpansion];
defineAlias[MostrarPasos, ShowSteps];

End[];
EndPackage[];
