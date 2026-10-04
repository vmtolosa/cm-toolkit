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

(* --- Esquema bilingüe --- *)

VerificationTest[
  $CMLanguage,
  "Spanish",
  TestID -> "idioma-por-defecto"
]

VerificationTest[
  VersionCMToolkit[] === CMToolkitVersion[],
  True,
  TestID -> "alias-VersionCMToolkit"
]

VerificationTest[
  Head[GraficoCM[Sin[x], {x, 0, 2 Pi}]],
  Graphics,
  TestID -> "alias-GraficoCM-devuelve-Graphics"
]

VerificationTest[
  MemberQ[Attributes[GraficoCM], HoldAll],
  True,
  TestID -> "alias-hereda-atributos"
]

VerificationTest[
  StringContainsQ[CMPlot::usage, "Alias"] && StringContainsQ[GraficoCM::usage, "Spanish alias"],
  True,
  TestID -> "ayuda-bilingue"
]
