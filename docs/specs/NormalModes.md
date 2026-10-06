# Especificación: modos normales en N dimensiones

Estado: aprobada para implementar. Versión 1 (6 de octubre de 2026).
Módulo nuevo: `CMToolkit/Kernel/NormalModes.wl` (se agrega al cargador después de Oscillations1D).
Referencia: Ayudantía 6, Problema 2 completo (cuatro masas y seis resortes), ecs. (35)–(93).
Versión del paquete al terminar: 0.2.0.

Va en **dos ramas**, cada una con su PR:

- Parte A, rama `feat/normal-modes`: cálculo. `SpringNetwork`, `SmallOscillations`,
  `NormalModes`, `NormalCoordinates`, `ModeResponse`.
- Parte B, rama `feat/normal-modes-plots`: visualización. `ModeGallery`, `AnimateMode`,
  `AnimateMotion`, `SpectrumPlot`, `EnergySharesChart`, notebook de ejemplo y versión 0.2.0.

Vale todo lo común de las especificaciones anteriores (bilingüe, `$texts`, `cmMessage`, `zeroQ`,
"Steps", límites de tiempo, precisiones de `Equilibria.md` v1.4 y reglas de gráficos de
`Motion1D.md`). Las funciones privadas de uso general que hoy están en `Oscillations1D.wl`
(`freeSymbols`, y lo que haga falta de suposiciones) se mueven a `Core.wl` en un primer commit,
sin cambiar comportamiento: los tests existentes deben pasar sin modificar ninguno.

## Idea general

Un **sistema** es una Association con las matrices de masas y de constantes elásticas en torno
a un equilibrio. Hay dos formas de construirlo, y todo lo demás trabaja sobre él:

    sistema = SpringNetwork[...]         (redes de masas y resortes, en 1, 2 o 3 dimensiones)
    sistema = SmallOscillations[...]     (cualquier lagrangiano de N coordenadas)

    modos = NormalModes[sistema]
    NormalCoordinates[modos]
    resp  = ModeResponse[modos, q0, v0]

El lagrangiano de pequeñas oscilaciones es L = ½ q̇·Mmat·q̇ − ½ q·Kmat·q, y los modos resuelven
(Kmat − ω² Mmat) A = 0.

Suposiciones: `Assumptions -> Automatic` significa que todos los parámetros simbólicos son reales
positivos, como en un grado de libertad. Se guardan en el sistema y las heredan las demás funciones.

---

# Parte A — rama `feat/normal-modes`

## SpringNetwork / RedDeResortes

    SpringNetwork[posiciones, resortes, masas]
    SpringNetwork[posiciones, resortes, masas, "Anchors" -> anclajes]

- `posiciones`: lista de las posiciones de equilibrio de las n masas; todas con la misma
  dimensión d ∈ {1, 2, 3}. Pueden ser simbólicas (por ejemplo {{0, 0}, {a, 0}, {a, a}, {0, a}}).
  En una dimensión se aceptan también números sueltos: {1, 2, 3}.
- `resortes`: lista de {j, i, k}: resorte de constante k entre las masas j e i (el mismo formato de
  la ayudantía; el vector del resorte va de j a i).
- `masas`: un valor (todas iguales) o una lista de n valores.
- `"Anchors"`: lista de {i, punto, k}: resorte de constante k entre la masa i y un punto fijo
  (una pared). Por defecto, ninguno.

Supone que todos los resortes están en su largo natural en el equilibrio (sin tensión previa).
"Steps" lo dice explícitamente; la tensión previa queda fuera de esta versión.

Coordenadas: los desplazamientos, en el orden {x1, y1, x2, y2, …} (con z en 3D; solo x en 1D).
Sus nombres se pueden cambiar con la opción `"Coordinates" -> lista de símbolos`.

Cálculo (el «camino 2» de la ayudantía): para cada resorte, el vector unitario
n = (R_i − R_j)/|R_i − R_j| y el estiramiento a primer orden δl = n·(r_i − r_j) = c·q;
Kmat = Σ k c cᵀ. Para un anclaje, δl = n·r_i. Mmat = diagonal con cada masa repetida d veces.

Devuelve el **sistema**:

| Clave | Contenido |
| --- | --- |
| "Coordinates" | los nombres de las N = n·d coordenadas |
| "Mmat", "Kmat" | matrices N×N (Kmat simplificada con las suposiciones) |
| "Assumptions" | suposiciones usadas |
| "Dimension", "Positions", "Springs", "Anchors", "Masses" | la geometría, para los gráficos |
| "SpringTable" | por resorte: <\|"Spring" -> {j, i}, "Direction" -> n, "Stretch" -> δl, "Constant" -> k\|> (la tabla de la p. 12) |
| "Steps" | supuesto de largo natural; tabla de resortes; Mmat; Kmat |

Validación: `args`; `positions` (dimensiones distintas, d fuera de 1–3 o dos masas en el mismo
punto); `springs` (índices fuera de rango, j = i, o formato incorrecto); `masses` (largo distinto
de n); `anchors`; `coords` (cantidad incorrecta o símbolos repetidos o con valor).

## SmallOscillations / PequenasOscilaciones

    SmallOscillations[L, {q1, q2, …}, t, {q10, q20, …}]

Para un lagrangiano cualquiera de N coordenadas (escrito con q1[t], q1'[t], …) y un punto de
equilibrio. Sirve cuando la matriz de masas no es diagonal (péndulo doble).

- U = −L con las velocidades en cero; T = L + U.
- Comprueba el equilibrio: ∂U/∂q_μ = 0 en el punto (con `zeroQ`); si no, `noteq`.
- Mmat_μν = ∂²T/∂q̇_μ∂q̇_ν y Kmat_μν = ∂²U/∂q_μ∂q_ν, evaluadas en el equilibrio con velocidades cero.
- Las coordenadas del sistema son las desviaciones respecto al equilibrio; conservan el nombre
  de las coordenadas originales.

Devuelve el sistema ("Coordinates", "Mmat", "Kmat", "Assumptions", "Equilibrium", "Steps"), sin
claves de geometría. Validación: `args`, `time` (t explícito), `noteq`, `mass` (Mmat singular).

## NormalModes / ModosNormales

    NormalModes[sistema]
    NormalModes[sistema, "Basis" -> {v1, v2, …}]
    NormalModes[Mmat, Kmat]          (atajo: matrices directamente)

Resuelve el problema de valores propios generalizado.

1. Ecuación secular: det(Kmat − λ Mmat), factorizada. En "Steps".
2. Valores propios ω² distintos, simplificados y ordenados de menor a mayor (si el orden no se
   puede decidir con las suposiciones, en el orden en que salen), cada uno con su multiplicidad.
3. Para cada ω², una base del subespacio: `NullSpace[Kmat − ω² Mmat]`, ortonormalizada con el
   producto u·Mmat·v (`Orthogonalize` con ese producto). Así A·Mmat·A = 1 y los modos de
   subespacios distintos son Mmat-ortogonales automáticamente.
4. Modos nulos: los de ω² = 0. Se informa cuántos son y el rango de Kmat (inciso (c) de la
   ayudantía: cuántos movimientos no estiran ningún resorte).

Opción `"Basis"`: el usuario entrega su propia base física (traslaciones, rotación, cizalle…),
N vectores. Se comprueba que cada vector sea propio (Kmat·v = ω² Mmat·v para algún ω²) y que la
base tenga rango N. Dentro de cada subespacio se ortonormaliza con Mmat **respetando el orden
dado** (Gram-Schmidt), de modo que si la base ya es Mmat-ortogonal solo se normaliza. Los modos
quedan en el orden en que el usuario los dio. Mensajes: `basis` (cantidad o largo incorrecto),
`noteigen` (dice qué vector no es propio), `rank` (los vectores no son independientes).

Devuelve:

| Clave | Contenido |
| --- | --- |
| "Coordinates", "Mmat", "Kmat", "Assumptions" | heredadas del sistema (y su geometría, si la tiene) |
| "SecularDeterminant" | det(Kmat − λ Mmat) factorizado, con λ = `\[FormalLambda]` |
| "Omega2" | lista de N valores, uno por modo (con repeticiones) |
| "Frequencies" | Sqrt de cada uno, simplificado |
| "Modes" | lista de N vectores Mmat-ortonormales, en el mismo orden que "Omega2" |
| "Degeneracies" | lista de <\|"Omega2" -> valor, "Multiplicity" -> g, "Indices" -> posiciones\|> |
| "ZeroModes" | cantidad de modos con ω² = 0 |
| "Rank" | rango de Kmat |
| "Steps" | ecuación secular; raíces y multiplicidades; base de cada subespacio; modos nulos y rango; comprobación de ortonormalidad |

Si `Eigenvalues` no da forma cerrada (sistemas grandes con parámetros simbólicos) en 30 s:
mensaje `symbolic`, que sugiere dar valores numéricos a los parámetros, y `$Failed`.
Con matrices numéricas inexactas se usa `Eigensystem[{Kmat, Mmat}]` y los valores propios que
difieren en menos de 10⁻⁸ (relativo) se agrupan como degenerados.

Nota pedagógica para "Steps": en un subespacio degenerado la base es una elección; cualquier
combinación de modos de igual frecuencia es también un modo.

## NormalCoordinates / CoordenadasNormales

    NormalCoordinates[modos]
    NormalCoordinates[modos, {Q1, Q2, …}]       (nombres elegidos por el usuario)

Por defecto las coordenadas normales se llaman Q[1], …, Q[N] con Q = `\[FormalCapitalQ]`.

Devuelve:

| Clave | Contenido |
| --- | --- |
| "NormalCoordinates" | Q_n = A_n·Mmat·q, como expresiones en las coordenadas originales (ec. 75) |
| "Inverse" | q_μ = Σ_n A_n,μ Q_n (ec. 71) |
| "Lagrangian" | Σ_n (½ Q̇_n² − ½ ω_n² Q_n²), con Q_n[t] (ec. 81) |
| "Steps" | definición; Q(q); q(Q); lagrangiano diagonal: sin términos cruzados |

## ModeResponse / RespuestaModal

    ModeResponse[modos, q0, v0]
    ModeResponse[modos, q0, v0, t]         (símbolo del tiempo; por defecto \[FormalT])

Movimiento del sistema dadas las posiciones q0 y velocidades v0 iniciales (listas de largo N):
los cuatro pasos del inciso (e).

- Q_n(0) = A_n·Mmat·q0 y Q̇_n(0) = A_n·Mmat·v0.
- Modo con ω_n ≠ 0: Q_n(t) = Q_n(0) Cos[ω_n t] + (Q̇_n(0)/ω_n) Sin[ω_n t].
  Modo nulo: Q_n(t) = Q_n(0) + Q̇_n(0) t.
- q(t) = Σ_n A_n Q_n(t).
- Energía de cada modo: E_n = ½ Q̇_n(0)² + ½ ω_n² Q_n(0)²; fracción E_n/ΣE.

Devuelve: "InitialQ", "InitialQdot", "NormalSolution" (lista de Q_n(t)), "Solution" (lista de
q_μ(t)), "ModeEnergies", "EnergyShares", "TotalEnergy", "Time", "Steps", más lo heredado de `modos`.

Validación: `ic` (q0 y v0 deben ser listas de largo N).
Si la energía total es cero, "EnergyShares" es una lista de ceros y se emite `rest` (informativo).

## Tests de la Parte A (Tests/NormalModes.wlt)

Cuadrado de la ayudantía:
`pos = {{0, 0}, {a, 0}, {a, a}, {0, a}}`,
`res = {{1, 2, k}, {4, 3, k}, {2, 3, k}, {1, 4, k}, {1, 3, kp}, {2, 4, kp}}`, masas `m`.
Base de la ayudantía (p. 17), en este orden: traslación x, traslación y, rotación, cizalle,
rectángulo, trapecio x, trapecio y, respiración:

    base = {{1,0,1,0,1,0,1,0}, {0,1,0,1,0,1,0,1}, {1,-1,1,1,-1,1,-1,-1}, {-1,-1,-1,1,1,1,1,-1},
            {-1,1,1,1,1,-1,-1,-1}, {1,0,-1,0,1,0,-1,0}, {0,1,0,-1,0,1,0,-1}, {-1,-1,1,-1,1,1,-1,1}}

| Caso | Esperado | Fuente |
| --- | --- | --- |
| SpringNetwork: Kmat | igual a la segunda derivada del potencial exacto Σ k/2 (largo − largo natural)² en q = 0 | Listado 6 (los dos caminos) |
| SpringNetwork: "SpringTable" | direcciones {1,0}, {1,0}, {0,1}, {0,1}, {1,1}/√2, {−1,1}/√2 | tabla p. 12 |
| NormalModes: determinante secular | proporcional a λ³ (λ − 2k)³ (λ − 2kp) (λ − 2k − 2kp) con m = 1 | ec. (57) |
| NormalModes: "Omega2" como conjunto con multiplicidad | 0 (×3), 2kp/m, 2k/m (×3), 2(k + kp)/m | ec. (57) |
| "ZeroModes" y "Rank" | 3 y 5 | inciso (c) |
| Ortonormalidad | Modes·Mmat·Modesᵀ = identidad; Modes·Kmat·Modesᵀ = diagonal con "Omega2" | ecs. (72)–(73) |
| Con "Basis" -> base | modos proporcionales a cada vector de la base, en ese orden | p. 17 |
| "Basis" con un vector que no es propio | $Failed, mensaje noteigen | |
| "Basis" con base[[6]] reemplazado por base[[5]] + base[[6]] | funciona, y los modos siguen siendo Mmat-ortonormales | Listado 9 («malos» y «buenos») |
| Sin diagonales (kp → 0, o lista sin ellas) | cuatro ceros y cuatro 2k/m; rango 4 | ec. (65) |
| Una sola diagonal | ω² m = k + kp ± Sqrt[k² + kp²], además de tres 0 y tres 2k; rango 5 | ec. (70) |
| NormalCoordinates con la base: lagrangiano | sin términos cruzados; coeficientes ½ y ½ ω_n² | ec. (81) |
| NormalCoordinates: Q(q) e inversa | una es la inversa de la otra | ecs. (71), (75) |
| ModeResponse, golpe radial: q0 = 0, v0 = v/√2 {1,1,0,0,0,0,0,0}, con la base | "EnergyShares" = {1/8, 1/8, 0, 1/4, 0, 1/8, 1/8, 1/4} | ec. (92) |
| Golpe tangencial: v0 = v/√2 {1,−1,0,0,0,0,0,0} | {1/8, 1/8, 1/4, 0, 1/4, 1/8, 1/8, 0} | Listado 11 |
| Golpe a lo largo de un lado: v0 = v {1,0,0,0,0,0,0,0} | {1/4, 0, 1/8, 1/8, 1/8, 1/4, 0, 1/8} | «Para explorar» |
| "Solution" cumple las ecuaciones | Mmat·q̈ + Kmat·q = 0, q(0) = q0, q̇(0) = v0 | Listado 10 |
| "Solution" contra NDSolve | con m = k = 1, kp = 0.5, v = 0.1, diferencia menor que 10⁻⁶ en t ∈ [0, 30] | Listado 10 |

Casos con solución conocida (no están en la ayudantía):

| Caso | Esperado |
| --- | --- |
| Cadena en 1D: posiciones {1, 2}, resorte {1, 2, k}, anclajes {1, 0, k} y {2, 3, k}, masas m | ω² = k/m y 3k/m; sin modos nulos |
| Cadena de 3 masas entre paredes, todo k y m | ω² m/k = 2 − √2, 2, 2 + √2 |
| Dos masas m y 2m unidas por un resorte k, en 1D, sin anclajes | ω² = 0 y 3k/(2m) |
| Triángulo equilátero en 2D, tres resortes k, masas m | ω² m/k = 0 (×3), 3/2 (×2), 3 |
| Tetraedro regular en 3D, seis resortes k, masas m (posiciones {1,1,1}, {1,−1,−1}, {−1,1,−1}, {−1,−1,1}) | ω² m/k = 0 (×6), 1 (×2), 2 (×3), 4 |
| Péndulo doble con SmallOscillations, `L = m l^2/2 (2 th1'[t]^2 + th2'[t]^2 + 2 th1'[t] th2'[t] Cos[th1[t] - th2[t]]) + m g l (2 Cos[th1[t]] + Cos[th2[t]])`, equilibrio {0, 0} | Mmat = m l² {{2, 1}, {1, 1}}, Kmat = m g l {{2, 0}, {0, 1}}, ω² = (g/l)(2 ∓ √2) |
| SmallOscillations en un punto que no es equilibrio | $Failed, mensaje noteq |
| NormalModes[Mmat, Kmat] con las matrices del péndulo doble | mismo resultado que con el sistema |

Además: errores de `SpringNetwork` (positions, springs, masses, anchors), los cinco alias, y un
mensaje en inglés.

---

# Parte B — rama `feat/normal-modes-plots`

Las funciones que dibujan la red necesitan un sistema creado con `SpringNetwork` (con geometría)
y valores numéricos para las posiciones; si faltan, mensajes `geometry` o `numeric`.
En 2D se dibuja con `Graphics`; en 3D con `Graphics3D`; en 1D, sobre una línea horizontal.

Convención de dibujo (la de la Figura 6): equilibrio en gris punteado, configuración desplazada
en línea gruesa, flechas rojas desde el equilibrio, masas como puntos, anclajes como cuadrados.
Los resortes se dibujan como segmentos.

## ModeGallery / GaleriaDeModos

    ModeGallery[modos]

Todos los modos dibujados en una grilla, cada uno con su número y su ω² como título.
Opciones: `"Amplitude" -> Automatic` (desplazamiento máximo igual al 20 % del tamaño de la red),
`"Labels" -> lista de nombres` (por ejemplo los de la ayudantía), `"Columns" -> 4`.

## AnimateMode / AnimarModo

    AnimateMode[modos, n]

Animación del modo n: la red oscila con Cos[fase]. Devuelve un `Animate` (o un `Manipulate` con
`"Controls" -> True`, que agrega un selector del modo). Para un modo nulo se muestra el
desplazamiento de ida y vuelta, y el título dice «modo nulo: no estira ningún resorte».

## AnimateMotion / AnimarMovimiento

    AnimateMotion[respuesta, tmax]

Animación del movimiento completo de `ModeResponse` (con valores numéricos), de t = 0 a tmax.
Opción `"FollowCenterOfMass" -> True`: resta el movimiento del centro de masa, para que una red
que se traslada no salga del cuadro.

## SpectrumPlot / GraficoDeEspectro

    SpectrumPlot[constructor, {p, pmin, pmax}]

ω² de cada modo en función de un parámetro: la Figura 7(ii). `constructor` es una función de un
argumento que devuelve un sistema, por ejemplo
`SpectrumPlot[SpringNetwork[pos, res /. kp -> #, 1] &, {r, 0, 1.6}]`.
Calcula los valores propios numéricos en una malla y los une por orden. Ejes: el parámetro y ω².

## EnergySharesChart / GraficoDeEnergias

    EnergySharesChart[respuesta]

Barras con la fracción de energía en cada modo (`BarChart`), con el número del modo (o las
etiquetas de `"Labels"`) en el eje.

## Notebook de ejemplo y cierre de la versión 0.2.0

`Examples/CuatroMasasYSeisResortes.nb`: el problema del cuadrado de principio a fin, con los
nombres en español, y un segundo ejemplo corto en 3D (el tetraedro). Mismas reglas que el
notebook de un grado de libertad. Al cierre: versión 0.2.0, README, ROADMAP y CLAUDE.md.

## Tests de la Parte B (Tests/NormalModesPlots.wlt)

Con el cuadrado numérico (a = 1, m = 1, k = 1, kp = 0.5) y la base de la ayudantía:

| Caso | Esperado |
| --- | --- |
| ModeGallery | un gráfico (Grid o GraphicsGrid), sin mensajes |
| AnimateMode[modos, 8] | Head Animate; con "Controls" -> True, Manipulate |
| AnimateMotion de la respuesta al golpe radial, tmax 20 | Head Animate |
| SpectrumPlot con kp de 0 a 1.6 | gráfico, sin mensajes |
| EnergySharesChart del golpe radial | gráfico, sin mensajes |
| Tetraedro: ModeGallery y AnimateMode | usan Graphics3D |
| Cadena 1D: ModeGallery | gráfico |
| Sistema de SmallOscillations (sin geometría) en ModeGallery | $Failed, mensaje geometry |
| Posiciones simbólicas en ModeGallery | $Failed, mensaje numeric |
| Cinco alias | iguales a las canónicas |

Revisión visual (PNG; para las animaciones, tres cuadros en fases 0, π/2 y π): la galería del
cuadrado debe reproducir la Figura 6; el espectro, la Figura 7(ii) (el cizalle sube desde cero
con pendiente 2; las líneas se cruzan en kp = k); el modo 8 del cuadrado es la respiración.
