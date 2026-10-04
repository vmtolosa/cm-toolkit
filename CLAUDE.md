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
- reference/ayudantia6/: material de referencia del curso (está en .gitignore, solo existe localmente). No modificar.

## Comandos
- Correr todos los tests: wolframscript -file Tests/RunTests.wls
- Para revisar un gráfico: exportarlo a PNG en /tmp con wolframscript y abrir la imagen.

## Convenciones de código
- Nombres públicos en inglés y CamelCase (NormalModes, ResonanceCurve).
- Mensajes ::usage y de error en español.
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
