
clear all 

global bases "C:\Trabajos\Bases ENAHO\"
global graficos "C:\Trabajos\Bases ENAHO\Graficos"
global cuadros "C:\Trabajos\Bases ENAHO\Cuadros"
global sesion "C:\Trabajos\Empresa2\ValoraConsult\1. Programas\1. Especialización en Econometría con ENAHO\3. Evaluación de impacto\3. Sesion 3 - PSM + DID\"

cd "$bases"

*** Pasar a código latino
clear all
foreach x in "sumaria_2007_2011_panel.dta" "enaho01_2007_2011_100_panel.dta" "enaho01a_2007_2011_300_panel.dta" "enaho01A-2007-2011-400-panel.dta"  {

unicode analyze  `x'
unicode encoding set ISO-8859-1 //código latino
unicode translate  `x'

}

clear all
unicode analyze  "enaho01A-2007-2011-500-panel.dta"
unicode encoding set ISO-8859-1 //código latino
unicode translate  "enaho01A-2007-2011-500-panel.dta"


*-------------------------------------------------------------
*         IMPACTO DE JUNTOS EN LAS HORAS TRABAJADAS
*-------------------------------------------------------------
clear all

use sumaria_2007_2011_panel,clear

count

br cong vivi num_hog hog* con_* viv_* hog_*

isid num_hog

d hpan* //ver panel de 5 años

tab hpan0708 //2 años, por la cantidad nos quedariamos con este panel
tab hpan0709 //3 años, alternativa

*** Vamos a trabajar con panel del 2007-2008

keep if hpan0708==1 //1er ejercicio

*** Factores
d fac*

tabstat fac_panel0708 , s(sum) format (%12.0fc)

*** Guardando las variables de interes
*-------------------------------------

keep cong vivi num_hog pobreza_* gashog2d_* inghog1d_* mieperho* dominio* estrato* ubigeo* percepho* fac_panel0708 fac_panel0809

save base_sumaria_panel_0708, replace

*------------------------------------------------------
*** CARACTERISTICAS DE LOS HOGARES CAP 100
*-----------------------------------------------------

clear all

use enaho01_2007_2011_100_panel,clear

keep if hpan0708==1

keep cong vivi num_hog p110_* p111_* p1121_*

save base_100_panel_0708, replace

*------------------------------------------------------
***    CARACTERISTICAS EDUCATIVAS CAP 300
*-----------------------------------------------------

*** Explorando la base de datos
use "enaho01a_2007_2011_300_panel.dta", clear

describe perpanel*

*** años 2019-2021

keep if perpan0708==1

*** Reconocemos los identificadores

isid cong vivi num_per

*** Guaardamos las variables que necesitamos
keep cong vivi num7 hog_08 num_per p301a_* p301b_* p301c_* p301d_*

ren num7 num_hog

save base_300_panel_0708, replace

*------------------------------------------------------
***    CARACTERISTICAS EDUCATIVAS CAP 400
*-----------------------------------------------------

*** Explorando la base de datos
use "enaho01A-2007-2011-400-panel.dta", clear

describe perpanel*

*** años 2019-2021

keep if perpan0708==1

*** Reconocemos los identificadores

isid cong vivi num_per

*** Guaardamos las variables que necesitamos
keep cong vivi num7 hog_08 num_per p203_* p204_* p207_* p208a_* p209_* p41414_*

ren num7 num_hog

save base_400_panel_0708, replace

*------------------------------------------------------
***    CARACTERISTICAS EMPLEO CAP 500
*-----------------------------------------------------

use cong vivi num_per num7 perpan* p507* ocu500* p514* i513t* i518* p519* i520* i524a1* d529t* i530a* d536* i538a1* d540t* i541a* d543* d544t*  p506r4* p512a* p5566a* using "enaho01A-2007-2011-500-panel.dta", clear

describe perpanel*

*** años 2007-2018

keep if perpan0708==1

*** Reconocemos los identificadores

isid cong vivi num_per

ren num7 num_hog

save base_500_panel_0708, replace

***************   UNIENDO BASES  **********************

use base_400_panel_0708, clear

merge m:1 num_hog using base_sumaria_panel_0708
keep if _merge==3
drop _merge

merge m:1 num_hog using base_100_panel_0708
keep if _merge==3
drop _merge

merge 1:1 num_hog num_per using base_300_panel_0708
keep if _merge==3
drop _merge

merge 1:1 num_hog num_per using base_500_panel_0708
keep if _merge==3
drop _merge

*** Dando formato de datos de panel
keep p110_* p1121_* p203_* p204_* p207_* p208a_* p209_* pobreza_*  gashog2d_*  inghog1d_* mieperho_* ubigeo_* dominio_* estrato_*  percepho_* p301a_* p301b_* p301c_* p301d_* p41414_* p506r4_* p507_* p512a_* p514_* p519_* ocu500_* d529t_* d536_* d540t_* d543_*  d544t_* i518_* i513t_* i520_* i530a_* i524a1_* i538a1_* i541a_* p5566a_* dominio_* num_hog num_per fac_panel0708

forval x=7/9 {

ren (p110_0`x' p1121_0`x' p203_0`x' p204_0`x' p207_0`x' p208a_0`x' p209_0`x' pobreza_0`x'  gashog2d_0`x'  inghog1d_0`x' mieperho_0`x' ubigeo_0`x' dominio_0`x' estrato_0`x'  percepho_0`x' p301a_0`x' p301b_0`x' p301c_0`x' p301d_0`x' p41414_0`x' p506r4_0`x' p507_0`x' p512a_0`x' p514_0`x' p519_0`x' ocu500_0`x' d529t_0`x' d536_0`x' d540t_0`x' d543_0`x'  d544t_0`x' i518_0`x' i513t_0`x' i520_0`x' i530a_0`x' i524a1_0`x' i538a1_0`x' i541a_0`x' p5566a_0`x') (p110_`x' p1121_`x' p203_`x' p204_`x' p207_`x' p208a_`x' p209_`x' pobreza_`x'  gashog2d_`x'  inghog1d_`x' mieperho_`x' ubigeo_`x' dominio_`x' estrato_`x' percepho_`x' p301a_`x' p301b_`x' p301c_`x' p301d_`x' p41414_`x' p506r4_`x' p507_`x' p512a_`x' p514_`x' p519_`x' ocu500_`x' d529t_`x' d536_`x' d540t_`x' d543_`x'  d544t_`x' i518_`x' i513t_`x' i520_`x' i530a_`x' i524a1_`x' i538a1_`x' i541a_`x' p5566a_`x')
}

**reshape
reshape long p110_ p1121_ p203_ p204_ p207_ p208a_ p209_ pobreza_  gashog2d_  inghog1d_ mieperho_ ubigeo_ dominio_ estrato_  percepho_ p301a_ p301b_ p301c_ p301d_ p41414_ p506r4_ p507_ p512a_ p514_ p519_ ocu500_ d529t_ d536_ d540t_ d543_  d544t_ i518_ i513t_ i520_ i530a_ i524a1_ i538a1_ i541a_ p5566a_ , i(num_hog num_per) j(año)


ren (p110_ p1121_ p203_ p204_ p207_ p208a_ p209_ pobreza_  gashog2d_  inghog1d_ mieperho_ ubigeo_ dominio_ estrato_  percepho_ p301a_ p301b_ p301c_ p301d_ p41414_ p506r4_ p507_ p512a_ p514_ p519_ ocu500_ d529t_ d536_ d540t_ d543_  d544t_ i518_ i513t_ i520_ i530a_ i524a1_ i538a1_ i541a_ p5566a_) (p110 p1121 p203 p204 p207 p208a p209 pobreza  gashog2d  inghog1d mieperho ubigeo dominio estrato percepho p301a p301b p301c p301d p41414 p506r4 p507 p512a p514 p519 ocu500 d529t d536 d540t d543  d544t i518 i513t i520 i530a i524a1 i538a1 i541a p5566a)

egen individuo=group(num_hog num_per)

***
keep if año==7 | año==8

keep if p204==1

order fac_* num_hog num_per individuo

sort individuo año
br individuo p208a p204 p209

*------------------------
*        Variables
*------------------------
***Agua y Luz
gen agua=(p110<=3) //hogares que tienen agua por red pública 
gen elect=(p1121==1) //hogares que tienen luz electrica 

*departamento
gen dpto=substr(ubigeo,1, 2)
destring dpto, replace

*** Area
tab estrato
gen area=(estrato<=5)
replace area=2 if area==0
lab def area 1 "urbano" 2 "rural"
lab val area area

** Jalando deflactores de precios
gen aniorec=2007 if año==7
replace aniorec=2008 if año==8
 
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

*** gasto percapita mensual
gen gp=(gashog2d/mieperho)/12 //gasto percapita mensual

gen gastopc_real=gashog2d/(i00*ld*12*mieperho) 

*** ingreso percapita hogar
gen ingper=(inghog1d/mieperho)/12 //gasto percapita mensual

gen ingper_real=inghog1d/(i00*ld*12*mieperho)

*** pobre monetario
gen pobre=(pobreza==1 | pobreza==2)

*** región natural
gen region=1 if dominio>=1 & dominio<=3 
replace region=1 if dominio==8
replace region=2 if dominio>=4 & dominio<=6 
replace region=3 if dominio==7 
label define region 1 "Costa" 2 "Sierra" 3 "Selva"

tab region,gen(reg)
ren reg1 costa
ren reg2 sierra
ren reg3 selva

*** ingreso percapita mensual
gen ly=ln(ingper)

*** Edad
gen edad=p208a
gen edad2=edad*edad

*** Sexo
gen hombre=(p207==1)
gen mujer=(p207==2)

*** Jefe de hogar
gen jefe=(p203==1)

*** Casado
gen casado=p209<=2 //casado o conviviente

*** Kids
preserve
use base_400_panel_0708, clear

keep p208a_* p204_* num_hog num_per

ren p208a_07 p208a_7
ren p208a_08 p208a_8
ren p208a_09 p208a_9

ren p204_07 p204_7
ren p204_08 p204_8
ren p204_09 p204_9

reshape long p208a_ p204_, i(num_hog num_per) j(año)

ren p208a_ p208a
ren p204_ p204

keep if año>=7 & año<=8
keep if p204==1

gen kids614=(p208a>=6 & p208a<14)
gen kids0a5=(p208a<=5)
gen menores_14=(kids0a5==1 | kids614==1)
collapse (sum) kids614 kids0a5 menores_14, by(num_hog)
replace menores_14=(menores_14>=1)
save niños_hogar_panel_0708, replace
restore

*** Jalando kids
merge m:1 num_hog using niños_hogar_panel_0708
drop if _merge==2
drop _merge

*Años de educación
fre p301a
fre p301b

gen educ=0 if p301a<=2
replace educ=p301b if  (p301a>=3  & p301a<=4) 
replace educ=p301c if  (p301a>=3  & p301a<=4) &  (p301b==0 | p301b==.)
replace educ=p301b+6 if  p301a>=5  & p301a<=6
replace educ=p301b+11 if  p301a>=7  & p301a<=10
replace educ=p301b+16 if  p301a==11
replace educ=p301b if  p301a==12

*colegio estatal
fre p301d

gen estatal=(p301d==1)

**Nivel educativo
fre p301a
recode p301a (1/2=1) (3/4=2) (5/6=3) (7/8=4) (9/11=5),gen (niveduc)
lab def niveduc 1 "Sin nivel" 2 "Primaria" 3 "secundaria" 4 "Sup. no universitario" 5 "Sup. universitario"
lab val niveduc niveduc

tab niveduc, g(neduc) //generar dicotómicas

drop if p301a==12 //saco del análisis a personas con EBE

*** Embarazo
preserve
gen embarazada=(p41414==1) 

keep num_hog num_per año embarazada

collapse (sum) embarazada, by(num_hog año)
gen embarazo_hogar=(embarazada>=1)

save embarazo_hogar_0708,replace
restore

***
merge m:1 num_hog año using embarazo_hogar_0708
drop if _merge==2
drop _merge

*** Ocupado
fre ocu500
gen ocupado=(ocu500==1)
lab def ocupado 1 "ocupado" 0 "no ocupado"
lab val ocupado ocupado

** Tiene ocupacion secundaria
gen ocusec=(p514==1)

** Categoria independiente en ocupacion principal (sentido amplio)
fre p507
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

** Ramas de actividad
gen ciuu=p506r4
tostring ciuu,replace
gen tam=length(ciuu)
replace tam=. if tam==1
replace ciuu="0"+ ciuu if tam==3   
gen ciuu2dig=substr(ciuu,1,2)
destring ciuu2dig, replace

recode ciuu2dig (1/3 =1) (5/9 =2) (10/33 =3) (35=4) (36/39 =5) (41/43 =6) (45/47 =7) (49/53 =8) (55/56 =9) (58/63 =10) (64/66 =11) (68 =12) (69/75 =13) (77/82 =14) (84 =15) (85 =16)(86/88 =17) (90/93 =18) (94/96 =19) (97/98 =20) (99 =21), gen(ciuu1dig)

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

*** Log de ingreso por hora
replace inghor=300 if inghor>300

gen log_inghor=log(inghor)

keep fac* num_hog num_per individuo año edad edad2 hombre mujer casado  jefe  p301a educ estatal p301d  neduc* niveduc ocu500 ocusec ocupado independiente p507 inghor ramas emp100_500 emp500_mas cat_ocup log_inghor kids* pobre pobreza percepho dominio* gastopc_real ingper_real mieperho costa sierra selva ly dpto p5566a p203 p204 ubigeo area embarazo_hogar menores_14 horas agua elect

save "basefinal_panel_0708", replace

** Beneficiarios JUNTOS

use basefinal_panel_0708,clear

gen ben_juntos=(p5566a==1) 

collapse (sum) ben_juntos, by(num_hog año)

replace ben_juntos=1 if ben_juntos>1

collapse (sum) ben_juntos, by(num_hog)
gen juntos=(ben_juntos==2) //Beneficiarios en ambos años

save hogares_juntos_0708, replace

*---------------------------------------------
******    PSM + DID PROGRAMA JUNTOS *********
*----------------------------------------------
use basefinal_panel_0708,clear

isid num_hog num_per año

keep if p203==1 | p203==2 //ha habido cambio entre jefe y esposo en el tiempo

br num_hog año num_per p203 

sort num_hog p203 año 
duplicates drop num_hog año, force //Solo con jefe de hogar

isid num_hog año p203

***
merge m:1 num_hog using hogares_juntos_0708
drop if _merge==2
drop _merge

*** Potenciales elegibles
*--------------------------
*** Distritos juntos
preserve
keep if p5566a==1
gen dist_juntos=1
collapse (sum) dist_juntos, by(ubigeo)
save distritos_juntos_0708,replace
restore

merge m:1 ubigeo using distritos_juntos_0708
gen distrito_juntos_0708=(_merge==3)
drop if _merge==2
drop _merge

*** Distritos Juntos (total hasta el 2014)
merge m:1 ubigeo using distritos_juntos
gen distrito_juntos_2014=(_merge==3)
drop if _merge==2
drop _merge

gen distritos_elegibles=(distrito_juntos_2014==1 & distrito_juntos_0708==0)

****
fre juntos
keep if area==2 //solo rural

** No tratados
gen notratado=1 if (embarazo_hogar==1 | menores_14==1) & pobre==1 & distritos_elegibles==1 & juntos==0

bys num_hog: egen notratado_s=sum(notratado)
replace notratado_s=1 if notratado_s==2

drop notratado
ren notratado_s notratado

**** Pobreza distrital
merge m:1 ubigeo using pobreza_total_unicos
drop if _merge==2
drop _merge

ren pob pob_dist 

**Regresando a formato wide
duplicates tag num_hog,gen (dup)
drop if dup==0

reshape wide p203 - log_inghor, i(num_hog num_per) j(año)

*----------------------------------------------------
*** Escogiendo un grupo de "No tratados" elegibles
*----------------------------------------------------
gen D=juntos

keep if D==1 | notratado==1

tab D notratado,m

tabstat horas8, s(n mean min p25 p50 p75 max sd) 

global X pobreza_index mieperho7 hombre7 edad7 educ7 agua7 elect7 sierra7 selva7 kids0a57

sum $X

probit D $X
dprobit D $X
predict pscore 
lstat

* Gráfico
twoway kdensity pscore if D==0 || kdensity pscore if D==1,  legend(order(1 "No tratados" 2 "Tratados"))

tabstat horas8, by(D)

**** Estimador
set seed 50
drawnorm orden
sort orden

*------------
*** 1 vecino
*------------

psmatch2 D $X, outcome(horas8 gastopc_real8 ingper_real8) n(1) com   //Hay que ver la base de precios, estoy usando base 2012, Cesar tomó base 2001

** Evaluar balanceo
pstest $X
psgraph

** Antes del matching
twoway kdensity _pscore if D==0, legend(label(1 "No Tratados")) || kdensity _pscore if D==1, name(sinm, replace) legend(label(2 "Tratados"))

** Con el matching
twoway (kdensity _pscore if D==0 [fw=_weight], legend(label(1 "Controles")))(kdensity _pscore if D==1 [fw=_weight], legend(label(2 "Tratados"))), name(conm, replace)

graph combine sinm conm

****
// |t|>1.64 entonces coeficiente significativo al 10%
// |t|>1.96 entonces coeficiente significativo al 5%
// |t|>2.33 entonces coeficiente significativo al 1%

*-------------
*** 5 vecinos
*------------

psmatch2 D $X, outcome(horas8 gastopc_real8 ingper_real8) n(5) com //Hay que ver la base de precios, estoy usando base 2012, Cesar tomó base 2001

pstest $X
psgraph

** Con el matching
twoway (kdensity _pscore if D==0 [aw=_weight], legend(label(1 "Controles")))(kdensity _pscore if D==1 [aw=_weight], legend(label(2 "Tratados"))), name(conm, replace)

*-----------------
*** radius Caliper
*-----------------

psmatch2 D $X, outcome(horas8 gastopc_real8 ingper_real8) radius caliper(0.005) com

pstest $X
psgraph

** Con el matching
twoway (kdensity _pscore if D==0 [aw=_weight], legend(label(1 "Controles")))(kdensity _pscore if D==1 [aw=_weight], legend(label(2 "Tratados"))), name(conm, replace)

*-----------
*** Kernel
*------------

psmatch2 D $X, outcome(horas8 gastopc_real8 ingper_real8) com kernel 
pstest $X
psgraph

** Con el matching
twoway (kdensity _pscore if D==0 [aw=_weight], legend(label(1 "Controles")))(kdensity _pscore if D==1 [aw=_weight], legend(label(2 "Tratados"))), name(conm, replace)

*------------------
****** Dif en Dif + PSM
*------------------

gen delta_hor=horas8-horas7

gen delta_gp=gastopc_real8 - gastopc_real7

gen delta_ingper= ingper_real8 - ingper_real7


**** 6.1.1 Imponiendo el soporte comun

psmatch2 D $X, outcome(delta_hor delta_gp delta_ingper) n(1) com 

**** 6.2 Matching con 5 vecinos

psmatch2 D $X, outcome(delta_hor delta_gp delta_ingper) n(5) com

**** 6.4.1 Emparejamiento de distancia maxima

psmatch2 D $X, outcome(delta_hor delta_gp delta_ingper) radius caliper(0.001) com

psmatch2 D $X, outcome(delta_hor delta_gp delta_ingper) radius caliper(0.005) com		

**** 6.5.1 Emparejamiento por kernel

psmatch2 D $X, outcome(delta_hor delta_gp delta_ingper) com kernel

bootstrap r(att) : psmatch2 D $X, out(delta_ha) com kernel




