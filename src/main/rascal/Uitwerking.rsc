// Uitwerking van de Rascal oefeningen (inwerkopdracht)
// Open Universiteit, oktober 2019

module Uitwerking

import IO;
import List;
import Map;
import Relation;
import Set;
import analysis::graphs::Graph;
import util::Resources;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import vis::Figure;
import vis::Render;
import vis::KeySym;

// --------------------------------------------------------------------------
// Exercise 6: Reguliere expressies

list[str] eu = ["Austria", "Belgium", "Bulgaria", "Czech Republic",
   "Cyprus", "Denmark", "Estonia", "Finland", "France", "Germany",
   "Greece", "Hungary", "Ireland", "Italy", "Latvia", "Lithuania",
   "Luxembourg", "Malta", "The Netherlands", "Poland",
   "Portugal", "Romania", "Slovenia", "Slovakia", "Spain",
   "Sweden", "United Kingdom"];

public void exercise6() {
   // bevat de letter 's'
   println("(6a)");
   println({ a | a <- eu, /s/i := a });
   // bevat (tenminste) twee 'e''s
   println("(6b)");
   println({ a | a <- eu, /e.*e/i := a });
   // bevat precies twee 'e's
   println("(6c)");
   println({ a | a <- eu, /^([^e]*e){2}[^e]*$/i := a });
   // bevat geen 'n' en geen 'e'
   println("(6d)");
   println({ a | a <- eu, /^[^en]*$/i := a });
   // bevat een letter met tenminste twee voorkomens
   println("(6e)");
   println({ a | a <- eu, /<x:[a-z]>.*<x>/i := a });
   // bevat een 'a' (eerste wordt een o)
   println("(6f)");
   println({ begin+"o"+eind | a <- eu, /^<begin:[^a]*>a<eind:.*>$/i := a });
}

// --------------------------------------------------------------------------
// Opgave 7: Functies met getallen

public rel[int, int] delers(int maxnum) {
   return { <a, b> | a <- [1..maxnum], b <- [1..a+1], a%b==0 };
}

public void exercise7() {
   rel[int, int] d = delers(100);
   // relatie met delers
   println("(7a)");
   println(d);
   // meeste delers
   println("(7b)");
   map[int, int] m = (a:size(d[a]) | a <- domain(d));
   int maxdiv = max(range(m));
   println({ a | a <- domain(d), m[a] == maxdiv });
   // priemgetallen (oplopend)
   println("(7c)");
   println(sort([ a | a <- domain(m), m[a] == 2 ]));
}

// --------------------------------------------------------------------------
// Opgave 8: Relaties

public Graph[str] gebruikt = {<"A", "B">, <"A", "D">,
   <"B", "D">, <"B", "E">, <"C", "B">, <"C", "E">,
   <"C", "F">, <"E", "D">, <"E", "F">};

public void exercise8() {
   componenten = carrier(gebruikt);
   // aantal componenten
   println("(8a)");
   println(size(componenten));
   // aantal afhankelijkheden
   println("(8b)");
   println(size(gebruikt));
   // ongebruikte componenten
   println("(8c)");
   println(top(gebruikt));
   // (in)direct nodig voor A
   println("(8d)");
   println((gebruikt+)["A"]);
   // in(direct) niet gebruikt door C
   println("(8e)");
   println(componenten - (gebruikt*)["C"]);
   // aantal keren (direct) gebruikt
   println("(8f)");
   println(( a:size(invert(gebruikt)[a]) | a <- componenten ));
}

// --------------------------------------------------------------------------
// Opgave 9: Eclipse project

public set[loc] javaBestanden(loc project) {
   Resource r = getProject(project);
   return { a | /file(a) <- r, a.extension == "java" };
}

public lrel[str, Statement] methodenAST(loc project) {
   set[loc] bestanden = javaBestanden(project);
   set[Declaration] decls = createAstsFromFiles(bestanden, false);
   lrel[str, Statement] result = [];
   visit (decls) {
      case \method(_, name, _, _, impl): result += <name, impl>;
      case \constructor(name, _, _, impl): result += <name, impl>;
   }
   return(result);
}

public bool aflopend(tuple[&a, num] x, tuple[&a, num] y) {
   return x[1] > y[1];
}

public int telIfs(Statement d) {
   int count = 0;
   visit(d) {
      case \if(_,_): count=count+1;
      case \if(_,_,_): count=count+1;
   }
   return count;
}

public void exercise9() {
   loc project = |project://JabberPoint/|;
   set[loc] bestanden = javaBestanden(project);
   // aantal Java-bestanden
   println("(9a)");
   println(size(bestanden));
   // aantal regels per Java-bestand
   println("(9b)");
   map[loc, int] regels = ( a:size(readFileLines(a)) | a <- bestanden );
   for (<a, b> <- sort(toList(regels), aflopend))
      println("<a.file>: <b> regels");
   // aantal methoden per klasse (gesorteerd)
   println("(9c)");
   M3 model = createM3FromEclipseProject(project);
   methoden =  { <x,y> | <x,y> <- model.containment
                       , x.scheme=="java+class"
                       , y.scheme=="java+method" || y.scheme=="java+constructor"
                       };
   telMethoden = { <a, size(methoden[a])> | a <- domain(methoden) };
   for (<a,n> <- sort(telMethoden, aflopend))
      println("<a>: <n> methoden");
   // klasse met meeste subklassen
   println("(9d)");
   subklassen = invert(model.extends);
   telKinderen = { <a, size((subklassen+)[a])> | a <- domain(subklassen) };
   for (<a, n> <- sort(telKinderen, aflopend))
      println("<a>: <n> subklassen");
   // klasse met meeste if-statements
   println("(9e)");
   stats = methodenAST(project);
   aantalIfs = sort([ <name, telIfs(s)> | <name, s> <- stats ], aflopend);
   println(aantalIfs[0]);
}

// --------------------------------------------------------------------------
// Opgave 10: visualisaties

public list[&T] copy(int n, &T element) {
   return [ element | _ <- [0..n] ];
}

Figure redSquares  = hcat(copy(10, box(size(40), fillColor("red"))), gap(10), resizable(false));

public void exercise10a() {
   render("red squares", redSquares);
}

public Figure shapeSwitch() {
   bool status = true;

   // local call-back function
   bool changeStatus(int butnr, map[KeyModifier,bool] modifiers) {
      status = !status;
      return true;
   };

   Figure s1 = box(size(40), fillColor("red"), resizable(false), onMouseDown(changeStatus));
   Figure s2 = ellipse(size(40), fillColor("green"), resizable(false), onMouseDown(changeStatus));

   return computeFigure(Figure() {return status ? s1 : s2;});
}

public void exercise10b() {
   render("click on square", shapeSwitch());
}

map[str, int] jabberSizes =
   ("AboutBox.java":28, "Accessor":30, "BitmapItem":67, "DemoPresentation":50,
    "JabberPoint":37, "KeyController":44, "MenuController":109, "Presentation":107,
    "Slide":85, "SlideItem": 38, "SlideViewerComponent":62, "SlideViewerFrame":36,
    "Style.java":57, "TextItem.java":108, "XMLAccessor":112);

Figure jabberTreemap = treemap([ box(text(s),area(n),fillColor(arbColor())) | <s,n> <- toRel(jabberSizes) ]);

public void exercise10c() {
   render("JabberPoint treemap", jabberTreemap);
}