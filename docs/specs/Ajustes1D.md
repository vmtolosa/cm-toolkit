# Especificación: ajustes tras la prueba con un sistema nuevo

Estado: aprobada para implementar. Versión 1.2 (6 de octubre de 2026).
- v1.1: agrega el punto 6 (parte potencial de la función energía).
- v1.2: agrega los puntos 7 (CMPlot con una sola curva) y 8 (números en los mensajes).
Rama: `fix/ajustes-1d`, después de mergear la parte A de `docs/specs/Motion1D.md`.
Origen: prueba en notebook con `L = m/2 x'[t]^2 - k/2 (Sqrt[x[t]^2 + h^2] - l0)^2` (masa en un riel
unida a un resorte anclado a una altura h). Todos los valores salieron correctos; estos son dos
errores y seis mejoras de presentación.

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

## 6. Parte potencial de la función energía, término a término

En el paso 3 de EnergyFunction, `Simplify` deja la parte potencial factorizada
(para el anillo, −½ b m (−2 g Cos[θ] + b w² Sin[θ]²)). Se lee mejor como en el material del curso:
m g b Cos[θ] − ½ m b² w² Sin[θ]². En "Steps" la parte potencial se muestra expandida (`Expand`) y
retenida término a término. La clave "EnergyFunction" no cambia.

## 7. Error: CMPlot con una sola curva mezcla los estilos

`CMPlot[f, {x, a, b}]` con una sola función sale en morado y punteado: cuando hay una única
curva, `Plot` interpreta la lista de cuatro directivas de `PlotStyle` como una sola directiva
combinada (último color, más el `Dashed` de la segunda). Con dos o más curvas funciona bien.

- Una sola curva debe usar el primer estilo (azul, continuo); una lista de curvas, los estilos en
  orden, como hoy. Debe seguir funcionando con `HoldAll` (variable con valor asignado), con una
  expresión que no es una lista a simple vista (por ejemplo `sol["Solution"][tt]`) y con un
  símbolo cuyo valor es una lista de funciones.
- Si el usuario entrega `PlotStyle`, gana el suyo.
- Tests: el gráfico de una sola curva contiene el color RGBColor[0.12, 0.35, 0.65] y ningún
  `Dashing`; el de dos curvas contiene los dos primeros colores y un solo `Dashing`.
- Revisar que las demás funciones gráficas del paquete no tengan el mismo problema.

## 8. Números en los mensajes

Los números de máquina se insertan en los mensajes con su marca de precisión
(«t = 1.8540746734841649`»). Todos los números que van a un mensaje se formatean con 6 cifras
significativas y sin marca (función privada en Core.wl, usada por `cmMessage`).

## Criterio de aceptación

Todos los tests anteriores de valores pasan sin cambios. Revisión visual de `ShowSteps` para el
riel (centro, equilibrio lateral, caso crítico) y para el anillo en π.
