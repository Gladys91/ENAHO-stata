
clear all  // Borrar la base de datos previa

global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"
global sesion "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\script\[2] Microeconomía\[1] mco\"

*------------------------------------------------------------
*   Procesamiento (Se va a trabajar con toda la PEA ocupada)
*-----------------------------------------------------------

do "$sesion/Procesamiento ENAHO"

cd "$bases"

*------------------------------------------------------------------
* Ingresos laborales y brecha salarial (MCO) para la PEA ocupada
*------------------------------------------------------------------

** PROPUESTA DE TAREA: Hacer algo similar a este ejercicio pero analizando a las parejas (casados, convivientes) donde ambos tengan ingresos laborales para analizar la brecha salarial, similar al trabajo de Nicodemo (2009)

*****************************
use base_enaho, clear

*** Relación de ingreso por trabajo principal solo para jefe de hogares ocupados //se considera jefes para tener personas más homogeneas y las brechas sean más reales.

keep if ocupado==1 
keep if inghor>0 //Corto la población de estudio a solo ocupados con ingresos

*** Variable dependiente: salario por hora
tabstat inghor, s(n mean min p25 p50 p75 p95 p99 max)
tabstat inghor, s(n mean min p25 p50 p75 p95 p99 max) by(urbano)
tabstat inghor, s(n mean min p25 p50 p75 p95 p99 max) by(mujer)
sum inghor,d

tw (kdensity inghor if mujer==0 & inghor<100) (kdensity inghor if mujer==1 & inghor<100) , legend(label(1 "Hombre") label(2 "Mujer")) xline(1025) xtitle("Salario por hora") ytitle("Frecuencia relativa")

graph export "$graficos/Densidad salario.png", replace

*** Quitando extremos del modelo
graph box inghor

keep if inghor<=300

*** Trabaja con logaritmo (valores mas normales, errores mas normales)
gen log_inghor=log(inghor)

hist inghor, normal name(h1,replace)
hist log_inghor, normal name(h2,replace)

graph combine h1 h2

graph twoway (scatter log_inghor educ) (lfit log_inghor educ)

*** Variables Explicativas

foreach x of varlist mujer educ casado jefe formal emp100_500 emp500_mas mas60horas kids* estatal urbano sierra selva ramas cat_ocup {

fre `x'
}

*** Variables
global X1 educ mujer casado edad edad2 jefe formal emp100_500 emp500_mas mas60horas kids* estatal urbano sierra selva
 
*** Correlaciones (revisar multicolinealiadad)
correlate $X1

*------------------
*** Modelo simple
*------------------
reg log_inghor educ

estimates store modelo1  //almacena modelo

*** Añadiendo algunas variables
reg log_inghor educ mujer //añadiendo mujer

reg log_inghor educ mujer formal

*---------------
** Modelo total
*----------------
reg log_inghor $X1 i.ramas i.cat_ocup

estimates store modelo2 

*** Hallar punto critico en edad (maximo)
display -_b[edad]/(2*_b[edad2])

nlcom  _b[edad]/(2*_b[edad2])

* Graficamente
gen lnw_predic=_b[edad]*edad + _b[edad2]*edad2
scatter lnw_predic edad

*---------------------
*** Multicolinealidad
*---------------------
reg log_inghor $X1 i.ramas i.cat_ocup
vif // todos los valores por debajo de 5, no hay multicolinealidad

*-------------------------------------------------------
** Análisis de significancia de cada estimador y prueba F
*--------------------------------------------------

* Prueba F, todas las beta son igual a cero 

*** Ver R2
*Por lo general en las investigaciones el R2 no pasa de 40%

*------------------------------------------
*** Heterocedasticidad ****
* White: regresiona error^2 con los regresores
*------------------------------------------


imtest,white //se rechaza la hipotesis de homocedaasticidad
estat hettest

*** Correccion (Se estima la matriz de varianzas-covarianzas) es para muestras grandes

reg log_inghor $X1 i.ramas i.cat_ocup, robust //mejora significancia de variables

estimates store modelo3 //almacena en memoria

*---------------------
*** Predicciones de Y 
*----------------------
predict log_inghor_mco,xb //predcir Y 

br log_inghor log_inghor_mco

*----------------
*** Normalidad
*--------------
predict errores,res //predecir residuos
format errores %2.0f
sum errores, d format

kdensity errores,normal //graficamente los residuos distan de la normalidad

graph box residuos

qnorm residuos //la línea es la normal, el grafico se sale de la linea, por lo tanto no es normal

sktest residuos //se rechaza normalidad
swilk residuos // se rechaza normalidad

** No es normal pero se aproxima, además en promedio es cero. La normalidad es más importante para predecir que para explicar.

*** En caso de no haber normalidad, una solución es aumentar el tamaño de la muestra. Otra borrar datos atipicos de otras variables, aplicar logartimos a otras variables

*--------------------
*** Comparar modelos
*--------------------
esttab modelo1 modelo2 modelo3, r2 ar2 aic bic  star(* 0.10 ** 0.05 *** 0.01)  //indicadores para comparar modelos

*--------------------
*** Exportar modelos
*--------------------
*ssc instal outreg2
reg log_inghor educ
estimates store modelo1
outreg2 modelo1 using "$cuadros/regresion1.xls", replace

reg log_inghor $X1 i.ramas i.cat_ocup
estimates store modelo2 
outreg2 modelo2 using "$cuadros/regresion1.xls", append

reg log_inghor $X1 i.ramas i.cat_ocup, robust
estimates store modelo3
outreg2 modelo3 using "$cuadros/regresion1.xls", append   

