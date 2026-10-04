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

(* --- Prioridad de las opciones del usuario en CMPlot --- *)

VerificationTest[
  Options[CMPlot[Sin[x], {x, 0, 2 Pi}], ImageSize],
  {ImageSize -> 420},
  TestID -> "CMPlot-usa-estilo-por-defecto"
]

VerificationTest[
  Options[CMPlot[Sin[x], {x, 0, 2 Pi}, ImageSize -> 200], ImageSize],
  {ImageSize -> 200},
  TestID -> "CMPlot-opcion-usuario-tiene-prioridad"
]

VerificationTest[
  Options[GraficoCM[Sin[x], {x, 0, 2 Pi}, ImageSize -> 200], ImageSize],
  {ImageSize -> 200},
  TestID -> "alias-GraficoCM-opcion-usuario-tiene-prioridad"
]

(* --- cmLanguage[] (privada, se llama por su nombre completo) --- *)

VerificationTest[
  Block[{$CMLanguage = "English"}, CMToolkit`Private`cmLanguage[]],
  "English",
  TestID -> "cmLanguage-ingles"
]

VerificationTest[
  Block[{$CMLanguage = "Klingon"}, CMToolkit`Private`cmLanguage[]],
  "Spanish",
  TestID -> "cmLanguage-valor-invalido-vuelve-a-espanol"
]
