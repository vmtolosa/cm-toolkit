# Especificación: EquilibriumPoints y ClassifyEquilibrium

Estado: aprobada para implementar. Versión 1.2 (5 de octubre de 2026).
- v1.1: resuelve las cinco dudas de la revisión de Claude Code (puntos repetidos, condición de
  existencia en la clasificación, suposiciones sin q0 ni x, textos por función, factorización).
- v1.2: orden de recorrido en la regla de puntos repetidos, significado de "Stable" en el caso
  "Conditional", mensaje `domain` y "LeadingCoefficient" en el caso "Undetermined".
Requiere: `docs/specs/Modulos.md` ya mergeado (usa sus funciones privadas compartidas).
Rama: `feat/equilibria`. Módulo: `Oscillations1D.wl`.
Referencia: Ayudantía 6, Problema 1, inciso (a), ecs. (7)–(13).

Mismas reglas que `HarmonicExpansion` para todo lo que esta especificación no diga:
suposiciones (`Assumptions -> Automatic` = parámetros reales positivos; las del usuario
reemplazan), criterio de cero `zeroQ`, validación `dev` y `time`, textos en `$texts`,
mensajes con `cmMessage` y "Steps" con formas retenidas donde ayude a la lectura.

---

## EquilibriumPoints / PuntosDeEquilibrio

    EquilibriumPoints[L, {q, t}]
    EquilibriumPoints[L, {q, t}, "Domain" -> {qmin, qmax}, Assumptions -> …]

Encuentra los puntos de equilibrio de un lagrangiano de un grado de libertad.

### Qué calcula ("Steps")

1. Suposiciones usadas.
2. Potencial efectivo U(q) = −L con q̇ = 0.
3. U'(q) factorizada (`Factor`, simplificada con las suposiciones).
4. Para cada factor que depende de q: sus soluciones de factor == 0 en el dominio.
5. Lista final de puntos, cada uno con su condición de existencia.

### Factorización

    dU = D[U, q];  fac = Factor[Simplify[dU, supuestos]]

"Derivative" es `fac`. Los factores son los de `FactorList[fac]` que dependen de q (las constantes
se descartan). Si `fac` no queda como producto, hay un solo factor: la expresión completa.

### Puntos repetidos

Dos soluciones distintas pueden coincidir para ciertos valores de los parámetros (en el anillo,
θ0 y 2π − θ0 coinciden con π cuando b w² = g). Orden de recorrido: primero los puntos que existen siempre (condición True), en el orden en que
los entrega `Solve`; después los condicionales, también en el orden de `Solve`. Así el punto que
existe siempre conserva el caso de coincidencia. En el anillo: 0, π y después los dos de ArcCos.
"Points" se devuelve en ese mismo orden. Regla: se recorren los puntos en ese orden y, a la
condición de cada punto, se le quita (con `And`/`Not` y simplificando) la condición en que coincide
con un punto anterior de la lista. Así cada equilibrio aparece una sola vez para cada valor de los
parámetros. En el anillo, las condiciones de θ0 y 2π − θ0 quedan estrictas: b w² > g.

### Dominio

- `"Domain" -> Automatic` (por defecto): todos los reales.
- Si las soluciones son periódicas (`Solve` devuelve constantes `C[k]` o `ConditionalExpression`
  con enteros), emite `EquilibriumPoints::periodic`, que sugiere `"Domain" -> {0, 2 Pi}`, y
  devuelve `$Failed`. Así el estudiante aprende a declarar el rango del ángulo.
- Con `{qmin, qmax}`: soluciones en el intervalo [qmin, qmax).
- Si el valor de "Domain" no es Automatic ni una lista de dos números reales con qmin < qmax
  (se aceptan expresiones exactas como 2 Pi): mensaje `EquilibriumPoints::domain`, que muestra el
  valor recibido y un ejemplo correcto, y `$Failed`.

### Qué devuelve

| Clave | Contenido |
| --- | --- |
| "Potential" | U como expresión en q |
| "Derivative" | U'(q) factorizada |
| "Factors" | lista de los factores de U' que dependen de q |
| "Points" | lista de <\|"Point" -> q0, "Condition" -> condición\|>, con la condición simplificada con las suposiciones (True si existe siempre) |
| "Steps" | como en HarmonicExpansion |

Si `Solve` no logra resolver un factor en un tiempo razonable (unos 10 s), ese factor aparece en
"Steps" como no resuelto, se emite `EquilibriumPoints::unsolved` y los demás puntos se devuelven igual.
Si no hay ningún punto de equilibrio, "Points" es la lista vacía y se emite `EquilibriumPoints::none`
(informativo, no es error).

---

## ClassifyEquilibrium / ClasificarEquilibrio

    ClassifyEquilibrium[L, {q, t}, q0, x]
    ClassifyEquilibrium[L, {q, t}, q0, x, Assumptions -> …]

Misma forma de llamada que `HarmonicExpansion` (el estudiante elige la desviación x, que aparece
en la serie de "Steps"). Validación en el mismo orden: `args`, `dev`, `time`, `noteq`. No hay
chequeo de `mass`: la clasificación depende solo del potencial.

### Criterio

Con los coeficientes c_n de U(q0 + x) (función privada `potentialCoefficients`, hasta orden 8):

| Caso | "Type" | "Stable" |
| --- | --- | --- |
| c2 > 0 bajo las suposiciones | "Minimum" | True |
| c2 < 0 bajo las suposiciones | "Maximum" | False |
| el signo de c2 depende de los parámetros | "Conditional" | la condición para c2 > 0 (ver nota) |
| c2 = 0, primer no nulo n impar | "Inflection" | False |
| c2 = 0, n par, cn > 0 | "Minimum" | True |
| c2 = 0, n par, cn < 0 | "Maximum" | False |
| c2 = 0 y ningún no nulo hasta orden 8 | "Undetermined" | Missing["Undetermined"] |

Nota sobre "Stable" en el caso "Conditional": es la condición para que el punto sea un mínimo
armónico (c2 > 0). La rama "Critical" (c2 = 0) no queda resuelta por esa condición: ahí la
estabilidad depende de órdenes superiores (en el anillo, π con b w² = g es un mínimo cuártico
estable). "Steps" lo dice con una nota en la conclusión: para el caso crítico, volver a llamar a
ClassifyEquilibrium con ese valor del parámetro sustituido.

Los valores de "Type" son datos (en inglés). La descripción en "Steps" está en el idioma de
`$CMLanguage` y explica la física: «mínimo: equilibrio estable», «máximo: inestable»,
«punto de inflexión: inestable», «mínimo no armónico: estable, pero el período depende de la
amplitud».

### Condición de existencia

Si q0 depende de parámetros, puede no existir para todos sus valores (θ0 = ArcCos[−g/(b w²)] solo
es real si b w² ≥ g). Se calcula "ExistenceCondition" = condición de que q0 sea real, simplificada con
las suposiciones (`Simplify` de `Element[q0, Reals]` y, si no se decide, `Reduce`). Si no se puede
decidir, se toma True y se anota en "Steps".

Cada condición de la clasificación se intersecta con "ExistenceCondition", y se descartan las ramas
cuya condición queda False. Si queda una sola rama, "Type" es esa rama (no "Conditional").

Caso "Conditional": se agrega la clave "Conditions" ->
<|"Minimum" -> cond(c2 > 0), "Maximum" -> cond(c2 < 0), "Critical" -> cond(c2 == 0)|>,
cada condición simplificada con las suposiciones (por ejemplo g > b w^2), ya intersectada con la
condición de existencia y sin las ramas que quedan en False.

### Qué devuelve

| Clave | Contenido |
| --- | --- |
| "Equilibrium", "Deviation", "Assumptions" | q0, x, suposiciones usadas |
| "ExistenceCondition" | condición para que q0 sea real (True si siempre existe) |
| "SecondDerivative" | U''(q0), simplificada |
| "LeadingOrder" | 2 si c2 no es nulo; si no, el primer n no nulo (o Missing["Undetermined"]) |
| "LeadingCoefficient" | c2 o c_n correspondiente (Missing["Undetermined"] si no hay ninguno hasta orden 8) |
| "Type", "Stable" | según la tabla |
| "Conditions" | solo en el caso "Conditional" |
| "Steps" | suposiciones, potencial, comprobación de equilibrio, serie de U(q0 + x) en orden creciente, U''(q0) y su signo, (si c2 = 0) primer orden no nulo, conclusión |

### Integración

El mensaje `HarmonicExpansion::critical` ya sugiere usar `ClassifyEquilibrium`; no cambia.

---

## Infraestructura compartida (cambios en Oscillations1D.wl)

- `assumptions1D` se generaliza a `assumptions1D[opt, exprs_List, exclude_List]`: si opt es
  Automatic, son positivos todos los símbolos libres de `exprs` salvo los de `exclude`.
  HarmonicExpansion la llama con `{L, q0}` y `{q, t, x}`; ClassifyEquilibrium igual;
  EquilibriumPoints con `{L}` y `{q, t}`. Los 48 tests existentes deben seguir pasando sin cambios.
- Cada función tiene sus propias entradas en `$texts` para todos sus mensajes (`args`, `dev`, `time`,
  `noteq`, `periodic`, `domain`, `unsolved`, `none`, según corresponda), con su propio nombre y su propio
  ejemplo de llamada en `args`. Se permite redactarlas igual que las de HarmonicExpansion.
  `validateDeviation1D` y `autonomousForm` ya reciben el símbolo de la función, así que emiten el
  mensaje con el nombre correcto.

---

## Tests (Tests/Equilibria.wlt)

Anillo que rota, `L = m b^2/2 (th'[t]^2 + w^2 Sin[th[t]]^2) - m g b Cos[th[t]]`:

| Caso | Esperado | Fuente |
| --- | --- | --- |
| EquilibriumPoints, "Domain" -> {0, 2 Pi}: "Derivative" | equivalente a −b m Sin[th] (g + b w^2 Cos[th]) | ec. (7) |
| ídem: "Points" | 0 y Pi con condición True; ArcCos[−g/(b w^2)] y 2 Pi − ArcCos[−g/(b w^2)] con condición equivalente a b w^2 > g (estricta: en b w^2 = g coinciden con Pi, ya listado) | ecs. (8)–(10) |
| EquilibriumPoints sin Domain | $Failed con mensaje periodic | |
| EquilibriumPoints con "Domain" -> {2 Pi, 0} o "Domain" -> {0, a} (a simbólico) | $Failed con mensaje domain | |
| ídem "Domain" -> {0, 2 Pi}: orden de "Points" | 0, Pi, y después los dos de ArcCos | regla de repetidos |
| Classify en q0 = Pi: nota de la rama crítica | la descripción del último paso menciona el caso crítico | ec. (13) |
| Classify en q0 = 0 | "Maximum", Stable False, U''(0) = −b m (g + b w^2) | ec. (11) |
| Classify en q0 = Pi | "Conditional"; Minimum si g > b w^2, Maximum si g < b w^2; U''(Pi) = b m (g − b w^2) | ec. (11) |
| Classify en q0 = Pi, Assumptions con b w^2 < g además de positividad | "Minimum" | ec. (11) |
| Classify en q0 = Pi con w → Sqrt[g/b] | "Minimum", LeadingOrder 4, LeadingCoefficient b g m/8 | ec. (13) |
| Classify en q0 = ArcCos[−g/(b w^2)] | ExistenceCondition equivalente a b w^2 ≥ g; "Conditional" con solo dos ramas: Minimum si b w^2 > g y Critical si b w^2 = g (sin rama Maximum, porque donde sería máximo el punto no existe); U'' = m (b^2 w^4 − g^2)/w^2 | ec. (12) |
| Classify en q0 = ArcCos[−g/(b w^2)] con Assumptions que incluyen b w^2 > g | "Minimum", Stable True | ec. (12) |
| Classify en q0 = Pi/2 | $Failed con mensaje noteq | |

Casos con solución conocida (no están en la ayudantía):

| Caso | Esperado |
| --- | --- |
| `L = m/2 y'[t]^2 - (y[t]^3/3 - c y[t])`, EquilibriumPoints | puntos −Sqrt[c] y Sqrt[c], condición True |
| ídem, Classify en Sqrt[c] y en −Sqrt[c] | "Minimum" y "Maximum" (U'' = ±2 Sqrt[c]) |
| `L = m/2 y'[t]^2 - a y[t]^3`, Classify en 0 | "Inflection", LeadingOrder 3, Stable False |
| `L = m/2 y'[t]^2 - a y[t]^4`, Classify en 0 | "Minimum", LeadingOrder 4 |
| resorte vertical `L = m/2 y'[t]^2 - k/2 y[t]^2 + m g y[t]`, EquilibriumPoints | un punto, m g/k, condición True, sin pedir Domain |

Además: errores args, dev y time de Classify; aliases PuntosDeEquilibrio y ClasificarEquilibrio
iguales a las funciones canónicas; ShowSteps de ambos resultados devuelve un Grid; mensaje en inglés
con `$CMLanguage = "English"`.

Al terminar: actualizar el estado en `docs/ROADMAP.md`.
