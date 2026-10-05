(* ::Package:: *)
(* CMToolkit: herramientas para mecánica clásica de pregrado *)

BeginPackage["CMToolkit`"];

(* Cada módulo declara sus símbolos públicos (con ::usage) en CMToolkit` y su implementación
   en CMToolkit`Private`. Core va primero: los demás usan tr, cmMessage, defineAlias y zeroQ.
   Sin variables aquí: se crearían como símbolos públicos de CMToolkit`. *)
Get[FileNameJoin[{DirectoryName[$InputFileName], "Core.wl"}]];
Get[FileNameJoin[{DirectoryName[$InputFileName], "Oscillations1D.wl"}]];

EndPackage[];
