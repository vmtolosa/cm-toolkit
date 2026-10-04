(* Tests de HarmonicExpansion / ShowSteps y de la infraestructura bilingüe.
   Especificación: docs/specs/HarmonicExpansion.md (versión 2).
   Valores de referencia: Ayudantía 6, Problema 1. *)

(* --- Infraestructura bilingüe: tr y cmMessage (privadas) --- *)

VerificationTest[
  Module[{es, en},
    es = Block[{$CMLanguage = "Spanish"}, CMToolkit`Private`tr["ShowSteps:description"]];
    en = Block[{$CMLanguage = "English"}, CMToolkit`Private`tr["ShowSteps:description"]];
    StringQ[es] && StringQ[en] && es =!= en],
  True,
  TestID -> "tr-espanol-e-ingles-distintos"
]

VerificationTest[
  CMToolkit`Private`tr["clave-que-no-existe"],
  "clave-que-no-existe",
  TestID -> "tr-clave-inexistente-devuelve-la-clave"
]

VerificationTest[
  CMToolkit`Private`cmMessage[cmTestSymbol, "prueba"],
  Null,
  {cmTestSymbol::prueba},
  TestID -> "cmMessage-emite-el-mensaje"
]
