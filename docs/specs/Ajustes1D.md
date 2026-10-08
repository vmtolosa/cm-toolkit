# Especificación: ajustes tras la prueba con un sistema nuevo

Estado: aprobada para implementar. Versión 1.5 (7 de octubre de 2026).
- v1.1: agrega el punto 6 (parte potencial de la función energía).
- v1.2: agrega los puntos 7 (CMPlot con una sola curva) y 8 (números en los mensajes).
- v1.3: precisiones aprobadas durante la implementación y puntos 9 a 12, que salen de la revisión
  en notebook del PR de esta rama. El punto 9 reemplaza la regla del punto de equilibrio del punto 5.
- v1.5: el punto 11 aclara que la columna de expresiones no debe cambiar.
- v1.4: se retira el punto 12. Su premisa era incorrecta: `FactorList` no entrega exponentes
  simbólicos (y^(p − 1) sale como {y^p, 1} y {y, −1}), así que el caso que describía no ocurre.
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

## Precisiones aprobadas durante la implementación

- Punto 1: la clave "Derivative" conserva U' completa, con su denominador.
- Punto 5: q̇ lleva el punto encima si el nombre de la coordenada tiene una letra (ẋ, θ̇) y la
  prima si tiene varias (th'). Hay además un marcador `t` para el símbolo del tiempo. El punto 5
  cubre las descripciones de "Steps"; los mensajes de error siguen usando los nombres de la firma.
- Punto 7: en el test de dos curvas, los `Dashing` se cuentan en las primitivas dibujadas
  (`First[g]`), porque `Plot` guarda una copia del estilo en sus metadatos. La evaluación que
  decide si hay una o varias curvas va en `Quiet`.
- Punto 8: los argumentos con números de máquina pasan a texto antes de emitir el mensaje: un
  número suelto, con 6 cifras significativas; una expresión que contiene números, en `InputForm`
  sin marcas.

## 9. El punto de equilibrio en las descripciones

Reemplaza la regla de los 20 caracteres del punto 5. Con ella, un equilibrio como
Sqrt[l0^2 − h^2] aparece en el texto como «Sqrt[-h^2 + l0^2]», y se lee mal al lado de la
expresión tipografiada.

- El punto se inserta tal cual solo si es simple: su texto en `InputForm` mide 8 caracteres o
  menos y no contiene «[» ni «^» (0, Pi, Pi/2, -a, 1.5708).
- En cualquier otro caso se escribe el nombre de la coordenada seguido de 0 (x0, th0); la
  expresión completa se ve en la columna de la derecha.
- Test: con el riel en el equilibrio lateral, ninguna descripción contiene «Sqrt» ni «^», y la de
  la serie contiene «x0».

## 10. «con x = 0 + u» en las descripciones

Es el punto 3 llevado al texto. Si `zeroQ[q0]`, las descripciones de la serie dicen
«con x = u» en vez de «con x = 0 + u», en los dos idiomas.

## 11. Saltos de línea de las descripciones en ShowSteps

En un notebook, las descripciones largas se cortan como si fueran fórmulas: después de un «+» o
de un «=» y con sangría en la línea siguiente («…con x = 0 +» / «u, hasta el primer término…»;
«(U''(0) =» / «0) la estabilidad…»).

- Deben cortarse como texto: entre palabras, llenando el ancho de la columna y sin sangría en
  las líneas de continuación.
- La forma de lograrlo queda a criterio de la implementación; el resultado sigue siendo un `Grid`.
- Los números de la columna «Paso» van también con el estilo "Text".
- La columna «Expresión» no cambia: las fracciones siguen apiladas y las raíces con su barra,
  igual que antes de este punto. En la primera implementación (descripciones con `TextCell`), en
  un notebook las fracciones anchas pasaron a escribirse en una línea con «/» y las raíces
  perdieron la barra; en esa forma no se acepta.
- Revisión visual en PNG con la clasificación del riel en el centro (su conclusión ocupa cuatro
  líneas) y, por parte del usuario, en un notebook.

## Criterio de aceptación

Todos los tests anteriores de valores pasan sin cambios. Revisión visual de `ShowSteps` para el
riel (centro, equilibrio lateral, caso crítico) y para el anillo en π.
