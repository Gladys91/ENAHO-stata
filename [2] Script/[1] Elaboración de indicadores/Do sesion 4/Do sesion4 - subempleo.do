
clear all  // Borrar la base de datos previa

global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho/bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"

cd "$bases"

**** BASE 500 ********
use enaho01a-2021-500, clear

drop if codinfor=="00" //missing

*RESIDENTE HABITUAL DEL HOGAR
*------------------------------
gen residente=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
keep if (residente==1) //siempre se trabaja con residentes habituales en esta base

*AREA
******
recode estrato (1/5=1)(6/8=2), gen(area)
lab def area 1 "Urbano" 2 "Rural"
lab val area area

************************************************************
                     * SUBEMPLEO
************************************************************

*ingresos por trabajo
egen ingtrab_año=rsum(i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t)
gen ingtrab=ingtrab_año/12

*Perceptores de ingresos
gen percep=1 if (residente ==1 & p203!=8 &  p203!=9 & ingtrab>0 & ingtrab!=.) 

preserve
collapse (sum) percep, by(aÑo conglome vivienda hogar)
save perceptores, replace
restore

*Metodologia Mintra
egen horawt=rsum(i513 i518) if p519==1
replace horawt=i520 if p519==2

*********** En la Sumaria
preserve
use sumaria-$anio,clear

gen facpob=factor07*mieperho

*Area
******
replace estrato =1 if dominio==8
recode estrato (1/5=1)(6/8=2), gen(area)
lab def area 1 "Urbano" 2 "Rural"
lab val area area

*crear dominio
gen dominio2=1 if (dominio>=1 & dominio<=3 & area==1) 
replace dominio2=2 if (dominio>=1 & dominio<=3 & area==2)
replace dominio2=3 if (dominio>=4 & dominio<=6 & area==1)
replace dominio2=4 if (dominio>=4 & dominio<=6 & area==2)
replace dominio2=5 if (dominio==7 & area==1)
replace dominio2=6 if (dominio==7 & area==2)
replace dominio2=7 if (dominio==8 & area==1)

lab def dominio2 1 "Costa urbana" 2 "Costa rural" 3 "Sierra urbana" 4 "Sierra rural" 5 "Selva urbana" 6 "Selva rural" 7 "Lima Metropolitana"
lab val dominio2 dominio2

*traer los perceptores
merge 1:1 aÑo conglome vivienda hogar using perceptores
drop if _merge==2
drop _merge

collapse (mean) linea mieperho percep [pw=facpob],by(aÑo dominio2)
gen imr=linea * mieperho / percep
keep imr aÑo dominio2
save base_imr,replace
restore //Regreso a base500

*************************

*genero domino2 en base500
gen dominio2=1 if (dominio>=1 & dominio<=3 & area==1) 
replace dominio2=2 if (dominio>=1 & dominio<=3 & area==2)
replace dominio2=3 if (dominio>=4 & dominio<=6 & area==1)
replace dominio2=4 if (dominio>=4 & dominio<=6 & area==2)
replace dominio2=5 if (dominio==7 & area==1)
replace dominio2=6 if (dominio==7 & area==2)
replace dominio2=7 if (dominio==8 & area==1)

*unir con IMR
merge m:1 aÑo dominio2 using base_imr,nogen

gen subempM=1 if (ocu500==1 & horawt<35 & (p521==1 & p521a==1)) 
replace subempM=2 if (ocu500==1 & ingtrab<imr & horawt<35 & (p521==1 & p521a==2)) 
replace subempM=2 if (ocu500==1 & ingtrab<imr & horawt<35 & (p521==2))
replace subempM=2 if (ocu500==1 & ingtrab<imr & horawt>=35 & !missing(horawt))
replace subempM=3 if (ocu500==1 & ingtrab>=imr & !missing(ingtrab) & horawt<35 & (p521==1 & p521a==2)) 
replace subempM=3 if (ocu500==1 & ingtrab>=imr & !missing(ingtrab) & horawt<35 & p521==2) 
replace subempM=3 if (ocu500==1 & ingtrab>=imr & !missing(ingtrab) & horawt>=35 & !missing(horawt))
replace subempM=3 if (ocu500==1 & horawt<35 & missing(p521) & missing(subempM) & ingtrab>imr & !missing(ingtrab)) 

*Algunos casos
replace subempM=1 if (ocu500==1 & horawt<35 & missing(p521) & missing(subempM) & ingtrab<imr)

replace subempM=2 if (ocu500==1 & ingtrab<imr & subempM==.)
replace subempM=1 if (ocu500==1 & horawt<35 & p521==1 & subempM==.)

replace subempM=4 if (ocu500==2) //desempleados 

lab var subempM "Subempleo_Mintra"
lab def subempM 1 "Visible o por horas" 2 "Invisible o por ingresos" 3 "Empleo Adecuado" 4 "Desempleado",modify
lab val subempM subempM

*-------------------
**** Nacional
*------------------
table subempM [pw=fac500a] if (ocu500== 1 | ocu500==2),row format(%10.0fc) 

tab subempM [iw=fac500a] if (ocu500== 1 | ocu500==2),m 

**** Solo urbana
table subempM [pw=fac500a] if (ocu500== 1 | ocu500==2) & area==1,row format(%10.0fc) 

tab subempM [iw=fac500a] if (ocu500== 1 | ocu500==2) & area==1,m

***** Solo Lima Metropolitana
table subempM [pw=fac500a] if (ocu500== 1 | ocu500==2) & dominio2==7,row format(%10.0fc) 

tab subempM [iw=fac500a] if (ocu500== 1 | ocu500==2) & dominio2==7,m

**** Cruce con informalidad
tab subempM ocupinf [iw=fac500a], col

