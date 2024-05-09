
clear all  // Borrar la base de datos previa

global bases "C:\Trabajos\Bases ENAHO\"
global graficos "C:\Trabajos\Bases ENAHO\Graficos"
global cuadros "C:\Trabajos\Bases ENAHO\Cuadros"
global sesion "C:\Trabajos\Empresa2\ValoraConsult\1. Programas\1. Especialización en Econometría con ENAHO\3. Evaluación de impacto\5. Sesion 5 - VI\"

*-----------------------------------*
*    Variables instrumentales       *
*-----------------------------------*

*** Abriendo base
use "$sesion/variables_instrumentales_base",clear

**** Para simplificar el análisis definimos un vector global con las variables control que se han utilizado antes:

global X "personas orden_n ocupado_jefe educa_jefe ingresos_hogar_jefe"

**** Veamos los resultados de una estimación simple por MCO:

tabstat ha_nchs, by(D) s(mean min p25 p50 p75 max sd)

reg ha_nchs D $X

**** Instrumentos: Número de oficinas operadoras en el municipio y distancia a las oficinas

*------------------*
* 1. Relevancia    *
*------------------*

**** 1.3 Distancia y oficinas operadoras:

reg D of_op distancia $X

test of_op distancia //F elevado

//Vemos que la distancia sí puede ser un buen predictor de la variable "D". El valor del estadístico F es 19,23. Si el estadístico F es superior a diez, se puede asegurar que el instrumento es relevante. Además, todos los coeficientes son estadísticamente significativos.

**** Podemos concluir, por lo tanto, que los instrumentos son relevantes.

*------------------*
* 2. Exogeneidad   *
*------------------*
**** Lo que vamos a hacer es predecir los errores de MCO y verificar que estos no estén relacionados con el instrumento

reg ha_nchs D $X

predict uhat, resid

**** 2.2.1 Regresión de errores en función de los instrumentos

reg uhat of_op distancia $X

*----------------------------*
*  3. Estimación por MC2E    *
*----------------------------*

**** Dado que ya probamos que los instrumentos que tenemos pueden ser utilizados, procedemos a realizar la estimación mediante MCO en dos etapas. 

**** Para llevar a cabo la estimación de manera directa con el comando "ivreg2" instrumentando el tratamiento con la distancia y el número de oficinas operadoras en el municipio:

ivreg2 ha_nchs (D = distancia of_op) $X , first

**** Utilizando mínimos cuadrados en dos etapas vemos que el efecto del tratamiento disminuye.

**** Mediante MCO el efecto del tratamiento en la talla para la edad era de 0.24 desviaciones estándar. Sin embargo, mediante MC2E pudimos confirmar que en realidad el efecto es 0.21. 
