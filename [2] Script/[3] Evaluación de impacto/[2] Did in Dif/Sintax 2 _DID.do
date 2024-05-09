
cd "C:\Trabajos\Empresa2\ValoraConsult\1. Programas\1. Especialización en Econometría con ENAHO\3. Evaluación de impacto\2. Sesion 2 - DifDif\"
			 
			 *----------------------------------------------------------------**--------------    Diferencias en diferencias    -------------  *    PANEL ANCHO    *

*-------------------------------------------*
*1. Veamos algunas estadísticas descriptivas*
*-------------------------------------------*

use experimentos_naturales_panel_base,clear


*Talla para la edad de los individuos del grupo de tratamiento en el primer periodo

*Talla para la edad de los individuos del grupo de control en el primer periodo

tabstat ha_nchs1, by(D)

*Talla para la edad de los individuos del grupo de tratamiento en el segundo periodo
*Talla para la edad de los individuos del grupo de control en el segundo periodo

tabstat ha_nchs2, by(D)

**** Aparentemente, existe una diferencia entre los individuos de tratamiento y de control en el primer periodo en lo referente
**** a la variable talla para la edad "ha_nchs. Además, esta diferencia se incrementa en el tiempo.

**** Haciendo una prueba de diferencia de medias, podemos ver que en los dos periodos hay una diferencia estadísticamente significativa que es mayor en el segundo periodo:

ttest ha_nchs1, by(D)

ttest ha_nchs2, by(D)

**** Mientras que en el primer periodo la diferencia es de 0.1, para el segundo se incrementa hasta 0.3. 


*--------------------------------------------------------*
*2. Modelo de diferencias en diferencias con datos panel *
*--------------------------------------------------------*

**** Para correr el modelo básico de diferencias en diferencias, utilizando una base de datos panel, utilizamos como variable dependiente el cambio en la talla para la edad en función del tratamiento. 

gen delta_ha_nchs=ha_nchs2-ha_nchs1

*impacto
reg delta_ha_nchs D

*El coeficiente asociado a la variable "D" tiene una magnitud de 0.2 y es significativo. Esto nos indica que la diferencia de talla para la edad entre los individuos de tratamiento y control se incrementa en 0.2 por la aplicación del tratamiento. 

*------------------------------------------------------------------------------------------*
*3. Modelo de diferencias en diferencias con datos panel utilizando regresores adicionales *
*------------------------------------------------------------------------------------------*

**** Podemos suponer que el crecimiento en la variable talla para la edad, además de deberse al tratamiento y al crecimiento natural en el tiempo, puede tener su origen en características de los individuos. 
**** Por ejemplo, resulta razonable suponer que el crecimiento en la talla para la edad de un individuo también está asociado al ingreso en el primer periodo del jefe del hogar. En este punto verificamos esta hipótesis con los ingresos del jefe de hogar y la educación del jefe de hogar. 

reg delta_ha_nchs D ingresos_hogar_jefe1 educa_jefe1 

*podemos decir entonces que un incremento en los ingresos del jefe de hogar tienen un efecto sobre el crecimiento de la talla para la edad (ha_nchs).

drop delta_ha_nchs

*------------------------------------------------------
*-------Diferencias en diferencias   *----------------------------------------------------*
		 *    PANEL LARGO   *
		 
gen id=_n

reshape long ha_nchs educa_jefe ingresos_hogar_jefe, i(id) j(año)

*-------------------------------------------*
*1. Veamos algunas estadísticas descriptivas
*-------------------------------------------*

gen t=(año==2)
tab t

*Talla para la edad de los individuos del grupo de tratamiento en el primer periodo

*Talla para la edad de los individuos del grupo de control en el primer periodo

tabstat ha_nchs if t==0, by(D) 

*Talla para la edad de los individuos del grupo de tratamiento en el segundo periodo
*Talla para la edad de los individuos del grupo de control en el segundo periodo

tabstat ha_nchs if t==1, by(D) 

*Viendo si es un panel balanceado 
xtset id año
xtdes

gen Dxt=D*año

*Aquí usamos panel con efectos fijos que es el más recomendable

xtreg ha_nchs D t Dxt,fe robust

*-----------------------------------------------------------------------------------*
*2. El modelo de diferencias-en-diferencias con datos de corte transversal repetidos*
*-----------------------------------------------------------------------------------*

*Vemos que independientemente de si el individuo pertenece al grupo de tratamiento o de control, hay una mejora en la talla para la edad (ha_nchs)

*al pasar al segundo periodo. El efecto del tratamiento por diferencias en diferencias está dado por el coeficiente de la variable Dxt.

*--------------------------------------------------------*
*2.1 El modelo de diferencias-en-diferencias con datos de *
* regresores adicionales   *
*--------------------------------------------------------*

reg ha_nchs D año Dxt,robust

reg  ha_nchs D año Dxt ingresos_hogar_jefe educa_jefe,robust


