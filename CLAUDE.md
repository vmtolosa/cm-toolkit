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
- Antes de implementar algo nuevo, proponer firma y valor de retorno y esperar confirmación.
- Primero el test, luego la implementación, luego correr RunTests.wls.
- No cambiar la firma de una función pública existente sin preguntar.
- Commits pequeños, un tema por commit, mensajes en español. No hacer push sin que lo pida.
- Si un Simplify tarda más de unos 10 s, avisar en vez de insistir.

## Notación física
- Matrices de masas y constantes elásticas: Mmat y Kmat en el código (m_μν y k_μν en el curso).
- λ = m ω² cuando la matriz de masas es m·identidad.
- Modos normalizados con A·Mmat·A = 1. En subespacios degenerados la base debe ser Mmat-ortonormal.
