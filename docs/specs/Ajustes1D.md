# Especificación: ajustes tras la prueba con un sistema nuevo

Estado: aprobada para implementar. Versión 1 (6 de octubre de 2026).
Rama: `fix/ajustes-1d`, después de mergear la parte A de `docs/specs/Motion1D.md`.
Origen: prueba en notebook con `L = m/2 x'[t]^2 - k/2 (Sqrt[x[t]^2 + h^2] - l0)^2` (masa en un riel
unida a un resorte anclado a una altura h). Todos los valores salieron correctos; estos son un
error y cuatro mejoras de presentación.

## 1. Error: EquilibriumPoints trata los denominadores como factores

`FactorList` devuelve también los factores con exponente negativo (aquí Sqrt[h^2 + x^2] con
exponente −1), y hoy se igualan a cero como los demás. Un cero del denominador no es un equilibrio:
es un punto donde U' no está definida.

- Solo se resuelven los factores con exponente positivo.
- "Factors" contiene solo esos factores.
- En "Steps", si hay denominador, va un paso propio: «Denominador de U'(q): no da equilibrios»,
  con la expresión del denominador. No se le aplica `Solve`.
- Tests: con el lagrangiano del riel, "Factors" tiene dos elementos (x y Sqrt[h^2 + x^2] − l0, salvo
  equivalencia) y los puntos siguen siendo 0 y ±Sqrt[l0^2 − h^2] con condición h < l0.
  Segundo test, con denominador que sí tiene un cero real: `L = m/2 y'[t]^2 - (y[t] - 2 Log[y[t]] - 1/y[t])`,
  donde U'(y) = (y − 1)^2/y^2: el único punto es y = 1, y y = 0 no aparece.

## 2. Signo «+» suelto en la serie retenida

Cuando la serie tiene un solo término (c0 = 0), `HoldForm[Plus[t]]` se muestra como «+ t»
(por ejemplo «U(0 + u) = + k u⁴/(8 h²)»). Con un solo término se muestra el término sin `Plus`.
Vale para `heldSeries` y para la conclusión de ClassifyEquilibrium.

## 3. «U(0 + u)» cuando q0 = 0

Si `zeroQ[q0]`, el lado izquierdo se muestra como U(u), no como U(0 + u).

## 4. Tipografía de ShowSteps

En un notebook, las descripciones y los encabezados salen en la fuente monoespaciada de las
salidas. Deben mostrarse como texto: `Style[texto, "Text"]` con el tamaño de `LabelStyle` de
`$CMPlotStyle` (sin fijar una familia propia: se hereda la del estilo "Text" del notebook).
Las expresiones siguen en `TraditionalForm`. El resultado sigue siendo un `Grid`.
Revisión visual: PNG desde wolframscript y, por parte del usuario, en un notebook.

## 5. Descripciones con los símbolos del usuario

Las descripciones de "Steps" hablan de «q», «q0» y «x» genéricos, aunque el estudiante haya
llamado x a su coordenada y u a la desviación: «con q = q0 + x» al lado de «U(0 + u)» confunde.

- Los textos de `$texts` pasan a ser plantillas con marcadores: `q` (coordenada), `x` (desviación)
  y `q0` (punto). `tr` acepta un segundo argumento opcional con los valores:
  `tr[clave, <|"q" -> "x", "x" -> "u", "q0" -> "0"|>]`, y los sustituye (`StringTemplate`).
  Sin segundo argumento se comporta como hoy.
- q̇ se escribe con el nombre de la coordenada y el punto encima.
- El punto de equilibrio se inserta como texto en `InputForm` si mide menos de 20 caracteres;
  si es más largo, se deja «q0» con el nombre de la coordenada (por ejemplo «x0») y la expresión
  se ve en la columna de la derecha.
- La nota del caso crítico nombra la función en el idioma vigente: ClasificarEquilibrio en
  español, ClassifyEquilibrium en inglés.
- Vale para HarmonicExpansion, EquilibriumPoints, ClassifyEquilibrium y las funciones de
  `Motion1D.md`.
- Tests: con el lagrangiano del riel y desviación u, ninguna descripción de "Steps" contiene «q»
  como símbolo suelto ni «q0»; la de la serie contiene «x = » y «u». Los tests existentes que
  comparen textos se actualizan; los que comparen valores no cambian.

## Criterio de aceptación

Todos los tests anteriores de valores pasan sin cambios. Revisión visual de `ShowSteps` para el
riel (centro, equilibrio lateral, caso crítico) y para el anillo en π.
