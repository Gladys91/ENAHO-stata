
clear all  // Borrar la base de datos previa

global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho/bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"

cd "$bases"

*unicode analyze sumaria-2015.dta 
*unicode encoding set ISO-8859-1 //código latino
*unicode translate sumaria-2015.dta 

**** BASE 500 ********
use enaho01a-2021-500, clear

drop if codinfor=="00" //missing

*RESIDENTE HABITUAL DEL HOGAR
*************
gen residente=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
keep if (residente==1) //siempre se trabaja con residentes habituales en esta base

*AREA
******
recode estrato (1/5=1)(6/8=2), gen(area)
lab def area 1 "Urbano" 2 "Rural"
lab val area area

*AMBITO GEOGRAFICO*.
**********************
gen areag=1 if (dominio==8)  
replace areag=2 if ((dominio >= 1 & dominio <= 7) & (estrato  >= 1 & estrato <= 5)) 
replace areag=3 if ((dominio >= 1 & dominio <= 7) & (estrato  >= 6 & estrato <= 8))  
lab def areag 1 "Lima Metropolitana" 2 "Resto Urbano" 3 "Rural"
lab val areag areag

*REGIÓN NATURAL 
**************
gen region=1 if dominio>=1 & dominio<=3 
replace region=1 if dominio==8
replace region=2 if dominio>=4 & dominio<=6 
replace region=3 if dominio==7 
label define region 1 "Costa" 2 "Sierra" 3 "Selva"

*DPTO
*******
gen dpto=substr(ubigeo,1, 2)
destring dpto, replace

lab def dpto 1 "AMAZONAS" 2 "ANCASH" 3 "APURIMAC" 4 "AREQUIPA" 5 "AYACUCHO" 6 "CAJAMARCA" 7 "CALLAO" 8 "CUSCO" 9 "HUANCAVELICA" 10 "HUANUCO" 11 "ICA" 12 "JUNIN" 13 "LA LIBERTAD" 14 "LAMBAYEQUE" 15 "LIMA" 16 "LORETO" 17 "MADRE DE DIOS" 18 "MOQUEGUA" 19 "PASCO" 20 "PIURA" 21 "PUNO" 22 "SAN MARTIN" 23 "TACNA" 24 "TUMBES" 25 "UCAYALI"
lab val dpto dpto

*GRUPOS DE EDAD
***************************
recode p208a (14/17=1) (18/29=2) (30/45=3) (46/60=4) (61/99=5), gen (g_edad)
lab def g_edad 1 "De 14 a 17 años" 2 "18 a 29 años" 3 "30 a 45 años" 4 "46 a 60 años" 5 "Más de 60 años"
lab val g_edad g_edad

*NIVEL EDUCATIVO
*************
gen n_edu=1 if p301a==1 | p301a==2
replace n_edu=2 if (p301a==3 | p301a==4 | p301a==12) 
replace n_edu=3 if (p301a==5 | p301a==6)
replace n_edu=4 if (p301a>=7 & p301a<=11)  
replace n_edu=1 if p301a==. 

lab def n_edu 1 "Sin instrucción" 2 "Primaria" 3 "Secundaria" 4 "Superior"
lab val n_edu n_edu

**TAMAÑO DE EMPRESA
*******************************
recode p512b (1/10=1)  (11/50=2)  (51/9998=3), gen (tam_emp)

lab def tam_emp 1 "De 1 a 10 trabajadores" 2 "De 11 a 50 trabajadores" 3 "De 51 y más" 
lab val tam_emp tam_emp

*************************** // INDICADORES //********************

*PEA
***********.
tab ocu500,m
fre ocu500
tab ocu500 [iw=fac500a],m

recode ocu500 (1/2=1)  (3/4=2), gen (PET)
label def PET 1 "PEA" 2 "NO_PEA"
lab val PET PET

tab PET,m
tab PET [iw=fac500a],m 

*Condicion de actividad*
****************************
recode ocu500 (1=1)(2=2)(3/4=3), gen (c_act)
lab def c_act 1 "Ocupado" 2 "Desocupado" 3 "No PEA"

lab val c_act c_act

**CATEGORIA DE OCUPACION (ocupacion principal)
**************************
fre p507
tab p507 [iw=fac500a] if ocu500==1,m

**ramas de actividad
**************************
gen ciuu=p506r4
tostring ciuu,replace
gen tam=length(ciuu)
replace tam=. if tam==1
replace ciuu="0"+ ciuu if tam==3   
gen ciuu2dig=substr(ciuu,1,2)
destring ciuu2dig, replace

recode ciuu2dig (1/3 =1) (5/9 =2) (10/33 =3) (35=4) (36/39 =5) ///
(41/43 =6) (45/47 =7) (49/53 =8) (55/56 =9) (58/63 =10) (64/66 =11) ///
(68 =12) (69/75 =13) (77/82 =14) (84 =15) (85 =16)(86/88 =17) (90/93 =18) ///
(94/96 =19) (97/98 =20) (99 =21), gen(ciuu1dig)

*grandes ramas
recode ciuu1dig (1/2=1) (3=2) (4=6) (5=6) (6=3) (7=4) (8=5) (10=5) (9=6) (11/21=6), gen(ramas)

lab def ramas ///
1 "Agricultura/Pesca/Minería" ///
2 "Manufactura" ///
3 "Construcción" ///
4 "Comercio" ///
5 "Transportes y Comunicaciones" ///
6 "Otros Servicios"
lab val ramas ramas

*sector
recode ramas (1=1) (2=2) (3=4) (4/6=3), gen(sector)
lab def sector 1 "Primario" 2 "Manufactura" 3 "Terciario" 4 "Construcción"
lab val sector sector

*------------------------
*      OCUPACIONES
*------------------------
recode  p505 (011/024=1) (111/139=2)(141/148 =3)(211/284 =4)(311/396 =5) (411/462=6)(511/565 =7)(571/583 =8) (611/641 =9)(711/799 =10) (811/886 =11)(911/927=12)(931/987 =13), gen(ocupac)

lab def ocupac 1 "Fuerzas Armadas y Policiales" 2 "Miembros del Poder  Ejecutivo y Directores Empresas" 3 "Gerentes de pequeñas empresas" 4 "Profesionales, Cientificos e Intelectuales" 5 "Técnicos y trabajadores asimilados" 6 "Jefes y empleados  de oficina" 7 "Trabajadores calificados de servicios  personales" 8 "Comerciantes y Vendedores" 9 "Agricultores trabajadores calificados agropecuarios" 10 "Obreros de manufactura y minas" 11 "Obreros de construcción y choferes" 12 "Vendedores ambulantes" 13 "Trabajadores no calificados de servicios personales" 
lab val ocupac ocupac

fre ocupac

*--------------------
*      Cuadros
*--------------------

gen factor2=round(fac500a)

tabulate PET [iw=fac500a]

table PET [pw=fac500a], format (%10.0fc) row

table PET area [pw=fac500a], format (%10.0fc) row col

tab PET area [iw=fac500a],col

*--------------------
*Tasa de desempleo
*--------------------
tab c_act [iw=fac500a] if PET==1 //PET=1 es la PEA
tab c_act area [iw=fac500a] if PET==1,col

*** Categoria ocupacional
tab p507 area [fw=factor2] if ocu500==1,col

**** Rama
tab rama area [iw=fac500a] if ocu500==1,col
tab rama p507 [iw=fac500a] if ocu500==1,row

************************. 
*Ingreso Por Trabajo
*************************.   
*i524a1: ingreso total en ocupación principal dependiente
*d529t: Pago en especie estimado
*i530a: ingresos en ocup. principal independiente
*d536: valor de productos para autoconsumo
*i538a1 d540t i541a d543: lo mismo pero para ocupacion secundaria
*d544t: ingresos extraordinarios

*total
egen ingtrab_año=rsum(i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t)
gen ingtrab=ingtrab_año/12

*Filtrar los ingresos mayores a 0

** *Ingresos por sexo
table p207 [pw=fac500a] if ingtrab>0, c(mean ingtrab) row

tabstat ingtrab [aw=fac500a] if ingtrab>0, s(mean min p25 p50 p75 p95 max) by(p207)

*** Ingresos por área
tabstat ingtrab [aw=fac500a] if ingtrab>0, s(mean min p25 p50 p75 p95 max) by(area)

*** Ingresos por ramas
tabstat ingtrab [aw=fac500a] if ingtrab>0, s(mean min p25 p50 p75 p95 max) by(ramas)

*** Ingresos por nivel educativo
tabstat ingtrab [aw=fac500a] if ingtrab>0, s(mean min p25 p50 p75 p95 max) by(n_edu)

**** ingresos por hora
recode i513t i518 (.=0) if p519==1
gen horawt=i513t+i518 if p519==1 //egen horawt=rsum(i513t i518)
replace horawt=i520 if p519==2

gen ing_sem=ingtrab/4
gen ing_hor= ing_sem/horawt

tabstat ing_hor [aw=fac500a] if ingtrab>0, s(mean min p25 p50 p75 p95 max) by(p207)

table ramas p207 [pw=fac500a] if ingtrab>0, c(mean ing_hor) 



*----------------------------
*      INFORMALIDAD
*---------------------------

tab ocupinf [iw=fac500a]

tab ocupinf area [iw=fac500a],col

tab  ramas ocupinf [iw=fac500a],row

tab dpto ocupinf [iw=fac500a],row nofreq

** Como indicador proporción
gen informalidad=(ocupinf==1) if ocupinf!=.
fre informalidad

table dpto [iw=fac500a], c(mean informalidad)

*-------------------------------------
         *TRABAJO INFANTIL
*-------------------------------------

use "enaho01-2015-200",clear  //Población
merge 1:1 aÑo conglome vivienda hogar codperso using enaho01a-2015-500
drop if _merge==2
drop _merge
drop if codinfor=="00" //missing

*Solo menores de 5 a 17 años
keep if p208a>=5 & p208a<=17 

*residente habitual para indicadores de empleo (estima mejor población absoluta)
gen residente=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
keep if (residente==1) 

**gen horas cap 500, 14 a 17 años
egen hw_1417=rsum(i513t i518)
*se usa i520 para los jovenes que vana regresar a trabajar
replace hw_1417=i520 if hw_1417==0 & ocu500==1

*gen factor
gen factor=facpob07 if p208a>=5 & p208a<=13
replace factor=fac500a if p208a>=14 & p208a<=17

***indicador ocupado
gen ocup=0
replace ocup=1 if ((p210==1 | (t211>=1 & t211<=7 | t211==12)) & p208a>=5 & p208a<=13) //niños
replace ocup=1 if ((hw_1417>=1 | ocu500==1) & p208a>=14 & p208a<=17) //adolescentes

*tablas
table ocup [pw=factor],row format(%12.0fc) //26.38 %

tab ocup [iw=factor],m

**horas_trab totales
gen horas_trab=hw_1417 if p208a>=14 & p208a<=17
replace horas_trab=p211d if p208a>=5 & p208a<=13
replace horas_trab=0 if horas_trab==. | horas_trab==999

***trab intensivo
gen trab_int=0
replace trab_int=1 if horas_trab>=24 & p208a>=5 & p208a<=13
replace trab_int=1 if horas_trab>=36 & p208a>=14 & p208a<=17
table trab_int [pw=factor],row format(%12.0f)
tab trab_int [iw=factor],m

***trab infantil
gen trab_inf=0
replace trab_inf=1 if ocup==1 & p208a>=5 & p208a<=11
replace trab_inf=1 if trab_int==1 & p208a>=12 & p208a<=17
table trab_inf [pw=factor],row format(%12.0f)
tab trab_inf [iw=factor],m

