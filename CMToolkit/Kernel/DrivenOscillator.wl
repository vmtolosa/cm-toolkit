(* ::Package:: *)
(* CMToolkit, módulo DrivenOscillator: oscilador amortiguado y forzado, y funciones de Green
   (especificación en docs/specs/DrivenOscillator.md, Parte A).
   Notación: ẍ + 2γ ẋ + ω0² x = F(t)/m, con γ el coeficiente de amortiguamiento y ω0 la
   frecuencia natural.
   Lo carga CMToolkit.wl dentro de BeginPackage, después de NormalModes.wl. *)

DampedOscillator::usage =
  "DampedOscillator[m, \[Gamma], \[Omega]0] describe el oscilador amortiguado m(x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x) = F(t), con \[Gamma] el coeficiente de amortiguamiento y \[Omega]0 la frecuencia natural. Entrega una Association con el régimen (\"Undamped\", \"Underdamped\", \"Critical\" u \"Overdamped\"), las raíces características, \[Omega]_d o \[CapitalGamma], el factor de calidad, el tiempo de decaimiento y los pasos intermedios (\"Steps\"). Es el objeto que reciben GreenFunction, GreenSolution y SteadyState. DampedOscillator[m, b, k, \"Form\" -> \"MBK\"] usa la forma m x\:0308 + b x\:0307 + k x = F. Opciones: Assumptions (Automatic: los parámetros son reales positivos) y \"Regime\" (declara el régimen cuando las suposiciones no lo deciden). Alias: OsciladorAmortiguado.\n\
DampedOscillator[m, \[Gamma], \[Omega]0] describes the damped oscillator m(x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x) = F(t), with \[Gamma] the damping coefficient and \[Omega]0 the natural frequency. It returns an Association with the regime (\"Undamped\", \"Underdamped\", \"Critical\" or \"Overdamped\"), the characteristic roots, \[Omega]_d or \[CapitalGamma], the quality factor, the decay time and the intermediate steps (\"Steps\"). It is the object taken by GreenFunction, GreenSolution and SteadyState. DampedOscillator[m, b, k, \"Form\" -> \"MBK\"] uses the form m x\:0308 + b x\:0307 + k x = F. Options: Assumptions (Automatic: parameters are positive reals) and \"Regime\" (declares the regime when the assumptions do not decide it).";
OsciladorAmortiguado::usage =
  "OsciladorAmortiguado[m, \[Gamma], \[Omega]0] es el alias en español de DampedOscillator. Los mensajes de error aparecen con el nombre DampedOscillator.\n\
OsciladorAmortiguado[m, \[Gamma], \[Omega]0] is the Spanish alias of DampedOscillator. Error messages appear under the name DampedOscillator.";

Begin["`Private`"];

(* Textos de este módulo: se agregan a la tabla $texts de Core.wl *)
AssociateTo[$texts, <|
  "DampedOscillator::args" -> <|
    "Spanish" -> "DampedOscillator se llama con tres argumentos: DampedOscillator[m, \[Gamma], \[Omega]0], para m(x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x) = F, o DampedOscillator[m, b, k, \"Form\" -> \"MBK\"], para m x\:0308 + b x\:0307 + k x = F.",
    "English" -> "DampedOscillator takes three arguments: DampedOscillator[m, \[Gamma], \[Omega]0], for m(x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x) = F, or DampedOscillator[m, b, k, \"Form\" -> \"MBK\"], for m x\:0308 + b x\:0307 + k x = F."|>,
  "DampedOscillator::params" -> <|
    "Spanish" -> "La masa y la frecuencia natural (o la constante k) deben ser positivas, y el amortiguamiento no puede ser negativo. Revisa los parámetros `1`.",
    "English" -> "The mass and the natural frequency (or the constant k) must be positive, and the damping cannot be negative. Check the parameters `1`."|>,
  "DampedOscillator::regime" -> <|
    "Spanish" -> "No se puede fijar el régimen con \[Gamma] = `1` y \[Omega]0 = `2`: depende de si \[Gamma] es menor, igual o mayor que \[Omega]0. Decláralo con las suposiciones, por ejemplo Assumptions -> 0 < \[Gamma] < \[Omega]0, o con la opción \"Regime\" -> \"Underdamped\" (también \"Undamped\", \"Critical\" u \"Overdamped\"). Si ya declaraste un régimen, revisa que no contradiga los valores de los parámetros.",
    "English" -> "The regime cannot be determined with \[Gamma] = `1` and \[Omega]0 = `2`: it depends on whether \[Gamma] is less than, equal to or greater than \[Omega]0. Declare it with the assumptions, for example Assumptions -> 0 < \[Gamma] < \[Omega]0, or with the option \"Regime\" -> \"Underdamped\" (also \"Undamped\", \"Critical\" or \"Overdamped\"). If you already declared a regime, check that it does not contradict the values of the parameters."|>,
  (* DampedOscillator: textos de "Steps", en el orden en que se haría a mano *)
  "DampedOscillator:equation" -> <|
    "Spanish" -> "Ecuación del oscilador sin fuerza: x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x = 0, con \[Gamma] el coeficiente de amortiguamiento y \[Omega]0 la frecuencia natural.",
    "English" -> "Equation of the oscillator with no force: x\:0308 + 2\[Gamma] x\:0307 + \[Omega]0\.b2 x = 0, with \[Gamma] the damping coefficient and \[Omega]0 the natural frequency."|>,
  "DampedOscillator:trial" -> <|
    "Spanish" -> "Ensayo x = e^(r t): cada término queda multiplicado por e^(r t), que nunca se anula, y queda la ecuación característica.",
    "English" -> "Trial x = e^(r t): every term gets multiplied by e^(r t), which never vanishes, and the characteristic equation remains."|>,
  "DampedOscillator:roots" -> <|
    "Spanish" -> "Raíces de la ecuación característica: r = \[Minus]\[Gamma] \[PlusMinus] \[Sqrt](\[Gamma]\.b2 \[Minus] \[Omega]0\.b2).",
    "English" -> "Roots of the characteristic equation: r = \[Minus]\[Gamma] \[PlusMinus] \[Sqrt](\[Gamma]\.b2 \[Minus] \[Omega]0\.b2)."|>,
  "DampedOscillator:Undamped" -> <|
    "Spanish" -> "Sin amortiguamiento (\[Gamma] = 0): las raíces son \[PlusMinus]i \[Omega]0 y el sistema oscila para siempre con frecuencia \[Omega]0.",
    "English" -> "Undamped (\[Gamma] = 0): the roots are \[PlusMinus]i \[Omega]0 and the system oscillates forever with frequency \[Omega]0."|>,
  "DampedOscillator:Underdamped" -> <|
    "Spanish" -> "Régimen subamortiguado (\[Gamma] < \[Omega]0): las raíces son complejas, \[Minus]\[Gamma] \[PlusMinus] i \[Omega]_d. El sistema oscila con frecuencia \[Omega]_d = \[Sqrt](\[Omega]0\.b2 \[Minus] \[Gamma]\.b2), menor que \[Omega]0, y la amplitud decae como e^(\[Minus]\[Gamma] t).",
    "English" -> "Underdamped regime (\[Gamma] < \[Omega]0): the roots are complex, \[Minus]\[Gamma] \[PlusMinus] i \[Omega]_d. The system oscillates with frequency \[Omega]_d = \[Sqrt](\[Omega]0\.b2 \[Minus] \[Gamma]\.b2), lower than \[Omega]0, and the amplitude decays as e^(\[Minus]\[Gamma] t)."|>,
  "DampedOscillator:Critical" -> <|
    "Spanish" -> "Amortiguamiento crítico (\[Gamma] = \[Omega]0): una raíz doble, \[Minus]\[Gamma]. El sistema vuelve al equilibrio sin oscilar, lo más rápido posible: x = (A + B t) e^(\[Minus]\[Gamma] t).",
    "English" -> "Critical damping (\[Gamma] = \[Omega]0): a double root, \[Minus]\[Gamma]. The system returns to equilibrium without oscillating, as fast as possible: x = (A + B t) e^(\[Minus]\[Gamma] t)."|>,
  "DampedOscillator:Overdamped" -> <|
    "Spanish" -> "Régimen sobreamortiguado (\[Gamma] > \[Omega]0): dos raíces reales negativas, \[Minus]\[Gamma] \[PlusMinus] \[CapitalGamma], con \[CapitalGamma] = \[Sqrt](\[Gamma]\.b2 \[Minus] \[Omega]0\.b2). El sistema vuelve al equilibrio sin oscilar, más lento que con amortiguamiento crítico.",
    "English" -> "Overdamped regime (\[Gamma] > \[Omega]0): two negative real roots, \[Minus]\[Gamma] \[PlusMinus] \[CapitalGamma], with \[CapitalGamma] = \[Sqrt](\[Gamma]\.b2 \[Minus] \[Omega]0\.b2). The system returns to equilibrium without oscillating, more slowly than with critical damping."|>
|>];

(* --- Funciones privadas de este módulo --- *)

(* Un oscilador: el resultado de DampedOscillator *)
oscillatorQ[osc_Association] :=
  AllTrue[{"Mass", "Gamma", "Omega0", "Regime", "Assumptions"}, KeyExistsQ[osc, #] &];
oscillatorQ[_] := False;

(* Un parámetro simbólico pasa; uno numérico debe ser real y positivo (o no negativo) *)
positiveParamQ[x_] := !NumericQ[x] || (realNumberQ[x] && TrueQ[N[x] > 0]);
nonNegativeParamQ[x_] := !NumericQ[x] || (realNumberQ[x] && TrueQ[N[x] >= 0]);

dampedRegimes = {"Undamped", "Underdamped", "Critical", "Overdamped"};

(* Condición que define cada régimen *)
regimeCondition[reg_, g_, w_] := Switch[reg,
  "Undamped", g == 0, "Underdamped", 0 < g < w, "Critical", g == w, "Overdamped", g > w];

(* Régimen que deciden las suposiciones, o None si no lo deciden *)
decideRegime[g_, w_, asm_] := Which[
  zeroQ[g, asm], "Undamped",
  zeroQ[w - g, asm], "Critical",
  TrueQ[Simplify[g < w, asm]], "Underdamped",
  TrueQ[Simplify[g > w, asm]], "Overdamped",
  True, None];

(* Término c·s de una suma retenida: se omite si c es 0 y se escribe solo s si c es 1 *)
coefTerm[c_, s_] := Which[zeroQ[c, True], Nothing, c === 1, s, True, HoldForm[c s]];

(* --- DampedOscillator: especificación en docs/specs/DrivenOscillator.md --- *)

Options[DampedOscillator] = {"Form" -> Automatic, "Regime" -> Automatic, Assumptions -> Automatic};

DampedOscillator[m_, a2_, a3_, opts : OptionsPattern[]] /; !OptionQ[a3] :=
  Module[{form, g, w, asm, decl, base, reg, wd, gd, roots, q, decay, steps},
    form = OptionValue["Form"];
    If[!MemberQ[{Automatic, "MBK"}, form], cmMessage[DampedOscillator, "args"]; Return[$Failed]];

    (* Parámetros numéricos: m > 0 primero (la forma MBK divide por m), después γ ≥ 0 y ω0 > 0
       (en la forma MBK, b ≥ 0 y k > 0) *)
    If[!positiveParamQ[m] ||
        If[form === "MBK", !nonNegativeParamQ[a2] || !positiveParamQ[a3], False],
      cmMessage[DampedOscillator, "params", {m, a2, a3}]; Return[$Failed]];
    asm = OptionValue[Assumptions];
    If[asm === Automatic, asm = positiveAssumptions[{m, a2, a3}, {}]];
    {g, w} = If[form === "MBK", Simplify[{a2/(2 m), Sqrt[a3/m]}, asm], {a2, a3}];
    If[!nonNegativeParamQ[g] || !positiveParamQ[w],
      cmMessage[DampedOscillator, "params", {m, a2, a3}]; Return[$Failed]];

    (* Régimen: el que deciden las suposiciones o el declarado con "Regime", que agrega su
       condición a las suposiciones. Un régimen declarado que contradice los valores es error *)
    decl = OptionValue["Regime"];
    base = decideRegime[g, w, asm];
    Which[
      decl === Automatic && base === None,
        cmMessage[DampedOscillator, "regime", g, w]; Return[$Failed],
      decl === Automatic,
        reg = base,
      !MemberQ[dampedRegimes, decl] || (base =!= None && base =!= decl) ||
          Simplify[asm && regimeCondition[decl, g, w]] === False,
        cmMessage[DampedOscillator, "regime", g, w]; Return[$Failed],
      True,
        asm = Simplify[asm && regimeCondition[decl, g, w]]; reg = decl];

    wd = If[reg === "Underdamped", Simplify[Sqrt[w^2 - g^2], asm], Missing["NotApplicable"]];
    gd = If[reg === "Overdamped", Simplify[Sqrt[g^2 - w^2], asm], Missing["NotApplicable"]];
    roots = Switch[reg,
      "Undamped", {I w, -I w},
      "Underdamped", {-g + I wd, -g - I wd},
      "Critical", {-g, -g},
      "Overdamped", {-g + gd, -g - gd}];
    {q, decay} = If[reg === "Undamped", {Infinity, Infinity},
      Simplify[{w/(2 g), 1/g}, asm]];

    steps = {
      {"equation", heldSum[{"x\:0308", coefTerm[2 g, "x\:0307"], coefTerm[w^2, "x"]}] == 0},
      {"trial", heldSum[{HoldForm["r"^2], coefTerm[2 g, "r"], If[zeroQ[w^2, True], Nothing, w^2]}] == 0},
      {"roots", Column[{Subscript["r", 1] == roots[[1]], Subscript["r", 2] == roots[[2]]}]},
      {reg, Switch[reg,
        "Undamped", Row[{"\[Gamma] = 0,   \[Omega]\:2080 = ", w}],
        "Underdamped", Subscript["\[Omega]", "d"] == wd,
        "Critical", Row[{"\[Gamma] = \[Omega]\:2080 = ", w}],
        "Overdamped", "\[CapitalGamma]" == gd]}};
    steps = <|"Description" -> tr["DampedOscillator:" <> #[[1]]], "Expression" -> #[[2]]|> & /@
      steps;

    <|"Mass" -> m, "Gamma" -> g, "Omega0" -> w, "Regime" -> reg, "Assumptions" -> asm,
      "Equation" -> \[FormalX]''[\[FormalT]] + 2 g \[FormalX]'[\[FormalT]] + w^2 \[FormalX][\[FormalT]] == 0,
      "CharacteristicRoots" -> roots, "OmegaD" -> wd, "GammaD" -> gd, "QualityFactor" -> q,
      "DecayTime" -> decay, "Steps" -> steps|>
  ];

DampedOscillator[___] := (cmMessage[DampedOscillator, "args"]; $Failed);

(* --- Alias en español (al final, cuando las funciones ya tienen sus atributos) --- *)
defineAlias[OsciladorAmortiguado, DampedOscillator];

End[];
