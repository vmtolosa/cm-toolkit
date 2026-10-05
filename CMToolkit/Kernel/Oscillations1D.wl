(* ::Package:: *)
(* CMToolkit, módulo Oscillations1D: un grado de libertad (HarmonicExpansion).
   Lo carga CMToolkit.wl dentro de BeginPackage, después de Core.wl. *)

HarmonicExpansion::usage =
  "HarmonicExpansion[L, {q, t}, q0, x] expande el lagrangiano L de un grado de libertad en torno al equilibrio q0, con q = q0 + x, y entrega una Association con la masa y la constante elástica efectivas, Ω², el lagrangiano armónico, la ecuación de movimiento, la cota de amplitud y los pasos intermedios (\"Steps\"). Opción: Assumptions (Automatic: los parámetros son reales positivos). Alias: ExpansionArmonica.\n\
HarmonicExpansion[L, {q, t}, q0, x] expands the one-degree-of-freedom Lagrangian L about the equilibrium q0, with q = q0 + x, and returns an Association with the effective mass and stiffness, Ω², the harmonic Lagrangian, the equation of motion, the amplitude bound and the intermediate steps (\"Steps\"). Option: Assumptions (Automatic: parameters are positive reals).";
ExpansionArmonica::usage =
  "ExpansionArmonica[L, {q, t}, q0, x] es el alias en español de HarmonicExpansion. Los mensajes de error aparecen con el nombre HarmonicExpansion.\n\
ExpansionArmonica[L, {q, t}, q0, x] is the Spanish alias of HarmonicExpansion. Error messages appear under the name HarmonicExpansion.";

EquilibriumPoints::usage =
  "EquilibriumPoints[L, {q, t}] encuentra los puntos de equilibrio del lagrangiano L de un grado de libertad: factoriza U'(q) y resuelve cada factor. Entrega una Association con el potencial, la derivada factorizada, los factores, los puntos con su condición de existencia (\"Points\") y los pasos intermedios (\"Steps\"). Opciones: \"Domain\" -> {qmin, qmax} (necesaria si q es un ángulo, por ejemplo {0, 2 Pi}) y Assumptions (Automatic: los parámetros son reales positivos). Alias: PuntosDeEquilibrio.\n\
EquilibriumPoints[L, {q, t}] finds the equilibrium points of the one-degree-of-freedom Lagrangian L: it factors U'(q) and solves each factor. It returns an Association with the potential, the factored derivative, the factors, the points with their existence condition (\"Points\") and the intermediate steps (\"Steps\"). Options: \"Domain\" -> {qmin, qmax} (needed when q is an angle, for example {0, 2 Pi}) and Assumptions (Automatic: parameters are positive reals).";
PuntosDeEquilibrio::usage =
  "PuntosDeEquilibrio[L, {q, t}] es el alias en español de EquilibriumPoints. Los mensajes de error aparecen con el nombre EquilibriumPoints.\n\
PuntosDeEquilibrio[L, {q, t}] is the Spanish alias of EquilibriumPoints. Error messages appear under the name EquilibriumPoints.";

Begin["`Private`"];

(* Textos de este módulo: se agregan a la tabla $texts de Core.wl *)
AssociateTo[$texts, <|
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
    "English" -> "Frequency of small oscillations: \[CapitalOmega]\.b2 = k_eff/m_eff."|>,

  (* EquilibriumPoints: mensajes *)
  "EquilibriumPoints::args" -> <|
    "Spanish" -> "EquilibriumPoints se llama con dos argumentos y, si hace falta, opciones: EquilibriumPoints[L, {q, t}, \"Domain\" -> {qmin, qmax}]. Por ejemplo, para un péndulo: EquilibriumPoints[m b^2/2 th'[t]^2 + m g b Cos[th[t]], {th, t}, \"Domain\" -> {0, 2 Pi}].",
    "English" -> "EquilibriumPoints takes two arguments and, if needed, options: EquilibriumPoints[L, {q, t}, \"Domain\" -> {qmin, qmax}]. For example, for a pendulum: EquilibriumPoints[m b^2/2 th'[t]^2 + m g b Cos[th[t]], {th, t}, \"Domain\" -> {0, 2 Pi}]."|>,
  "EquilibriumPoints::time" -> <|
    "Spanish" -> "EquilibriumPoints requiere un lagrangiano autónomo: solo puede depender de `1`[`2`] y `1`'[`2`], sin `2` explícito ni derivadas de orden superior.",
    "English" -> "EquilibriumPoints requires an autonomous Lagrangian: it may depend only on `1`[`2`] and `1`'[`2`], with no explicit `2` and no higher derivatives."|>,
  "EquilibriumPoints::domain" -> <|
    "Spanish" -> "\"Domain\" -> `1` no es válido: debe ser Automatic o una lista {qmin, qmax} de dos números reales con qmin < qmax. Por ejemplo, para un ángulo: \"Domain\" -> {0, 2 Pi}.",
    "English" -> "\"Domain\" -> `1` is not valid: it must be Automatic or a list {qmin, qmax} of two real numbers with qmin < qmax. For example, for an angle: \"Domain\" -> {0, 2 Pi}."|>,
  "EquilibriumPoints::periodic" -> <|
    "Spanish" -> "Las soluciones de `1` == 0 se repiten periódicamente: `2` es un ángulo. Declara su rango con la opción \"Domain\", por ejemplo \"Domain\" -> {0, 2 Pi}.",
    "English" -> "The solutions of `1` == 0 repeat periodically: `2` is an angle. Declare its range with the \"Domain\" option, for example \"Domain\" -> {0, 2 Pi}."|>,
  "EquilibriumPoints::unsolved" -> <|
    "Spanish" -> "Solve no logró resolver `1` == 0. Ese factor aparece como no resuelto en \"Steps\"; los demás puntos se entregan igual.",
    "English" -> "Solve could not solve `1` == 0. That factor appears as unsolved in \"Steps\"; the other points are returned anyway."|>,
  "EquilibriumPoints::none" -> <|
    "Spanish" -> "No hay puntos de equilibrio: U'(q) no se anula en el dominio. \"Points\" es la lista vacía.",
    "English" -> "There are no equilibrium points: U'(q) does not vanish in the domain. \"Points\" is the empty list."|>,

  (* EquilibriumPoints: textos de "Steps", en el orden de la ayudantía *)
  "EquilibriumPoints:assumptions" -> <|
    "Spanish" -> "Suposiciones usadas.",
    "English" -> "Assumptions used."|>,
  "EquilibriumPoints:potential" -> <|
    "Spanish" -> "Potencial efectivo: U(q) = \[Minus]L con q\:0307 = 0 (incluye los términos centrífugos).",
    "English" -> "Effective potential: U(q) = \[Minus]L with q\:0307 = 0 (includes centrifugal terms)."|>,
  "EquilibriumPoints:derivative" -> <|
    "Spanish" -> "Derivada del potencial, factorizada: los equilibrios son los ceros de U'(q).",
    "English" -> "Derivative of the potential, factored: the equilibria are the zeros of U'(q)."|>,
  "EquilibriumPoints:factor" -> <|
    "Spanish" -> "Un factor de U'(q) igualado a cero y sus soluciones en el dominio.",
    "English" -> "A factor of U'(q) set to zero and its solutions in the domain."|>,
  "EquilibriumPoints:unsolved" -> <|
    "Spanish" -> "Un factor de U'(q) igualado a cero que Solve no logró resolver.",
    "English" -> "A factor of U'(q) set to zero that Solve could not solve."|>,
  "EquilibriumPoints:points" -> <|
    "Spanish" -> "Puntos de equilibrio, cada uno con su condición de existencia, sin repetir los que coinciden.",
    "English" -> "Equilibrium points, each with its existence condition, without repeating those that coincide."|>
|>];

(* --- Funciones privadas compartidas por las funciones de un grado de libertad
   (especificación en docs/specs/Modulos.md). f es la función que llama: los mensajes
   salen con su nombre --- *)

(* La desviación x debe ser un símbolo sin valor, distinto de q y t, que no aparezca en L ni en q0 *)
validateDeviation1D[f_Symbol, x_, q_, t_, L_, q0_] :=
  If[MatchQ[x, _Symbol] && !MemberQ[Attributes[x], Protected] &&
       x =!= q && x =!= t && FreeQ[{L, q0}, x],
    True,
    cmMessage[f, "dev", x, q, t]; False];

(* L con q[t] -> qs y q'[t] -> qd; devuelve {Lr, qs, qd}, o $Failed si queda t
   (t explícito o derivadas de orden superior) *)
autonomousForm[f_Symbol, L_, q_, t_] := Module[{qs, qd, Lr},
  Lr = L /. {Derivative[1][q][t] -> qd, q[t] -> qs};
  If[FreeQ[Lr, t], {Lr, qs, qd}, cmMessage[f, "time", q, t]; $Failed]];

(* Automatic: todos los símbolos libres de exprs, salvo los de exclude, son reales positivos
   (HarmonicExpansion y ClassifyEquilibrium: {L, q0} y {q, t, x}; EquilibriumPoints: {L} y {q, t}) *)
assumptions1D[Automatic, exprs_List, exclude_List] := And @@ Thread[freeSymbols[exprs, exclude] > 0];

(* Símbolos libres (los parámetros) de exprs, salvo los de exclude *)
freeSymbols[exprs_List, exclude_List] := Complement[
  Union[Cases[exprs, s_Symbol /; Context[s] =!= "System`", {0, Infinity}, Heads -> False]],
  exclude];
assumptions1D[asm_, ___] := asm;

(* Coeficientes c_k = U^(k)(q0)/k! de la serie de U en torno a q0. Calcula siempre hasta
   c_nmin y después sigue hasta el primer no nulo de orden >= 3 ("FirstNonzero") o hasta
   nmax (None). Lo que zeroQ declara cero queda como 0 exacto: sin ruido de máquina *)
potentialCoefficients[U_, qs_, q0_, asm_, nmax_, nmin_ : 2] :=
  Module[{dk = U, ck, coeffs = {}, n = None, k = 0},
    While[k <= nmax && (k <= nmin || n === None),
      If[k > 0, dk = D[dk, qs]];
      ck = Simplify[(dk /. qs -> q0)/k!, asm];
      If[zeroQ[ck, asm], ck = 0];
      If[k >= 3 && n === None && ck =!= 0, n = k];
      AppendTo[coeffs, ck];
      k++];
    <|"Coefficients" -> coeffs, "FirstNonzero" -> n|>];

(* --- HarmonicExpansion: especificación en docs/specs/HarmonicExpansion.md --- *)

Options[HarmonicExpansion] = {Assumptions -> Automatic};

HarmonicExpansion[L_, {q_Symbol, t_Symbol}, q0_, x_ /; !OptionQ[x], opts : OptionsPattern[]] :=
  Module[{form, asm, Lr, qs, qd, U, mef, lin, dU, coeffs, c, n, nmax, bound, series,
      kef, omega2, lagH, eom, steps},

    (* Validación, en el orden de la especificación *)
    If[!validateDeviation1D[HarmonicExpansion, x, q, t, L, q0], Return[$Failed]];
    form = autonomousForm[HarmonicExpansion, L, q, t];
    If[form === $Failed, Return[$Failed]];
    {Lr, qs, qd} = form;

    asm = assumptions1D[OptionValue[Assumptions], {L, q0}, {q, t, x}];

    mef = Simplify[D[Lr, {qd, 2}] /. {qd -> 0, qs -> q0}, asm];
    If[zeroQ[mef, asm], cmMessage[HarmonicExpansion, "mass", q0]; Return[$Failed]];
    lin = D[Lr, qd] /. qd -> 0;

    U = -Lr /. qd -> 0;
    dU = D[U, qs] /. qs -> q0;
    If[!zeroQ[dU, asm] && !zeroQ[FullSimplify[dU, asm], asm],
      cmMessage[HarmonicExpansion, "noteq", q0, Simplify[dU, asm]]; Return[$Failed]];

    (* La serie llega hasta x^4, o hasta el primer no nulo de orden >= 3 si es mayor *)
    coeffs = potentialCoefficients[U, qs, q0, asm, 8, 4];
    n = coeffs["FirstNonzero"];
    nmax = If[n === None, 4, Max[4, n]];
    c = Take[coeffs["Coefficients"], nmax + 1];
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
      (* Formas retenidas para mostrar en el orden de la ayudantía: q0 + x, grados crecientes
         y x'' + Ω² x = 0 (TraditionalForm respeta HoldForm, verificado en el PNG) *)
      {"series", With[{q0h = q0, terms = DeleteCases[c x^Range[0, nmax], 0]},
        HoldForm["U"[q0h + x]] ==
          If[terms === {}, 0, HoldForm[Plus[##]] & @@ terms]]},
      {"stiffness", Subscript["k", "ef"] == kef},
      {"lagrangian", "L" == lagH},
      {"bound", If[AssociationQ[bound], bound["Condition"], bound]},
      {"eom", With[{o = omega2}, HoldForm[x''[t] + o x[t] == 0]]},
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

(* --- EquilibriumPoints: especificación en docs/specs/Equilibria.md --- *)

Options[EquilibriumPoints] = {"Domain" -> Automatic, Assumptions -> Automatic};

(* "Domain": Automatic o dos reales, exactos o no, con qmin < qmax *)
domainQ[Automatic] = True;
domainQ[{lo_, hi_}] := TrueQ[Element[{lo, hi}, Reals]] && TrueQ[lo < hi];
domainQ[_] = False;

(* Solve sin evaluar o con tiempo agotado: no resuelto *)
solveFactor[f_, qs_, dom_] := Quiet[TimeConstrained[
  Solve[f == 0 && If[dom === Automatic, True, dom[[1]] <= qs < dom[[2]]], qs, Reals],
  10, $TimedOut]];

(* Una solución {qs -> v} como {punto, condición}; la condición sale de su ConditionalExpression *)
solutionPoint[qs_ -> ConditionalExpression[v_, cond_], asm_] := {v, Simplify[cond, asm]};
solutionPoint[qs_ -> v_, asm_] := {v, True};

EquilibriumPoints[L_, {q_Symbol, t_Symbol}, opts : OptionsPattern[]] :=
  Module[{form, dom, asm, Lr, qs, qd, U, fac, factors, sols, bad, pts, params, coinc, steps},

    (* Validación *)
    form = autonomousForm[EquilibriumPoints, L, q, t];
    If[form === $Failed, Return[$Failed]];
    {Lr, qs, qd} = form;
    dom = OptionValue["Domain"];
    If[!domainQ[dom], cmMessage[EquilibriumPoints, "domain", dom]; Return[$Failed]];

    asm = assumptions1D[OptionValue[Assumptions], {L}, {q, t}];

    U = -Lr /. qd -> 0;
    fac = Factor[Simplify[D[U, qs], asm]];
    factors = Select[FactorList[fac][[All, 1]], !FreeQ[#, qs] &];
    sols = solveFactor[#, qs, dom] & /@ factors;

    (* Soluciones periódicas (constantes C[k] o enteros): hay que declarar el dominio *)
    bad = FirstPosition[sols, s_ /; !FreeQ[s, _C | Element[_, Integers]], None, {1}];
    If[bad =!= None,
      cmMessage[EquilibriumPoints, "periodic", factors[[First[bad]]] /. qs -> q, q];
      Return[$Failed]];

    (* Puntos de los factores resueltos; primero los que existen siempre, cada grupo en el
       orden de Solve *)
    pts = Join @@ (Map[solutionPoint[First[#], asm] &, #] & /@ Select[sols, ListQ]);
    pts = Select[pts, #[[2]] =!= False &];
    pts = Join[Select[pts, #[[2]] === True &], Select[pts, #[[2]] =!= True &]];

    (* Puntos repetidos: a cada punto se le quita la condición en que coincide con uno anterior *)
    params = freeSymbols[{L, asm}, {q, t}];
    coinc[{p1_, c1_}, {p2_, c2_}] := With[
      {r = Quiet[TimeConstrained[Reduce[p1 == p2 && c1 && c2 && asm, params, Reals], 10, False]]},
      If[MatchQ[r, _Reduce], False, r]];
    Do[
      pts[[i, 2]] = Simplify[pts[[i, 2]] && !Or @@ (coinc[pts[[i]], #] & /@ pts[[;; i - 1]]), asm],
      {i, 2, Length[pts]}];
    pts = Select[pts, #[[2]] =!= False &];

    steps = Join[
      {{"assumptions", asm},
       {"potential", "U"[q] == (U /. qs -> q)},
       {"derivative", Derivative[1]["U"][q] == (fac /. qs -> q)}},
      MapThread[
        If[ListQ[#2],
          {"factor", ((#1 /. qs -> q) == 0) -> (q == First[solutionPoint[First[#], asm]] & /@ #2)},
          {"unsolved", (#1 /. qs -> q) == 0}] &,
        {factors, sols}],
      {{"points", If[#[[2]] === True, q == #[[1]], ConditionalExpression[q == #[[1]], #[[2]]]] & /@
        pts}}];
    steps = <|"Description" -> tr["EquilibriumPoints:" <> #[[1]]], "Expression" -> #[[2]]|> & /@
      steps;

    Scan[If[!ListQ[sols[[#]]], cmMessage[EquilibriumPoints, "unsolved", factors[[#]] /. qs -> q]] &,
      Range[Length[factors]]];
    If[pts === {} && AllTrue[sols, ListQ], cmMessage[EquilibriumPoints, "none"]];

    <|"Potential" -> (U /. qs -> q), "Derivative" -> (fac /. qs -> q),
      "Factors" -> (factors /. qs -> q),
      "Points" -> (<|"Point" -> #[[1]], "Condition" -> #[[2]]|> & /@ pts),
      "Steps" -> steps|>
  ];

EquilibriumPoints[___] := (cmMessage[EquilibriumPoints, "args"]; $Failed);

(* --- Alias en español (al final, cuando las funciones ya tienen sus atributos) --- *)
defineAlias[ExpansionArmonica, HarmonicExpansion];
defineAlias[PuntosDeEquilibrio, EquilibriumPoints];

End[];
