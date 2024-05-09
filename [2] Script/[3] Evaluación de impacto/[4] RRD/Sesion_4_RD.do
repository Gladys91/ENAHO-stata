
global sesion "C:\Trabajos\Empresa2\ValoraConsult\1. Programas\1. Especialización en Econometría con ENAHO\3. Evaluación de impacto\4. Sesion 4 - RD\"

*---------------------------------------------------------------
*  Estimar el efecto de la victoria de un partido político en un año "t" sobre el porcetaje de votación que tendría en el año "t+2"
*-----------------------------------------------------------------

*El autor usa el margen de victoria en un año "t", en este caso del partido demócrata

**====== Sesion 4 - Regresión discontinua =======**

use "$sesion/Sesion_4_data.dta", clear

*search rdrobust //install package st0366

** Comenzamos renombrando y generando algunas variables de interes

rename demmv x //margen de victoria demócrata
sum 

rename demvoteshfor2 y //proporción de votos dos años después

*En este caso x=0 por lo que recentrar es lo mismo.

/* Generamos nuestra dummy de tratamiento, que sera =1 para las observaciones que
   tienen un valor mayor o igual a cero en "x", que es el margen de votacion.
   De esta forma tenemos un indicador de victoria de los democratas */
gen D=0 if x<0 & x!=.
replace D=1 if x>=0 & x!=.
label var D "Victoria demócrata en t"

* Usamos el comando "order" para colocar nuestras tres variables al comienzo
order y x D

** Graficos de dispersion
* Este grafico muestra la discontinuidad en la probabilidad de tratamiento 
scatter D x

* Este grafico muestra la relacion entre la variable Y y running variable
scatter y x 
scatter y x if x>-5 & x<5

sum

** Grafico
rdplot y x, c(0) graph_options(title("RD Plot: U.S. Senate Election Data") ytitle(Democratic vote share in next election at time t+2) xtitle(Democratic vote share Margin of Victory at time t) graphregion(color(white)))

** Analisis de regresion **
/* Comenzamos comprobando el signo y la significancia de nuestra variable de asignacion para ver si se comporta como esperamos. 
   
Pensamos que un mayor margen de victoria en el periodo T esta relacionado con un mayor porcentaje de votos en en T+2 */
reg y x

* Podriamos utilizar esta regresion unicamente con la dummy de tratamiento, esto no es preciso 
reg y D

predict y_p
scatter y_p x

*----------------------------------------
*  No paramétrica 
*---------------------------------------

/* Probamos con diferentes valores de h para generar una discontinuity sample. Estas son regresiones locales que son nuestro metodo no parametrico para estimar el efecto de tratamiento en RDD
   
Con abs(x)<h le indicamos a Stata que considere solamente las observaciones con valor absoluto de x menor al valor que indicamos (nuestra bandwidth) */

reg y D if abs(x)<50
reg y D if abs(x)<20
reg y D if abs(x)<10

/* Usamos nuestra regla empírica para estimar la bandwidth (h)
Primero obtenemos la desviacion estandar de x mediante el comando summarize. 
Luego generamos un escalar (un valor puntual) con la formula de h */

sum x
scalar h=1.06*r(sd)*_N^(-0.2)
di h

* Usamos este valor calculado de h para estimar una nueva regresion local
reg y D if abs(x)<h

*----------------------------------------
* Estimación parametrica
*----------------------------------------
reg y c.x##D //efecto es el coefciente de variable D

* Generamos variables de interaccion y de termino cuadratico
gen Dx=D*x
gen x2=x^2
gen Dx2=D*x2

* Utilizamos nuestras variables nuevas para estimar la regresion siguente
reg y D x x2 Dx Dx2

* Lo anterior es equivalente a indicar dos interacciones en Stata:
reg y c.x##D c.x2##D

/* Agregamos algunos controles para probar si nuestra estimacion de rho (coeficiente de d=1) es solida */
reg y D x x2 Dx Dx2 i.state
reg y D x x2 Dx Dx2 i.state i.year

*----------------------------------------
*  No paramétrica con comando rdrobust
*---------------------------------------

*ssc install rdrobust

/* Comparamos una regresion como las anteriores con lo obtenido por rdrobust Este comando nos permite especificar el grado del polinomio p(), y el valor de la bandwidth h() */

reg y x D Dx if abs(x)<h //Estimación no paramétrica

rdrobust y x, kernel(uniform) p(1) h(8.556812) //Para comparar

/* Podemos comparar tambien con esta regresion. Con rdrobust no necesitamos indicar interacciones ni generar variables nuevas */
reg y D x x2 Dx Dx2  if abs(x)<h

rdrobust y x, kernel(uniform) p(2) h(8.556812)

* El paquete tambien incluye rdplot para graficos de discontinuidad.
rdplot y x, nbins(2500 500) p(0)
rdplot y x, nbins(2500 500) p(1)
rdplot y x, nbins(2500 500) p(2)

rdplot y x, p(2)
