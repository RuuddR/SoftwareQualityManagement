module MetaModel

import IO;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import util::Resources;

// De 'uses' relatie uit het M3-metamodel van een project
public rel[loc, loc] usesRelation(loc l) {
   M3 model = createM3FromEclipseProject(l);
   return model.uses;
}

// Toon de 'uses' relatie voor JabberPoint
// De locaties die worden geprint in de REPL zijn 'klikbaar'
public void printUses() {
   for (<a,b> <- usesRelation(|project://JabberPoint|)) {
      println("<a> uses <b>");
      // Lees een deel van een bestand (van begin- tot eindpositie)
      str s = readFile(a);
      println("   code = <s>");
   }
}

// Alle bestanden in een project met extensie java
public set[loc] javaBestanden(loc project) {
   Resource r = getProject(project);
   return { a | /file(a) <- r, a.extension == "java" };
}

// Zoek naar condities van een IfThen statement, en toon deze
// De tweede parameter van createAstsFromFiles (van type bool) is de collectBindings optie voor name resolution
// zie https://stackoverflow.com/questions/27397593/rascal-what-does-the-bool-collectbindings-in-creating-ast-do
//
// Alternatief: createAstFromFile
public void printConditions() {
   set[loc] files = javaBestanden(|project://JabberPoint|);
   set[Declaration] decls = createAstsFromFiles(files, false);
   visit(decls) {
      case \if(cond, thenBranch): {
         println("condition at <cond.src>");
      }
   }
}