
*Modelos ordinales: ologit , oprobit
*Modelos nominales: mlogit, mprobit 
*----------------------------------------

clear all  // Borrar la base de datos previa

global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"

cd "$bases"

*********************************
* Analizar la pobreza extrema
*--------------------------------

do "$sesion/Procesamiento ENAHO.do"

cd "$bases"

*----------------
*** Abrir base 
*-----------------
use base_enaho, clear

keep if jefe==1 //Solo se trabajará con hogares y jefes de hogar

count

describe

*--------------------------------------------------------------
*                       Modelo
*--------------------------------------------------------------

*-----------------------------
*   Variable dependiente
*-------------------------

* Quiero que el pobre extremo tenga el número 3

fre pobreza

gen pobreza2=1 if pobreza==3
replace pobreza2=2 if pobreza==2
replace pobreza2=3 if pobreza==1


*--------------------------------
*     Variables independientes
*--------------------------------

global  X1 log_ingper casado neduc2 neduc3 neduc4 neduc5 formal estatal kids614 kids0a5 

sum $X1

*--------------------------------------
*           Modelo ologit
*--------------------------------------

*Correlaciones
correlate $X1

*** Modelo

ologit pobreza2 $X1

oprobit pobreza2 $X1

*Podemos ver los cortes (cut 1 cut2), en esta primer ecuación se puede ver los signos.

*** Valores predichos
predict no_pobre pobre_noext pobre_ext   

sum no_pobre pobre_noext pobre_ext 

br no_pobre pobre_noext pobre_ext 

ologit pobreza2 $X1
fitstat //Ver R2 Count que es % de acierto

//calcula la probabilidad para cada nivel de Y en cada individuo. Cada variable predicha tiene independencia, se puede entender que el modelo construye 3 logit

dotplot no_pobre pobre_noext pobre_ext 

*** Efectos marginales promedio
margins, dydx(*) predict(outcome(3)) //pobre_ext
margins, dydx(*) predict(outcome(2))  //pobre_noext
margins, dydx(*) predict(outcome(1))  //no_pobre

*** Efectos marginales en el punto medio
margins, dydx(*) predict(outcome(3)) atmean 

*--------------------------------
* Multinomial (solo a modo de ejemplo)
*---------------------------------

mlogit pobreza2 $X1, b(1) //indicar categoría base

predict p1 p2 p3

dotplot no_pobre p1
dotplot pobre_noext p2
dotplot pobre_ext p3

margins, dydx(*) predict(outcome(3)) //pobre_ext
margins, dydx(*) predict(outcome(2))  //pobre_noext
margins, dydx(*) predict(outcome(1))  //no_pobre

