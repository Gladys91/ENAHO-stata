
clear all  // Borrar la base de datos previa

 
global sesion "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\script\[2] Microeconomía\[2] logit\"

*-------------------
*   Procesamiento
*------------------

do "$sesion/Procesamiento ENAHO.do"

cd "$bases"

*----------------------------------------------------------------
*     Modelo logit: Determinates de la pobreza en el hogar 
*--------------------------------------------------------------

//Esta base es una base de hogares del año 2021
use base_enaho, clear

keep if jefe==1 //Solo se trabajará con hogares y jefes de hogar

count

describe

sum

*---------------------
*** Ver correlaciones
*---------------------
global X log_ingper agua elect hombre casado edad estatal neduc2 neduc3 neduc4 neduc5 ocupado independiente percepho kids614 kids0a5 urbano sierra selva //la categorica educativa está en dummys

correlate $X
return list

matrix matriz_cor=r(C)
matrix list matriz_cor

** Chi cuadrado
tab agua desag, chi2  V //Ho: Hay independia

tab urbano desag, chi2  V //Chi2 con V de Cramer para variables categoricas no ordinales

*---------------------
*    Mapa de calor
*--------------------
* ssc install heatplot
* ssc install palettes
* ssc install colrspace

rename (log_ingper agua desag elect hombre casado edad estatal educ ocupado independiente kids614 kids0a5) (ly ag des el hom ca ed est edu ocu ind k1 k2)

global Xm ly ag de el hom ca ed est edu ocu ind k1 k2

correlate $Xm
matrix matriz_cor=r(C)

heatplot matriz_cor, colors(blue cyan magenta orange red)

heatplot matriz_cor, legend(off) colors(blue cyan magenta orange red)

**regresando
ren (ly ag de el hom ca ed est edu ocu ind k1 k2) (log_ingper agua desag elect hombre casado edad estatal educ ocupado independiente kids614 kids0a5) 

****Variable Y: pobre
fre pobre

*--------------------
*** Modelo preliminar
*---------------------

logit pobre $X //hay que ver la lógica de los signos

//Seudo R2 es complementario pero debe de ser aceptable
// La variable ingreso capta otras variables

*--------------
**** Modelo 1
*--------------
global  xb1 agua desag elect hombre casado edad edad2 neduc2 neduc3 neduc4 neduc5 ocupado formal kids614 kids0a5 urbano sierra selva 

logit pobre $xb1  //ver signos
estimates store m1
lstat //ver tambien Seudo R2

*-------------
*** Modelo 2
*------------
global  xb2 log_ingper casado neduc2 neduc3 neduc4 neduc5 formal estatal kids614 kids0a5 

logit pobre $xb2 //ver signos
estimates store m2
lstat

*criterios de información para comparar modelos
estimates table m1 m2, stat(aic bic)

*** Modelo2
logit pobre $xb2

*predicción de probabilidades
predict pobre_logit

br pobre_logit pobre

sum pobre_logit

*Calculo el Y predicho con corte 0.5
gen pobre_est=(pobre_logit>=0.5) //por defecto 

tab pobre_est pobre 

br pobre_est pobre 

*Para ver la precisión, sensibiidad y especificidad
lstat

*Dibujar la sensibilidad y especificidad
lsens, xline(0.21)

logit pobre $xb2
lstat, cutoff(0.21)
lstat, cutoff(0.22)

*Curva ROC
lroc

*calculo una variable predicha pero con corte 0.21
drop pobre_est
gen pobre_est=(pobre_logit>=0.21) //corregido

tab  pobre_est pobre, col

*-----------------------
*    Efectos marginal
*-----------------------
logit pobre $xb2

*** Efecto marginal promedio total
** Esto es lo que se presenta generalmente
margins, dydx(*) 

*** Efecto marginal en el promedio
logit pobre $xb2
margins, dydx(*) atmean 

*** Probabilidad de Y=1 en un punto especifico
logit pobre $xb2
margins, at(neduc5=1 casado=0 estatal=0)

 *** //Predicción en probabilidades
predict xbb, xb 
label var xbb "xb-logit"
scatter pobre pobre_logit xbb, symbol(+ o) jitter(2) l1title("Pr Logit")

*** Comparando modelos logit y probit
logit pobre $xb2 
estimate store  modelo1

probit pobre $xb2
estimate store  modelo2

esttab modelo1 modelo2, aic bic  star(* 0.10 ** 0.05 *** 0.01)

*------------------
**** Modelo probit
*-------------------

quietly logit pobre $xb2
lstat
margins, dydx(*) 
matrix logit_dydx=r(b)'

quietly probit pobre $xb2
lstat
margins, dydx(*) 
matrix probit_dydx=r(b)'

matrix unido=matrix(logit_dydx,probit_dydx)
matrix list unido

*------------
* ODS Ratio
*-----------

logistic pobre $xb2

*------------------------------
******Tarea
*Hacer un modelo logit o probit para la variable Y (1: informalidad) en el cap500 (ocupinf) 




