# CMToolkit: guía para Claude

## Qué es
Paquete (paclet) de Wolfram Language para el curso FIS210, mecánica clásica de pregrado.
Ayuda a calcular y, sobre todo, a visualizar: pequeñas oscilaciones, modos normales,
oscilaciones amortiguadas y forzadas, y correcciones anarmónicas por perturbaciones.
Los usuarios son estudiantes que recién aprenden Mathematica.

## Estructura
- CMToolkit/PacletInfo.wl: metadatos. La versión se cambia solo aquí.
- CMToolkit/Kernel/CMToolkit.wl: el código. Símbolos públicos con ::usage antes de Begin["`Private`"].
- Tests/*.wlt: tests con VerificationTest. Tests/RunTests.wls los corre todos.
- Examples/: notebooks de ejemplo, guardados sin salidas.
- docs/specs/: especificaciones aprobadas de cada función. Implementar exactamente lo que dicen;
  si algo no cuadra o falta, preguntar antes de decidir.
- reference/ayudantia6/: material de referencia del curso (está en .gitignore, solo existe localmente). No modificar.

## Comandos
- Correr todos los tests: wolframscript -file Tests/RunTests.wls
- Para revisar un gráfico: exportarlo a PNG en /tmp con wolframscript y abrir la imagen.

## Versión de Mathematica
- Mínima: 15.0 (los alumnos usan 15.0.1). Se puede usar todo lo disponible en 15.0.

## Esquema bilingüe (inglés y español)
- Nombre canónico de cada función pública en inglés y CamelCase (HarmonicExpansion, NormalModes).
- Cada función pública tiene un alias en español creado con defineAlias[alias, canonical]
  al final del archivo (ExpansionArmonica, ModosNormales). El alias hereda atributos y opciones.
  Ambos nombres se declaran con ::usage en la sección pública.
- ::usage de ambos nombres: un solo texto, primero en español y luego en inglés, separados por \n.
  El del nombre canónico menciona el alias; el del alias dice de qué función es alias.
- Mensajes de error, textos de "Steps" y etiquetas de gráficos: en un solo idioma, el de
  $CMLanguage ("Spanish" por defecto, o "English"). Leerlo siempre con cmLanguage[], nunca directo.
  Los textos traducibles van en una tabla privada con las dos versiones, no repartidos por el código.
- Claves de las Association: solo en inglés ("Omega2", "EffectiveMass"). ShowSteps muestra su
  significado en el idioma de $CMLanguage.
- Cada alias tiene un test que comprueba que da el mismo resultado que la función canónica.
- Notebooks del curso (Examples/) usan los nombres en español; el README usa los nombres en inglés.

## Convenciones de código
- Nada en el contexto Global`. Variables locales con Module, With o Block.
- No usar como variables las letras reservadas de Mathematica (C, D, E, I, K, N, O).
- Las funciones de análisis devuelven una Association con los resultados y una clave
  "Steps" con los pasos intermedios, en el orden en que se harían a mano.
- Las funciones gráficas usan $CMPlotStyle; las opciones del usuario tienen prioridad.
- Argumentos inválidos: emitir un mensaje (f::arg) y devolver $Failed.
- Toda función pública tiene tests. Los valores de referencia salen de reference/ayudantia6.

## Forma de trabajar
- La firma y el valor de retorno de algo nuevo salen de su especificación en docs/specs/.
  Si la especificación no los fija, proponerlos y esperar confirmación antes de implementar.
- Primero el test, luego la implementación, luego correr RunTests.wls.
- No cambiar la firma de una función pública existente sin preguntar.
- Commits pequeños, un tema por commit, mensajes en español. Push solo con el visto bueno
  del usuario y nunca a main (ver "Flujo de trabajo con ramas y revisión").
- Si un Simplify tarda más de unos 10 s, avisar en vez de insistir.

## Flujo de trabajo con ramas y revisión
- Cada función o cambio de diseño parte de una especificación en docs/specs/, escrita y aprobada en el chat de claude.ai. Las especificaciones no se editan desde Claude Code; si una está mal o es ambigua, detenerse y explicar el problema.
- Antes de empezar una tarea: git switch main && git pull. Luego crear una rama: git switch -c feat/<nombre-corto> (o test/, fix/, docs/ según corresponda).
- En la rama: tests primero, luego implementación, hasta que RunTests.wls pase completo.
- Al terminar: resumir lo hecho y preguntar antes de hacer push. Con el visto bueno: git push -u origin <rama> y abrir un PR con gh pr create, en español, que incluya: qué implementa (con la ruta de la especificación), resultado de RunTests.wls, cómo probarlo en un notebook y cualquier desvío o duda respecto a la especificación.
- Nunca hacer merge ni push directo a main: el merge lo hace el usuario después de la revisión.
- Los cambios pedidos en la revisión se hacen en la misma rama y se suben con push; el PR se actualiza solo.

## Notación física
- Matrices de masas y constantes elásticas: Mmat y Kmat en el código (m_μν y k_μν en el curso).
- λ = m ω² cuando la matriz de masas es m·identidad.
- Modos normalizados con A·Mmat·A = 1. En subespacios degenerados la base debe ser Mmat-ortonormal.
