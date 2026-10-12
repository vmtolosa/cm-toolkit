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
  "SpringNetwork::positions" -> <|
    "Spanish" -> "Las posiciones deben ser una lista de puntos de la misma dimensión, 1, 2 o 3, sin dos masas en el mismo punto. En una dimensión se aceptan números sueltos: {1, 2, 3}.",
    "English" -> "The positions must be a list of points of the same dimension, 1, 2 or 3, with no two masses at the same point. In one dimension plain numbers are accepted: {1, 2, 3}."|>,
  "SpringNetwork::springs" -> <|
    "Spanish" -> "Cada resorte se escribe {j, i, k}: j e i son los números de dos masas distintas, entre 1 y `1`, y k es la constante elástica. Revisa `2`.",
    "English" -> "Each spring is written {j, i, k}: j and i are the numbers of two different masses, between 1 and `1`, and k is the spring constant. Check `2`."|>,
  "SpringNetwork::masses" -> <|
    "Spanish" -> "Las masas deben ser un solo valor (todas iguales) o una lista de `1` valores, uno por masa; la lista dada tiene `2`.",
    "English" -> "The masses must be a single value (all equal) or a list of `1` values, one per mass; the given list has `2`."|>,
  "SpringNetwork::anchors" -> <|
    "Spanish" -> "Cada anclaje se escribe {i, punto, k}: i es el número de una masa, entre 1 y `1`; punto es un punto fijo de dimensión `2`, distinto de la posición de la masa; y k es la constante elástica. Revisa `3`.",
    "English" -> "Each anchor is written {i, point, k}: i is the number of a mass, between 1 and `1`; point is a fixed point of dimension `2`, different from the position of the mass; and k is the spring constant. Check `3`."|>,
  "SpringNetwork::coords" -> <|
    "Spanish" -> "Las coordenadas deben ser `1` símbolos distintos, sin valor asignado, que no aparezcan en los datos de la red; no cumple `2`. Si los nombres por defecto (x1, y1, \[Ellipsis]) ya tienen valor, elige otros con la opción \"Coordinates\" -> {\[Ellipsis]}.",
    "English" -> "The coordinates must be `1` distinct symbols with no assigned value that do not appear in the network data; `2` does not qualify. If the default names (x1, y1, \[Ellipsis]) already have values, choose others with the option \"Coordinates\" -> {\[Ellipsis]}."|>,
  (* SpringNetwork: textos de "Steps", en el orden de la ayudantía *)
  "SpringNetwork:natural" -> <|
    "Spanish" -> "Supuesto: en el equilibrio todos los resortes están en su largo natural (sin tensión previa). A primer orden, un resorte de la masa j a la masa i se estira δl = n\[CenterDot](r_i \[Minus] r_j), con n el vector unitario de j a i y r los desplazamientos.",
    "English" -> "Assumption: at equilibrium every spring is at its natural length (no pretension). To first order, a spring from mass j to mass i stretches by δl = n\[CenterDot](r_i \[Minus] r_j), with n the unit vector from j to i and r the displacements."|>,
  "SpringNetwork:table" -> <|
    "Spanish" -> "Tabla de resortes: dirección n = (R_i \[Minus] R_j)/|R_i \[Minus] R_j| en el equilibrio y estiramiento δl = c\[CenterDot]q de cada resorte. Un resorte a una pared se estira δl = n\[CenterDot]r_i.",
    "English" -> "Spring table: direction n = (R_i \[Minus] R_j)/|R_i \[Minus] R_j| at equilibrium and stretch δl = c\[CenterDot]q of each spring. A spring to a wall stretches by δl = n\[CenterDot]r_i."|>,
  "SpringNetwork:mass" -> <|
    "Spanish" -> "Matriz de masas: diagonal, con la masa de cada partícula en cada una de sus coordenadas.",
    "English" -> "Mass matrix: diagonal, with the mass of each particle on each of its coordinates."|>,
  "SpringNetwork:stiffness" -> <|
    "Spanish" -> "Matriz de constantes elásticas: la energía potencial es \[CapitalSigma] \.bd k δl\.b2 = \.bd q\[CenterDot]Kmat\[CenterDot]q, así que Kmat = \[CapitalSigma] k c c\[Transpose], sumando sobre los resortes.",
    "English" -> "Stiffness matrix: the potential energy is \[CapitalSigma] \.bd k δl\.b2 = \.bd q\[CenterDot]Kmat\[CenterDot]q, so Kmat = \[CapitalSigma] k c c\[Transpose], summing over the springs."|>,
  "SpringNetwork:spring" -> <|"Spanish" -> "Resorte", "English" -> "Spring"|>,
  "SpringNetwork:direction" -> <|"Spanish" -> "Dirección n", "English" -> "Direction n"|>,
  "SpringNetwork:stretch" -> <|"Spanish" -> "Estiramiento δl", "English" -> "Stretch δl"|>,
  "SpringNetwork:constant" -> <|"Spanish" -> "Constante", "English" -> "Constant"|>,
  "SpringNetwork:wall" -> <|"Spanish" -> "pared", "English" -> "wall"|>,
  "SmallOscillations::args" -> <|
    "Spanish" -> "SmallOscillations se llama con cuatro argumentos: SmallOscillations[L, {q1, q2, \[Ellipsis]}, t, {q10, q20, \[Ellipsis]}], con el lagrangiano escrito con q1[t], q1'[t], \[Ellipsis] y el punto de equilibrio.",
    "English" -> "SmallOscillations takes four arguments: SmallOscillations[L, {q1, q2, \[Ellipsis]}, t, {q10, q20, \[Ellipsis]}], with the Lagrangian written with q1[t], q1'[t], \[Ellipsis] and the equilibrium point."|>,
  "SmallOscillations::time" -> <|
    "Spanish" -> "SmallOscillations requiere un lagrangiano autónomo: solo puede depender de las coordenadas `1` evaluadas en `2` y de sus primeras derivadas, sin `2` explícito ni derivadas de orden superior.",
    "English" -> "SmallOscillations requires an autonomous Lagrangian: it may depend only on the coordinates `1` evaluated at `2` and on their first derivatives, with no explicit `2` and no higher derivatives."|>,
  "SmallOscillations::noteq" -> <|
    "Spanish" -> "No se pudo comprobar que `1` = `2` sea un equilibrio: \[PartialD]U/\[PartialD]q en ese punto se simplifica a `3`, no a 0. Revisa el punto o entrega con Assumptions las suposiciones que permiten comprobarlo.",
    "English" -> "Could not verify that `1` = `2` is an equilibrium: \[PartialD]U/\[PartialD]q at that point simplifies to `3`, not 0. Check the point, or give with Assumptions the assumptions that make it verifiable."|>,
  "SmallOscillations::mass" -> <|
    "Spanish" -> "La matriz de masas en el equilibrio es singular (determinante 0): `1`. Alguna coordenada, o combinación de coordenadas, no tiene término cinético, y no hay oscilaciones que describir.",
    "English" -> "The mass matrix at equilibrium is singular (determinant 0): `1`. Some coordinate, or combination of coordinates, has no kinetic term, and there are no oscillations to describe."|>,
  (* SmallOscillations: textos de "Steps", en el orden en que se haría a mano *)
  "SmallOscillations:potential" -> <|
    "Spanish" -> "Energía potencial: U = \[Minus]L con todas las velocidades en cero.",
    "English" -> "Potential energy: U = \[Minus]L with all velocities set to zero."|>,
  "SmallOscillations:kinetic" -> <|
    "Spanish" -> "Energía cinética: T = L + U.",
    "English" -> "Kinetic energy: T = L + U."|>,
  "SmallOscillations:equilibrium" -> <|
    "Spanish" -> "Comprobación del equilibrio: todas las derivadas \[PartialD]U/\[PartialD]q_\[Mu] se anulan en el punto dado.",
    "English" -> "Equilibrium check: every derivative \[PartialD]U/\[PartialD]q_\[Mu] vanishes at the given point."|>,
  "SmallOscillations:at" -> <|"Spanish" -> "en", "English" -> "at"|>,
  "SmallOscillations:mass" -> <|
    "Spanish" -> "Matriz de masas: Mmat_\[Mu]\[Nu] = \[PartialD]\.b2T/\[PartialD]q\:0307_\[Mu]\[PartialD]q\:0307_\[Nu], evaluada en el equilibrio con velocidades cero.",
    "English" -> "Mass matrix: Mmat_\[Mu]\[Nu] = \[PartialD]\.b2T/\[PartialD]q\:0307_\[Mu]\[PartialD]q\:0307_\[Nu], evaluated at equilibrium with zero velocities."|>,
  "SmallOscillations:stiffness" -> <|
    "Spanish" -> "Matriz de constantes elásticas: Kmat_\[Mu]\[Nu] = \[PartialD]\.b2U/\[PartialD]q_\[Mu]\[PartialD]q_\[Nu], evaluada en el equilibrio.",
    "English" -> "Stiffness matrix: Kmat_\[Mu]\[Nu] = \[PartialD]\.b2U/\[PartialD]q_\[Mu]\[PartialD]q_\[Nu], evaluated at equilibrium."|>,
  "SmallOscillations:lagrangian" -> <|
    "Spanish" -> "Lagrangiano de pequeñas oscilaciones, con las coordenadas `coords` medidas desde el equilibrio: desde aquí son desviaciones respecto al equilibrio, aunque conserven su nombre.",
    "English" -> "Small-oscillation Lagrangian, with the coordinates `coords` measured from equilibrium: from here on they are deviations from equilibrium, even though they keep their names."|>,
  "SmallOscillations:lagrangian1" -> <|
    "Spanish" -> "Lagrangiano de pequeñas oscilaciones, con la coordenada `coords` medida desde el equilibrio: desde aquí es la desviación respecto al equilibrio, aunque conserve su nombre.",
    "English" -> "Small-oscillation Lagrangian, with the coordinate `coords` measured from equilibrium: from here on it is the deviation from equilibrium, even though it keeps its name."|>,
  "NormalModes:and" -> <|"Spanish" -> "y", "English" -> "and"|>,
  "NormalModes::args" -> <|
    "Spanish" -> "NormalModes se llama con un sistema de SpringNetwork o SmallOscillations, NormalModes[sistema], o con las dos matrices, NormalModes[Mmat, Kmat].",
    "English" -> "NormalModes takes a system from SpringNetwork or SmallOscillations, NormalModes[system], or the two matrices, NormalModes[Mmat, Kmat]."|>,
  "NormalModes::symbolic" -> <|
    "Spanish" -> "No se encontraron en 30 s los valores propios en forma cerrada: el sistema es grande o tiene demasiados parámetros simbólicos. Da valores numéricos a los parámetros (por ejemplo con /. {k -> 1, m -> 1}) y vuelve a llamar a NormalModes.",
    "English" -> "The eigenvalues could not be found in closed form within 30 s: the system is large or has too many symbolic parameters. Give numeric values to the parameters (for example with /. {k -> 1, m -> 1}) and call NormalModes again."|>,
  "NormalModes::basis" -> <|
    "Spanish" -> "La opción \"Basis\" debe ser una lista de `1` vectores, cada uno con `1` componentes (una por coordenada).",
    "English" -> "The \"Basis\" option must be a list of `1` vectors, each with `1` components (one per coordinate)."|>,
  "NormalModes::noteigen" -> <|
    "Spanish" -> "El vector `1` de \"Basis\", `2`, no es un modo: Kmat\[CenterDot]v no es igual a \[Omega]\.b2 Mmat\[CenterDot]v para ningún \[Omega]\.b2. Cada vector de la base tiene que resolver (Kmat \[Minus] \[Omega]\.b2 Mmat) v = 0.",
    "English" -> "Vector `1` of \"Basis\", `2`, is not a mode: Kmat\[CenterDot]v is not equal to \[Omega]\.b2 Mmat\[CenterDot]v for any \[Omega]\.b2. Each basis vector must solve (Kmat \[Minus] \[Omega]\.b2 Mmat) v = 0."|>,
  "NormalModes::rank" -> <|
    "Spanish" -> "Los vectores de \"Basis\" no son linealmente independientes: alguno es combinación de los otros. Hacen falta `1` modos independientes.",
    "English" -> "The \"Basis\" vectors are not linearly independent: one of them is a combination of the others. `1` independent modes are needed."|>,
  (* NormalModes: textos de "Steps", en el orden en que se haría a mano *)
  "NormalModes:secular" -> <|
    "Spanish" -> "Ecuación secular: los modos resuelven (Kmat \[Minus] \[Omega]\.b2 Mmat) A = 0, que tiene solución no nula solo si det(Kmat \[Minus] \[Lambda] Mmat) = 0, con \[Lambda] = \[Omega]\.b2. El determinante, factorizado:",
    "English" -> "Secular equation: the modes solve (Kmat \[Minus] \[Omega]\.b2 Mmat) A = 0, which has a nonzero solution only if det(Kmat \[Minus] \[Lambda] Mmat) = 0, with \[Lambda] = \[Omega]\.b2. The determinant, factored:"|>,
  "NormalModes:roots" -> <|
    "Spanish" -> "Raíces de la ecuación secular: los valores de \[Omega]\.b2, cada uno con su multiplicidad (cuántos modos independientes tienen esa frecuencia).",
    "English" -> "Roots of the secular equation: the values of \[Omega]\.b2, each with its multiplicity (how many independent modes have that frequency)."|>,
  "NormalModes:basis" -> <|
    "Spanish" -> "Para cada \[Omega]\.b2, el modo resuelve (Kmat \[Minus] \[Omega]\.b2 Mmat) A = 0 y se normaliza con A\[CenterDot]Mmat\[CenterDot]A = 1.",
    "English" -> "For each \[Omega]\.b2, the mode solves (Kmat \[Minus] \[Omega]\.b2 Mmat) A = 0 and is normalized with A\[CenterDot]Mmat\[CenterDot]A = 1."|>,
  "NormalModes:basisDegenerate" -> <|
    "Spanish" -> "Para cada \[Omega]\.b2, una base del subespacio de soluciones de (Kmat \[Minus] \[Omega]\.b2 Mmat) A = 0, ortonormalizada con el producto u\[CenterDot]Mmat\[CenterDot]v. En un subespacio degenerado la base es una elección: cualquier combinación de modos de igual frecuencia es también un modo (la opción \"Basis\" permite elegir otra).",
    "English" -> "For each \[Omega]\.b2, a basis of the solution subspace of (Kmat \[Minus] \[Omega]\.b2 Mmat) A = 0, orthonormalized with the product u\[CenterDot]Mmat\[CenterDot]v. In a degenerate subspace the basis is a choice: any combination of modes with the same frequency is also a mode (the \"Basis\" option lets you choose another one)."|>,
  "NormalModes:basisGiven" -> <|
    "Spanish" -> "Base elegida (opción \"Basis\"): cada vector v es un modo, con \[Omega]\.b2 = v\[CenterDot]Kmat\[CenterDot]v / v\[CenterDot]Mmat\[CenterDot]v. Dentro de cada subespacio se ortonormaliza con el producto u\[CenterDot]Mmat\[CenterDot]v en el orden dado (Gram-Schmidt): si los vectores ya son Mmat-ortogonales, solo se normalizan. Los modos quedan en el orden de la base.",
    "English" -> "Chosen basis (\"Basis\" option): each vector v is a mode, with \[Omega]\.b2 = v\[CenterDot]Kmat\[CenterDot]v / v\[CenterDot]Mmat\[CenterDot]v. Within each subspace it is orthonormalized with the product u\[CenterDot]Mmat\[CenterDot]v in the given order (Gram-Schmidt): if the vectors are already Mmat-orthogonal, they are only normalized. The modes keep the order of the basis."|>,
  "NormalModes:zero" -> <|
    "Spanish" -> "Modos nulos (\[Omega]\.b2 = 0): `zero`. Son movimientos que no cambian la energía potencial a segundo orden; en una red de resortes, los que no estiran ningún resorte, como traslaciones y rotaciones rígidas. El rango de Kmat es el número de coordenadas, `n`, menos los modos nulos.",
    "English" -> "Zero modes (\[Omega]\.b2 = 0): `zero`. They are motions that do not change the potential energy to second order; in a spring network, those that stretch no spring, such as rigid translations and rotations. The rank of Kmat is the number of coordinates, `n`, minus the zero modes."|>,
  "NormalModes:check" -> <|
    "Spanish" -> "Comprobación: con los modos como filas de A, A\[CenterDot]Mmat\[CenterDot]A\[Transpose] es la identidad, así que los modos son Mmat-ortonormales.",
    "English" -> "Check: with the modes as rows of A, A\[CenterDot]Mmat\[CenterDot]A\[Transpose] is the identity, so the modes are Mmat-orthonormal."|>,
  "NormalModes:omega2" -> <|"Spanish" -> "\[Omega]\.b2", "English" -> "\[Omega]\.b2"|>,
  "NormalModes:multiplicity" -> <|"Spanish" -> "Multiplicidad", "English" -> "Multiplicity"|>,
  "NormalModes:modes" -> <|"Spanish" -> "Modos", "English" -> "Modes"|>,
  "NormalModes:rank" -> <|"Spanish" -> "rango", "English" -> "rank"|>,
  "NormalCoordinates::args" -> <|
    "Spanish" -> "NormalCoordinates se llama con el resultado de NormalModes: NormalCoordinates[modos], o NormalCoordinates[modos, {Q1, Q2, \[Ellipsis]}] para elegir los nombres.",
    "English" -> "NormalCoordinates takes a NormalModes result: NormalCoordinates[modes], or NormalCoordinates[modes, {Q1, Q2, \[Ellipsis]}] to choose the names."|>,
  "ModeResponse::args" -> <|
    "Spanish" -> "ModeResponse se llama con el resultado de NormalModes y las condiciones iniciales: ModeResponse[modos, q0, v0], o ModeResponse[modos, q0, v0, t] para elegir el símbolo del tiempo.",
    "English" -> "ModeResponse takes a NormalModes result and the initial conditions: ModeResponse[modes, q0, v0], or ModeResponse[modes, q0, v0, t] to choose the time symbol."|>
|>];

(* --- SpringNetwork: especificación en docs/specs/NormalModes.md --- *)

Options[SpringNetwork] = {"Anchors" -> {}, "Coordinates" -> Automatic, Assumptions -> Automatic};

(* Posiciones como lista de puntos de dimensión d ∈ {1, 2, 3}; en 1D se aceptan números
   sueltos. Devuelve {puntos, d} o $Failed *)
networkPositions[pos_List /; pos =!= {} && FreeQ[pos, _List, {1}]] := {List /@ pos, 1};
networkPositions[pos : {__List}] := With[{d = Length[First[pos]]},
  If[MemberQ[{1, 2, 3}, d] && AllTrue[pos, Length[#] === d && FreeQ[#, _List, {1}] &],
    {pos, d}, $Failed]];
networkPositions[_] := $Failed;

(* Punto de un anclaje: en 1D también un número suelto *)
anchorPoint[p_List, d_] := If[Length[p] === d && FreeQ[p, _List, {1}], p, $Failed];
anchorPoint[p_, 1] := {p};
anchorPoint[_, _] := $Failed;

(* Anclaje {i, punto, k}: una masa de la red y un punto fijo distinto de su posición *)
anchorQ[a_, pos_, d_, asm_] := MatchQ[a, {i_Integer, _, _} /; 1 <= i <= Length[pos]] &&
  With[{p = anchorPoint[a[[2]], d]},
    p =!= $Failed && !zeroQ[(pos[[a[[1]]]] - p) . (pos[[a[[1]]]] - p), asm]];

(* Nombres por defecto x1, y1, z1, x2, …: símbolos del contexto vigente al llamar la función,
   como si los hubiera escrito el usuario (precisión 1 de la v1.1) *)
defaultCoordinates[n_, d_] := ToExpression[
  Flatten[Table[l <> ToString[i], {i, n}, {l, Take[{"x", "y", "z"}, d]}]], InputForm, Hold];

(* Las coordenadas son símbolos distintos, sin valor, que no aparecen en los datos de la red *)
coordinatesQ[held_List, nn_, data_] :=
  Length[held] === nn && AllTrue[held, MatchQ[#, Hold[_Symbol]] &] &&
    DuplicateFreeQ[held] &&
    AllTrue[held, Function[h, (OwnValues @@ h) === {} &&
      !MemberQ[Attributes @@ h, Protected] && FreeQ[data, First[h]]]];

(* Vector c del estiramiento δl = c·q: +n en las coordenadas de la masa i y −n en las de j
   (j = None para un anclaje) *)
stretchVector[nn_, d_, i_, j_, nvec_] := Module[{c = ConstantArray[0, nn]},
  c[[d (i - 1) + 1 ;; d i]] = nvec;
  If[j =!= None, c[[d (j - 1) + 1 ;; d j]] = -nvec];
  c];

unitVector[r_, asm_] := Simplify[r/Sqrt[r . r], asm];

SpringNetwork[pos0_List, springs_List, masses0_, opts : OptionsPattern[]] /; !OptionQ[masses0] :=
  Module[{pp, pos, d, n, nn, bad, masses, anchors0, anchors, asm, held, coords, rows, anchorRows,
      kmat, mmat, steps},

    (* Posiciones: dimensión común y sin dos masas en el mismo punto *)
    pp = networkPositions[pos0];
    If[pp === $Failed, cmMessage[SpringNetwork, "positions"]; Return[$Failed]];
    {pos, d} = pp;
    n = Length[pos]; nn = n d;
    anchors0 = OptionValue["Anchors"];
    asm = OptionValue[Assumptions];
    If[asm === Automatic,
      asm = positiveAssumptions[{pos0, springs, masses0, anchors0}, {}]];
    If[AnyTrue[Subsets[Range[n], {2}],
        zeroQ[(pos[[#[[1]]]] - pos[[#[[2]]]]) . (pos[[#[[1]]]] - pos[[#[[2]]]]), asm] &],
      cmMessage[SpringNetwork, "positions"]; Return[$Failed]];

    (* Resortes {j, i, k}: dos masas distintas de la red *)
    bad = SelectFirst[springs,
      !MatchQ[#, {j_Integer, i_Integer, _} /; 1 <= j <= n && 1 <= i <= n && j != i] &, None];
    If[bad =!= None, cmMessage[SpringNetwork, "springs", n, bad]; Return[$Failed]];

    (* Masas: un valor para todas o una lista de n *)
    masses = If[ListQ[masses0], masses0, ConstantArray[masses0, n]];
    If[Length[masses] =!= n,
      cmMessage[SpringNetwork, "masses", n, Length[masses]]; Return[$Failed]];

    (* Anclajes {i, punto, k}: una masa de la red y un punto distinto de su posición *)
    If[!ListQ[anchors0], cmMessage[SpringNetwork, "anchors", n, d, anchors0]; Return[$Failed]];
    bad = SelectFirst[anchors0, !anchorQ[#, pos, d, asm] &, None];
    If[bad =!= None, cmMessage[SpringNetwork, "anchors", n, d, bad]; Return[$Failed]];
    anchors = {#[[1]], anchorPoint[#[[2]], d], #[[3]]} & /@ anchors0;

    (* Coordenadas: las de la opción o x1, y1, … *)
    held = Replace[OptionValue["Coordinates"],
      {Automatic :> defaultCoordinates[n, d], l_List :> (Hold /@ l)}];
    If[!ListQ[held] || !coordinatesQ[held, nn, {pos0, springs, masses0, anchors0}],
      cmMessage[SpringNetwork, "coords", nn,
        If[ListQ[held], Replace[held, Hold[c_] :> HoldForm[c], {1}], held]]; Return[$Failed]];
    coords = ReleaseHold[held];

    (* Cada resorte: dirección n de j a i, vector c y estiramiento δl = c·q *)
    rows = Function[{j, i, k}, With[{nvec = unitVector[pos[[i]] - pos[[j]], asm]},
        With[{c = stretchVector[nn, d, i, j, nvec]},
          <|"Spring" -> {j, i}, "Direction" -> nvec, "Stretch" -> c . coords, "Constant" -> k,
            "c" -> c|>]]] @@@ springs;
    anchorRows = Function[{i, p, k}, With[{nvec = unitVector[pos[[i]] - p, asm]},
        With[{c = stretchVector[nn, d, i, None, nvec]},
          <|"Anchor" -> {i, p}, "Direction" -> nvec, "Stretch" -> c . coords, "Constant" -> k,
            "c" -> c|>]]] @@@ anchors;

    kmat = If[rows === {} && anchorRows === {}, ConstantArray[0, {nn, nn}],
      Simplify[Total[(#["Constant"] Outer[Times, #["c"], #["c"]]) & /@ Join[rows, anchorRows]],
        asm]];
    mmat = DiagonalMatrix[Flatten[ConstantArray[#, d] & /@ masses]];

    steps = {
      {"natural", HoldForm["\[Delta]l" == CenterDot["n", Subscript["r", "i"] - Subscript["r", "j"]]]},
      {"table", springTableGrid[rows, anchorRows]},
      {"mass", "Mmat" == MatrixForm[mmat]},
      {"stiffness", "Kmat" == MatrixForm[kmat]}};
    steps = <|"Description" -> tr["SpringNetwork:" <> #[[1]]], "Expression" -> #[[2]]|> & /@
      steps;

    <|"Coordinates" -> coords, "Mmat" -> mmat, "Kmat" -> kmat, "Assumptions" -> asm,
      "Dimension" -> d, "Positions" -> pos, "Springs" -> springs, "Anchors" -> anchors,
      "Masses" -> masses, "SpringTable" -> (KeyDrop[#, "c"] & /@ rows), "Steps" -> steps|>
  ];

(* Tabla de resortes para "Steps": resorte, dirección, estiramiento y constante; los anclajes
   al final, con la pared en vez de la segunda masa *)
springTableGrid[rows_, anchorRows_] := Grid[
  Join[
    {tableText /@ tr /@ {"SpringNetwork:spring", "SpringNetwork:direction",
      "SpringNetwork:stretch", "SpringNetwork:constant"}},
    {tableText[StringRiffle[#["Spring"], "\[Dash]"]], #["Direction"], #["Stretch"],
      #["Constant"]} & /@ rows,
    {tableText[ToString[First[#["Anchor"]]] <> "\[Dash]" <> tr["SpringNetwork:wall"]],
      #["Direction"], #["Stretch"], #["Constant"]} & /@ anchorRows],
  Alignment -> Left, Spacings -> {2, 0.6},
  Dividers -> {None, {2 -> GrayLevel[0.8]}}];

(* Encabezados y nombres de resortes como texto, no como fórmula (letra de texto, sin comillas) *)
tableText[s_String] := TextCell[s, "Text",
  FontSize -> FirstCase[Lookup[$CMPlotStyle, LabelStyle, {}], (FontSize -> f_) :> f, 12, Infinity]];

SpringNetwork[___] := (cmMessage[SpringNetwork, "args"]; $Failed);

(* --- SmallOscillations: especificación en docs/specs/NormalModes.md --- *)

Options[SmallOscillations] = {Assumptions -> Automatic};

SmallOscillations[L_, qlist : {__Symbol}, t_Symbol, q0_List, opts : OptionsPattern[]] /;
    Length[q0] === Length[qlist] && !MemberQ[qlist, t] :=
  Module[{nq = Length[qlist], qs, qd, toLocal, back, Lr, asm, U, T, grad, eqRules, mmat, kmat,
      steps, held},

    (* Como en un grado de libertad: q_μ[t] y q_μ'[t] pasan a símbolos locales; si queda t,
       el lagrangiano no es autónomo *)
    qs = Table[Module[{q}, q], {nq}]; qd = Table[Module[{v}, v], {nq}];
    toLocal = Join[Thread[(Derivative[1][#][t] & /@ qlist) -> qd], Thread[(#[t] & /@ qlist) -> qs]];
    back = Join[Thread[qs -> (#[t] & /@ qlist)], Thread[qd -> (Derivative[1][#][t] & /@ qlist)]];
    Lr = L /. toLocal;
    If[!FreeQ[Lr, t], cmMessage[SmallOscillations, "time", qlist, t]; Return[$Failed]];

    asm = OptionValue[Assumptions];
    If[asm === Automatic, asm = positiveAssumptions[{L, q0}, Join[qlist, {t}]]];

    U = -Lr /. Thread[qd -> 0];
    T = Lr + U;
    eqRules = Join[Thread[qs -> q0], Thread[qd -> 0]];

    (* Equilibrio: ∂U/∂q_μ = 0 en el punto, con zeroQ o con FullSimplify si Simplify no basta *)
    grad = D[U, {qs}] /. eqRules;
    If[!AllTrue[grad, zeroQ[#, asm] || zeroQ[FullSimplify[#, asm], asm] &],
      cmMessage[SmallOscillations, "noteq", qlist, q0, Simplify[grad, asm]]; Return[$Failed]];

    mmat = Simplify[D[T, {qd, 2}] /. eqRules, asm];
    kmat = Simplify[D[U, {qs, 2}] /. eqRules, asm];
    If[zeroQ[Det[mmat], asm],
      cmMessage[SmallOscillations, "mass", mmat]; Return[$Failed]];

    (* Lagrangiano de pequeñas oscilaciones, con las desviaciones respecto al equilibrio;
       retenido para que no se expanda *)
    held = With[{v = Derivative[1][#][t] & /@ qlist, x = #[t] & /@ qlist},
      With[{tq = Expand[v . mmat . v], uq = Expand[x . kmat . x]}, HoldForm[1/2 tq - 1/2 uq]]];
    steps = {
      {"potential", "U" == (U /. back)},
      {"kinetic", "T" == Simplify[T /. back, asm]},
      {"equilibrium", Row[{"\[PartialD]U/\[PartialD]q" == Simplify[grad, asm],
        "  " <> tr["SmallOscillations:at"] <> "  ", qlist == q0}]},
      {"mass", "Mmat" == MatrixForm[mmat]},
      {"stiffness", "Kmat" == MatrixForm[kmat]},
      {If[nq == 1, "lagrangian1", "lagrangian"], "L" == held}};
    steps = <|"Description" -> tr["SmallOscillations:" <> #[[1]], <|"coords" -> namesText[qlist]|>],
      "Expression" -> #[[2]]|> & /@ steps;

    <|"Coordinates" -> qlist, "Mmat" -> mmat, "Kmat" -> kmat, "Assumptions" -> asm,
      "Equilibrium" -> q0, "Steps" -> steps|>
  ];

(* Nombres de símbolos como texto: «th1», «th1 y th2», «x, y y z» *)
namesText[{s_}] := SymbolName[s];
namesText[l_List] := StringRiffle[SymbolName /@ Most[l], ", "] <> " " <> tr["NormalModes:and"] <>
  " " <> SymbolName[Last[l]];

SmallOscillations[___] := (cmMessage[SmallOscillations, "args"]; $Failed);

(* --- NormalModes: especificación en docs/specs/NormalModes.md --- *)

Options[NormalModes] = {"Basis" -> Automatic};

(* Un sistema: Mmat y Kmat cuadradas del mismo tamaño, y una coordenada por fila *)
systemQ[sys_Association] := With[{mm = Lookup[sys, "Mmat"], kk = Lookup[sys, "Kmat"]},
  SquareMatrixQ[mm] && SquareMatrixQ[kk] && Length[mm] === Length[kk] &&
    Length[Lookup[sys, "Coordinates", {}]] === Length[mm]];
systemQ[_] := False;

(* Matrices numéricas inexactas: se usa Eigensystem y se agrupan los ω² cercanos *)
inexactQ[mats_] := AllTrue[Flatten[mats], NumericQ] && !FreeQ[mats, _Real];

(* Simplify y, si termina en 2 s, FullSimplify: deja las raíces anidadas en forma legible,
   como Sqrt[2 - Sqrt[2]], sin arriesgar tiempos largos en sistemas grandes *)
niceSimplify[e_, asm_] := With[{s = Simplify[e, asm]},
  TimeConstrained[FullSimplify[s, asm], 2, s]];

(* Gram-Schmidt en el orden dado, con el producto u·Mmat·v *)
massOrthonormalize[vecs_List, mm_, asm_] := Module[{basis = {}, u},
  Do[u = If[basis === {}, v, v - Total[(v . mm . #) # & /@ basis]];
    u = niceSimplify[u, asm];
    AppendTo[basis, niceSimplify[u/Sqrt[niceSimplify[u . mm . u, asm]], asm]],
    {v, vecs}];
  basis];

(* Subespacios exactos: lista de {ω², {modos}} con los modos Mmat-ortonormales, o $Failed si
   Eigenvalues no da forma cerrada en 30 s *)
exactSubspaces[mm_, kk_, asm_] := Module[{vals, distinct = {}, mult = {}, pos, order},
  vals = TimeConstrained[Eigenvalues[{kk, mm}], 30, $TimedOut];
  If[vals === $TimedOut || (!FreeQ[vals, _Root] && freeSymbols[{mm, kk}, {}] =!= {}),
    Return[$Failed]];
  (* ω² distintos con su multiplicidad, en el orden en que salen *)
  Do[pos = FirstPosition[distinct, d_ /; zeroQ[d - v, asm], None, {1}];
    If[pos === None, AppendTo[distinct, v]; AppendTo[mult, 1], mult[[First[pos]]] += 1],
    {v, niceSimplify[vals, asm]}];
  (* De menor a mayor solo si las suposiciones deciden todas las comparaciones *)
  order = Catch[Ordering[distinct, All, Function[{a, b},
    Replace[Simplify[a <= b, asm], {True -> True, False -> False, _ :> Throw[None]}]]]];
  If[order =!= None, distinct = distinct[[order]]; mult = mult[[order]]];
  MapThread[Function[{w2, g}, With[{ns = NullSpace[Simplify[kk - w2 mm, asm]]},
      If[Length[ns] =!= g, Return[$Failed, Module]];
      {w2, massOrthonormalize[ns, mm, asm]}]],
    {distinct, mult}]];

(* Subespacios numéricos: ω² ordenados; los que difieren en menos de 10^-8 (relativo al mayor
   |ω²|) forman un subespacio degenerado, y los que quedan bajo esa tolerancia son nulos *)
numericSubspaces[mm_, kk_] := Module[{vals, vecs, ord, tol, groups},
  {vals, vecs} = Chop[Eigensystem[{kk, mm}]];
  ord = Ordering[vals];
  tol = 10^-8 Max[1, Abs[vals]];
  groups = Split[Transpose[{vals[[ord]], vecs[[ord]]}], Abs[#1[[1]] - #2[[1]]] <= tol &];
  {If[Abs[#] <= tol, 0, #] &[Mean[#[[All, 1]]]],
    Orthogonalize[#[[All, 2]], #1 . mm . #2 &]} & /@ groups];

(* Opción "Basis": lista de {ω², {modos}, posiciones}, con los ω² en el orden en que aparecen
   en la base y cada subespacio ortonormalizado en el orden dado; o $Failed con su mensaje *)
basisSubspaces[basis_, mm_, kk_, asm_] :=
  Module[{nn = Length[mm], numeric, w2s, bad, tol, sameQ, distinct = {}, pos, groups = {}},
    If[!MatrixQ[basis] || Dimensions[basis] =!= {nn, nn},
      cmMessage[NormalModes, "basis", nn]; Return[$Failed]];
    numeric = inexactQ[{mm, kk, basis}];
    (* ω² de cada vector con el cociente de Rayleigh; el vector es un modo si Kmat·v = ω² Mmat·v *)
    w2s = Function[v, With[{den = niceSimplify[v . mm . v, asm]},
        If[zeroQ[den, asm], $Failed, niceSimplify[v . kk . v/den, asm]]]] /@ basis;
    bad = SelectFirst[Range[nn], w2s[[#]] === $Failed ||
        With[{r = kk . basis[[#]] - w2s[[#]] mm . basis[[#]]},
          If[numeric, Norm[r] > 10^-8 Max[1, Norm[kk . basis[[#]]]],
            !AllTrue[r, zeroQ[#, asm] &]]] &, None];
    If[bad =!= None, cmMessage[NormalModes, "noteigen", bad, basis[[bad]]]; Return[$Failed]];
    If[If[numeric, MatrixRank[basis] < nn, zeroQ[Det[basis], asm]],
      cmMessage[NormalModes, "rank", nn]; Return[$Failed]];
    (* Mismos ω² con zeroQ, o a menos de 10^-8 relativo al mayor |ω²| si son inexactos *)
    tol = 10^-8 Max[1, Abs[w2s]];
    sameQ[a_, b_] := If[numeric, Abs[a - b] <= tol, zeroQ[a - b, asm]];
    Do[pos = FirstPosition[distinct, d_ /; sameQ[d, w2s[[i]]], None, {1}];
      If[pos === None, AppendTo[distinct, w2s[[i]]]; AppendTo[groups, {i}],
        AppendTo[groups[[First[pos]]], i]],
      {i, nn}];
    If[numeric, distinct = If[Abs[#] <= tol, 0, #] & /@ distinct];
    MapThread[{#1, massOrthonormalize[basis[[#2]], mm, asm], #2} &, {distinct, groups}]];

NormalModes[sys_Association?systemQ, opts : OptionsPattern[]] :=
  Module[{mm, kk, asm, nn, lam = \[FormalLambda], basis, det, subspaces, omega2, modes, deg, zero,
      steps},
    mm = sys["Mmat"]; kk = sys["Kmat"]; nn = Length[mm];
    asm = Lookup[sys, "Assumptions", positiveAssumptions[{mm, kk}, {}]];
    basis = OptionValue["Basis"];

    det = Factor[Simplify[Det[kk - lam mm], asm]];
    (* subspaces: lista de {ω², {modos}, posiciones de esos modos en "Modes"} *)
    If[basis =!= Automatic,
      subspaces = basisSubspaces[basis, mm, kk, asm];
      If[subspaces === $Failed, Return[$Failed]],
      subspaces = If[inexactQ[{mm, kk}], numericSubspaces[mm, kk], exactSubspaces[mm, kk, asm]];
      If[subspaces === $Failed, cmMessage[NormalModes, "symbolic"]; Return[$Failed]];
      subspaces = MapThread[Append, {subspaces,
        TakeList[Range[nn], Length /@ subspaces[[All, 2]]]}]];

    omega2 = modes = ConstantArray[0, nn];
    Do[omega2[[s[[3]]]] = s[[1]]; modes[[s[[3]]]] = s[[2]], {s, subspaces}];
    deg = <|"Omega2" -> #[[1]], "Multiplicity" -> Length[#[[2]]], "Indices" -> #[[3]]|> & /@
      subspaces;
    zero = Count[omega2, w_ /; zeroQ[w, asm]];

    steps = normalModesSteps[mm, det, subspaces, deg, modes, zero, nn, asm, basis =!= Automatic];

    Join[KeyDrop[sys, "Steps"],
      <|"SecularDeterminant" -> det, "Omega2" -> omega2,
        "Frequencies" -> Simplify[Sqrt[omega2], asm], "Modes" -> modes, "Degeneracies" -> deg,
        "ZeroModes" -> zero, "Rank" -> nn - zero, "Steps" -> steps|>]
  ];

(* Atajo: las matrices directamente, con coordenadas \[FormalQ][1], …, \[FormalQ][N] *)
NormalModes[mm_?SquareMatrixQ, kk_?SquareMatrixQ, opts : OptionsPattern[]] /;
    Length[mm] === Length[kk] :=
  NormalModes[<|"Coordinates" -> Array[\[FormalQ], Length[mm]], "Mmat" -> mm, "Kmat" -> kk,
    "Assumptions" -> positiveAssumptions[{mm, kk}, {}]|>, opts];

(* "Steps" de NormalModes, en el orden en que se haría a mano *)
normalModesSteps[mm_, det_, subspaces_, deg_, modes_, zero_, nn_, asm_, given_] :=
 Module[{steps},
  steps = {
    {"secular", "det(Kmat \[Minus] \[Lambda] Mmat)" == (det /. \[FormalLambda] -> "\[Lambda]")},
    {"roots", Grid[Prepend[{#["Omega2"], #["Multiplicity"]} & /@ deg,
        tableText /@ tr /@ {"NormalModes:omega2", "NormalModes:multiplicity"}],
      Alignment -> Left, Spacings -> {3, 0.6}, Dividers -> {None, {2 -> GrayLevel[0.8]}}]},
    {Which[given, "basisGiven", Max[Length /@ subspaces[[All, 2]]] > 1, "basisDegenerate",
        True, "basis"],
      Grid[Prepend[{#[[1]], Column[#[[2]]]} & /@ subspaces,
        tableText /@ tr /@ {"NormalModes:omega2", "NormalModes:modes"}],
      Alignment -> {Left, Center}, Spacings -> {3, 0.8}, Dividers -> {None, {2 -> GrayLevel[0.8]}}]},
    {"zero", Row[{tr["NormalModes:rank"], "(Kmat) = ", nn, " \[Minus] ", zero, " = ", nn - zero}]},
    {"check", "A\[CenterDot]Mmat\[CenterDot]A\[Transpose]" ==
      MatrixForm[niceSimplify[modes . mm . Transpose[modes], asm]]}};
  <|"Description" -> tr["NormalModes:" <> #[[1]], <|"zero" -> zero, "n" -> nn|>],
    "Expression" -> #[[2]]|> & /@ steps];

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
