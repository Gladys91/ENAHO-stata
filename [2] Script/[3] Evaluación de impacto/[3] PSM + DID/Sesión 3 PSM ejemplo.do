
********************************************
* Sesión 3 Emparejamiento 
********************************************

clear all  

global bases "C:\Trabajos\Bases ENAHO\"
global graficos "C:\Trabajos\Bases ENAHO\Graficos"
global cuadros "C:\Trabajos\Bases ENAHO\Cuadros"
global sesion "C:\Trabajos\Empresa\ValoraConsult\Cursos\1. Programas\1. (Docente) Especialización en Econometria con ENAHO-ENA\3. Avanzado\3. Sesion3 - PSM\"

cd "$bases"

* Redireccionar y cargar la base de datos
use "$sesion/Base_psm.dta", clear

**************************************
* Probabilidad de participacion
**************************************

* Estimamos probabilidades de participacion

* Empleamos dprobit para generar directamente los efectos marginales

* Notar que el parametro de la variabe hombre resulta no significativo. Guarda lÃ³gica debido a que el  programa no se focaliza en hombres o mujeres 
   
* Fijamos un vector para todas las variables

global X "ingresos_hogar_jefe personas orden_n educa_jefe ocupado_jefe"

dprobit D $X

* Paso 2: Generamos las probabilidades predichas en el probit
predict pscore 

* Paso 3: Observamos los resultados en histogramas

histogram pscore, by(D) // Tratados y No tratados

twoway kdensity pscore if D==0 || kdensity pscore if D==1,  legend(order(1 "No tratados" 2 "Tratados"))

*-------------------------------------------------------------------*
*4. Seleccion de un algoritmo de emparejamiento (talla para la edad)*
*-------------------------------------------------------------------*
set seed 50
drawnorm orden
sort orden

**** 4.1 Estimador PSM por vecino más cercano

psmatch2 D $X, outcome(ha_nchs2) n(1) com

pstest $X //Balanceo 

psgraph //grafico emparejamiento

** Con regresión
reg ha_nchs2 D [pw=_weight],robust

****
// |t|>1.64 entonces coeficiente significativo al 10%
// |t|>1.96 entonces coeficiente significativo al 5%
// |t|>2.33 entonces coeficiente significativo al 1%

** Con el matching
twoway (kdensity _pscore if D==0 [aw=_weight], legend(label(1 "Controles")))(kdensity _pscore if D==1 [aw=_weight], legend(label(2 "Tratados"))), name(conm, replace)

**** 4.2 Matching con 5 vecinos

psmatch2 D $X, outcome(ha_nchs2) n(5) com


**** 4.4.1 Emparejamiento de distancia 

psmatch2 D $X, outcome(ha_nchs2) radius caliper(0.001) com

psmatch2 D $X, outcome(ha_nchs2) radius caliper(0.005) com		

**** 4.5.1 Emparejamiento por kernel

psmatch2 D $X, outcome(ha_nchs2) com kernel  

pstest $X //Balanceo 

psgraph //grafico emparejamiento

bootstrap r(att) : psmatch2 D $X, out(ha_nchs2) com kernel 

** Con regresión
reg ha_nchs2 D [pw=_weight],robust

*---------------------------------------------------------------------*
*5. Seleccion de un algoritmo de emparejamiento (desnutrición
*---------------------------------------------------------------------*
**** 5.1.1 Imponiendo el soporte comÃºn mediante el comando:

psmatch2 D $X, outcome(desn_cr) n(1) com

pstest $X //Balanceo 

psgraph //grafico emparejamiento

**** 5.2 Matching con 5 vecinos

**** 5.2.1 Imponiendo el soporte comun mediante el comando:

psmatch2 D $X, outcome(desn_cr) n(5) com

**** 5.3 Matching con 10 vecinos

**** 5.3.1 Imponiendo el soporte comÃºn mediante el comando:

psmatch2 D $X, outcome(desn_cr) n(10) com

**** 5.4.1 Emparejamiento de distancia

psmatch2 D $X, outcome(desn_cr) radius caliper(0.001) com

psmatch2 D $X, outcome(desn_cr) radius caliper(0.005) com		
**** 5.5.1 Emparejamiento por kernel

psmatch2 D $X, outcome(desn_cr) com kernel

bootstrap r(att) : psmatch2 D $X, out(desn_cr) com kernel

*-----------------------------------* 
* 6. Dobles diferencias emparejadas (PSM + DID) *
*-----------------------------------*

**** Lo primero que debemos hacer es generar la variable de diferencia entre las dos observaciones:

gen delta_ha=ha_nchs2-ha_nchs1

**** 6.1 Estimador PSM por vecino mÃ¡s cercano.

**** 6.1.1 Imponiendo el soporte comun

psmatch2 D $X, outcome(delta_ha) n(1) com 

pstest $X //Balanceo 

psgraph //grafico emparejamiento

**** 6.2 Matching con 5 vecinos

**** 6.2.1 Imponiendo el soporte comun mediante el comando:

psmatch2 D $X, outcome(delta_ha) n(5) com

**** 6.4.1 Emparejamiento de distancia maxima

psmatch2 D $X, outcome(delta_ha) radius caliper(0.001) com

psmatch2 D $X, outcome(delta_ha) radius caliper(0.005) com		

**** 6.5.1 Emparejamiento por kernel

psmatch2 D $X, outcome(delta_ha) com kernel

bootstrap r(att) : psmatch2 D $X, out(delta_ha) com kernel

