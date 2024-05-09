
clear all  // Borrar la base de datos previa

global bases "C:\Trabajos\Bases ENAHO\"
global graficos "C:\Trabajos\Bases ENAHO\Graficos"
global cuadros "C:\Trabajos\Bases ENAHO\Cuadros"
global sesion "C:\Trabajos\Empresa2\ValoraConsult\1. Programas\1. Especialización en Econometría con ENAHO\3. Evaluación de impacto\5. Sesion 5 - VI\"

*------------------------------------------------------------
*   Procesamiento
*-----------------------------------------------------------

do "$sesion/Procesamiento ENAHO para VI"

cd "$bases"

*------------------------------------------------------------------
* Ingresos laborales y años de educación del jefe de hogar (MCO)
*------------------------------------------------------------------

use base_enaho, clear

*** Relación de ingreso por trabajo principal solo para jefe de hogares ocupados //se considera jefes para tener personas más homogeneas y las brechas sean más reales.

keep if ocupado==1 
keep if inghor>0 //Corto la población de estudio a solo ocupados con ingresos

keep if jefe==1 // Tomando solo jefe de hogar ya que la educación de los padres es respecto al jefe

keep if edad>=18 & edad<=65

keep if edu_pa!=.

keep if edu_ma!=.

*** Variable dependiente: salario por hora
tabstat inghor, s(n mean min p25 p50 p75 p95 p99 max)

tabstat inghor, s(n mean min p25 p50 p75 p95 p99 max) by(urbano)

tabstat inghor, s(n mean min p25 p50 p75 p95 p99 max) by(mujer)

tw (kdensity inghor if mujer==0 & inghor<100) (kdensity inghor if mujer==1 & inghor<100) , legend(label(1 "Hombre") label(2 "Mujer")) xline(1025) xtitle("Salario por hora") ytitle("Frecuencia relativa")

*** Quitando extremos del modelo
keep if inghor<=300

*** Trabaja con logaritmo (valores mas normales, errores mas normales)
gen log_inghor=log(inghor)

hist inghor, normal
hist log_inghor, normal

graph twoway (scatter log_inghor educ) (lfit log_inghor educ)

*** Ramas dicotomicas
tab ramas, gen(rama)

*** Cat ocupacion dicotomica
tab cat_ocup, gen(cat_ocup)

*** Variables
global X1 educ mujer casado edad edad2 formal emp100_500 emp500_mas mas60horas kids* urbano sierra rama2-rama6 cat_ocup2 cat_ocup3
 
*** Modelo simple
reg log_inghor educ

** Modelo total
reg log_inghor $X1 
estimates store modelo_mco //almacena en memoria

*** Hallar punto critico (maximo)
display -_b[edad]/(2*_b[edad2])

nlcom  _b[edad]/(2*_b[edad2])

* Graficamente
gen lnw_predic=_b[edad]*edad + _b[edad2]*edad2
scatter lnw_predic edad

*** Multicolinealidad
reg log_inghor $X1
vif // todos los valores por debajo de 5, no hay multicolinealidad

*** Heterocedasticidad a lo white *****
imtest,white //se rechaza la hipotesis de homocedaasticidad
estat hettest

*** Correccion white
reg log_inghor $X1, robust //mejora significancia de variables

*ssc instal outreg2
outreg2 modelo_mco using "$cuadros/regresion_iv.xls", replace //exportar resultados

*----------------------------------------------------------------
* Ingresos laborales y Años de educación del jefe de hogar (Variable instrumental) 
*----------------------------------------------------------------

*Instrumentos

glo Z "edu_pa edu_ma"

*------------------------
*Estimacion en dos etapas 
*------------------------

**Regresion primera etapa

glo X2 mujer casado edad edad2 formal emp100_500 emp500_mas mas60horas kids* urbano sierra rama2-rama6 cat_ocup2 cat_ocup3

reg educ $Z $X2 //coef. de Z es significativo

test $Z //test conjunta F (Relevancia >10)

predict educ_hat

** Regresion de segunda etapa
reg log_inghor educ_hat $X2

*----------------
**** Exogeneidad de Z (cov(Z,e)=0)
*----------------

ivreg log_inghor (educ = $Z) $X2

predict uhat_iv,resid

*----------------------------------
*Test de Sargan //Testear Ho: Z es exogeno
*----------------------------------

reg uhat_iv $Z $X2 //Los coef. de los instrumentos deben de ser no significativos

scalar r2 = e(r2)
scalar sample = e(N)
scalar sargan_test_1 = r2*sample
display sargan_test_1
display chi2tail(1,sargan_test_1) //no se rechaza H0 

*-------------------------
*** Test de exogeniedad de Wu-Hausman (forma 1) //para ver si el regresor "educ" es endogena o exogena
*---------------------------

reg log_inghor $Z $X2
predict ehat, resid 

reg log_inghor educ ehat $X2 //si ehat es significativa entonces educ es endogena, 

*Ho: Exogeneidad de educ, en función del coef. del error 
*Si el error es significativo entonces educ es endogena
*Por lo tanto educ si es endogena
	
*-------------------------
*** Comando ivreg2
*---------------------

*findit ivreg2

ivreg2 log_inghor (educ = $Z) $X2 ,first

ivreg2 log_inghor (educ = $Z) $X2 
estimates store modelo_vi 

esttab modelo_mco modelo_vi, mtitle("MCO" "IV")

outreg2 modelo_vi using "$cuadros/regresion_iv.xls", append

*ivreg2: Este comando brinda test de identificacion de instrumentos débiles, Prueba F de relevancia (debe ser >10), y Sargan (exogeneidad)

*** Prueba canónica de Anderson
*La prueba  de Anderson testea si los instrumentos son debiles

**** Prueba Cragg-Donald
*La prueba Cragg-Donald testea si los instrumentos son debiles (F>10), el instrumento es relevante

**** Prueba Sargan
*Ho: Al menos un instrumetno es exogeno

***Test de Wu-Hausman en STATA (forma 2) 

*Ho: La variable regresora (educ) es exogena
quiet ivreg2 log_inghor (educ = $Z) $X2 

ivendog

** Hausman Ho: No hay diferencia entre MCO y VI
hausman modelo_vi modelo_mco
