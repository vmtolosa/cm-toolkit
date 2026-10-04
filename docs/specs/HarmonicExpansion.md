# Especificación: HarmonicExpansion / ExpansionArmonica

Estado: aprobada para implementar (4 de octubre de 2026).
Referencia: Ayudantía 6, Problema 1, incisos (b) y (c) y sección «¿y si ω > ωc?».

## Llamada

    HarmonicExpansion[L, {q, t}, q0, x]
    ExpansionArmonica[L, {q, t}, q0, x]      (alias en español, vía defineAlias)

- `L`: lagrangiano de un grado de libertad, escrito con `q[t]` y `q'[t]`.
- `{q, t}`: la coordenada generalizada (como símbolo de función) y el tiempo.
- `q0`: punto en torno al cual se expande. Debe ser un equilibrio.
- `x`: símbolo para la desviación, q = q0 + x. **Obligatorio**: lo elige el alumno.
  Debe ser un símbolo sin valor asignado y distinto de `q` y de `t`.

Opción: `Assumptions -> Automatic`. Automatic supone que todos los símbolos libres de `L`
distintos de `q`, `t` y `x` son reales positivos (m, b, g, ω, k…). El usuario puede dar las suyas.

## Qué calcula, en orden (cada paso es una entrada de "Steps")

1. Potencial efectivo: U(q) = −L con q'[t] → 0 (incluye términos centrífugos).
2. Masa efectiva: m_ef = ∂²L/∂q̇² evaluada en q = q0, q̇ = 0.
   Un término lineal en q̇ se ignora (en 1D es una derivada total); si existe, se menciona en el paso.
3. Comprobación de equilibrio: U'(q0) simplificado con las suposiciones debe ser 0.
4. Serie de U(q0 + x) hasta orden 4: coeficientes c0 … c4.
5. k_ef = U''(q0) = 2 c2 y Ω² = k_ef / m_ef.
6. Lagrangiano armónico: (m_ef/2) x'[t]² − (k_ef/2) x[t]².
7. Ecuación de movimiento: x''[t] + Ω² x[t] == 0.
8. Cota de amplitud: sea n el primer orden mayor que 2 con coeficiente no nulo (3 o 4).
   La aproximación vale si |x|^(n−2) ≪ |c2/cn|. Si c3 = c4 = 0, no hay cota a este orden.

## Qué devuelve

Una Association con claves en inglés:

| Clave | Contenido |
| --- | --- |
| "Coordinate", "Deviation", "Equilibrium" | q, x, q0 |
| "Potential" | U como expresión en q (el símbolo, no q[t]) |
| "EffectiveMass" | m_ef |
| "EffectiveStiffness" | k_ef |
| "Omega2" | Ω² simplificado |
| "PotentialSeries" | U(q0 + x) hasta x^4, como polinomio (Normal) |
| "HarmonicLagrangian" | lagrangiano armónico en x[t], x'[t] |
| "EquationOfMotion" | x''[t] + Ω² x[t] == 0 |
| "AmplitudeBound" | <\|"Order" -> n, "Bound" -> \|c2/cn\|, "Condition" -> MuchLess[Abs[x]^(n−2), \|c2/cn\|]\|>, o <\|"Order" -> None\|> |
| "Steps" | lista de <\|"Description" -> texto, "Expression" -> expresión\|> |

Los textos de "Description" están en el idioma de cmLanguage[] y viven en la tabla privada de textos.

## Errores y casos borde (mensajes en español o inglés según $CMLanguage)

- Número de argumentos incorrecto o falta `x`: mensaje `HarmonicExpansion::args`
  que explica la forma correcta de la llamada; devuelve `$Failed`.
- `x` no es un símbolo libre, o coincide con `q` o `t`: `HarmonicExpansion::dev`; `$Failed`.
- `q0` no es equilibrio: `HarmonicExpansion::noteq` con el valor de U'(q0); `$Failed`.
- k_ef = 0 (caso crítico): `HarmonicExpansion::critical` que sugiere ClassifyEquilibrium.
  Igual devuelve la Association, con "Omega2" -> 0, para que se vea la serie y el término x⁴.
- m_ef ≤ 0 o k_ef < 0 no son errores: se devuelven tal cual (k_ef < 0 es un máximo).

## ShowSteps (en el mismo trabajo, versión mínima)

    ShowSteps[res]      alias: MostrarPasos

Muestra res["Steps"] como una tabla de dos columnas (descripción, expresión), con el estilo
del paquete. Si res no tiene "Steps", mensaje y `$Failed`.

## Tests (Tests/HarmonicExpansion.wlt)

Anillo que rota, `L = m b^2/2 (th'[t]^2 + w^2 Sin[th[t]]^2) - m g b Cos[th[t]]`:

| Caso | Esperado |
| --- | --- |
| q0 = Pi: "EffectiveMass" | m b^2 |
| q0 = Pi: "EffectiveStiffness" | b m (g − b w^2) |
| q0 = Pi: "Omega2" | g/b − w^2 |
| q0 = Pi: "AmplitudeBound" | Order 4; Bound equivalente a Abs[12 (g/b − w^2)/(4 w^2 − g/b)] |
| q0 = ArcCos[−g/(b w^2)]: "Omega2" | w^2 − g^2/(b^2 w^2) |
| q0 = Pi con w → 0 (péndulo): "Omega2" | g/b |
| q0 = Pi con w → Sqrt[g/b]: mensaje critical, "Omega2" | 0 |
| q0 = Pi/2 (no es equilibrio) | $Failed con mensaje noteq |
| Llamada con 3 argumentos | $Failed con mensaje args |
| x = t | $Failed con mensaje dev |
| ExpansionArmonica[...] | igual a HarmonicExpansion[...] |

Sistema fuera de la ayudantía: masa en resorte vertical,
`L = m/2 y'[t]^2 - k/2 y[t]^2 + m g y[t]`, equilibrio y0 = m g/k:
"Omega2" → k/m y "AmplitudeBound" → <|"Order" -> None|> (el potencial es exactamente cuadrático).

ShowSteps: devuelve un objeto gráfico (Head distinto de ShowSteps) y `$Failed` con una Association sin "Steps".

Comparar expresiones simbólicas con `Simplify[a - b, supuestos] === 0` o `FullSimplify[a == b, supuestos]`,
nunca con `===` directo sobre formas no simplificadas.
