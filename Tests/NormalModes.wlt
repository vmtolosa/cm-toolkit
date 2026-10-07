(* Tests de SpringNetwork, SmallOscillations, NormalModes, NormalCoordinates y ModeResponse.
   Especificación: docs/specs/NormalModes.md (versión 1, Parte A).
   Valores de referencia: Ayudantía 6, Problema 2 (cuatro masas y seis resortes), ecs. (35)–(93),
   tabla de la p. 12, base de la p. 17, Listados 6, 9, 10 y 11. *)

nmAsm = a > 0 && k > 0 && kp > 0 && m > 0 && v > 0;

(* Las dos listas tienen los mismos elementos, con la misma multiplicidad: mismo polinomio
   con esas raíces *)
nmSameRootsQ[l1_List, l2_List, asm_] := Module[{x},
  Length[l1] === Length[l2] &&
    Simplify[Expand[Times @@ (x - l1) - Times @@ (x - l2)], asm] === 0];

nmZeroMatrixQ[mat_, asm_] := Union[Flatten[Simplify[mat, asm]]] === {0};

(* Cada modo es proporcional al vector de la base de la misma posición *)
nmParallelQ[modes_List, vecs_List] :=
  Length[modes] === Length[vecs] &&
    And @@ MapThread[MatrixRank[{#1, #2}] === 1 &, {modes, vecs}];

(* --- Cuadrado de la ayudantía (Problema 2) --- *)

nmPos = {{0, 0}, {a, 0}, {a, a}, {0, a}};
nmSprings = {{1, 2, k}, {4, 3, k}, {2, 3, k}, {1, 4, k}, {1, 3, kp}, {2, 4, kp}};

(* Base de la p. 17: traslación x, traslación y, rotación, cizalle, rectángulo, trapecio x,
   trapecio y, respiración *)
nmBase = {{1, 0, 1, 0, 1, 0, 1, 0}, {0, 1, 0, 1, 0, 1, 0, 1}, {1, -1, 1, 1, -1, 1, -1, -1},
  {-1, -1, -1, 1, 1, 1, 1, -1}, {-1, 1, 1, 1, 1, -1, -1, -1}, {1, 0, -1, 0, 1, 0, -1, 0},
  {0, 1, 0, -1, 0, 1, 0, -1}, {-1, -1, 1, -1, 1, 1, -1, 1}};
nmBaseOmega2 = {0, 0, 0, 2 kp/m, 2 k/m, 2 k/m, 2 k/m, 2 (k + kp)/m};

nmSquare = SpringNetwork[nmPos, nmSprings, m];
nmModes = NormalModes[nmSquare];
nmBaseModes = NormalModes[nmSquare, "Basis" -> nmBase];

(* === SpringNetwork === *)

(* Listado 6: Kmat de Σ k c cᵀ coincide con la segunda derivada del potencial exacto *)
VerificationTest[
  Module[{q, r, pot, hess},
    q = Array[\[FormalQ], 8];
    r[i_] := nmPos[[i]] + q[[2 i - 1 ;; 2 i]];
    pot = Total[
      (#3/2 (Sqrt[(r[#2] - r[#1]) . (r[#2] - r[#1])] -
        Sqrt[(nmPos[[#2]] - nmPos[[#1]]) . (nmPos[[#2]] - nmPos[[#1]])])^2) & @@@ nmSprings];
    hess = D[pot, {q, 2}] /. Thread[q -> 0];
    nmZeroMatrixQ[hess - nmSquare["Kmat"], nmAsm]],
  True,
  TestID -> "red-cuadrado-Kmat-potencial-exacto-listado-6"
]

VerificationTest[
  nmSquare["Mmat"],
  m IdentityMatrix[8],
  TestID -> "red-cuadrado-Mmat"
]

VerificationTest[
  Simplify[nmSquare["SpringTable"][[All, "Direction"]] -
    {{1, 0}, {1, 0}, {0, 1}, {0, 1}, {1, 1}/Sqrt[2], {-1, 1}/Sqrt[2]}, nmAsm],
  ConstantArray[0, {6, 2}],
  TestID -> "red-cuadrado-tabla-de-resortes-p-12"
]

VerificationTest[
  nmSquare["SpringTable"][[All, "Spring"]],
  nmSprings[[All, 1 ;; 2]],
  TestID -> "red-cuadrado-tabla-de-resortes-orden"
]

(* === NormalModes === *)

VerificationTest[
  Module[{det, ratio},
    det = NormalModes[SpringNetwork[nmPos, nmSprings, 1]]["SecularDeterminant"];
    ratio = Simplify[det/(\[FormalLambda]^3 (\[FormalLambda] - 2 k)^3 (\[FormalLambda] - 2 kp)
      (\[FormalLambda] - 2 k - 2 kp)), nmAsm];
    FreeQ[ratio, \[FormalLambda]] && Simplify[ratio != 0, nmAsm]],
  True,
  TestID -> "modos-cuadrado-determinante-secular-ec-57"
]

VerificationTest[
  nmSameRootsQ[nmModes["Omega2"], nmBaseOmega2, nmAsm],
  True,
  TestID -> "modos-cuadrado-omega2-ec-57"
]

VerificationTest[
  {nmModes["ZeroModes"], nmModes["Rank"]},
  {3, 5},
  TestID -> "modos-cuadrado-modos-nulos-y-rango-inciso-c"
]

VerificationTest[
  Module[{a8 = nmModes["Modes"]},
    {nmZeroMatrixQ[a8 . nmSquare["Mmat"] . Transpose[a8] - IdentityMatrix[8], nmAsm],
     nmZeroMatrixQ[a8 . nmSquare["Kmat"] . Transpose[a8] - DiagonalMatrix[nmModes["Omega2"]],
       nmAsm]}],
  {True, True},
  TestID -> "modos-cuadrado-ortonormales-ecs-72-73"
]

(* --- Con la base de la ayudantía --- *)

VerificationTest[
  {nmParallelQ[nmBaseModes["Modes"], nmBase],
   Simplify[nmBaseModes["Omega2"] - nmBaseOmega2, nmAsm]},
  {True, ConstantArray[0, 8]},
  TestID -> "modos-cuadrado-base-p-17-en-orden"
]

VerificationTest[
  Module[{a8 = nmBaseModes["Modes"]},
    {nmZeroMatrixQ[a8 . nmSquare["Mmat"] . Transpose[a8] - IdentityMatrix[8], nmAsm],
     nmZeroMatrixQ[a8 . nmSquare["Kmat"] . Transpose[a8] - DiagonalMatrix[nmBaseOmega2], nmAsm]}],
  {True, True},
  TestID -> "modos-cuadrado-base-ortonormal"
]

VerificationTest[
  NormalModes[nmSquare, "Basis" -> ReplacePart[nmBase, 1 -> {1, 0, 0, 0, 0, 0, 0, 0}]],
  $Failed,
  {NormalModes::noteigen},
  TestID -> "modos-cuadrado-base-vector-no-propio-noteigen"
]

(* Listado 9: base «mala» (no Mmat-ortogonal en el subespacio 2k/m). Gram-Schmidt en el orden
   dado deja el modo 5 igual y devuelve el 6 al trapecio x *)
VerificationTest[
  Module[{res, a8},
    res = NormalModes[nmSquare, "Basis" -> ReplacePart[nmBase, 6 -> nmBase[[5]] + nmBase[[6]]]];
    a8 = res["Modes"];
    {nmZeroMatrixQ[a8 . nmSquare["Mmat"] . Transpose[a8] - IdentityMatrix[8], nmAsm],
     nmParallelQ[a8, nmBase]}],
  {True, True},
  TestID -> "modos-cuadrado-base-no-ortogonal-listado-9"
]

(* --- Sin diagonales y con una sola --- *)

VerificationTest[
  Module[{res = NormalModes[SpringNetwork[nmPos, nmSprings /. kp -> 0, m]]},
    {nmSameRootsQ[res["Omega2"], {0, 0, 0, 0, 2 k/m, 2 k/m, 2 k/m, 2 k/m}, nmAsm],
     res["ZeroModes"], res["Rank"]}],
  {True, 4, 4},
  TestID -> "modos-cuadrado-kp-cero-ec-65"
]

VerificationTest[
  Module[{res = NormalModes[SpringNetwork[nmPos, nmSprings[[1 ;; 4]], m]]},
    {nmSameRootsQ[res["Omega2"], {0, 0, 0, 0, 2 k/m, 2 k/m, 2 k/m, 2 k/m}, nmAsm],
     res["ZeroModes"], res["Rank"]}],
  {True, 4, 4},
  TestID -> "modos-cuadrado-sin-diagonales-ec-65"
]

VerificationTest[
  Module[{res = NormalModes[SpringNetwork[nmPos, nmSprings[[1 ;; 5]], m]]},
    {nmSameRootsQ[res["Omega2"],
      {0, 0, 0, 2 k/m, 2 k/m, 2 k/m,
       (k + kp + Sqrt[k^2 + kp^2])/m, (k + kp - Sqrt[k^2 + kp^2])/m}, nmAsm],
     res["ZeroModes"], res["Rank"]}],
  {True, 3, 5},
  TestID -> "modos-cuadrado-una-diagonal-ec-70"
]

(* === NormalCoordinates === *)

(* El lagrangiano es exactamente Σ (½ Q̇² − ½ ω² Q²): sin términos cruzados. El símbolo del
   tiempo se lee del propio lagrangiano *)
nmDiagonalLagrangianQ[lag_, qs_List, w2_List] := Module[{tt},
  tt = First[Cases[lag, Derivative[1][First[qs]][s_] :> s, Infinity], $Failed];
  tt =!= $Failed &&
    Simplify[lag - Sum[(qs[[n]]'[tt]^2 - w2[[n]] qs[[n]][tt]^2)/2, {n, Length[qs]}], nmAsm] === 0];

VerificationTest[
  nmDiagonalLagrangianQ[NormalCoordinates[nmBaseModes]["Lagrangian"],
    Array[\[FormalCapitalQ], 8], nmBaseOmega2],
  True,
  TestID -> "coordenadas-cuadrado-lagrangiano-diagonal-ec-81"
]

VerificationTest[
  nmDiagonalLagrangianQ[NormalCoordinates[nmBaseModes, {Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8}][
    "Lagrangian"], {Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8}, nmBaseOmega2],
  True,
  TestID -> "coordenadas-cuadrado-nombres-del-usuario"
]

(* Q(q) y q(Q) son una la inversa de la otra; si vienen como ecuaciones se toma el lado derecho *)
VerificationTest[
  Module[{qs = {Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8}, coords, res, ofq, ofQ},
    coords = nmBaseModes["Coordinates"];
    res = NormalCoordinates[nmBaseModes, qs];
    ofq = res["NormalCoordinates"] /. Equal[_, rhs_] :> rhs;
    ofQ = res["Inverse"] /. Equal[_, rhs_] :> rhs;
    {Simplify[(ofq /. Thread[coords -> ofQ]) - qs, nmAsm],
     Simplify[(ofQ /. Thread[qs -> ofq]) - coords, nmAsm]}],
  {ConstantArray[0, 8], ConstantArray[0, 8]},
  TestID -> "coordenadas-cuadrado-inversa-ecs-71-75"
]

(* === ModeResponse === *)

nmShares[v0_] := Simplify[
  ModeResponse[nmBaseModes, ConstantArray[0, 8], v0]["EnergyShares"], nmAsm];

VerificationTest[
  nmShares[v/Sqrt[2] {1, 1, 0, 0, 0, 0, 0, 0}],
  {1/8, 1/8, 0, 1/4, 0, 1/8, 1/8, 1/4},
  TestID -> "respuesta-cuadrado-golpe-radial-ec-92"
]

VerificationTest[
  nmShares[v/Sqrt[2] {1, -1, 0, 0, 0, 0, 0, 0}],
  {1/8, 1/8, 1/4, 0, 1/4, 1/8, 1/8, 0},
  TestID -> "respuesta-cuadrado-golpe-tangencial-listado-11"
]

VerificationTest[
  nmShares[v {1, 0, 0, 0, 0, 0, 0, 0}],
  {1/4, 0, 1/8, 1/8, 1/8, 1/4, 0, 1/8},
  TestID -> "respuesta-cuadrado-golpe-lado"
]

(* Listado 10: con posición inicial distinta de cero, para que entren los cosenos *)
VerificationTest[
  Module[{q0 = {d, 0, 0, 0, 0, 0, 0, 0}, v0 = v/Sqrt[2] {1, 1, 0, 0, 0, 0, 0, 0}, res, sol, tt},
    res = ModeResponse[nmModes, q0, v0];
    sol = res["Solution"];
    tt = res["Time"];
    {nmZeroMatrixQ[nmSquare["Mmat"] . D[sol, {tt, 2}] + nmSquare["Kmat"] . sol, nmAsm],
     Simplify[(sol /. tt -> 0) - q0, nmAsm],
     Simplify[(D[sol, tt] /. tt -> 0) - v0, nmAsm]}],
  {True, ConstantArray[0, 8], ConstantArray[0, 8]},
  TestID -> "respuesta-cuadrado-cumple-ecuaciones-listado-10"
]

VerificationTest[
  Module[{sys, res, sol, tt, v0, y, s, nd},
    sys = SpringNetwork[nmPos /. a -> 1, nmSprings /. {k -> 1, kp -> 0.5}, 1];
    v0 = 0.1/Sqrt[2] {1, 1, 0, 0, 0, 0, 0, 0};
    res = ModeResponse[NormalModes[sys, "Basis" -> nmBase], ConstantArray[0, 8], v0];
    sol = res["Solution"];
    tt = res["Time"];
    nd = First[NDSolve[{sys["Mmat"] . y''[s] + sys["Kmat"] . y[s] == ConstantArray[0, 8],
      y[0] == ConstantArray[0, 8], y'[0] == v0}, y, {s, 0, 30},
      PrecisionGoal -> 12, AccuracyGoal -> 14, MaxSteps -> Infinity]];
    Max[Table[Norm[(sol /. tt -> s0) - (y[s0] /. nd), Infinity], {s0, 0, 30, 0.05}]] < 10^-6],
  True,
  TestID -> "respuesta-cuadrado-contra-NDSolve-listado-10"
]

(* --- Casos con solución conocida (no están en la ayudantía) --- *)

VerificationTest[
  Module[{res = NormalModes[
      SpringNetwork[{1, 2}, {{1, 2, k}}, m, "Anchors" -> {{1, 0, k}, {2, 3, k}}]]},
    {nmSameRootsQ[res["Omega2"], {k/m, 3 k/m}, nmAsm], res["ZeroModes"]}],
  {True, 0},
  TestID -> "modos-cadena-1D-dos-masas-con-paredes"
]

VerificationTest[
  nmSameRootsQ[
    m/k NormalModes[SpringNetwork[{1, 2, 3}, {{1, 2, k}, {2, 3, k}}, m,
      "Anchors" -> {{1, 0, k}, {3, 4, k}}]]["Omega2"],
    {2 - Sqrt[2], 2, 2 + Sqrt[2]}, nmAsm],
  True,
  TestID -> "modos-cadena-1D-tres-masas-con-paredes"
]

VerificationTest[
  nmSameRootsQ[NormalModes[SpringNetwork[{0, 1}, {{1, 2, k}}, {m, 2 m}]]["Omega2"],
    {0, 3 k/(2 m)}, nmAsm],
  True,
  TestID -> "modos-dos-masas-distintas-1D"
]

VerificationTest[
  nmSameRootsQ[
    m/k NormalModes[SpringNetwork[{{0, 0}, {1, 0}, {1/2, Sqrt[3]/2}},
      {{1, 2, k}, {2, 3, k}, {1, 3, k}}, m]]["Omega2"],
    {0, 0, 0, 3/2, 3/2, 3}, nmAsm],
  True,
  TestID -> "modos-triangulo-equilatero-2D"
]

VerificationTest[
  nmSameRootsQ[
    m/k NormalModes[SpringNetwork[{{1, 1, 1}, {1, -1, -1}, {-1, 1, -1}, {-1, -1, 1}},
      {{1, 2, k}, {1, 3, k}, {1, 4, k}, {2, 3, k}, {2, 4, k}, {3, 4, k}}, m]]["Omega2"],
    {0, 0, 0, 0, 0, 0, 1, 1, 2, 2, 2, 4}, nmAsm],
  True,
  TestID -> "modos-tetraedro-regular-3D"
]

(* === SmallOscillations: péndulo doble === *)

nmPendulumL = m l^2/2 (2 th1'[t]^2 + th2'[t]^2 + 2 th1'[t] th2'[t] Cos[th1[t] - th2[t]]) +
  m g l (2 Cos[th1[t]] + Cos[th2[t]]);
nmPendulumAsm = m > 0 && l > 0 && g > 0;
nmPendulum = SmallOscillations[nmPendulumL, {th1, th2}, t, {0, 0}];

VerificationTest[
  Simplify[{nmPendulum["Mmat"] - m l^2 {{2, 1}, {1, 1}},
    nmPendulum["Kmat"] - m g l {{2, 0}, {0, 1}}}, nmPendulumAsm],
  ConstantArray[0, {2, 2, 2}],
  TestID -> "pequenas-pendulo-doble-matrices"
]

VerificationTest[
  nmSameRootsQ[NormalModes[nmPendulum]["Omega2"],
    {g/l (2 - Sqrt[2]), g/l (2 + Sqrt[2])}, nmPendulumAsm],
  True,
  TestID -> "pequenas-pendulo-doble-frecuencias"
]

VerificationTest[
  SmallOscillations[nmPendulumL, {th1, th2}, t, {Pi/2, 0}],
  $Failed,
  {SmallOscillations::noteq},
  TestID -> "pequenas-error-no-es-equilibrio"
]

VerificationTest[
  Module[{keys = {"Omega2", "Frequencies", "Modes", "SecularDeterminant", "Degeneracies",
      "ZeroModes", "Rank"}},
    KeyTake[NormalModes[nmPendulum["Mmat"], nmPendulum["Kmat"]], keys] ===
      KeyTake[NormalModes[nmPendulum], keys]],
  True,
  TestID -> "modos-atajo-matrices-pendulo-doble"
]

(* --- Errores de SpringNetwork --- *)

VerificationTest[
  SpringNetwork[{{0, 0}, {1}}, {{1, 2, k}}, m],
  $Failed,
  {SpringNetwork::positions},
  TestID -> "red-error-dimensiones-distintas"
]

VerificationTest[
  SpringNetwork[{{0, 0, 0, 0}, {1, 0, 0, 0}}, {{1, 2, k}}, m],
  $Failed,
  {SpringNetwork::positions},
  TestID -> "red-error-dimension-4"
]

VerificationTest[
  SpringNetwork[{{0, 0}, {0, 0}}, {{1, 2, k}}, m],
  $Failed,
  {SpringNetwork::positions},
  TestID -> "red-error-dos-masas-en-el-mismo-punto"
]

VerificationTest[
  SpringNetwork[nmPos, {{1, 5, k}}, m],
  $Failed,
  {SpringNetwork::springs},
  TestID -> "red-error-resorte-indice-fuera-de-rango"
]

VerificationTest[
  SpringNetwork[nmPos, {{2, 2, k}}, m],
  $Failed,
  {SpringNetwork::springs},
  TestID -> "red-error-resorte-j-igual-a-i"
]

VerificationTest[
  SpringNetwork[nmPos, {{1, 2}}, m],
  $Failed,
  {SpringNetwork::springs},
  TestID -> "red-error-resorte-formato"
]

VerificationTest[
  SpringNetwork[nmPos, nmSprings, {m, m, m}],
  $Failed,
  {SpringNetwork::masses},
  TestID -> "red-error-largo-de-masas"
]

VerificationTest[
  SpringNetwork[nmPos, nmSprings, m, "Anchors" -> {{5, {0, 0}, k}}],
  $Failed,
  {SpringNetwork::anchors},
  TestID -> "red-error-anclaje-indice-fuera-de-rango"
]

VerificationTest[
  Module[{en},
    en = Block[{$CMLanguage = "English"},
      Quiet[SpringNetwork[nmPos, nmSprings, {m, m, m}]];
      SpringNetwork::masses];
    StringQ[en] && en === CMToolkit`Private`$texts["SpringNetwork::masses"]["English"]],
  True,
  TestID -> "red-mensaje-en-ingles"
]

(* --- Alias --- *)

VerificationTest[
  RedDeResortes[nmPos, nmSprings, m] === nmSquare,
  True,
  TestID -> "alias-RedDeResortes"
]

VerificationTest[
  PequenasOscilaciones[nmPendulumL, {th1, th2}, t, {0, 0}] === nmPendulum,
  True,
  TestID -> "alias-PequenasOscilaciones"
]

VerificationTest[
  ModosNormales[nmSquare, "Basis" -> nmBase] === nmBaseModes,
  True,
  TestID -> "alias-ModosNormales"
]

VerificationTest[
  CoordenadasNormales[nmBaseModes] === NormalCoordinates[nmBaseModes],
  True,
  TestID -> "alias-CoordenadasNormales"
]

VerificationTest[
  Module[{v0 = v/Sqrt[2] {1, 1, 0, 0, 0, 0, 0, 0}},
    RespuestaModal[nmBaseModes, ConstantArray[0, 8], v0] ===
      ModeResponse[nmBaseModes, ConstantArray[0, 8], v0]],
  True,
  TestID -> "alias-RespuestaModal"
]
