# Especificación: HarmonicExpansion / ExpansionArmonica

Estado: aprobada para implementar. Versión 3 (4 de octubre de 2026).
- v2: resuelve las 12 dudas de la revisión de Claude Code.
- v3: LessLess en vez de MuchLess (que no existe en Mathematica) y criterio de cero único
  que acepta números inexactos.
- v3.1: zeroQ también se usa en la detección del término lineal en q̇ y en ExactlyQuadratic,
  y los coeficientes nulos de "PotentialSeries" se escriben como 0 exacto.
- v3.2: las expresiones de "Steps" se muestran en el orden en que se escriben a mano.
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
| zeroQ[m_ef] | `HarmonicExpansion::mass` |
| U'(q0) no se puede demostrar igual a 0 (ver abajo) | `HarmonicExpansion::noteq` con el valor simplificado de U'(q0) y la sugerencia de revisar q0 o las suposiciones |

## Criterio de cero (único para toda la función)

Una función privada `zeroQ[e, supuestos]` decide si algo es cero, y se usa en todos los lugares
donde la especificación pregunta por un cero: U'(q0), m_ef, c2 (caso crítico) y cada cn.

    zeroQ[e, supuestos]: sea s = Simplify[e, supuestos]
      - si TrueQ[s == 0], es cero;
      - si s es un número inexacto (InexactNumberQ) y Chop[s] == 0, es cero;
      - en cualquier otro caso, no es cero.

Para expresiones simbólicas equivale a `=== 0`, porque `expr == 0` queda sin evaluar y TrueQ da
False. Para números acepta `0.` y ruido de máquina (por ejemplo, un q0 dado como N[Pi]; en cambio 3.14159 está a 2.7·10⁻⁶ rad de π y correctamente no es equilibrio).

Criterio de equilibrio: zeroQ de U'(q0); si da False, se intenta con `FullSimplify` en vez de
`Simplify`; si tampoco, es `noteq`, aunque no se haya demostrado que sea distinto de cero. Es
estricto a propósito: el alumno debe dar un equilibrio verificable o las suposiciones que lo
hacen verificable.

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

Un coeficiente cn es nulo si `zeroQ[cn, supuestos]`. Un coeficiente que se anula solo
para valores particulares de los parámetros (como c4 en ω = ωc/2 con ω simbólico) cuenta como
no nulo: el resultado es el genérico.

### Cota de amplitud

Sea n el primer orden entre 3 y 8 con cn no nulo.

| Caso | "AmplitudeBound" |
| --- | --- |
| c2 = 0 (punto crítico) | `Missing["CriticalPoint"]` (y se emite `HarmonicExpansion::critical`) |
| existe n | `<\|"Order" -> n, "Bound" -> Abs[c2/cn], "Condition" -> LessLess[Abs[x]^(n-2), Abs[c2/cn]]\|>` |
| no existe n y U(q0 + x) es exactamente c0 + c1 x + c2 x² | `Missing["ExactlyQuadratic"]` |
| no existe n y U no es exactamente cuadrático | `Missing["BeyondOrder8"]` |

"PotentialSeries" llega hasta el orden max(4, n).
Cada coeficiente cn que zeroQ declara cero se escribe como 0 exacto en "PotentialSeries"
(así no aparece ruido de máquina como −7.8·10⁻¹⁷ x cuando q0 = N[Pi]).

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

### Orden de presentación en "Steps" (v3.2)

Mathematica reordena las sumas al mostrarlas. Para que "Steps" se lea como en la ayudantía,
"Expression" puede guardar una forma retenida (HoldForm u otra que funcione en TraditionalForm):
- la serie de U(q0 + x) en orden creciente de grado: c0 + c1 x + c2 x² + …;
- la ecuación de movimiento como x''(t) + Ω² x(t) = 0, con Ω² ya simplificado en su lugar;
- U(q0 + x) escrito con q0 primero.
Las claves principales ("PotentialSeries", "EquationOfMotion", etc.) siguen guardando las
expresiones normales, sin retener, para que el alumno pueda calcular con ellas.
Se verifica visualmente (PNG) y con un test que compruebe que "Steps" sigue teniendo 10 entradas
y que ShowSteps devuelve un Grid.

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
| q0 = Pi: "AmplitudeBound" | Order 4; Bound equivalente a Abs[12 (g/b − w^2)/(4 w^2 − g/b)]; "Condition" con Head LessLess | ecs. (20)–(21) |
| q0 = Pi, numérico (g = b = m = 1) con w = 0; 0.6; 0.9; 0.95; 0.99 | Bound = 12; 17.4545; 1.0179; 0.4483; 0.0818 (tolerancia 10⁻³) | texto tras ec. (21) |
| q0 = Pi con w → Sqrt[g/b]/2 | Order 6, Bound 90 | «el coeficiente cuártico se anula» (p. 6) |
| q0 = Pi con w → Sqrt[g/b] | mensaje critical; "Omega2" 0; AmplitudeBound Missing["CriticalPoint"] | ec. (13) |
| q0 = ArcCos[−g/(b w^2)]: "Omega2" | w^2 − g^2/(b^2 w^2) | ec. (29) |
| q0 = Pi con w → 0 (péndulo): "Omega2" | g/b | caso límite |
| q0 = Pi/2 | $Failed con mensaje noteq | U'(π/2) = −m g b |
| Llamada con 3 argumentos | $Failed con mensaje args | |
| 4.º argumento `Assumptions -> {}` | $Failed con mensaje args | |
| x = t; x que aparece en L | $Failed con mensaje dev | |
| L = −k/2 th[t]^2 (sin término cinético), q0 = 0 | $Failed con mensaje mass | |
| q0 = N[Pi], con g = b = m = 1, w = 0.6 | no da noteq; Order 4; "PotentialSeries" sin términos en x ni x³ (coeficientes 0 exactos) | criterio de cero |
| q0 = 3.14159, con g = b = m = 1, w = 0.6 | $Failed con mensaje noteq (no es equilibrio) | criterio de cero |
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
