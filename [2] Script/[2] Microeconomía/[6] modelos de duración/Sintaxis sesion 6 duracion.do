
clear all  

global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"
global sesion "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\script\[2] Microeconomía\[6] modelos de duración"

cd "$sesion"

use diaz_maruyama,clear

order semanas salio dur1

*Estadisticas
sum 

* duracion completada promedio 
  table edadgg1 sexo, c(mean dur1) col row f(%4.1f)
  table educ    sexo, c(mean dur1) col row f(%4.1f)
  table cesante sexo, c(mean dur1) col row f(%4.1f)
  table jefe    sexo, c(mean dur1) col row f(%4.1f)

* duracion promedio (completa mas censurada)
  table edadgg1 sexo, c(mean semanas) col row f(%4.1f)
  table educ    sexo, c(mean semanas) col row f(%4.1f)
  table cesante sexo, c(mean semanas) col row f(%4.1f)
  table jefe    sexo, c(mean semanas) col row f(%4.1f)

*estructura de modelos de duracion*
stset semanas, failure(salio) 
stdes
centile semanas

*Estadisticas sobre el tiempo, solo para los que salieron
centile semanas if salio==1 

tab semanas salio //se puede calcular la tasa de riesgo, freq/total, en cada periodo se resta los que salieron

*Este comando reporta el tiempo de falla por periodos de informacion
*en particular el calculo de la funcion de riesgo (hazard rate)

ltable semanas salio, hazard  //ver suma de begtotal
ltable semanas salio, hazard interval(4)

*** Función de riesgo dado el comando sts
sts gr, hazard title("Fn. de riesgo - Hazard") ytitle("Pr. condicional de salir del desempleo") xtitle("Semanas") 

sts gr, hazard title("Fn. de riesgo - Hazard") ytitle("Pr. condicional de salir del desempleo") xtitle("Semanas") by(sexo)

sts gr, hazard title("Fn. de riesgo - Hazard") ytitle("Pr. condicional de salir del desempleo") xtitle("Semanas") by(casado)

sts gr, hazard title("Fn. de riesgo - Hazard") ytitle("Pr. condicional de salir del desempleo") xtitle("Semanas") by(educ)

** Funcion de riesgo acumulado
sts gr, failure title("Fn. de riesgo - Hazard acumulado") ytitle("Pr. condicional de salir del desempleo") xtitle("Semanas") 

sts gr, failure title("Fn. de riesgo - Hazard acumulado") ytitle("Pr. condicional de salir del desempleo") xtitle("Semanas")   by(sexo)

sts gr, failure title("Fn. de riesgo - Hazard") ytitle("Pr. condicional de salir del desempleo") xtitle("Semanas") by(educ)

*** Funcion de supervivencia
sts gr, title("Fn. de supervivencia Kaplan-Meier") ytitle("Pr. condicional de mantenerse en desempleo") xtitle("Semanas")

sts gr, title("Fn. de supervivencia Kaplan-Meier") ytitle("Pr. condicional de mantenerse en desempleo") xtitle("Semanas") by(sexo)

sts gr, by(casado) title("Fn. de supervivencia Kaplan-Meier") ytitle("Pr. condicional de mantenerse en desempleo") xtitle("Semanas")

sts list
sts list, by(sexo) compare at(1 4 8 12 16 24 32 40 48 52)

*** Prueba de hipotesis, Funciones de sobrevivencia son iguales?
sts test sexo // H0: Las Funciones de supervivencia son iguales. 

*-------------------------------------
*** Estimacion del modelo exponencial
*------------------------------------

*Cesante:Tiene experiencia laboral

streg cesante educ0 educ1 educ2 edad lnavging, distribution(exponential) nohr //estima coeficientes

est store expon

stcurve, haz name(g1, replace)
stcurve, sur name(g2, replace)
stcurve, cumh name(g3, replace)
graph combine g1 g2 g3

*-----------------------------------
*** Estimacion para Weibull PH model
*-----------------------------------
streg cesante educ0 educ1 educ2 edad lnavging, distribution(weibull) nohr

est store weibull

*el p viene a ser el alfa= 1.49, pero se puede emplear el ln_p
*Ho: Ln_p==0 (es lo mismo que decir alfa==1) - Solo se necesita una exponencial
//Se  rechaza la Ho según el p valor.

stcurve, haz name(g4, replace)
stcurve, sur name(g5, replace)
stcurve, cumh name(g6, replace)
graph combine g4 g5 g6

*-----------------------------------
* Estimacion para the Cox PH model
*------------------------------------
stcox cesante educ0 educ1 educ2 edad lnavging, nohr

est store cox

estat phtest, rank detail //Ho: Proporciones independientes
estat phtest //Ho: Hay proporcionalidad Cox en las covariables a lo largo del tiempo, aqui se acepta, se puede usar la COX

stphplot, by(casado) //graficos para ver proporcionalidad
stphplot, by(educ0)

stcurve, haz name(g7, replace)
stcurve, sur name(g8, replace)
stcurve, cumh name(g9, replace)
graph combine g7 g8 g9

*** Comparativo
est table expon weibull cox, eq(1) star //Podemos ver similitudes en los coeficientes

*** Esto estima Schoenfeld residuals para cada covariable basado en the Cox PH model
stcox cesante educ0 educ1 educ2 edad lnavging,nohr schoenfeld(sch*)

*Summarise the Schoenfeld residuals for the 'black' covariate
su sch1

** Test del supuesto PH basado en los residuso de Schonfeld
estat phtest, plot(cesante)
estat phtest, plot(educ0)

