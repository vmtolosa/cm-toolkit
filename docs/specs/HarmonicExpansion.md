# Especificación: HarmonicExpansion / ExpansionArmonica

Estado: aprobada para implementar. Versión 2 (4 de octubre de 2026): resuelve las 12 dudas
de la revisión de Claude Code.
Referencia: Ayudantía 6, Problema 1, incisos (b) y (c) y sección «¿y si ω > ωc?».

## Llamada

    HarmonicExpansion[L, {q, t}, q0, x]
    HarmonicExpansion[L, {q, t}, q0, x, Assumptions -> supuestos]
    ExpansionArmonica[...]      (alias en español, vía defineAlias)

- `L`: lagrangiano de un grado de libertad, escrito con `q[t]` y `q'[t]`.
- `{q, t}`: la coordenada generalizada (símbolo de función) y el tiempo.
- `q0`: punto en torno al cual se expande. Debe ser un equilibrio.
- `x`: símbolo de la desviación, q = q0 + x. **Obligatorio**: lo elige el alumno.

### Suposiciones

- `Assumptions -> Automatic` (por defecto): todos los símbolos libres de `L` y de `q0`,
  salvo `q`, `t` y `x`, son reales positivos.
- Si el usuario entrega sus propias suposiciones, **reemplazan** a las automáticas
  (no se suman). Así el usuario puede declarar un parámetro negativo sin contradicción.
- Las suposiciones usadas se muestran en el primer paso de "Steps".

## Validación de argumentos (en este orden; cada error emite su mensaje y devuelve $Failed)

| Situación | Mensaje |
| --- | --- |
| Número de argumentos distinto de 4, o el 4.º argumento es una opción (falta `x`) | `HarmonicExpansion::args`: explica la forma de la llamada con un ejemplo |
| `x` no es un símbolo sin valor, coincide con `q` o `t`, o aparece en `L` o en `q0` | `HarmonicExpansion::dev` |
| `L` contiene `q''[t]` o depende explícitamente de `t` (después de reemplazar q[t] y q'[t]) | `HarmonicExpansion::time`: la función requiere un lagrangiano autónomo |
| m_ef se simplifica a 0 | `HarmonicExpansion::mass` |
| U'(q0) no se puede demostrar igual a 0 (ver abajo) | `HarmonicExpansion::noteq` con el valor simplificado de U'(q0) y la sugerencia de revisar q0 o las suposiciones |

Criterio de equilibrio: `Simplify[U'(q0), supuestos]`; si no da 0, `FullSimplify`; si tampoco da 0,
es `noteq`, aunque no se haya demostrado que sea distinto de cero. Es estricto a propósito: el
alumno debe dar un equilibrio verificable o las suposiciones que lo hacen verificable.

## Qué calcula, en orden (cada paso es una entrada de "Steps"; el orden sigue a la ayudantía)

1. Suposiciones usadas.
2. Potencial efectivo: U(q) = −L con q'[t] → 0 (incluye términos centrífugos).
3. Masa efectiva: m_ef = ∂²L/∂q̇² en q = q0, q̇ = 0. Si L tiene un término lineal en q̇,
   el paso lo dice: en 1D es una derivada total y no afecta la ecuación de movimiento.
4. Comprobación de equilibrio: U'(q0) = 0.
5. Serie de U(q0 + x): coeficientes c0, c1, c2, … (ver la cota de amplitud para el orden).
6. k_ef = U''(q0) = 2 c2.
7. Lagrangiano armónico: (m_ef/2) x'[t]² − (k_ef/2) x[t]².
8. Cota de amplitud (ver abajo).
9. Ecuación de movimiento: x''[t] + Ω² x[t] == 0.
10. Ω² = k_ef / m_ef.

### Coeficientes «no nulos»

Un coeficiente cn es nulo si `Simplify[cn, supuestos] === 0`. Un coeficiente que se anula solo
para valores particulares de los parámetros (como c4 en ω = ωc/2 con ω simbólico) cuenta como
no nulo: el resultado es el genérico.

### Cota de amplitud

Sea n el primer orden entre 3 y 8 con cn no nulo.

| Caso | "AmplitudeBound" |
| --- | --- |
| c2 = 0 (punto crítico) | `Missing["CriticalPoint"]` (y se emite `HarmonicExpansion::critical`) |
| existe n | `<\|"Order" -> n, "Bound" -> Abs[c2/cn], "Condition" -> MuchLess[Abs[x]^(n-2), Abs[c2/cn]]\|>` |
| no existe n y U(q0 + x) es exactamente c0 + c1 x + c2 x² | `Missing["ExactlyQuadratic"]` |
| no existe n y U no es exactamente cuadrático | `Missing["BeyondOrder8"]` |

"PotentialSeries" llega hasta el orden max(4, n).

## Qué devuelve

| Clave | Contenido |
| --- | --- |
| "Coordinate", "Deviation", "Equilibrium" | q, x, q0 |
| "Assumptions" | las suposiciones usadas |
| "Potential" | U como expresión en q (el símbolo, no q[t]) |
| "EffectiveMass" | m_ef |
| "EffectiveStiffness" | k_ef |
| "Omega2" | Ω² simplificado (0 en el caso crítico) |
| "PotentialSeries" | U(q0 + x) como polinomio (Normal) |
| "HarmonicLagrangian" | lagrangiano armónico en x[t], x'[t] |
| "EquationOfMotion" | x''[t] + Ω² x[t] == 0 |
| "AmplitudeBound" | según la tabla anterior |
| "Steps" | lista de <\|"Description" -> texto, "Expression" -> expresión\|> |

Caso crítico (k_ef = 0): se emite `HarmonicExpansion::critical`, que sugiere ClassifyEquilibrium,
y se devuelve igual la Association completa, para que se vea la serie con el término x⁴.
k_ef < 0 (máximo) no es error: se devuelve tal cual, con Ω² negativo.

## Infraestructura bilingüe (se implementa en este mismo trabajo)

- Tabla privada `$texts`: Association de claves a `<|"Spanish" -> ..., "English" -> ...|>`.
  Contiene los textos de "Steps" y los mensajes.
- `tr[clave]`: devuelve el texto en el idioma de `cmLanguage[]`. Si la clave no existe,
  devuelve la clave misma (para que un olvido se note sin romper nada).
- `cmMessage[símbolo, etiqueta, args...]`: asigna a `símbolo::etiqueta` el texto traducido
  justo antes de emitirlo, y lo emite con `Message`.
- Los mensajes siempre usan el nombre canónico: al llamar `ExpansionArmonica`, el mensaje
  aparece como `HarmonicExpansion::...`. El `::usage` del alias lo advierte.

## ShowSteps / MostrarPasos (versión mínima)

    ShowSteps[res]

- Devuelve un `Grid` de tres columnas (número, descripción, expresión), con fila de
  encabezado en negrita en el idioma vigente, líneas horizontales finas grises y la fuente de
  `LabelStyle` de `$CMPlotStyle`. Las expresiones se muestran en `TraditionalForm`.
- Si `res` es `$Failed`, devuelve `$Failed` sin emitir otro mensaje (el error ya se informó).
- Si `res` no es una Association con "Steps": `ShowSteps::nosteps` y `$Failed`.

## Tests (Tests/HarmonicExpansion.wlt)

Anillo que rota, `L = m b^2/2 (th'[t]^2 + w^2 Sin[th[t]]^2) - m g b Cos[th[t]]`,
con `Assumptions -> Automatic` salvo que se indique:

| Caso | Esperado | Fuente |
| --- | --- | --- |
| q0 = Pi: "EffectiveMass" | m b^2 | ec. (19) |
| q0 = Pi: "EffectiveStiffness" | b m (g − b w^2) | ec. (19) |
| q0 = Pi: "Omega2" | g/b − w^2 | ec. (23) |
| q0 = Pi: "AmplitudeBound" | Order 4; Bound equivalente a Abs[12 (g/b − w^2)/(4 w^2 − g/b)] | ecs. (20)–(21) |
| q0 = Pi, numérico (g = b = m = 1) con w = 0; 0.6; 0.9; 0.95; 0.99 | Bound = 12; 17.4545; 1.0179; 0.4483; 0.0818 (tolerancia 10⁻³) | texto tras ec. (21) |
| q0 = Pi con w → Sqrt[g/b]/2 | Order 6, Bound 90 | «el coeficiente cuártico se anula» (p. 6) |
| q0 = Pi con w → Sqrt[g/b] | mensaje critical; "Omega2" 0; AmplitudeBound Missing["CriticalPoint"] | ec. (13) |
| q0 = ArcCos[−g/(b w^2)]: "Omega2" | w^2 − g^2/(b^2 w^2) | ec. (29) |
| q0 = Pi con w → 0 (péndulo): "Omega2" | g/b | caso límite |
| q0 = Pi/2 | $Failed con mensaje noteq | U'(π/2) = −m g b |
| Llamada con 3 argumentos | $Failed con mensaje args | |
| 4.º argumento `Assumptions -> {}` | $Failed con mensaje args | |
| x = t; x que aparece en L | $Failed con mensaje dev | |
| L con un término `t q[t]` | $Failed con mensaje time | |
| Steps | 10 entradas, cada una con "Description" (String) y "Expression" | |
| ExpansionArmonica[...] | igual a HarmonicExpansion[...] | |

Sistema con solución conocida (no está en la ayudantía): masa en resorte vertical,
`L = m/2 y'[t]^2 - k/2 y[t]^2 + m g y[t]`, equilibrio y0 = m g/k:
"Omega2" → k/m y "AmplitudeBound" → Missing["ExactlyQuadratic"].

Infraestructura y ShowSteps:
- `tr` devuelve textos distintos con $CMLanguage = "Spanish" y "English", y la clave misma si no existe.
- Un mensaje de HarmonicExpansion sale en inglés dentro de `Block[{$CMLanguage = "English"}, ...]`.
- ShowSteps del anillo: Head `Grid`. ShowSteps[$Failed]: $Failed sin mensajes.
  ShowSteps[<|"a" -> 1|>]: $Failed con mensaje nosteps.
- MostrarPasos[res] igual a ShowSteps[res].

Comparar expresiones simbólicas con `Simplify[a - b, supuestos] === 0` o
`FullSimplify[a == b, supuestos]`, nunca con `===` directo sobre formas no simplificadas.
