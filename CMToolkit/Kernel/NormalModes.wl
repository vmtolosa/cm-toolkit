(* ::Package:: *)
(* CMToolkit, módulo NormalModes: pequeñas oscilaciones y modos normales en N dimensiones
   (especificación en docs/specs/NormalModes.md, Parte A).
   Lo carga CMToolkit.wl dentro de BeginPackage, después de Oscillations1D.wl. *)

SpringNetwork::usage =
  "SpringNetwork[posiciones, resortes, masas] construye el sistema de pequeñas oscilaciones de una red de masas unidas por resortes, en 1, 2 o 3 dimensiones: posiciones de equilibrio de las masas, resortes {j, i, k} (constante k entre las masas j e i) y masas (un valor o una lista). Supone que los resortes están en su largo natural en el equilibrio. Entrega una Association con las coordenadas, las matrices de masas (\"Mmat\") y de constantes elásticas (\"Kmat\"), la geometría, la tabla de resortes y los pasos intermedios (\"Steps\"). Opciones: \"Anchors\" -> {{i, punto, k}, \[Ellipsis]} (resortes a puntos fijos), \"Coordinates\" -> lista de símbolos y Assumptions (Automatic: los parámetros son reales positivos). Alias: RedDeResortes.\n\
SpringNetwork[positions, springs, masses] builds the small-oscillation system of a network of masses joined by springs, in 1, 2 or 3 dimensions: equilibrium positions of the masses, springs {j, i, k} (constant k between masses j and i) and masses (one value or a list). It assumes the springs are at their natural length at equilibrium. It returns an Association with the coordinates, the mass matrix (\"Mmat\") and stiffness matrix (\"Kmat\"), the geometry, the spring table and the intermediate steps (\"Steps\"). Options: \"Anchors\" -> {{i, point, k}, \[Ellipsis]} (springs to fixed points), \"Coordinates\" -> list of symbols and Assumptions (Automatic: parameters are positive reals).";
RedDeResortes::usage =
  "RedDeResortes[posiciones, resortes, masas] es el alias en español de SpringNetwork. Los mensajes de error aparecen con el nombre SpringNetwork.\n\
RedDeResortes[positions, springs, masses] is the Spanish alias of SpringNetwork. Error messages appear under the name SpringNetwork.";

SmallOscillations::usage =
  "SmallOscillations[L, {q1, q2, \[Ellipsis]}, t, {q10, q20, \[Ellipsis]}] construye el sistema de pequeñas oscilaciones del lagrangiano L de N coordenadas (escrito con q1[t], q1'[t], \[Ellipsis]) en torno al equilibrio {q10, q20, \[Ellipsis]}. Entrega una Association con las coordenadas (las desviaciones respecto al equilibrio), las matrices de masas (\"Mmat\") y de constantes elásticas (\"Kmat\") y los pasos intermedios (\"Steps\"). Opción: Assumptions (Automatic: los parámetros son reales positivos). Alias: PequenasOscilaciones.\n\
SmallOscillations[L, {q1, q2, \[Ellipsis]}, t, {q10, q20, \[Ellipsis]}] builds the small-oscillation system of the N-coordinate Lagrangian L (written with q1[t], q1'[t], \[Ellipsis]) about the equilibrium {q10, q20, \[Ellipsis]}. It returns an Association with the coordinates (the deviations from equilibrium), the mass matrix (\"Mmat\") and stiffness matrix (\"Kmat\") and the intermediate steps (\"Steps\"). Option: Assumptions (Automatic: parameters are positive reals).";
PequenasOscilaciones::usage =
  "PequenasOscilaciones[L, {q1, q2, \[Ellipsis]}, t, {q10, q20, \[Ellipsis]}] es el alias en español de SmallOscillations. Los mensajes de error aparecen con el nombre SmallOscillations.\n\
PequenasOscilaciones[L, {q1, q2, \[Ellipsis]}, t, {q10, q20, \[Ellipsis]}] is the Spanish alias of SmallOscillations. Error messages appear under the name SmallOscillations.";

NormalModes::usage =
  "NormalModes[sistema] calcula los modos normales de un sistema de SpringNetwork o SmallOscillations: resuelve (Kmat \[Minus] \[Omega]\.b2 Mmat) A = 0 y entrega una Association con el determinante secular, los \[Omega]\.b2 (\"Omega2\"), las frecuencias, los modos normalizados con A\[CenterDot]Mmat\[CenterDot]A = 1 (\"Modes\"), las degeneraciones, los modos nulos, el rango de Kmat y los pasos intermedios (\"Steps\"). NormalModes[Mmat, Kmat] usa las matrices directamente. Opción: \"Basis\" -> {v1, v2, \[Ellipsis]} (una base de vectores propios elegida por ti, en ese orden). Alias: ModosNormales.\n\
NormalModes[system] computes the normal modes of a system from SpringNetwork or SmallOscillations: it solves (Kmat \[Minus] \[Omega]\.b2 Mmat) A = 0 and returns an Association with the secular determinant, the \[Omega]\.b2 (\"Omega2\"), the frequencies, the modes normalized with A\[CenterDot]Mmat\[CenterDot]A = 1 (\"Modes\"), the degeneracies, the zero modes, the rank of Kmat and the intermediate steps (\"Steps\"). NormalModes[Mmat, Kmat] uses the matrices directly. Option: \"Basis\" -> {v1, v2, \[Ellipsis]} (a basis of eigenvectors of your choice, in that order).";
ModosNormales::usage =
  "ModosNormales[sistema] es el alias en español de NormalModes. Los mensajes de error aparecen con el nombre NormalModes.\n\
ModosNormales[system] is the Spanish alias of NormalModes. Error messages appear under the name NormalModes.";

NormalCoordinates::usage =
  "NormalCoordinates[modos] entrega las coordenadas normales Q_n = A_n\[CenterDot]Mmat\[CenterDot]q del resultado de NormalModes, su inversa q = \[CapitalSigma] A_n Q_n, el lagrangiano diagonal \[CapitalSigma] (\.bd Q\:0307_n\.b2 \[Minus] \.bd \[Omega]_n\.b2 Q_n\.b2) y los pasos intermedios (\"Steps\"). NormalCoordinates[modos, {Q1, Q2, \[Ellipsis]}] usa los nombres que elijas. Alias: CoordenadasNormales.\n\
NormalCoordinates[modes] gives the normal coordinates Q_n = A_n\[CenterDot]Mmat\[CenterDot]q of a NormalModes result, their inverse q = \[CapitalSigma] A_n Q_n, the diagonal Lagrangian \[CapitalSigma] (\.bd Q\:0307_n\.b2 \[Minus] \.bd \[Omega]_n\.b2 Q_n\.b2) and the intermediate steps (\"Steps\"). NormalCoordinates[modes, {Q1, Q2, \[Ellipsis]}] uses the names you choose.";
CoordenadasNormales::usage =
  "CoordenadasNormales[modos] es el alias en español de NormalCoordinates. Los mensajes de error aparecen con el nombre NormalCoordinates.\n\
CoordenadasNormales[modes] is the Spanish alias of NormalCoordinates. Error messages appear under the name NormalCoordinates.";

ModeResponse::usage =
  "ModeResponse[modos, q0, v0] calcula el movimiento del sistema de NormalModes con posiciones iniciales q0 y velocidades iniciales v0, como superposición de modos normales. Entrega una Association con las coordenadas normales iniciales, la solución de cada modo (\"NormalSolution\"), la solución en las coordenadas originales (\"Solution\"), la energía de cada modo, su fracción de la energía total (\"EnergyShares\") y los pasos intermedios (\"Steps\"). ModeResponse[modos, q0, v0, t] usa t como símbolo del tiempo. Alias: RespuestaModal.\n\
ModeResponse[modes, q0, v0] computes the motion of the NormalModes system with initial positions q0 and initial velocities v0, as a superposition of normal modes. It returns an Association with the initial normal coordinates, the solution of each mode (\"NormalSolution\"), the solution in the original coordinates (\"Solution\"), the energy of each mode, its share of the total energy (\"EnergyShares\") and the intermediate steps (\"Steps\"). ModeResponse[modes, q0, v0, t] uses t as the time symbol.";
RespuestaModal::usage =
  "RespuestaModal[modos, q0, v0] es el alias en español de ModeResponse. Los mensajes de error aparecen con el nombre ModeResponse.\n\
RespuestaModal[modes, q0, v0] is the Spanish alias of ModeResponse. Error messages appear under the name ModeResponse.";

Begin["`Private`"];

(* Textos de este módulo: se agregan a la tabla $texts de Core.wl *)
AssociateTo[$texts, <|
  "SpringNetwork::args" -> <|
    "Spanish" -> "SpringNetwork se llama con tres argumentos: SpringNetwork[posiciones, resortes, masas]. Por ejemplo, dos masas en una recta unidas por un resorte: SpringNetwork[{0, 1}, {{1, 2, k}}, m].",
    "English" -> "SpringNetwork takes three arguments: SpringNetwork[positions, springs, masses]. For example, two masses on a line joined by a spring: SpringNetwork[{0, 1}, {{1, 2, k}}, m]."|>,
  "SmallOscillations::args" -> <|
    "Spanish" -> "SmallOscillations se llama con cuatro argumentos: SmallOscillations[L, {q1, q2, \[Ellipsis]}, t, {q10, q20, \[Ellipsis]}], con el lagrangiano escrito con q1[t], q1'[t], \[Ellipsis] y el punto de equilibrio.",
    "English" -> "SmallOscillations takes four arguments: SmallOscillations[L, {q1, q2, \[Ellipsis]}, t, {q10, q20, \[Ellipsis]}], with the Lagrangian written with q1[t], q1'[t], \[Ellipsis] and the equilibrium point."|>,
  "NormalModes::args" -> <|
    "Spanish" -> "NormalModes se llama con un sistema de SpringNetwork o SmallOscillations, NormalModes[sistema], o con las dos matrices, NormalModes[Mmat, Kmat].",
    "English" -> "NormalModes takes a system from SpringNetwork or SmallOscillations, NormalModes[system], or the two matrices, NormalModes[Mmat, Kmat]."|>,
  "NormalCoordinates::args" -> <|
    "Spanish" -> "NormalCoordinates se llama con el resultado de NormalModes: NormalCoordinates[modos], o NormalCoordinates[modos, {Q1, Q2, \[Ellipsis]}] para elegir los nombres.",
    "English" -> "NormalCoordinates takes a NormalModes result: NormalCoordinates[modes], or NormalCoordinates[modes, {Q1, Q2, \[Ellipsis]}] to choose the names."|>,
  "ModeResponse::args" -> <|
    "Spanish" -> "ModeResponse se llama con el resultado de NormalModes y las condiciones iniciales: ModeResponse[modos, q0, v0], o ModeResponse[modos, q0, v0, t] para elegir el símbolo del tiempo.",
    "English" -> "ModeResponse takes a NormalModes result and the initial conditions: ModeResponse[modes, q0, v0], or ModeResponse[modes, q0, v0, t] to choose the time symbol."|>
|>];

(* --- SpringNetwork: especificación en docs/specs/NormalModes.md --- *)

Options[SpringNetwork] = {"Anchors" -> {}, "Coordinates" -> Automatic, Assumptions -> Automatic};

SpringNetwork[___] := (cmMessage[SpringNetwork, "args"]; $Failed);

(* --- SmallOscillations: especificación en docs/specs/NormalModes.md --- *)

Options[SmallOscillations] = {Assumptions -> Automatic};

SmallOscillations[___] := (cmMessage[SmallOscillations, "args"]; $Failed);

(* --- NormalModes: especificación en docs/specs/NormalModes.md --- *)

Options[NormalModes] = {"Basis" -> Automatic};

NormalModes[___] := (cmMessage[NormalModes, "args"]; $Failed);

(* --- NormalCoordinates: especificación en docs/specs/NormalModes.md --- *)

NormalCoordinates[___] := (cmMessage[NormalCoordinates, "args"]; $Failed);

(* --- ModeResponse: especificación en docs/specs/NormalModes.md --- *)

ModeResponse[___] := (cmMessage[ModeResponse, "args"]; $Failed);

(* --- Alias en español (al final, cuando las funciones ya tienen sus atributos) --- *)
defineAlias[RedDeResortes, SpringNetwork];
defineAlias[PequenasOscilaciones, SmallOscillations];
defineAlias[ModosNormales, NormalModes];
defineAlias[CoordenadasNormales, NormalCoordinates];
defineAlias[RespuestaModal, ModeResponse];

End[];
