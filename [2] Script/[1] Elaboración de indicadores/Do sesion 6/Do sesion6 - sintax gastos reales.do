
clear all  // Borrar la base de datos previa

global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"

cd "$bases"

***
*** Translate (corrige la Ñ)
foreach x in "sumaria-2016.dta" "sumaria-2012.dta"  "sumaria-2010.dta" "sumaria-2015.dta" "sumaria-2019.dta" "sumaria-2020.dta" "sumaria-2021.dta" {

unicode analyze `x'
unicode encoding set ISO-8859-1 //código latino
unicode translate `x'
}

****

use sumaria-2015,clear
append using sumaria-2019
append using sumaria-2020
append using sumaria-2021
append using sumaria-2010

destring conglome, replace
tostring conglome, replace format(%06.0f)

recode ing* ig* g* (.= 0)
recode insedthd1 paesechd1 (.=0)

rename aÑo anio
gen aniorec=real(anio)

*** Dpto.
gen dpto= real(substr(ubigeo,1,2))
replace dpto=15 if (dpto==7)
label define dpto 1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica"  12"Junin" 13"La_Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre_de_Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San_Martin" 23"Tacna" 24"Tumbes" 25"Ucayali" 
lab val dpto dpto 

*Jalando deflactores de precios
sort aniorec dpto
merge m:1 aniorec dpto using "deflactores_base2021_new.dta"
drop if _merge==2
drop _m

*área
replace estrato = 1 if dominio ==8 
gen area = estrato <6
replace area=2 if area==0
label define area 2 "rural" 1 "urbana"
label val area area

*Grandes dominios
gen domin02=1 if dominio>=1 & dominio<=3 & area==1
replace domin02=2 if dominio>=1 & dominio<=3 & area==2
replace domin02=3 if dominio>=4 & dominio<=6 & area==1
replace domin02=4 if dominio>=4 & dominio<=6 & area==2
replace domin02=5 if dominio==7 & area==1
replace domin02=6 if dominio==7 & area==2
replace domin02=7 if dominio==8

label define domin02 1 "Costa_urbana" 2 "Costa_rural" 3 "Sierra_urbana" 4 "Sierra_rural" 5 "Selva_urbana" 6 "Selva_rural" 7 "Lima_Metropolitana"
label value domin02 domin02

*Region natural
gen region=1 if dominio>=1 & dominio<=3 
replace region=1 if dominio==8
replace region=2 if dominio>=4 & dominio<=6 
replace region=3 if dominio==7 

label define region 1 "Costa" 2 "Sierra" 3 "Selva"

*ámbito 
gen areag = dominio == 8
replace areag = 2 if dominio >= 1 & dominio <= 7 & estrato >= 1 & estrato <= 5
replace areag = 3 if dominio >= 1 & dominio <= 7 & estrato >= 6 & estrato <= 8
lab define areag 1 "Lima_Metro" 2 "Resto_Urbano" 3 "Rural" 
label values areag  areag

** Dominios
gen     dominioA=1 if dominio==1 & area==1
replace dominioA=2 if dominio==1 & area==2
replace dominioA=3 if dominio==2 & area==1
replace dominioA=4 if dominio==2 & area==2
replace dominioA=5 if dominio==3 & area==1
replace dominioA=6 if dominio==3 & area==2
replace dominioA=7 if dominio==4 & area==1
replace dominioA=8 if dominio==4 & area==2
replace dominioA=9 if dominio==5 & area==1
replace dominioA=10 if dominio==5 & area==2
replace dominioA=11 if dominio==6 & area==1
replace dominioA=12 if dominio==6 & area==2
replace dominioA=13 if dominio==7 & area==1
replace dominioA=14 if dominio==7 & area==2
replace dominioA=15 if dominio==7 & (dpto==16 | dpto==17 | dpto==25) & area==1
replace dominioA=16 if dominio==7 & (dpto==16 | dpto==17 | dpto==25) & area==2
replace dominioA=17 if dominio==8 & area==1
replace dominioA=17 if dominio==8 & area==2

label define dominioA 1 "Costa norte urbana" 2 "Costa norte rural" 3 "Costa centro urbana" 4 "Costa centro rural" 5 "Costa sur urbana" 6 "Costa sur rural"	7 "Sierra norte urbana"	8 "Sierra norte rural"	9 "Sierra centro urbana" 10 "Sierra centro rural"	11 "Sierra sur urbana" 12 "Sierra sur rural" 13 "Selva alta urbana"	14 "Selva alta rural" 15 "Selva baja urbana" 16 "Selva baja rural" 17 "Lima Metropolitana"
lab val dominioA dominioA 

****

drop ld

*Jalando deflactores espaciales
merge m:1 dominioA using "despacial_ldnew.dta"
drop _m

** Factor
gen factorpob=round(factor07*mieperho)

*** Limareg
gen limareg=1 if(substr(ubigeo,1,4))=="1501"
replace limareg=2 if(substr(ubigeo,1,2))=="07"
replace limareg=3 if((substr(ubigeo,1,4))>="1502" & (substr(ubigeo,1,4))<"1599")

label define limareg 1 "Prov Lima" 2 "Prov Const. Callao" 3 "Región Lima"
label val limareg limareg

***
svyset [pweight = factorpob], psu(conglome)

*-----------------
*GASTOS REALES
*------------------
***CREANDO VARIABLES DEL GASTO DEFLACTADO A PRECIOS DE LIMA Y BASE 2018 a nivel total*********

******Gasto por 8  grupos de la canastas************
d gru11hd  gru12hd1  gru12hd2  gru13hd1  gru13hd2  gru13hd3

gen 		gpcrg1a= (gru11hd + gru12hd1 + gru12hd2 + gru13hd1 + gru13hd2 + gru13hd3)/(12*mieperho*ld*i01)

gen 		gpcrg1b1 = ((g05hd + g05hd1 + g05hd2 + g05hd3 + g05hd4 + g05hd5 +g05hd6 +ig06hd)/(12*mieperho*ld*i01))

gen 		gpcrg1b2= ((sg23 + sig24)/(12*mieperho*ld*i01))

gen 		gpcrg1b3= ((gru14hd + gru14hd1 +  gru14hd2 + gru14hd3 + gru14hd4 + gru14hd5 + sg25 + sig26)/(12*mieperho*ld*i01))

gen    		gpcrg2= ((gru21hd + gru22hd1 + gru22hd2 + gru23hd1 + gru23hd2 + gru23hd3 + gru24hd)/(12*mieperho*ld*i02))

gen     	gpcrg3= ((gru31hd + gru32hd1 + gru32hd2 + gru33hd1 + gru33hd2 + gru33hd3 + gru34hd)/(12*mieperho*ld*i03))

gen     	gpcrg4= ((gru41hd + gru42hd1 + gru42hd2 + gru43hd1 + gru43hd2 + gru43hd3 + gru44hd + sg421 + sg42d1 + sg423 + sg42d3)/(12*mieperho*ld*i04))

gen    		gpcrg5= ((gru51hd + gru52hd1 + gru52hd2 + gru53hd1 + gru53hd2 + gru53hd3 + gru54hd)/(12*mieperho*ld*i05))

gen     	gpcrg6= ((gru61hd + gru62hd1 + gru62hd2 + gru63hd1 + gru63hd2 + gru63hd3 + gru64hd + g07hd + ig08hd + sg422 + sg42d2)/(12*mieperho*ld*i06))

gen     	gpcrg7= ((gru71hd + gru72hd1 + gru72hd2 + gru73hd1 + gru73hd2 + gru73hd3 + gru74hd + sg42 + sg42d)/(12*mieperho*ld*i07))

gen     	gpcrg8= ((gru81hd + gru82hd1 + gru82hd2 + gru83hd1 + gru83hd2 + gru83hd3 + gru84hd)/(12*mieperho*ld*i08))

label var gpcrg1a	"Alimentos Preparados dentro del hogar"
label var gpcrg1b1	"Alimentos Adquiridos Fuera del hogar 559"
label var gpcrg1b2	"Alimentos Adquiridos de instituciones beneficas 602a"
label var gpcrg1b3	"Alimentos Adquiridos fuera del hogar item 47 y 50 y 602"

label var gpcrg2	"Vestido y calzado"
label var gpcrg3	"Gasto Alquiler de vivienda y combustible"
label var gpcrg4	"Muebles y enseres"
label var gpcrg5	"Cuidados de la salud"
label var gpcrg6	"Transporte y comunicaciones"
label var gpcrg7	"Esparcimiento diversión y cultura"
label var gpcrg8	"Otros gastos de bienes y servicios"


*RECODIFICANDO POR grupo de gastos
**********************************
gen 	gpgru1a= gpcrg1a
gen		gpgru1b= gpcrg1b1 + gpcrg1b2 + gpcrg1b3
gen 	gpgru1 = gpgru1a + gpgru1b
gen		gpgru2 = gpcrg2
gen		gpgru3 = gpcrg3
gen		gpgru4 = gpcrg4
gen		gpgru5= gpcrg5
gen		gpgru6 = gpcrg6
gen		gpgru7 = gpcrg7
gen		gpgru8 = gpcrg8 

gen  	gpgru0 = gpgru1 + gpgru2 + gpgru3 + gpgru4 + gpgru5 + gpgru6 + gpgru7 + gpgru8 

label var gpgru1 "G01.Total en Alimentos real mensual percápita"
label var gpgru1a "G011.Alimentos dentro del hogar real"
label var gpgru1b "G012.Alimentos fuera del hogar real"
label var gpgru2 "G02.Vestido y calzado real"
label var gpgru3 "G03.Alquiler de Vivienda y combustible real"
label var gpgru4 "G04.Muebles y enseres real"
label var gpgru5 "G05.Cuidados de la salud real"
label var gpgru6 "G06.Transportes y comunicaciones real"
label var gpgru7 "G07.Esparcimiento diversion y cultura real"
label var gpgru8 "G08.otros gastos en bienes y servicios real"


************* Ingresos **************************************************************

gen ipcr_2 = (ingbruhd +ingindhd)/(12*mieperho*ld*i00) 
gen ipcr_3 = (insedthd + ingseihd + insedthd1)/(12*mieperho*ld*i00) 
gen ipcr_4 = (pagesphd + paesechd + ingauthd + isecauhd + paesechd1)/(12*mieperho*ld*i00) 
gen ipcr_5 = (ingexthd)/(12*mieperho*ld*i00) 
gen ipcr_1 = (ipcr_2 + ipcr_3 + ipcr_4 + ipcr_5)

gen ipcr_7 = (ingtrahd)/(12*mieperho*ld*i00)
gen ipcr_8 = (ingtexhd)/(12*mieperho*ld*i00)
gen ipcr_6 = (ipcr_7 + ipcr_8)

*ambos suman ipcr_7
gen ipcr_9  = (ingtprhd)/(12*mieperho*ld*i00)
gen ipcr_10 = (ingtpuhd)/(12*mieperho*ld*i00)

**desglose de ingtpuhd
gen ipcr_11 = (ingtpu01)/(12*mieperho*ld*i00)
gen ipcr_12 = (ingtpu03)/(12*mieperho*ld*i00)
gen ipcr_13 = (ingtpu05)/(12*mieperho*ld*i00)
gen ipcr_14 = (ingtpu04)/(12*mieperho*ld*i00)
gen ipcr_15 = (ingtpu02)/(12*mieperho*ld*i00)

gen ipcr_16 = (ingrenhd)/(12*mieperho*ld*i00)
gen ipcr_17 = (ingoexhd + gru13hd3 + gru23hd3 + gru33hd3 + gru43hd3 + gru53hd3 + gru63hd3 + gru73hd3 + gru83hd3 + gru24hd +gru44hd + gru54hd + gru74hd + gru84hd + gru14hd5)/(12*mieperho*ld*i00)

*ajuste por el alquiler imputado
gen ipcr_18 =(ia01hd +gru34hd - ga04hd + gru64hd)/(12*mieperho*ld*i00)

gen ipcr_19 = (gru13hd1 + sig24 + gru23hd1 + gru33hd1 + gru43hd1 + gru53hd1 + gru63hd1 + gru73hd1 + gru83hd1 + gru14hd3 + sig26)/(12*mieperho*ld*i00)

gen ipcr_20 = (gru13hd2 + ig06hd + gru23hd2 + gru33hd2 + gru43hd2 + gru53hd2 + gru63hd2 + ig08hd + gru73hd2 + gru83hd2 + gru14hd4 + sg42d + sg42d1 + sg42d2 + sg42d3)/(12*mieperho*ld*i00)

gen  ipcr_0= ipcr_2 + ipcr_3 + ipcr_4 + ipcr_5+ ipcr_7 + ipcr_8 + ipcr_16 + ipcr_17 + ipcr_18 + ipcr_19 + ipcr_20

label var ipcr_0 "Ingreso percapita mensual a precios de Lima"

label var ipcr_1 "Ingreso por trabajo percapita mensual a precios de Lima "
label var ipcr_2 "Ingreso monetario por trabajo principal percapita mensual a precios de Lima"
label var ipcr_3 "Ingreso monetario por trabajo secundario percapita mensual a precios de Lima"
label var ipcr_4 "Ingreso percapita pago en especie y autoconsumo mensual a precios de Lima "
label var ipcr_5 "Ingreso extraordinario por trabajo percapita mensual a precios de Lima pago "

label var ipcr_6 "Ingreso transferencia corriente percapita mensual a precios de Lima "
label var ipcr_7 "Ingreso transferencia monetaria del pais percapita mensual a precios de Lima "
label var ipcr_8 "Ingreso transferencia monetaria extranjero percapita mensual a precios de Lima "

label var ipcr_9  "Ingreso transferencia monetaria privada percapita mensual a precios de Lima "
label var ipcr_10 "Ingreso transferencia monetaria Publica total percapita mensual a precios de Lima "
label var ipcr_11 "Ingreso transferencia monetaria Publica Juntos percapita mensual a precios de Lima "
label var ipcr_12 "Ingreso transferencia monetaria Publica Pensión65 percapita mensual a precios de Lima "
label var ipcr_13 "Ingreso transferencia monetaria Bono Gas percapita mensual a precios de Lima "
label var ipcr_14 "Ingreso transferencia monetaria Beca 18 percapita mensual a precios de Lima"
label var ipcr_15 "Ingreso transferencia monetaria Otros Publica percapita mensual a precios de Lima"
label var ipcr_16 "Ingreso por renta percapita mensual a precios de Lima "
label var ipcr_17 "Ingreso extraordinario percapita mensual a precios de Lima "
label var ipcr_18 "Ingreso alquiler imputado percapita mensual a precios de Lima"
label var ipcr_19 "Ingreso donacion publica percapita mensual a precios de Lima "
label var ipcr_20 "Ingreso donacion privada percapita mensual a precios de Lima "

*** Salidas ***

svyset [pweight = factorpob], psu(conglome) strata(estrato)

*** Gasto real promedio percapita mensual***

svy:mean gpgru0, over(aniorec)

lincom gpgru0@2021.aniorec - gpgru0@2020.aniorec //Diferencias de medias

svy:mean gpgru0 if aniorec==2021, over(area)
lincom gpgru0@1.area - gpgru0@2.area

svy:mean gpgru0 if aniorec==2021, over(dpto)

*gasto percápita nominal
gen gastopm=gashog2d/(12*mieperho)
svy:mean gastopm if aniorec==2021, over(area)

****** Gráficos por deciles ************
xtile x21=gpgru0 if aniorec==2021 & gpgru0>0 [fw=factorpob],nq(10)

br x21 gpgru0 anio if aniorec==2021 

xtile x20=gpgru0 if aniorec==2020 & gpgru0>0 [fw=factorpob],nq(10)

gen decil=x21 if aniorec==2021
replace decil=x20 if aniorec==2020

**tablas
table x21 [fw=factorpob]  if aniorec==2021 & gpgru0>0 , c(mean gpgru0)

table x20 [fw=factorpob]  if aniorec==2020 & gpgru0>0 , c(mean gpgru0)

table decil aniorec [fw=factorpob] , c(mean gpgru0)

svy: mean gpgru0 if decil==10,  over(aniorec) 
lincom gpgru0@2021.aniorec - gpgru0@2020.aniorec

svy: mean gpgru0 if decil==9,  over(aniorec) 
lincom gpgru0@2021.aniorec - gpgru0@2020.aniorec

****** Frecuencias Acumuladas ********
*Gráfico Nacional
gen g_limit=2800

cumul gpgru0 [fw=factorpob] if aniorec==2010 & gpgru0>0, gen(c10)
cumul gpgru0 [fw=factorpob] if aniorec==2021 & gpgru0>0, gen(c21)

label var c10 "2010" 
label var c21 "2021"

graph twoway line c10 c21 gpgru0 if gpgru0<g_limit, sort ylab(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1) legend(rows(1) size(small)) scheme(s2color) xtitle(" " "Gasto real percapita mensual", size(small)) ytitle("% Población", size(small)) title("Perú: Frecuencia Acumulada del Gasto percapita mensual. 2010-2021" , size(medsmall))  xlab(0 400 800 1200 1600 2000 2400 2800) xline(352) subtitle("(Soles constantes=2021 a precios de Lima Met.)", size(small))

*Gráfico para LimaMet
drop c10 c21
cumul gpgru0 [fw=factorpob] if aniorec==2010 & areag==1 & gpgru0>0, gen(c10)

cumul gpgru0 [fw=factorpob] if aniorec==2021 & areag==1 & gpgru0>0, gen(c21)

label var c10 "2010" 
label var c21 "2021"

graph twoway line c10 c21 gpgru0 if areag==1 & gpgru0<g_limit, sort ylab(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1) legend(rows(1) size(small)) scheme(s2color) xtitle(" " "Gasto real percapita mensual", size(small)) ytitle("% Población", size(small)) title("Lima Metropolitana: Frecuencia Acumulada del Gasto percapita mensual. 2010-2021" , size(medsmall))  xlab(0 400 800 1200 1600 2000 2400 2800) xline(441) subtitle("(Soles constantes=2021 a precios de Lima Met.)", size(small))

*** Ingreso real promedio percapita mensual (soles constantes)***
svy:mean ipcr_0, over(aniorec)

svy:mean ipcr_0 if aniorec==2021, over(area)
svy:mean ipcr_0 if aniorec==2021, over(domin02)
svy:mean ipcr_0 if aniorec==2021, over(dpto)

tabstat ipcr_0 [fw=factorpob] if aniorec==2021, s(mean min p25 p50 p75 p95 p99 max)

*ingreso nominal (soles)
gen ingpm=inghog1d/(12*mieperho)

svy:mean ingpm, over(aniorec)









