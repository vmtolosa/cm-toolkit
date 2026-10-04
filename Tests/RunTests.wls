#!/usr/bin/env wolframscript
(* Corre todos los archivos Tests/*.wlt. Termina con código 0 si todo pasa y 1 si algo falla.
   Uso, desde la raíz del repo:  wolframscript -file Tests/RunTests.wls *)

root = ParentDirectory[DirectoryName[$InputFileName]];
PacletDirectoryLoad[FileNameJoin[{root, "CMToolkit"}]];
Needs["CMToolkit`"];

files = FileNames["*.wlt", FileNameJoin[{root, "Tests"}]];
reports = AssociationMap[TestReport, files];

KeyValueMap[
  Print[FileNameTake[#1], ": ", #2["TestsSucceededCount"], " ok, ",
    #2["TestsFailedCount"], " fallidos"] &,
  reports];

failed = Select[
  Join @@ (Values[#["TestResults"]] & /@ Values[reports]),
  #["Outcome"] =!= "Success" &];

Do[
  Print["\nFALLÓ: ", t["TestID"],
    "\n  esperado: ", InputForm[t["ExpectedOutput"]],
    "\n  obtenido: ", InputForm[t["ActualOutput"]]],
  {t, failed}];

Exit[If[failed === {}, 0, 1]]
