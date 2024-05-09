

**** Pocesamiento de datos

clear all 

global bases "C:\Trabajos\Bases ENAHO\"
global graficos "C:\Trabajos\Bases ENAHO\Graficos"
global cuadros "C:\Trabajos\Bases ENAHO\Cuadros"

cd "$bases"

clear all
foreach x in "sumaria-2005.dta" "sumaria-2006.dta" "sumaria-2007.dta" "sumaria-2008.dta" "sumaria-2009.dta" "sumaria-2010.dta" "enaho01-2005-100.dta" "enaho01-2006-100.dta" "enaho01-2007-100.dta" "enaho01-2008-100.dta" "enaho01-2009-100.dta" "enaho01-2010-100.dta"  "enaho01-2005-200.dta" "enaho01-2006-200.dta"  "enaho01-2007-200.dta" "enaho01-2008-200.dta" "enaho01-2009-200.dta" "enaho01-2010-200.dta" "enaho01a-2005-300.dta"  "enaho01a-2006-300.dta" "enaho01a-2007-300.dta" "enaho01a-2008-300.dta" "enaho01a-2009-300.dta"  "enaho01a-2010-300.dta" "enaho01a-2005-400.dta" "enaho01a-2006-400.dta" "enaho01a-2007-400.dta" "enaho01a-2008-400.dta" "enaho01a-2009-400.dta" "enaho01a-2010-400.dta" "enaho01a-2005-500.dta" "enaho01a-2006-500.dta" "enaho01a-2007-500.dta" "enaho01a-2008-500.dta" "enaho01a-2009-500.dta" "enaho01a-2010-500.dta" "enaho02-2005-2100.dta" "enaho02-2006-2100.dta" "enaho02-2007-2100.dta"  "enaho02-2008-2100.dta" "enaho02-2009-2100.dta" "enaho02-2010-2100.dta" {

unicode analyze  `x'
unicode encoding set ISO-8859-1 //código latino
unicode translate  `x'
}

use "enaho01a-2009-500.dta",clear
capture ren año aÑo
save "enaho01a-2009-500.dta",replace

************ Sumaria *************

foreach i in "2005" "2006" "2007" "2008" "2009" "2010" {

use sumaria-`i', clear

*Area
tab estrato
gen urbano=estrato<=5
lab def urbano 1 "urbano" 0 "rural"
lab val urbano urbano

gen area=1 if urbano==1
replace area=2 if urbano==0

*dominio
gen domin02=1 if dominio>=1 & dominio<=3 & urbano==1
replace domin02=2 if dominio>=1 & dominio<=3 & urbano==0
replace domin02=3 if dominio>=4 & dominio<=6 & urbano==1
replace domin02=4 if dominio>=4 & dominio<=6 & urbano==0
replace domin02=5 if dominio==7 & urbano==1
replace domin02=6 if dominio==7 & urbano==0
replace domin02=7 if dominio==8

label define domin02 1 "Costa urbana" 2 "Costa rural" 3 "Sierra urbana" 4 "Sierra rural" 5 "Selva urbana" 6 "Selva rural" 7 "Lima Metropolitana"
label value domin02 domin02

*departamento
**************
gen dpto=substr(ubigeo,1, 2)
destring dpto, replace

lab def dpto 1 "AMAZONAS" 2 "ANCASH" 3 "APURIMAC" 4 "AREQUIPA" 5 "AYACUCHO" 6 "CAJAMARCA" 7 "CALLAO" 8 "CUSCO" 9 "HUANCAVELICA" 10 "HUANUCO" 11 "ICA" 12 "JUNIN" 13 "LA LIBERTAD" 14 "LAMBAYEQUE" 15 "LIMA" 16 "LORETO" 17 "MADRE DE DIOS" 18 "MOQUEGUA" 19 "PASCO" 20 "PIURA" 21 "PUNO" 22 "SAN MARTIN" 23 "TACNA" 24 "TUMBES" 25 "UCAYALI"
lab val dpto dpto

*región natural
**************
gen region=1 if dominio>=1 & dominio<=3 
replace region=1 if dominio==8
replace region=2 if dominio>=4 & dominio<=6 
replace region=3 if dominio==7 
label define region 1 "Costa" 2 "Sierra" 3 "Selva"

tab region,gen(reg)
ren reg1 costa
ren reg2 sierra
ren reg3 selva

** Jalando deflactores de precios
destring aÑo, gen(aniorec)
merge m:1 aniorec dpto using "deflactores_base2012.dta"
drop if _merge==2
drop _merge

** Dominio 2
gen dominioA=1 if dominio==1 & area==1
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

label define dominioA 1 "Costa norte urbana" 2 "Costa norte rural" 3 "Costa centro urbana" 4 "Costa centro rural" /*
*/ 5 "Costa sur urbana" 6 "Costa sur rural"	7 "Sierra norte urbana"	8 "Sierra norte rural"	9 "Sierra centro urbana" /* 
*/ 10 "Sierra centro rural"	11 "Sierra sur urbana" 12 "Sierra sur rural" 13 "Selva alta urbana"	14 "Selva alta rural" /*
*/ 15 "Selva baja urbana" 16 "Selva baja rural" 17 "Lima Metropolitana"
lab val dominioA dominioA 

*Jalando deflactores espaciales
merge m:1 dominioA using "despacial_ldnew.dta"
drop _m

*hist ly, normal
*hist ingper, normal

*** gasto percapita mensual
gen gastopc_real=gashog2d/(mieperho*12*i00*ld) //gasto percapita mensual

gen gasto_real=gashog2d/(i00*ld) 

*** ingreso percapita hogar
gen ingper_real=inghog1d/(mieperho*12*i00*ld) //gasto percapita mensual
gen ing_real=inghog1d/(i00*ld)

*** pobre monetario
gen pobre=(pobreza==1 | pobreza==2)

**
keep aÑo pobre percepho urbano  dominio* gastopc_real gasto_real ingper_real ing_real mieperho conglome vivienda hogar factor07 costa sierra selva  domin02 ly dpto linpe linea i00 ld area

save sumaria, replace

*-----------------------------------
*********** Cap. 100 *************
*---------------------------------
use enaho01-`i'-100, clear

keep if result==1 | result==2 // completa e incompleta

gen agua=(p110<=3) //hogares que tienen agua por red pública 
gen desag=(p111<=2) //hogares que tienen desague por red pública 
gen elect=(p1121==1) //hogares que tienen luz electrica 


keep aÑo agua desag elect  conglome vivienda hogar factor07
save cap100, replace

*------------------------------
******** Cap 200 **************
*-------------------------------
use enaho01-`i'-200, clear

gen edad=p208a
gen edad2=edad*edad
keep if p204==1

capture ren a_o aÑo

***
replace conglome=ltrim(rtrim(conglome))
gen tam=length(conglome)
replace conglome="0"+ conglome if tam==3
replace conglome="00" + conglome if tam==2
replace conglome="000" + conglome if tam==1
drop tam

replace vivienda=ltrim(rtrim(vivienda))
gen tam=length(vivienda)
replace vivienda="0" + vivienda if tam==2
replace vivienda="00" + vivienda if tam==1
drop tam

replace codperso=ltrim(rtrim(codperso))
gen tam=length(codperso)
replace codperso="0" + codperso if tam==1
drop tam

**sexo
fre p207
gen hombre=(p207==1)
gen mujer=(p207==2)

gen jefe=(p203==1)

tab p209
gen casado=p209<=2 //casado o conviviente

keep aÑo edad edad2 hombre mujer casado conglome vivienda hogar codperso jefe

save cap200, replace

***** Niños en el hogar
use enaho01-`i'-200, clear

keep if p204==1

capture ren a_o aÑo
***
replace conglome=ltrim(rtrim(conglome))
gen tam=length(conglome)
replace conglome="0"+ conglome if tam==3
replace conglome="00" + conglome if tam==2
replace conglome="000" + conglome if tam==1
drop tam

replace vivienda=ltrim(rtrim(vivienda))
gen tam=length(vivienda)
replace vivienda="0" + vivienda if tam==2
replace vivienda="00" + vivienda if tam==1
drop tam

replace codperso=ltrim(rtrim(codperso))
gen tam=length(codperso)
replace codperso="0" + codperso if tam==1
drop tam
***

gen kids614=(p208a>=6 & p208a<14)
gen kids0a5=(p208a<=5)
collapse (sum) kids614 kids0a5, by(aÑo conglome vivienda hogar)
save niños_hogar, replace

*------------------------------------------
************* Capitulo 300
*-----------------------------------------
use enaho01a-`i'-300, clear

drop if p301a==.
drop if p301a==12
keep if p204==1

***
replace conglome=ltrim(rtrim(conglome))
gen tam=length(conglome)
replace conglome="0"+ conglome if tam==3
replace conglome="00" + conglome if tam==2
replace conglome="000" + conglome if tam==1
drop tam

replace vivienda=ltrim(rtrim(vivienda))
gen tam=length(vivienda)
replace vivienda="0" + vivienda if tam==2
replace vivienda="00" + vivienda if tam==1
drop tam

replace codperso=ltrim(rtrim(codperso))
gen tam=length(codperso)
replace codperso="0" + codperso if tam==1
drop tam

*Años de educación
fre p301a
fre p301b

gen educ=0  if  p301a<=2
replace educ=p301b if  (p301a>=3  & p301a<=4) 
replace educ=p301c if  (p301a>=3  & p301a<=4) &  (p301b==0 | p301b==.)
replace educ=p301b+6 if  p301a>=5  & p301a<=6
replace educ=p301b+11 if  p301a>=7  & p301a<=10
replace educ=p301b+16 if  p301a==11
replace educ=p301b if  p301a==12

*colegio estatal
fre p301d

gen estatal=(p301d==1)
tab estatal

**Nivel educativo
fre p301a
recode p301a (1/2=1) (3/4=2) (5/6=3) (7/8=4) (9/11=5),gen (niveduc)
lab def niveduc 1 "Sin nivel" 2 "Primaria" 3 "secundaria" 4 "Sup. no universitario" 5 "Sup. universitario"
lab val niveduc niveduc

tab niveduc, g(neduc) //generar dicotómicas

** Asistencia escolar
gen asist=(p307==1 & p208a<=14)

bys conglome vivienda hogar: egen asist_esc=sum(asist)
replace asist_esc=(asist_esc>0)

keep aÑo conglome vivienda hogar codperso p301a educ estatal p301d  neduc* niveduc asist_esc
save cap300, replace

*------------------------------------------
************* Capitulo 400
*-----------------------------------------
use enaho01a-`i'-400, clear

drop if codinfor=="0"
keep if p204==1
capture ren a_o aÑo

***
replace conglome=ltrim(rtrim(conglome))
gen tam=length(conglome)
replace conglome="0"+ conglome if tam==3
replace conglome="00" + conglome if tam==2
replace conglome="000" + conglome if tam==1
drop tam

replace vivienda=ltrim(rtrim(vivienda))
gen tam=length(vivienda)
replace vivienda="0" + vivienda if tam==2
replace vivienda="00" + vivienda if tam==1
drop tam

replace codperso=ltrim(rtrim(codperso))
gen tam=length(codperso)
replace codperso="0" + codperso if tam==1
drop tam

*** Embarazo
gen embarazada=(p414_14==1) 

keep aÑo conglome vivienda hogar codperso embarazada

save cap400,replace

*** Embarazada a nivel hogar
use cap400, clear

collapse (sum) embarazada, by(aÑo conglome vivienda hogar)
gen embarazo_hogar=(embarazada>0)
save embarazo_hogar,replace

*-----------------------------
********** Cap 500 *********
*-----------------------------
use enaho01a-`i'-500, clear

drop if codinfor=="00"
keep if p204==1

***
replace conglome=ltrim(rtrim(conglome))
gen tam=length(conglome)
replace conglome="0"+ conglome if tam==3
replace conglome="00" + conglome if tam==2
replace conglome="000" + conglome if tam==1
drop tam

replace vivienda=ltrim(rtrim(vivienda))
gen tam=length(vivienda)
replace vivienda="0" + vivienda if tam==2
replace vivienda="00" + vivienda if tam==1
drop tam

replace codperso=ltrim(rtrim(codperso))
gen tam=length(codperso)
replace codperso="0" + codperso if tam==1
drop tam

*** ocupado
fre ocu500
gen ocupado=(ocu500==1)
lab def ocupado 1 "ocupado" 0 "no ocupado"
lab val ocupado ocupado

** Tiene ocupacion secundaria
tab p514
gen ocusec=(p514==1)

** Categoria independiente en ocupacion principal (sentido amplio)
tab p507
gen independiente=(p507==2)
lab def independiente 1 "independiente" 0 "dependiente"
lab val independiente independiente

recode p507 (1=3 "Empleador o patrono") (2=2 "Independiente") (3/7=1 "Dependiente"), gen(cat_ocup)

** Horas trabajadas a la semana
egen horas=rsum(i513t i518) if p519==1 
replace horas=i520 if p519==2

** Ingreso por trabajo
egen ingtrab_año=rsum(i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t)

gen ingtrab_mes=ingtrab_año/12
gen ingtrab_sem=ingtrab_mes/4
gen inghor=ingtrab_sem/horas

** Categoria de horas trabajadas a la semana
tabstat horas, s(mean min p5 p25 p50 p75 p95 max)
gen mas60horas=horas>=60 & horas!=.
fre mas60horas

** Ramas de actividad
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

** Tamaño de empresa
g emp100_500=(p512a==4) if ocupado==1
g emp500_mas=(p512a==5) if ocupado==1

** Beneficiario de JUNTOS
gen ben_juntos=(p5566a==1) 

****
keep aÑo conglome vivienda hogar ubigeo estrato ocu500 ocusec ocupado independiente codperso p507 inghor ramas emp100_500 emp500_mas cat_ocup mas60horas ben_juntos horas
save cap500, replace

**** JUNTOS a nivel de hogar
use cap500, clear

collapse (sum) ben_juntos, by(aÑo conglome vivienda hogar)
gen juntos=(ben_juntos>0)
save hogares_juntos, replace

*------------------------------------------
*     Producción agrícola (Cap. 2100)
*------------------------------------------
use enaho02-`i'-2100, clear

capture ren a_o aÑo
***
replace conglome=ltrim(rtrim(conglome))
gen tam=length(conglome)
replace conglome="0"+ conglome if tam==3
replace conglome="00" + conglome if tam==2
replace conglome="000" + conglome if tam==1
drop tam

replace vivienda=ltrim(rtrim(vivienda))
gen tam=length(vivienda)
replace vivienda="0" + vivienda if tam==2
replace vivienda="00" + vivienda if tam==1
drop tam

replace codperso=ltrim(rtrim(codperso))
gen tam=length(codperso)
replace codperso="0" + codperso if tam==1
drop tam

*tabla de producots
gen codigo=p2100b
destring codigo, replace force
merge m:1 codigo using enaho-tabla-agropecuario
drop if _merge==2
drop _merge

drop if codinfor=="00" //missing

sort conglome vivienda hogar codperso p2100a

*Valor agricola anual S/.
gen produccion_agri=.
capture replace produccion_agri=p21003n if aÑo=="2005"
capture replace produccion_agri=p21002n if aÑo!="2005"
drop if produccion_agri==.

keep aÑo conglome vivienda hogar produccion_agri
merge m:1 aÑo conglome vivienda hogar using sumaria,keepusing(i00 ld)

** Valor agricola anual real
gen produccion_agri_real=produccion_agri/(i00*ld)

collapse (sum) produccion_agri_real, by(aÑo conglome vivienda hogar)

save produccion_agri, replace

***************unión de bases
use sumaria, clear

merge 1:1 aÑo conglome vivienda hogar using cap100
drop _merge

merge 1:m aÑo conglome vivienda hogar using cap200
keep if _merge==3
drop _merge

merge 1:1 aÑo conglome vivienda hogar codperso using cap300
drop _merge

merge m:1 aÑo conglome vivienda hogar codperso using cap400
drop if _merge==2
drop _merge

merge 1:1 aÑo conglome vivienda hogar codperso using cap500
keep if _merge==3
drop _merge

merge m:1 aÑo conglome vivienda hogar using niños_hogar
keep if _merge==3
drop _merge

merge m:1 aÑo conglome vivienda hogar using produccion_agri
drop if _merge==2
drop _merge

merge m:1 aÑo conglome vivienda hogar using hogares_juntos
drop if _merge==2
replace juntos=0 if juntos==.
drop _merge

merge m:1 aÑo conglome vivienda hogar using embarazo_hogar
drop if _merge==2
replace embarazo_hogar=0 if embarazo_hogar==.
drop _merge

save base_enaho_`i', replace

**** Solo hogares (jefe de hogar)

keep if jefe==1
save base_enaho_hogares_`i', replace

}

