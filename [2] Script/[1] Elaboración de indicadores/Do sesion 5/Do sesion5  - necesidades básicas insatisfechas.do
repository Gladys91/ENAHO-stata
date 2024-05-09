
clear all  // Borrar la base de datos previa

global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho/bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"


cd "$bases"

global anio 2016

********** BASE 100 **************

use enaho01-$anio-100, clear

keep if result==1 | result==2 //completas e incompletas

merge 1:1 aÑo conglome vivienda hogar using sumaria-$anio, keepusing(mieperho pobreza)
drop _merge

*Factor de población
gen factorpob=factor07*mieperho

*departamento
gen dpto=substr(ubigeo,1, 2)
destring dpto, replace

lab def dpto 1 "AMAZONAS" 2 "ANCASH" 3 "APURIMAC" 4 "AREQUIPA" 5 "AYACUCHO" 6 "CAJAMARCA" 7 "CALLAO" 8 "CUSCO" 9 "HUANCAVELICA" 10 "HUANUCO" 11 "ICA" 12 "JUNIN" 13 "LA LIBERTAD" 14 "LAMBAYEQUE" 15 "LIMA" 16 "LORETO" 17 "MADRE DE DIOS" 18 "MOQUEGUA" 19 "PASCO" 20 "PIURA" 21 "PUNO" 22 "SAN MARTIN" 23 "TACNA" 24 "TUMBES" 25 "UCAYALI"
lab val dpto dpto

*área
replace estrato =1 if dominio==8
recode estrato (1/5=1)(6/8=2), gen(area)
lab def area 1 "Urbano" 2 "Rural"
lab val area area

tab nbi1,m
tab nbi1 [iw=factor07],m //expandido a nivel de hogares
tab nbi1 [iw=factorpob],m //expandido a nivel de población

tab nbi2 [iw=factorpob],m
tab nbi3 [iw=factorpob] ,m
tab nbi4 [iw=factorpob],m
tab nbi5 [iw=factorpob],m

*Nota El supuesto que se suele hacer es que si el hogar es Pobre, todos sus miembros son pobres

save base_hogares, replace

*********** Ejemplo con cap200
use enaho01-$anio-200, clear
merge m:1 aÑo conglome vivienda hogar using enaho01-$anio-100, keepusing(nbi1 nbi2 nbi3 nbi4 nbi5)
drop if _merge==2
drop _merge

*Para tener mismos resultados que arriba

keep if p204==1

tab nbi1 [iw=facpob07]

tab nbi1 p207 [iw=facpob07], col
tab nbi2 p207 [iw=facpob07], col

************ Regresando al cap100 *********************

use base_hogares,clear

*** Indicador "% de población con al menos 1 NBI"

gen con_1NBI=0
replace con_1NBI=100 if nbi1==1 | nbi2==1 | nbi3==1 | nbi4==1 | nbi5==1 

table area [pw=factorpob], c(mean con_1NBI) row

tabstat con_1NBI [aw=factorpob],by(area) s(mean) //de población

tabstat con_1NBI [aw=factor07],by(area) s(mean) //de hogares

*** Indicador "% de población con 2 o más NBI"
egen nNBI=rsum(nbi1 nbi2 nbi3 nbi4 nbi5)

gen con_2a5NBI=0
replace con_2a5NBI=100 if nNBI>=2

tabstat con_2a5NBI [aw=factorpob],by(area)

save base_hogares2,replace

*----------------------------------------
***************** Mapas ***************
*----------------------------------------

*--------------------------------------
*Primero: preparamos la base de datos de la Enaho con lo ya calculado
*---------------------------------------
table dpto [iw=factorpob], c(mean con_1NBI) row

collapse (mean) con_1NBI con_2a5NBI [pw=factorpob], by(dpto)
label var con_1NBI "Con al menos 1 NBI"
label var con_2a5NBI "Con 2 o más NBI"
save "nbi.dta", replace

*---------------------------------------------------
*Segundo: convertimos los "shapefile" a base de datos de Stata 
*ssc install shp2dta
*-------------------------------------------
shp2dta using BAS_LIM_DEPARTAMENTO, database(data_depar) coordinates(coord_depar) genid(id_cert) gencentroids(coord) replace 

*-------------------------
*Tercero: trabajamos la base de datos del departamento
*---------------------------
use data_depar, clear
gen dpto=id_cert //Para crear las etiquetas del departamento

*Dpto
lab def dpto 1 "AMAZONAS" 2 "ANCASH" 3 "APURIMAC" 4 "AREQUIPA" 5 "AYACUCHO" 6 "CAJAMARCA" 7 "CALLAO" 8 "CUSCO" 9 "HUANCAVELICA" 10 "HUANUCO" 11 "ICA" 12 "JUNIN" 13 "LA LIBERTAD" 14 "LAMBAYEQUE" 15 "LIMA" 16 "LORETO" 17 "MADRE DE DIOS" 18 "MOQUEGUA" 19 "PASCO" 20 "PIURA" 21 "PUNO" 22 "SAN MARTIN" 23 "TACNA" 24 "TUMBES" 25 "UCAYALI"
lab val dpto dpto

*--------------------------
*Cuarto: unimos ambas bases y hacemos el mapa
*--------------------------
merge 1:1 dpto using nbi.dta
drop _merge

tabstat con_1NBI, s(mean min p5 p25 p50 p75 p95 max)

*ssc install spmap
spmap con_1NBI using coord_depar, id (id_cert) fcolor(Oranges) clmethod(custom) clbreaks(6 10 20 30 40 57) oc(black) os(vvvthick_list) mop(dash) ///
title("Población con al menos 1 NBI, Perú 2018") ///
legend(on) clnumber(5) legend(title("Niveles", size(*0.5))) ///
label(label(NOMBDEP) xcoord(x_coord) ycoord(y_coord) size(*0.7)) ///
name(nbi1, replace)

graph export "$graficos\NBI.png", replace

tabstat con_2a5NBI, s(mean min p5 p25 p50 p75 p95 max)

spmap con_2a5NBI using coord_depar, id (id_cert) fcolor(Oranges) clmethod(custom) clbreaks(0 3 5 10 20) oc(black) os(vvvthick_list) mop(dash) ///
title("Población con al menos 2 NBI, Perú 2018") ///
legend(on) clnumber(4) legend(title("Niveles", size(*0.5))) ///
label(label(NOMBDEP) xcoord(x_coord) ycoord(y_coord) size(*0.7)) ///
name(nbi2, replace)

graph export "$graficos\NBI2.png", replace

********** Método Integrado
use base_hogares2,clear

gen pobre=(pobreza==1 | pobreza==2)

gen pobre_cron=(pobre==1 & con_1NBI==100)

gen pobre_estruc=(pobre==0 & con_1NBI==100)

gen pobre_coyunt=(pobre==1 & con_1NBI==0)

gen social_integ=(pobre==0 & con_1NBI==0)

********* Tabulados

ren aÑo año

svyset conglome [pw=factorpob], strata(estrato)

svy: tab pobre_cron año,col

svy: tab pobre_estruc año,col

svy: tab pobre_coyunt año,col

svy: tab social_integ año,col

