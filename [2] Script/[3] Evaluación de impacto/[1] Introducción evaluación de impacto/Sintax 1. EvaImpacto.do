
cd "C:\Trabajos\Empresa\ValoraConsult\Cursos\1. Programas\1. Especialización en Econometria con ENAHO-ENA\3. Econometria (Mod3 - EvaImpacto)\1. Sesion1. EvaImpacto\"

**** Programa de Nutrición (0 a 5 años)

*El indicador de talla por edad (ha_nchs) se expresa en puntuaciones z (desviaciones estándar) y se calcula comparando la estatura del niño con una población de referencia que ha sido debidamente estandarizada. Si el niño se encuentra dentro de ±2 desviaciones estándar de la media (puntuación z entre -2 y +2), se considera que tiene una talla adecuada para su edad. Si la puntuación z es menor a -2 desviaciones estándar, se considera que el niño tiene desnutrición crónica

**************************
**** Talla para la edad****
***************************
				
use experimentos_aleatorios_base,clear

*--------------------------------------*
*1. Estadísticas descriptivas
*--------------------------------------*

format ha_nchs %9.2fc
tabstat ha_nchs, s(n mean min p25 p50 p75 p95 max sd) by(D) format

**** Podemos ver algunas características de la variable ha_nchs. Entre estas, el máximo, mínimo, desviación estándar y promedio.

*----------------------------
*2. Balanceo
*-----------------------------

ttest personas, by(D)
ttest hombre, by(D)
ttest orden_n, by(D)
ttest baja, by(D)
ttest ocupado_jefe, by(D)
ttest educa_jefe, by(D)
ttest ingresos_hogar_jefe, by(D)

*Otra forma es hacerlo con un loop: 
foreach x in personas hombre orden_n baja ocupado_jefe educa_jefe ingresos_hogar_jefe  {
ttest `x', by (D)
}

*--------------------------------------*
*3. Impacto del programa
*--------------------------------------*

ttest ha_nchs, by(D)

*incrementa 0.2343 sd en estatura según edad
*1 sd equivale mas omenos entre 3 y 5 cm dependiendo de la edad

*-------------------------------------------------------------------*
*4.Regresión con "D" siendo la única variable explicativa *
*----------------------------------------------------------------*

reg ha_nchs D

**** Mediante la estimación de MCO podemos ver una prueba de diferencia de medias entre los dos grupos (tratamiento
**** y control).
*------------------------------------------------*
*5. Regresión adicionando variables explicativas
*------------------------------------------------*
*Esto mejora la estimación a pesar de la aleatorización
*ssc install outreg2

global X "personas hombre orden_n baja ocupado_jefe educa_jefe ingresos_hogar_jefe"

reg ha_nchs D $X

**** Dado que en realidad la variable talla para la edad depende de factores adicionales
**** como el ingreso del jefe de hogar, el orden de nacimiento, la educación del jefe de hogar
**** y el número de personas en el hogar, entre otras, realizamos la prueba de diferencia de medias
**** entre los dos grupos pero ahora controlando por estas variables.

****************************************
**** Verificación de aleatorización ****
****************************************

dprobit D $X //te saca los efectos marginales

logit D $X
margins,  dydx(*) post

//Ninguna de las variables es significativa en ninguno de los dos modelos y ningún modelo es significativo. Esto nos garantiza la aleatorización en la asignación del tratamiento.

****************************************
**** 			Outreg2 			****
****************************************

reg ha_nchs D
outreg2 using "resultados_aleatorio.xlsm", excel

reg ha_nchs D $X 
outreg2 using "resultados_aleatorio.xlsm", excel append
