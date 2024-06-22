#import "@preview/fletcher:0.4.5": *
#let signe = "Sign"
#let variation = "Variation"

// les deux prochaine fonctions son pour connaitre le nombre d’éléments à skip
#let prochainNonVideSigne(x, i) = {
  let k = 0
  let j = i + 1
  while j < x.len() and type(x.at(j)) == array and x.at(j).len() == 0 {
    k += 1
    j += 1
  }
  k
}
#let prochainNonVideVar(x, i) = {
  let k = 0
  let j = i + 1
  while j < x.len() and x.at(j).len() == 0 {
    k += 1
    j += 1
  }
  k
}
// fin des deux fonctions

// pour gérer le dernier élément
#let lastele(x, domain, j, init, stroke) = {
  // le placement de l’élément
  if x.first() == top {
    node((domain.len() - 1 / 3, 1 + (j) * 3 + 0.4), x.last())
  } else if x.first() == center {
    node((domain.len() - 1 / 3, 2 + (j) * 3 + 0.3), x.last())
  } else if x.first() == bottom {
    node((domain.len() - 1 / 3, 3 + (j) * 3 - 0.12), x.last())
  }
  // pour géré le cas de l’indèfinie
  if x.at(1) == "||" {
    edge(
      (
        domain.len() + 0.137 - 0.067 * calc.pow(stroke.thickness.pt(), 1 / 2),
        j * 3 + if j == 0 {
          0.85
        } + if j == 0 and j == init.at("label").len() - 1 {
          -0.05
        } + if j == 0 and init.at("label").len() == 1 {
          0.05
        },
      ),
      (
        domain.len() + 0.137 - 0.067 * calc.pow(stroke.thickness.pt(), 1 / 2),
        j * 3 + 4 + if j == init.at("label").len() - 1 {
          4
        },
      ),
      stroke: stroke.thickness / 2 + stroke.paint,
    )
  }
}

///Render a variation table and sign table of your functions
///
/// - init (dictionary): initialitation of the table \
///  - in "variable", is an content wich contain the table’s variable (like $x$ or $t$)
///  - in "label", you have to put array of 2 arguments that contain in first position the lign’s label and in second position, if the lign is a variation table or a sign table with this following keys : "Variation" and "Sign"
/// *Example :* for a variation table of a function f, you should write : \
/// ```
/// init(
///   variable: $x$,
///   label: (
///     ([sign of $f$], "Sign"), //<- the first lign is a sign table
///     ([variation of $f$], "Variation") //<- the second lign is a variation table
///   )
/// )
/// ```
///
/// - domain (array): values taken by the variable \
/// for example if your funtion changes sign or reaches a max/min for $x in {0,1,2,3}$ \
/// you should write this :
/// ```
/// domain: ($0$, $1$, $2$, $3$)
/// ```
///
/// - arrow (string): the style of the arrow\
/// you can use all diffrents kind of "string" arrow of the package fletcher, so I invite you to read the #link("https://github.com/Jollywatt/typst-fletcher", underline(stroke: blue)[fletcher documentation])
///
/// - content (array): the content of the table \
/// see bellow for more details
///
/// - stroke (lenght, color, gradient): the table’s color and thickness \
/// *Caution :* this stroke can take only lenght, color or gradient types but none of the others
///
/// - stroke-arrow (lenght, color, gradient): the arrow’s color and thickness \
/// *Caution :* this stroke can take only lenght, color or gradient types but none of the others
///
/// - lign-0 (bool): if you want 0 on lign betwen the sign
#let tabvar(
  init: (
    "variable": [],
    "label": [],
  ),
  domain: (),
  arrow: "->",
  content: ((),),
  stroke: 1pt + black,
  stroke-arrow: 0.6pt + black,
  lign-0: false,
  _debug: false,
) = {

  // auxiliary function
  let bo(x) = table(columns: 2cm, stroke: 0pt)[#table.cell(align: center + horizon)[#x]]

  //start of function
  context {
    diagram(
        spacing: ((4/3)*1cm, 1.3pt),
        cell-size: 0pt,
        debug: _debug,
        node((0,0), stroke: stroke,enclose:  (//contour du tableau
          ..for i in range(domain.len() + 1){
              for j in range(-2 ,init.at("label").len()*3 +2){
                ((i,j),)
              }
            }
          ),
        ),
        edge( // ligne de séparation x du reste
          (-0.86,0.87 + if init.at("label").first().last() == signe{0.1}),
          (domain.len()+0.12,0.87 + if init.at("label").first().last() == signe{0.1}),
          stroke: stroke
        ),
        edge(  // ligne de séparation des label, des varations
          (0.36,-6),
          (0.36,init.at("label").len()*3 + 5),
          stroke: stroke
        ),
        node((-0.19,-1), (init.at("variable")), width: 2cm), // affichage de la variable

        for i in range(domain.len()-1){ // affichage de l’domainle
          node((i+2/3, -1), domain.at(i), width: (2/3)*1cm)
        },
        node((domain.len()-1/3,-1), domain.at(domain.len()-1), width: (2/3)*1cm),// affichage du dernier élément de l’domaine

        ..for j in range(init.at("label").len()){(// affichage des label
          node((-0.19,2+j*3), bo(init.at("label").at(j).first()), height: calc.max(measure(bo(init.at("label").at(j).first())).height, 45pt)),)
        },

        ..for j in range(init.at("label").len()){(
          if init.at("label").at(j).last() == signe{( //tableau de signe

            // le cas s’il y a une ligne indèf à la fin
            if content.at(j).len() != domain.len()-1{
              edge(
                (
                  domain.len() + 0.137 - 0.067 * calc.pow(stroke.thickness.pt(), 1/2),
                  j * 3 + 1
                ),
                (
                  domain.len() + 0.137 - 0.067 * calc.pow(stroke.thickness.pt(), 1/2),
                  j * 3 + 4 + if j == init.at("label").len() - 1 {
                    4.5
                  },
                ),
                stroke: stroke.thickness / 2 + stroke.paint,
              )
            },

            for i in range(1,domain.len()-1){ //les labels + et -
              if type(content.at(j).at(i))== array and content.at(j).at(i).len() == 0{}
              else if type(content.at(j).at(i))== array and content.at(j).at(i).len() != 0{
                let decalage = prochainNonVideSigne(content.at(j), i)
                node((i + 1.2 + decalage*0.5, 2+(j)*3),content.at(j).at(i).last())
              }
              else{
                let decalage = prochainNonVideSigne(content.at(j), i)
                node((i + 1.2 + decalage*0.5, 2+(j)*3),content.at(j).at(i))
              }
            },
            if type(content.at(j).first()) == array and content.at(j).first().len() != 0 {// premier signe
              node((1.05 + prochainNonVideSigne(content.at(j), 0)*0.6, 2+(j)*3),content.at(j).first().last())
              edge(
                (0.4 * calc.pow(stroke.thickness.pt(), 1/20), 1+j*3),
                (0.4 * calc.pow(stroke.thickness.pt(), 1/20), 3+j*3 + if j == init.at("label").len()-1{5.5} ),
                stroke: stroke.thickness/2 + stroke.paint,
              )
            }
            else {
              node((1.05 + prochainNonVideSigne(content.at(j), 0)*0.6, 2+(j)*3),content.at(j).first())
            },

            // ligne de séparation
            for i in range(1,domain.len()-1){

              if type(content.at(j).at(i)) == array and content.at(j).at(i).len() == 0{} // pas de ligne de séparation.
              else if type(content.at(j).at(i)) == array and content.at(j).at(i).len() != 0{ // ligne de séparation custom
                if content.at(j).at(i).first() == "0"{
                  edge((i+2/3, 1+(j)*3), (i+2/3,3+(j)*3 + if j == init.at("label").len()-1{5.5}),label-sep: -7.1pt, stroke: stroke.thickness/2 + stroke.paint, $0$)
                }
                else if content.at(j).at(i).first() == "|"{
                  edge((i+2/3, 1+(j)*3), (i+2/3,3+(j)*3 + if j == init.at("label").len()-1{5.5}),label-sep: -7pt, stroke: stroke.thickness/2 + stroke.paint)
                }
                else if content.at(j).at(i).first() == "||"{
                  edge(
                    (i+2/3 + 0.02 * calc.sqrt(stroke.thickness.pt()) ,1+(j)*3),
                    (i+2/3 + 0.02 * calc.sqrt(stroke.thickness.pt()) ,3+(j)*3 + if j == init.at("label").len()-1{5.5}),
                    label-sep: -7pt,
                    stroke: stroke.thickness/2 + stroke.paint
                  )
                  edge(
                    (i+2/3- 0.02 * calc.sqrt(stroke.thickness.pt()) ,1+(j)*3),
                    (i+2/3- 0.02 * calc.sqrt(stroke.thickness.pt()) ,3+(j)*3 + if j == init.at("label").len()-1{5.5}),
                    label-sep: -7pt,
                    stroke: stroke.thickness/2 + stroke.paint
                  )
                }
              }
              else{ // ligne de séparation par défaut
                edge((i+2/3, 1+(j)*3), (i+2/3,3+(j)*3 + if j == init.at("label").len()-1{5.5}),label-sep: -7.1pt, stroke: stroke.thickness/2 + stroke.paint, if lign-0{$0$})
              }
            },
            if j != init.at("label").len()-1{edge((-0.74,3+(j)*3), (domain.len()+0.122, 3+(j)*3), stroke: stroke)} // ligne sous les tableaux de content
          )},

          if init.at("label").at(j).last() == variation{( // tableau de variation
            for i in range(content.at(j).len()-1){
              let proch= 0
              let decalindef = if content.at(j).at(i).len() >= 3 and i != 0 and (content.at(j).at(i).at(2) == "||" or content.at(j).at(i).at(1) == "||"){0.255} else{0}
              let edgeprochindef = if content.at(j).at(i+1).len() >= 3 and (content.at(j).at(i+1).at(2) == "||" or content.at(j).at(i+1).at(1) == "||"){0.3} else{0}
              let prochainIndef = if content.at(j).at(i).len() >= 3 and i != 0 and (content.at(j).at(i).at(2) == "||" or content.at(j).at(i).at(1) == "||"){
                if content.at(j).at(i).first() == top{1}
                else if content.at(j).at(i).first() == center{1.75}
                else if content.at(j).at(i).first() == bottom{2.5}
              }

              if content.at(j).at(i).len()>2 and i != 0 and content.at(j).at(i).at(2) == "||"{ // cas de l'ajout d'une ligne indéfine

                node((i +2/3 - decalindef*1.06, prochainIndef +(j)*3+ 0.4), content.at(j).at(i).at(3))

                //la double ligne de l'indéfine
                edge(
                  (i +2/3 -0.02 * calc.sqrt(stroke.thickness.pt()) ,3*j + if j == 0{0.9} + if j == 0 and j == init.at("label").len() - 1 {-0.03}),
                  (i +2/3 - 0.02 * calc.sqrt(stroke.thickness.pt()) ,3*j+4 + if j == init.at("label").len()-1{4}),
                  stroke: stroke.thickness/2 + stroke.paint
                )
                edge(
                  (i +2/3 + 0.02 * calc.sqrt(stroke.thickness.pt()),3*j + if j == 0{0.9} + if j == 0 and j == init.at("label").len() - 1 {-0.03}),
                  (i +2/3 + 0.02 * calc.sqrt(stroke.thickness.pt()),3*j+4 + if j == init.at("label").len()-1{4}),
                  stroke: stroke.thickness/2 + stroke.paint
                )
              }

              if content.at(j).at(i).len()>2 and i != 0 and content.at(j).at(i).at(1) == "||"{ // cas de l'ajout d'une ligne indéfine s’il y a 1 seul alignement

                node((i +2/3 - decalindef*1.06, prochainIndef +(j)*3+ 0.4), content.at(j).at(i).at(2))

                //la double ligne de l'indéfine
                edge(
                  (i +2/3 -0.02 * calc.sqrt(stroke.thickness.pt()) ,3*j + if j == 0{0.9} + if j == 0 and 1 == init.at("label").len() {-0.03}),
                  (i +2/3 - 0.02 * calc.sqrt(stroke.thickness.pt()) ,3*j+4 + if j == init.at("label").len()-1{4}),
                  stroke: stroke.thickness/2 + stroke.paint
                )
                edge(
                  (i +2/3 + 0.02 * calc.sqrt(stroke.thickness.pt()),3*j + if j == 0{0.9} + if j == 0 and j == init.at("label").len() - 1 {-0.03}),
                  (i +2/3 + 0.02 * calc.sqrt(stroke.thickness.pt()),3*j+4 + if j == init.at("label").len()-1{4}),
                  stroke: stroke.thickness/2 + stroke.paint
                )
              }

              //traite le premier cas s'il est non défine
              else if content.at(j).at(i).len()>2 and content.at(j).at(i).at(1) == "||"{

                //le node qui contient l'élément
                if content.at(j).at(i).first() == top{
                  node((2/3, 1+(j)*3+0.4), content.at(j).first().last())
                  proch = 1+(j)*3+0.32
                }
                else if content.at(j).at(i).first() == center{
                  node((2/3, 2+(j)*3+ 0.3), content.at(j).first().last())
                  proch = 2+(j)*3+ 0.3
                }
                else if content.at(j).at(i).first() == bottom{
                  node((2/3, 3+(j)*3-0.12), content.at(j).first().last())
                  proch = 3+(j)*3-0.12
                }

                // la ligne de l'indéfine
                edge(
                  (0.4 * calc.pow(stroke.thickness.pt(), 1/20) ,3*j + if j == 0{0.9} + if j == 0 and j == init.at("label").len() - 1 {-0.01}),
                  (0.4 * calc.pow(stroke.thickness.pt(), 1/20) ,3*j+4 + if j == init.at("label").len() - 1 {4}),
                  stroke: stroke.thickness/2 + stroke.paint
                )
              }

              // les nodes contenants les éléments
              if content.at(j).at(i).len()!=0{
                if content.at(j).at(i).at(if content.at(j).at(i).len()>2 and content.at(j).at(i).at(2) == "||"{1} else{0}) == top{
                  node((i +2/3 + decalindef*1.06, 1+(j)*3+0.4), content.at(j).at(i).last())
                  proch = 1+(j)*3+0.4
                }
                else if content.at(j).at(i).at(if content.at(j).at(i).len()>2 and content.at(j).at(i).at(2) == "||"{1} else{0}) == center{
                  node((i +2/3 + decalindef*1.06, 2+(j)*3+ 0.3), content.at(j).at(i).last())
                  proch = 2+(j)*3+ 0.3
                }
                else if content.at(j).at(i).at(if content.at(j).at(i).len()>2 and content.at(j).at(i).at(2) == "||"{1} else{0}) == bottom{
                  node((i +2/3 + decalindef*1.06, 3+(j)*3-0.12), content.at(j).at(i).last())
                  proch = 3+(j)*3-0.12
                }
              }

              // les flèches entre les éléments s'il n'y a pas d'élément à skip
              if content.at(j).at(i+1).len()!=0 and content.at(j).at(i).len()!=0{
                if content.at(j).at(i+1).first() == top{
                  edge((i +2/3 + decalindef ,proch),(i+5/3 + if i+2 != content.at(j).len(){- edgeprochindef} ,3*(j)+1+0.4), arrow, stroke: stroke-arrow)
                }
                else if content.at(j).at(i+1).first() == bottom{
                  edge((i +2/3 + decalindef ,proch),(i+5/3 + if i+2 != content.at(j).len(){- edgeprochindef},3*(j)+3-0.12), arrow, stroke: stroke-arrow)
                }
                else if content.at(j).at(i+1).first() == center{
                  edge((i +2/3 + decalindef ,proch),(i+5/3 + if i+2 != content.at(j).len(){- edgeprochindef} ,3*(j)+2+ 0.3), arrow, stroke: stroke-arrow)
                }
              }

              // élément a skip
              if content.at(j).at(i+1).len()==0 and content.at(j).at(i).len()!=0 {
                if content.at(j).at(i+prochainNonVideVar(content.at(j), i)+1).first() == top{
                  edge(
                    (i +2/3 + decalindef ,proch),
                    (i + (prochainNonVideVar(content.at(j), i)+1)+ 1/3 + 0.3  + if prochainNonVideVar(content.at(j), i)+1 != content.at(j).len(){- edgeprochindef} ,3*(j)+1+0.4),
                    arrow, stroke: stroke-arrow
                  )
                }
                else if content.at(j).at(i+prochainNonVideVar(content.at(j), i)+1).first() == bottom{
                  edge(
                    (i +2/3 + decalindef ,proch),
                    (i + (prochainNonVideVar(content.at(j), i)+1)+ 1/3 + 0.3 + if prochainNonVideVar(content.at(j), i)+1 != content.at(j).len(){- edgeprochindef},3*(j)+3-0.12),
                    arrow, stroke: stroke-arrow
                  )
                }
                else if content.at(j).at(i+prochainNonVideVar(content.at(j), i)+1).first() == center{
                  edge(
                    (i +2/3 + decalindef ,proch),
                    (i + (prochainNonVideVar(content.at(j), i)+1)+ 1/3 + 0.3+ if prochainNonVideVar(content.at(j), i)+1 != content.at(j).len(){- edgeprochindef} ,3*(j)+2 + 0.3),
                    arrow, stroke: stroke-arrow
                  )
                }
              }
            },
            lastele(content.at(j).last(), domain, j,init , stroke), // pour gérer le dernier élément

            if j  != init.at("label").len()-1{edge((-0.74,3*(j)+4), (domain.len()+0.122, 3*(j)+4), stroke: stroke)} // ligne sous les tableaux de variation
          )}
        )}
      )
  }
}