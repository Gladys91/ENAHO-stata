
clear all  // Borrar la base de datos previa

global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"

cd "$bases"

*-----------------------------------
*      Estadistica descriptiva
*-----------------------------------

use "enaho01-2021-200",clear  //Población

drop ocupac_r3 - nconglome sub_conglome tipocuestionario

ren aÑo año

*** Nota: Cap200 y Cap500 se trabaja con residente habitual 
*(palote: alt 124)

gen residente=((p204==1 & p205==2) | (p204==2 & p206==1))
keep if residente==1

***** Tabla de frecuencia Sexo
tab p207

**** Tabla de frecuencia "edad"
recode p208a (0/13=1 "Hasta 13 años") (14/17=2 "De 14 a 17 años") (18/29=3 "De 18 a 29 años") (30/45=4 "De 30 a 45 años") (46/60=5 "De 46 a 60 años") (61/99=6 "De 61 a más años"), gen (g_edad)

tab g_edad

fre g_edad

*** Principales estadísticas

tabstat p208a, s(n mean min p25 p50 p75 max sd cv)

tabstat p208a, s(n mean min p25 p50 p75 max sd cv) by(p207)

*** Otro comando

table p207, c(mean p208a min p208a max p208a) row

**** Tabular 2 variables

tab g_edad p207
tab g_edad p207, row //porcetaje filas
tab g_edad p207, col //porcetaje columnas

tab g_edad p207, row nofreq //solo porcetaje filas 
tab g_edad p207, col nofreq //solo porcetaje columna 

*------------------------------
*            Gráficos
*------------------------------

*** Gráfico de cajas

graph box p208a

graph box p208a, by(p207)

*** Histograma

hist p208a, norm //que muestre la frecuencia absoluta y una curva normal

hist p208a, freq norm //que muestre la frecuencia absoluta y una curva normal

hist p208a, kdensity
kdensity p208a, //Densidad de Kernel
kdensity p208a, norm //Densidad de Kernel

hist p208a if p207==1, freq kdensity  xtitle("Edad (Hombre)") name(g1, replace)
hist p208a if p207==2, freq kdensity  xtitle("Edad (Mujer)") name(g2, replace)

graph combine g1 g2

graph export "$graficos\histograma edad.png", replace

*** Barras
graph bar (mean) p208a, over(p207) ytitle("Edad") title("Edad por sexo") subtitle("Años") note("Fuente: INEI - ENAHO 2021")

#delimit;
graph bar (mean) p208a,
		over(p207) 
		ytitle("Edad")
		title("Edad por sexo")
		subtitle("Años")
		note("Fuente: INEI - ENAHO 2021");
#delimit cr

*** Scatter 
keep if p208a>=5 & p208a<=17

scatter p211d p208a, name(graf3, replace) title(Edad vs Horas trabajadas) 

tw (scatter p211d p208a) (lfit p211d p208a) 

*** Pie
graph pie, over(p207) plab(_all percent) scheme(economist)

******* Fijando algún esquema de gráficos
set scheme sj, perm

*--------------------------------
***** Uso de factor de expansión
*---------------------------------

*Algunos comandos solo trabajan con factor entero
gen factor2=round(facpob07,2)

tabstat facpob07, s(sum) format(%10.0fc) 

**** Tabulados
tab g_edad p207 [fw=factor2]
tab g_edad p207 [iw=facpob07] 

fre p203

tab g_edad p207 [iw=facpob07] if p203==1,col //columna es 100%
tab g_edad p207 [iw=facpob07] if p203==1,row //fila es 100%

tab g_edad p207 [iw=facpob07] if p203==1,col nofreq 

tab g_edad p207 [iw=facpob07] if p203==1,row nofreq 

***** Estadísticos por categoría

tabstat p208a [aw=facpob07], by(p207) //defecto es promedio

tabstat p208a [aw=facpob07], by(p207) s(n mean min p25 p50 p75 max sd cv)

tabstat p208a if p203==1 [aw=facpob07], by(p207) s(n mean min p25 p50 p75 max sd) format (%5.1fc)

tabstat p208a if p203==1 [aw=facpob07], by(p207) s(n mean min p25 p50 p75 max sd) format (%10.1fc)

tabstat p208a if p203==1 [fw=factor2], by(p207) s(n mean min p25 p50 p75 max sd) format (%10.1fc)

** Otra tabla
table g_edad p207 [iw=facpob07], c(mean p208a) row format (%10.1fc)



