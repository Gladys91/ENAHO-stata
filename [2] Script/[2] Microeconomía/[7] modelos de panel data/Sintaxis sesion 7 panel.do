
clear all  // Borrar la base de datos previa

global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"
global sesion "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\script\[2] Microeconomía\[7] modelos de panel data"

cd "$bases"


*--------------------------------
*     Explorar base de ejemplo
*---------------------------------

** Base de la web de stata (cerdos)

webuse pig,clear

describe

*** Declarando el uso de un panel data

xtset id week //ver el mensaje de balanceo

xtdescribe //pattern: periodos

*** Haciendo algunos gráficos

xtline weight if id<=4, byopts(title ("Gráfico panel")) //un grafico para cada individuo
xtline weight if id<=4, overlay legend(order(1 "A" 2 "B" 3 "C" 4 "D"))

*** Descriptivos
xtsum
xtsum weight //overal, between, within

*****
sort id week

*-------------------------
*   Otra data de ejemplo
*-------------------------
use "$sesion/gasoline",clear

xtset country_ year

ren lgaspcar log_gasto
ren lincomep log_ingreso
ren lrpmg log_precio
ren lcarpcap log_otros_precios

xtsum

xtline log_gasto, byopts(title ("Gráfico panel")) //un grafico para cada individuo
xtline log_gasto if country_>=3 & country_<=6 , overlay legend(order(3 "CANADA" 4 "DINAMARCA" 5 "FRANCIA" 6 "ALEMANIA"))

*** Modelo Pooled
//modelo de regresión, pooled MCO (MCO agrupado)

reg log_gasto log_ingreso log_precio log_otros_precios

est sto regpooled

*** Estimador efectos fijos
reg log_gasto log_ingreso log_precio log_otros_precios i.country_

xtreg log_gasto log_ingreso log_precio log_otros_precios, fe //ver la prueba F

estimates store regfe

*** Estimador efectos aleatorias

xtreg log_gasto log_ingreso log_precio log_otros_precios, re
xttest0 //para comparar vs datos agrupados, se rechaza Ho, entonces EA mejor Agrupados

est sto regre

***
esttab regpooled regfe regre

*** test hausman

hausman regfe regre

*--------------------------------------------------------
*        Trabajando con base 200, 300, 500 y sumaria
*
*                  Efectos en el salario
*----------------------------------------------------------

*------------------------------------------------------
*              Explorar sumaria ENAHO
*-------------------------------------------------------

** Tenemos bases en formato wide (a lo ancho)
** Para trabajar panel data debemos de pasar a formato long

use sumaria-2017-2021-panel,clear

count
d hpanel*

br conglome* vivienda* hogar* hpanel* numpanh

d conglome* vivienda* hogar* hpanel*

*hpanel_1719s  //el "s" indica salto

tab hpanel_1721 //ver panel de 5 años

tab hpanel_1921  //3 años

*** Vamos a trabajar con panel del 2019 a 2021

keep if hpanel_1921==1

*** Factores
d fac*

tabstat  facpanel1921, s(sum) format (%12.0fc)

*-----------------------------------------------
*** Algunas cosas que podemos hacer con un panel
*-----------------------------------------------

** Matriz de transición
tab hpanel_2021  //2 años (2020 y 2021)

gen pobre20=(pobreza_20==1 | pobreza_20==2)
gen pobre21=(pobreza_21==1 | pobreza_20==2)

tab pobre20 pobre21 [iw=facpanel1921] if hpanel_2021==1

*---------------------------------------
*** Guardando las variables de interes
*----------------------------------------
isid numpanh

order conglome vivienda numpanh pobreza_* gashog2d* inghog1d* mieperho*

br conglome vivienda numpanh pobreza_* gashog2d* inghog1d* mieperho*

keep conglome vivienda numpanh pobreza_* gashog2d_* inghog1d_* mieperho* dominio* estrato* ubigeo* hpanel_1921 percepho*

save base_sumaria_panel, replace

*------------------------------------------------------
*** CARACTERISTICAS DE LOS MIEMBROS DEL HOGAR CAP 200
*-----------------------------------------------------

*** Explorando la base de datos
use "enaho01-2017-2021-200-panel.dta", clear

describe perpanel*

*** observando el balance de la data

tab perpanel2021
tab perpanel1921
tab perpanel1821
tab perpanel1721

*** Deseamos trabajar con los años 2019-2021

keep if perpanel1921==1

*** Reconocemos los identificadores

sort conglome vivienda numper

isid conglome vivienda numper

br conglome* vivienda* numper numpanh* p203*

br conglome vivienda numper numpanh19 numpanh20 numpanh21 p207_* p208a_* p209* p203* p204*

keep conglome vivienda numper perpanel1921 numpanh19 p207* p208a_* p209* p203_* p204* facpanel1921 

ren numpanh19 numpanh

tabstat facpanel1921,s(sum) format (%12.0fc)

save base_200_panel, replace

*------------------------------------------------------
***    CARACTERISTICAS EDUCATIVAS CAP 300
*-----------------------------------------------------

*** Explorando la base de datos
use "enaho01a-2017-2021-300-panel.dta", clear

describe perpanel*

*** años 2019-2021

keep if perpanel1921==1

*** Reconocemos los identificadores

isid conglome vivienda numper

*** Guaardamos las variables que necesitamos
keep conglome vivienda numper numpanh19 perpanel1921 p301a_* p301b_* p301c_* p301d_*

ren numpanh19 numpanh

save base_300_panel, replace

*------------------------------------------------------
***    CARACTERISTICAS EMPLEO CAP 500
*-----------------------------------------------------

*** Explorando la base de datos
use conglome vivienda numper numpanh19 codinfo* perpanel* p507* ocu500* p514* ocupinf* i513t* i518* p519* i520* i524a1* d529t* i530a* d536* i538a1* d540t* i541a* d543* d544t*  p506r4* p512a* perpanel1921 using "enaho01a-2017-2021-500-panel.dta", clear

describe perpanel*

*** años 2019-2021

keep if perpanel1921==1

*** Reconocemos los identificadores

isid conglome vivienda numper

ren numpanh19 numpanh

save base_500_panel, replace

***************   UNIENDO BASES  **********************

use base_200_panel, clear

merge m:1 conglome vivienda numpanh using base_sumaria_panel
keep if _merge==3
drop _merge

merge 1:1 conglome vivienda numpanh numper using base_300_panel
keep if _merge==3
drop _merge

merge 1:1 conglome vivienda numpanh numper using base_500_panel
keep if _merge==3
drop _merge

drop perpanel*
drop hpanel*

*** Dando formato de datos de panel

reshape long p203_ p204_ p207_ p208a_ p209_ pobreza_  gashog2d_  inghog1d_ mieperho_ ubigeo_ dominio_ estrato_  percepho_ p301a_ p301b_ p301c_ p301d_ p506r4_ p507_ p512a_ p514_ p519_ ocu500_ d529t_ d536_ d540t_ d543_  d544t_ i518_ i513t_ i520_ i530a_ i524a1_ i538a1_ i541a_ ocupinf_, i(conglome vivienda numpanh numper) j(año)


ren (p203_ p204_ p207_ p208a_ p209_ pobreza_  gashog2d_  inghog1d_ mieperho_ ubigeo_ dominio_ estrato_  percepho_ p301a_ p301b_ p301c_ p301d_ p506r4_ p507_ p512a_ p514_ p519_ ocu500_ d529t_ d536_ d540t_ d543_  d544t_ i518_ i513t_ i520_ i530a_ i524a1_ i538a1_ i541a_ ocupinf_) (p203 p204 p207 p208a p209 pobreza  gashog2d  inghog1d mieperho ubigeo dominio estrato percepho p301a p301b p301c p301d p506r4 p507 p512a p514 p519 ocu500 d529t d536 d540t d543  d544t i518 i513t i520 i530a i524a1 i538a1 i541a ocupinf)

****
egen individuo=group(conglome vivienda numpanh numper)

***
keep if año>=19 & año<=21

keep if p204==1

order facpanel* conglome vivienda numpanh numper individuo

sort individuo año
br individuo año p208a p204 p207 p209

*------------------------
*        Variables
*------------------------

*** gasto percapita mensual
gen gp=(gashog2d/mieperho)/12 //gasto percapita mensual

*** ingreso percapita hogar
gen ingper=(inghog1d/mieperho)/12 //gasto percapita mensual

*** pobre monetario
gen pobre=(pobreza==1 | pobreza==2)

*** Area
tab estrato
gen urbano=estrato<=5
lab def urbano 1 "urbano" 0 "rural"
lab val urbano urbano

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
use base_200_panel, clear

reshape long p208a_ p204_, i(conglome vivienda numpanh numper) j(año)

ren p208a_ p208a
ren p204_ p204

keep if año>=19 & año<=21
keep if p204==1

gen kids614=(p208a>=6 & p208a<14)
gen kids0a5=(p208a<=5)
collapse (sum) kids614 kids0a5, by(conglome vivienda numpanh año)
save niños_hogar_panel, replace
restore

*** Jalando kids
merge m:1 conglome vivienda numpanh año using niños_hogar_panel
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

** Formal
gen formal=(ocupinf==2)

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

*** Log de ingreso por hora
replace inghor=300 if inghor>300 & inghor!=.

gen log_inghor=log(inghor)

keep facpanel1921 conglome vivienda numpanh numper individuo año edad edad2 hombre mujer casado  jefe  p301a educ estatal p301d  neduc* niveduc ocu500 ocusec ocupado independiente formal p507 inghor ramas emp100_500 emp500_mas cat_ocup log_inghor kids* pobre pobreza percepho urbano dominio* ingper mieperho costa sierra selva ly

save "basefinal_panel", replace

*****************************************************************
* Solo se va a analizar  las personas que estuvieron ocupados los tres años 
*****************************************************************
use basefinal_panel,clear

sort numper año
isid numper año 

br individuo año ocu500 ramas log_inghor

bys numper: egen control=sum(ocupado)
keep if control==3 //estuvieron ocupados los 3 años
drop control

** Personas con ingresos mayores a cero en los 3 años
gen control=1 if inghor>0
bys numper: egen control2=sum(control)
keep if control2==3 
drop control*

*** Algunas inconsistencias
bys individuo: egen min_sex=min(mujer)
bys individuo: egen max_sex=max(mujer)
gen cont=min_sex-max_sex
tab cont

sort cont individuo
br cont individuo mujer año

replace mujer=0 if año==19 & individuo==749
replace mujer=1 if año==20 & individuo==3991
replace mujer=1 if año==19 & individuo==8989

drop cont min_sex max_sex 

** Seteando el panel
xtset individuo año
xtdescribe

xtsum inghor log_inghor

twoway (scatter log_inghor educ,msymbol(X)) (lfit log_inghor educ),name(graph1, replace)

regress log_inghor educ

*** Modelo MCO agrupado (pooled MCO)

global X1 mujer educ casado c.edad##c.edad jefe formal emp100_500 emp500_mas kids* estatal urbano sierra selva i.ramas i.cat_ocup //sobretodo por el test de Hausman

***
reg log_inghor $X1

est sto regpo

*** Estimador de efectos fijos

xtreg log_inghor $X1, fe
est sto regfe

*** Estimador de efectos aleatorios

xtreg log_inghor $X1, re 
est sto regre

esttab regpo regfe regre

*** Test de Hausman

hausman regfe regre

//se concluye que el mejor estimador es el de efectos fijos

*** Alternativa: Efectos fijos correlacionados
tab ramas, gen(ramas) 
tab cat_ocup, gen(cat_ocup) 

*Calculamos medias para cada individuo
egen meduc=mean(educ), by(individuo)
egen mcasado=mean(casado), by(individuo)
egen medad=mean(edad), by(individuo)
egen mjefe=mean(jefe), by(individuo)
egen mformal=mean(formal), by(individuo)
egen memp100_500=mean(emp100_500) , by(individuo)
egen memp500_mas=mean(emp500_mas) , by(individuo)
egen mkids614=mean(kids614) , by(individuo)
egen mkids0a5=mean(kids0a5) , by(individuo)
egen mestatal=mean(estatal) , by(individuo)
egen mramas2=mean(ramas2) , by(individuo)
egen mramas3=mean(ramas3) , by(individuo)
egen mramas4=mean(ramas4) , by(individuo)
egen mramas5=mean(ramas5) , by(individuo)
egen mramas6=mean(ramas6) , by(individuo)
egen mcat_ocup2=mean(cat_ocup2) , by(individuo)
egen mcat_ocup3=mean(cat_ocup3) , by(individuo)

** De nuevo
global X2 mujer educ casado c.edad##c.edad jefe formal emp100_500 emp500_mas kids* estatal urbano sierra selva ramas2-ramas6 cat_ocup2 cat_ocup3

*Efectos fijos
xtreg log_inghor $X2, fe
est store ef

*Efectos aleatorios
xtreg log_inghor $X2, re 
est store ea

** Para EAC
global X3 mujer educ casado c.edad##c.edad jefe formal emp100_500 emp500_mas kids* estatal urbano sierra selva ramas2-ramas6 cat_ocup2 cat_ocup3 meduc mcasado c.medad##c.medad mjefe mformal memp100_500 memp500_mas mkids614 mkids0a5 mestatal mramas2 mramas3 mramas4 mramas5 mramas6 mcat_ocup2 mcat_ocup3

xtreg log_inghor $X3, re 
est store eac

esttab ef ea eac 

test meduc mcasado c.medad#c.medad mjefe mformal memp100_500 memp500_mas mkids614 mkids0a5 mestatal mramas2 mramas3 mramas4 mramas5 mramas6 mcat_ocup2 mcat_ocup3 //prueba F conjunta
