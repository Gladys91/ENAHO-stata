
clear all  // Borrar la base de datos previa

global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"             


cd "$bases"

*** Translate (corrige la Ñ)
foreach x in "sumaria-2016.dta" "sumaria-2012.dta" {

unicode analyze `x'
unicode encoding set ISO-8859-1 //código latino
unicode translate `x'
}


************** // Pobreza // **********************


use sumaria-2021, clear //La base está a nivel de hogares
append using sumaria-2016
append using sumaria-2012

*describe

gen factorpob=round(factor07*mieperho)

destring aÑo, gen(año)

*** Área
recode estrato (1/5=1)(6/8=2), gen(area)
lab def area 1 "Urbano" 2 "Rural"
lab val area area

*** Departamento
gen dpto= real(substr(ubigeo,1,2))
replace dpto=15 if (dpto==7)
label define dpto 1 "Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica" 12"Junin" 13"La_Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre_de_Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San_Martin" 23"Tacna" 24"Tumbes" 25"Ucayali" 
lab val dpto dpto 

*Region natural
gen region=1 if dominio>=1 & dominio<=3 
replace region=1 if dominio==8
replace region=2 if dominio>=4 & dominio<=6 
replace region=3 if dominio==7 

label define region 1 "Costa" 2 "Sierra" 3 "Selva"

*** gasto mensual percápita
gen gpcm=gashog2d/(12*mieperho)

*** ingreso mensual percapita
gen ingpc=inghog1d/(12*mieperho)

*** Replicando pobreza
gen pobreza_calc=1 if gpcm<linpe //pobre extremo
replace pobreza_calc=2 if gpcm<linea & pobreza_calc!=1 //pobre no extremo
replace pobreza_calc=3 if gpcm>=linea //No pobre

tab pobreza pobreza_calc

*** pobre
gen pobre=(pobreza==1 | pobreza==2) //genera dummys en función de la condición

lab def pobre 1 "Pobre" 0 "No pobre"
lab val pobre pobre

tab pobre año [fw=factorpob] ,col nofreq

tab pobre area if año==2021 [fw=factorpob],col nofreq

*-------------
*** Muestra compleja
svyset [pweight = factorpob], psu(conglome) strata(estrato)

svy:mean pobre, over(año)
svy:mean pobre if año==2021, over(dpto)
estat cv

svy: mean pobre if año==2021,  over(dpto) 
lincom pobre@1.dpto - pobre@2.dpto
lincom pobre@1.dpto - pobre@3.dpto

table dpto año [fw=factorpob],c(mean pobre) row

*** gasto percapita
svy:mean gpcm if año==2021
svy:mean gpcm if año==2021, over(area)

*** pobre extremo
gen pobre_ext=(pobreza==1) //genera dummys en función de la condición

table dpto año [fw=factorpob],c(mean pobre_ext) row

svy:mean pobre_ext if año==2021, over(dpto)
estat cv

svy:mean pobre_ext if año==2021, over(region)
estat cv
66
*** Indicadores de pobreza (incidencia, brecha y severidad)

*** Brecha
g brecha=(linea-gpcm)/linea if (pobreza==1 | pobreza==2)
replace brecha=0 if pobreza==3
sum brecha if año==2021 [fw=factorpob]
sum brecha if año==2012 [fw=factorpob]

*** Severidad
g severidad=((linea-gpcm)/linea)^2 if (pobreza==1 | pobreza==2)
replace severidad=0 if pobreza==3
sum severidad if año==2021  [fw=factorpob]
sum severidad if año==2012  [fw=factorpob]

*** Comando directo
*ssc install sepov
sepov gpcm [pw=factorpob] if año==2021 , povline(linea) psu(conglome) strata(estrato)

sepov gpcm [pw=factorpob] if año==2021 , povline(linea) psu(conglome) strata(estrato) by(area)

sepov gpcm [pw=factorpob] if año==2021 , povline(linea) psu(conglome) strata(estrato) by(dpto)

sepov gpcm [pw=factorpob], povline(linea) psu(conglome) strata(estrato) by(dpto año)



*-------------------------------------
********* Indicadores de desigualdad

*básicos
tabstat gpcm if gpcm>0 & año==2021 [fw=factorpob], s(mean min p10 p25 p50 p75 p90 max sd cv)

tabstat ingpc if ingpc>0 & año==2021 [fw=factorpob], s(mean min p10 p25 p50 p75 p90 max sd cv)

*** Diviendien en deciles
xtile decil=gpcm [fw=factorpob] if año==2021, nq(10)

tabstat gpcm if gpcm>0 & año==2021 [fw=factorpob], s(mean) by(decil)

xtile decil_ing=ingpc [fw=factorpob] if año==2021, nq(10)

tabstat ingpc if ingpc>0 & año==2021 [fw=factorpob], s(mean) by(decil_ing)

****
sum gpcm [fw=factorpob] if año==2021 & decil==1,d
scalar d1=r(mean)

sum gpcm [fw=factorpob] if año==2021 & decil==10,d
scalar d10=r(mean)

*** Indicador division d10/d1
gen indicador_a=d10/d1
scalar indicador_b=d10/d1

display indicador_b

*ssc install clorenz

*** Coeficiente de Gini
drop if año==2016
lab def año 2012 "2012" 2021 "2021"
lab val año año

clorenz gpcm, hweight(factorpob) hgroup(año) 

preserve
keep if año==2021
clorenz gpcm, hweight(factorpob) hgroup(area) 
restore

preserve
keep if año==2021
clorenz ingpc, hweight(factorpob) hgroup(area) 
restore

*ssc install inequal7 

inequal7 gpcm [fw=factorpob] if año==2021
66
inequal7 gpcm [fw=factorpob] if area==1 & año==2021
inequal7 gpcm [fw=factorpob] if area==2 & año==2021

inequal7 ingpc [fw=factorpob] if año==2021





