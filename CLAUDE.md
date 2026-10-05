# CMToolkit: guía para Claude

## Qué es
Paquete (paclet) de Wolfram Language para cursos de mecánica clásica de pregrado.
Ayuda a calcular y, sobre todo, a visualizar. Hoy cubre oscilaciones: un grado de libertad,
modos normales en N dimensiones, oscilaciones amortiguadas y forzadas, y funciones de Green.
Los demás temas están en docs/ROADMAP.md. Los usuarios son estudiantes que recién aprenden
Mathematica. El paquete es genérico: no menciona ningún curso, institución ni persona.

## Estructura
- CMToolkit/PacletInfo.wl: metadatos. La versión se cambia solo aquí.
- CMToolkit/Kernel/CMToolkit.wl: el código. Símbolos públicos con ::usage antes de Begin["`Private`"].
- Tests/*.wlt: tests con VerificationTest. Tests/RunTests.wls los corre todos.
- Examples/: notebooks de ejemplo, guardados sin salidas.
- docs/specs/: especificaciones aprobadas de cada función. Implementar exactamente lo que dicen;
  si algo no cuadra o falta, preguntar antes de decidir.
- docs/ROADMAP.md: visión, principios, módulos y versiones. Actualizar el estado al terminar un módulo.
- reference/: material de referencia del curso (en .gitignore, solo existe localmente). No modificar.
- privado/: carpeta personal del usuario (en .gitignore). No leer ni escribir.
- scripts/check-repo.sh, .githooks/pre-commit, .github/workflows/check-repo.yml: revisión de seguridad.

## Comandos
- Correr todos los tests: wolframscript -file Tests/RunTests.wls
- Para revisar un gráfico: exportarlo a PNG en /tmp con wolframscript y abrir la imagen.

## Seguridad
- Nunca copiar al repo archivos de fuera de él, ni contenido de reference/ o privado/.
- Nunca usar datos de estudiantes (nombres, notas, entregas) en ejemplos, tests ni documentación.
  Los ejemplos se inventan o salen de material del curso que el usuario autorizó publicar.
- Nunca escribir claves, tokens ni contraseñas en archivos. Si una tarea los necesita, detenerse
  y preguntar.
- No escribir el nombre ni el código de ningún curso, institución ni persona en el repo.
- Notebooks en Examples/ siempre sin salidas (las salidas suelen incluir rutas personales).
- Si scripts/check-repo.sh reporta un problema, detenerse y explicarlo. Nunca usar --no-verify
  ni buscar otra forma de saltarse la revisión.

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
- Toda función pública tiene tests. Los valores de referencia salen del material del curso en
  reference/ o de casos con solución conocida que la especificación documente explícitamente.

## Forma de trabajar
- Responder al usuario siempre en español, aunque las herramientas o los errores estén en inglés.
- La firma y el valor de retorno de algo nuevo salen de su especificación en docs/specs/.
  Si la especificación no los fija, proponerlos y esperar confirmación antes de implementar.
- Primero el test, luego la implementación, luego correr RunTests.wls.
- No cambiar la firma de una función pública existente sin preguntar.
- Commits pequeños, un tema por commit, mensajes en español. Los commits, el push y el PR
  los hace el usuario, no Claude Code (ver "Flujo de trabajo con ramas y revisión").
- Si un Simplify tarda más de unos 10 s, avisar en vez de insistir.

## Flujo de trabajo con ramas y revisión
- Cada función o cambio de diseño parte de una especificación en docs/specs/, escrita y aprobada en el chat de claude.ai. Las especificaciones no se editan desde Claude Code; si una está mal o es ambigua, detenerse y explicar el problema.
- Antes de empezar una tarea: git switch main && git pull. Luego crear una rama: git switch -c feat/<nombre-corto> (o test/, fix/, docs/ según corresponda).
- En la rama: tests primero, luego implementación, hasta que RunTests.wls pase completo.
- Claude Code no ejecuta git commit, git push ni gh pr create. Al cerrar cada punto del plan:
  corre RunTests.wls, muestra git status y git diff --stat, y propone el comando de commit
  listo para copiar: los archivos para git add y el mensaje en español, terminado en una línea
  en blanco y "Co-Authored-By: Claude <noreply@anthropic.com>". Luego espera a que el usuario
  confirme que hizo el commit antes de seguir con el punto siguiente.
- Al terminar la tarea: escribir la descripción del PR en /tmp/pr-<rama>.md, en español, con:
  qué implementa (con la ruta de la especificación), resultado de RunTests.wls, cómo probarlo
  en un notebook y cualquier desvío o duda respecto a la especificación. Indicar al usuario los
  comandos: git push -u origin <rama> y gh pr create --base main --title "..." --body-file /tmp/pr-<rama>.md
- Nunca hacer merge ni push a main: el merge lo hace el usuario después de la revisión.
- Los cambios pedidos en la revisión se hacen en la misma rama, con el mismo procedimiento de
  commit; al hacer push, el PR se actualiza solo.

## Notación física
- Matrices de masas y constantes elásticas: Mmat y Kmat en el código (m_μν y k_μν en el curso).
- λ = m ω² cuando la matriz de masas es m·identidad.
- Modos normalizados con A·Mmat·A = 1. En subespacios degenerados la base debe ser Mmat-ortonormal.
- Oscilador amortiguado y forzado: ẍ + 2γ ẋ + ω₀² x = F(t)/m, con γ el coeficiente de
  amortiguamiento y ω₀ la frecuencia natural.
