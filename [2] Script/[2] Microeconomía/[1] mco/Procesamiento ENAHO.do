
clear all  // Borrar la base de datos previa

global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"

cd "$bases"


************ Sumaria *************
use sumaria-2021, clear

*gasto percapita mensual
gen gp=(gashog2d/mieperho)/12 //gasto percapita mensual

*ingreso percapita hogar
gen ingper=(inghog1d/mieperho)/12 //gasto percapita mensual

*pobre monetario
gen pobre=(pobreza==1 | pobreza==2)

*Area
tab estrato
gen urbano=estrato<=5
lab def urbano 1 "urbano" 0 "rural"
lab val urbano urbano

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

*** ingreso percapita mensual
gen ly=ln(ingper)

*hist ly, normal
*hist ingper, normal

keep  pobre pobreza percepho urbano  dominio*  ingper mieperho conglome vivienda hogar factor07 costa sierra selva  domin02 ly dpto

save sumaria, replace

*-----------------------------------
*********** Cap. 100 *************
*---------------------------------
use enaho01-2021-100, clear

keep if result==1 | result==2 // completa e incompleta

gen agua=(p110<=2) //hogares que tienen agua por red pública 
gen desag=(p111<=2) //hogares que tienen desague por red pública 
gen elect=(p1121==1) //hogares que tienen luz electrica 

keep  agua desag elect  conglome vivienda hogar factor07
save cap100, replace

*------------------------------
******** Cap 200 **************
*-------------------------------
use enaho01-2021-200, clear

gen edad=p208a
gen edad2=edad*edad
keep if p204==1

fre p207
gen hombre=(p207==1)
gen mujer=(p207==2)

gen jefe=(p203==1)

tab p209
gen casado=p209<=2 //casado o conviviente

keep edad edad2 hombre mujer casado conglome vivienda hogar codperso jefe

save cap200, replace

*****
use enaho01-2021-200, clear

keep if p204==1

gen kids614=(p208a>=6 & p208a<14)
gen kids0a5=(p208a<=5)
collapse (sum) kids614 kids0a5, by(conglome vivienda hogar)
save niños_hogar, replace

*------------------------------------------
************* Capitulo 300
*-----------------------------------------
use enaho01a-2021-300, clear

drop if p301a==.
drop if p301a==12
keep if p204==1

*Años de educación
fre p301a
fre p301b
fre p301c

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

keep  conglome vivienda hogar codperso p301a educ estatal p301d  neduc* niveduc
save cap300, replace

*-----------------------------
********** Cap 500 *********
*-----------------------------
use enaho01a-2021-500, clear

drop if codinfor=="00"
keep if p204==1

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

** Categoria de horas trabajadas a la semana
tabstat horas, s(mean min p5 p25 p50 p75 p95 max)
gen mas60horas=(horas>=60 & horas!=.)
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

** Sector publico
gen sec_pub=(p510>=1 & p510<=3)
fre sec_pub

*------------------------
*      OCUPACIONES
*------------------------
recode  p505 (011/024=1) (111/139=2)(141/148 =3)(211/284 =4)(311/396 =5) (411/462=6)(511/565 =7)(571/583 =8) (611/641 =9)(711/799 =10) (811/886 =11)(911/927=12)(931/987 =13), gen(ocupac)

lab def ocupac 1 "Fuerzas Armadas y Policiales" 2 "Miembros del Poder  Ejecutivo y Directores Empresas" 3 "Gerentes de pequeñas empresas" 4 "Profesionales, Cientificos e Intelectuales" 5 "Técnicos y trabajadores asimilados" 6 "Jefes y empleados  de oficina" 7 "Trabajadores calificados de servicios  personales" 8 "Comerciantes y Vendedores" 9 "Agricultores trabajadores calificados agropecuarios" 10 "Obreros de manufactura y minas" 11 "Obreros de construcción y choferes" 12 "Vendedores ambulantes" 13 "Trabajadores no calificados de servicios personales" 
lab val ocupac ocupac

****
keep conglome vivienda hogar ubigeo estrato ocu500 ocusec ocupado independiente formal codperso p507 inghor ramas emp100_500 emp500_mas cat_ocup mas60horas sec_pub ocupac 
save cap500, replace

***************unión de bases
use sumaria, clear

merge 1:1 conglome vivienda hogar using cap100
drop _merge

merge 1:m conglome vivienda hogar using cap200
keep if _merge==3
drop _merge

merge 1:1 conglome vivienda hogar codperso using cap300
keep if _merge==3
drop _merge

merge 1:1 conglome vivienda hogar codperso using cap500
keep if _merge==3
drop _merge

merge m:1 conglome vivienda hogar using niños_hogar
keep if _merge==3
drop _merge

save base_enaho, replace

