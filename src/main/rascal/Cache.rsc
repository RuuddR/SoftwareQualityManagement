/* Omdat de resultaten van opdracht 1 moeten worden gebruikt om tot een visualisatie
   te komen, en je waarschijnlijk niet telkens wilt wachten op het uitrekenen van de
   metrieken, is het verstandig om tussenresultaten op te slaan (te cachen). Dat gaat
   gelukkig vrij eenvoudig in Rascal. Hieronder staat een codefragment om je alvast op
   weg te helpen (binair wegschrijven en inlezen kan ook).
*/
module Cache

import analysis::graphs::Graph;
import IO;
import Set;
import ValueIO;

loc tmp = |file:///D:/tmp.txt|;

Graph[str] gebruikt = {<"A", "B">, <"A", "D">,
   <"B", "D">, <"B", "E">, <"C", "B">, <"C", "E">,
   <"C", "F">, <"E", "D">, <"E", "F">};

public void schrijf() {
   writeTextValueFile(tmp, gebruikt);
}

public void leesEnToon() {
   Graph[str] g = readTextValueFile(#Graph[str], tmp);
   println("ingelezen: <g>");
   println("grootte: <size(g)>");
}