
clear all  // Borrar la base de datos previa

global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"
global sesion "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\script\[2] Microeconomía\[5] modelos de regresión cuántilica\"

*------------------------------------------------------------
*   Procesamiento (Se va a trabajar con toda la PEA ocupada)
*-----------------------------------------------------------

do "$sesion/Procesamiento ENAHO"

cd "$bases"

*------------------------------------------------------------------
* Ingresos laborales y brecha salarial (MCO) para la PEA ocupada
*------------------------------------------------------------------

*****************************
use base_enaho, clear

*** Relación de ingreso por trabajo principal solo para jefe de hogares ocupados //se considera jefes para tener personas más homogeneas y las brechas sean más reales.

keep if ocupado==1 
keep if inghor>0 //Corto la población de estudio a solo ocupados con ingresos

*keep if dpto==24 //El dpto que se desea

*keep if sec_pub==1 //Solo para el sector público

*Analizar solo urbano 
*keep if urbano==1

*** Variable dependiente: salario por hora
tabstat inghor, s(n mean min p25 p50 p75 p95 p99 max)

tabstat inghor, s(n mean min p25 p50 p75 p95 p99 max) by(urbano)

tabstat inghor, s(n mean min p25 p50 p75 p95 p99 max) by(mujer)

sum inghor,d

tw (kdensity inghor if mujer==0 & inghor<100) (kdensity inghor if mujer==1 & inghor<100) , legend(label(1 "Hombre") label(2 "Mujer")) xline(1025) xtitle("Salario por hora") ytitle("Frecuencia relativa")

*** Imputando con la mediana

summarize inghor,d

replace inghor=r(p50) if inghor>=300

*** Trabaja con logaritmo (valores mas normales, errores mas normales)
gen log_inghor=log(inghor)
hist inghor, normal
hist log_inghor, normal

graph twoway (scatter log_inghor educ) (lfit log_inghor educ)

*** Variables
global X1 mujer educ casado edad edad2 jefe formal emp100_500 emp500_mas mas60horas kids* estatal urbano sierra disca
 
*** Correlaciones
correlate $X1

*** Modelo simple
reg log_inghor mujer educ

** Modelo final
reg log_inghor $X1 i.ramas i.cat_ocup

*** Hallar punto critico (maximo)
display -_b[edad]/(2*_b[edad2])

nlcom  _b[edad]/(2*_b[edad2])

* Graficamente
gen lnw_predic=_b[edad]*edad + _b[edad2]*edad2
scatter lnw_predic edad

*** Multicolinealidad
reg log_inghor $X1 i.ramas i.cat_ocup
vif // todos los valores por debajo de 5, no hay multicolinealidad

*** Heterocedasticidad a lo white *****
imtest,white //se rechaza la hipotesis de homocedasticidad
estat hettest

*** Correccion white
reg log_inghor $X1 i.ramas i.cat_ocup, robust //mejora significancia de variables
estimates store modelo1 //almacena en memoria

*** Predecir Y en toda la muestra
predict log_inghor_mco,xb //estimar toda la muestra

br log_inghor_mco log_inghor

*** Normalidad
predict residuos,resid //predecir residuos

format residuos %2.0f
sum residuos, d format
*ssc instal asdoc
asdoc sum, save($cuadros/Descriptivos.doc)

kdensity residuos,normal //graficamente los residuos distan de la normalidad
graph box residuos
qnorm residuos //la línea es la normal, el grafico se sale de la linea, por lo tanto no es normal
sktest residuos //se rechaza normalidad
swilk residuos // se rechaza normalidad

** No es normal pero se aproxima, además en promedio es cero.

*ssc instal outreg2
outreg2 modelo1 using "$cuadros/regresion_cuantil.xls", replace ctitle ("MCO")

*----------------------------------------------------------------
*    Ingresos laborales y brecha salarial (Regresión Cuantil) 
*----------------------------------------------------------------

qreg log_inghor $X1 i.ramas i.cat_ocup //Por default es la mediana	

qreg log_inghor $X1 i.ramas i.cat_ocup, quantile (0.1)
	
qreg log_inghor $X1 i.ramas i.cat_ocup, quantile (0.9)

** Si queremos usar robust, instalamos qreg2
ssc install qreg2

qreg2 log_inghor $X1 i.ramas i.cat_ocup
predict predp50
estimates store modelo2
outreg2 modelo2 using "$cuadros/regresion_cuantil.xls", append ctitle("Mediana")

qreg2 log_inghor $X1 i.ramas i.cat_ocup, quantile (0.1)
predict predp10
estimates store modelo3 
outreg2 modelo2 using "$cuadros/regresion_cuantil.xls", append ctitle("P10")

qreg2 log_inghor $X1 i.ramas i.cat_ocup, quantile (0.9)
predict predp90
estimates store modelo3 
outreg2 modelo2 using "$cuadros/regresion_cuantil.xls", append ctitle("P90")

*** Gráfico
twoway (scatter log_inghor educ) (lfit log_inghor_mco educ, lcolor(blue)) (lfit predp50 educ, lcolor(red)) (lfit predp10 educ, lcolor(green)) (lfit predp90 educ, lcolor(purple)), legend(on order(1 "" 2 "mco" 3 "mediana" 4 "q10" 5 "q90")) title(Logaritmo salario y años de escolaridad)

twoway (scatter log_inghor mujer) (lfit log_inghor_mco mujer, lcolor(blue)) (lfit predp50 mujer, lcolor(red)) (lfit predp10 mujer, lcolor(green)) (lfit predp90 mujer, lcolor(purple)), legend(on order(1 "" 2 "mco" 3 "mediana" 4 "q10" 5 "q90")) title(Logaritmo salario y condición de ser mujer)

*** Grafico de los beta para la variable mujer (brecha de genero) en cada cuantil
matrix Q=J(99,2,0)
local i=0.01 //percentiles
while `i'<1{
qreg log_inghor mujer educ formal, quantile(`i')
matrix Q[`i'*100,1]=e(q)
matrix Q[`i'*100,2]=_b[mujer]
local i=`i'+0.01
}
svmat Q, name(quantile)
rename quantile1 quantile
rename quantile2 beta

twoway (line beta quantile, msize(vtiny) mstyle(p1) clstyle(p1)),yline(-0.25, lcolor(red)) title(Brecha salarial Hombre-Mujer para cada percentil)


