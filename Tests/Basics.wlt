(* Tests básicos: el paquete carga y el estilo gráfico funciona *)

VerificationTest[
  StringQ[CMToolkitVersion[]],
  True,
  TestID -> "version-es-texto"
]

VerificationTest[
  Head[CMPlot[Sin[x], {x, 0, 2 Pi}]],
  Graphics,
  TestID -> "CMPlot-devuelve-Graphics"
]

VerificationTest[
  MemberQ[$ContextPath, "CMToolkit`Private`"],
  False,
  TestID -> "contexto-privado-oculto"
]
