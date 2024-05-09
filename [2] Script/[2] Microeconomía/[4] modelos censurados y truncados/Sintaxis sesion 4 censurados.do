
clear all  // Borrar la base de datos previa


global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"

cd "$bases"

*---------------------
*** Ejemplo simulado 
*---------------------

clear
set seed 010203

set obs 1000

g x=rnormal(0,1)

g e=rnormal(0,1)

g y=1+1.5*x+e

*----------------
*** Regresión
*-----------------
reg y x 

two scatter y x ||  lfit y x

*----------------
*** Truncamiento (se acotó la muestra a una submuestra)
*----------------

gen y1=y if y>0  //missing para menores a cero

tw (hist y, color(red))(hist y1, color(blue))

reg y1 x //tengo sesgo en esta regresión

tw sc y x ||  lfit y x || sc y1 x  || lfit y1 x

truncreg y1 x, ll(0)
predict y1_trunc //estos nos predice el m

tw  lfit y x ||  lfit y1 x  || lfit y1_trunc x

sum y y1_trunc y1
sum y y1_trunc if y>0

*efectos marginales
truncreg y1 x, ll(0)

margins, dydx(*) predict(e(0,.))

*--------------
*** Censura 
*---------------
gen y2=y1
replace y2=0 if y2==. //completamos con ceros

tobit y2  x, ll(0)
predict  y2_cens

tw  lfit y x  || lfit y1_trunc x || lfit y2_cens x

tabstat y y1_trunc y2_cens, stat(mean median min max)

*Efectos marginales
tobit y2  x, ll(0)
margins, dydx(*) predict(e(0,.))

*---------------------------------------
*         Ejemplo con ENAHO 1
*---------------------------------------

** Oferta Laboral (Horas de trabajo a a semana) que esta en función del precio del trabajo (salario) y otros

*Se va a hacer el ejercico de truncamiento.

use enaho01a-2021-500, clear

keep if p204==1

*drop if ocu500==0

*** Horas trabajadas a la semana
d i513t i518 p519
fre p519

egen horas=rsum(i513t i518) if p519==1 
replace horas=i520 if p519==2
codebook horas

g mas60horas=(horas>=60 & horas!=.)
replace mas60horas=. if horas==.
tab mas60horas, miss

gen jefe=(p203==1)

gen urbano=(estrato<=5)

gen lima=(dominio==8)

gen hombre=(p207==1)

rename p208a edad

save b500, replace

******* 300
use enaho01a-2021-300, clear

*Años de educación
lab list p301a
g educ=0 if p301a<=2
replace educ=p301b  if p301a>=3 & p301a<=4
replace educ=p301b+6  if p301a>=5 & p301a<=6
replace educ=p301b+11  if p301a>=7 & p301a<=10
replace educ=p301b+16  if p301a==11
drop if p301a==12

gen estatal=(p301d==1)

save b300, replace

******** Uniendo bases
use b500, clear
merge 1:1 conglome vivienda hogar codperso using b300, keepusing(educ estatal)
keep if _merge==3
drop _merge

merge m:1 conglome vivienda hogar using sumaria-2021, keepusing(mieperho percepho inghog1d)
keep if _merge==3
drop _merge

g nopercepho=mieperho-percepho

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

gen ingtrab_mes=ingtrab_año/12

gen ingtrab_sem=ingtrab_mes/4

gen inghor=ingtrab_sem/horas

codebook inghor

tabstat inghor if inghor>0, s(mean min p5 p25 p50 p75 p99 max)

** Imputando algunos extremos
replace inghor=300 if inghor>300 & inghor!=. 
hist inghor

*** Varias variables solo tienen información para la persona ocupada

fre ocu500
g ocupado=(ocu500==1)
tab ocupado

** Oupación secundaria
d p517
fre p517
g ocupsec=(p517<=4  | p517==6) if ocupado==1
fre ocupsec

*** Independiente
fre p507
g independiente=(p507<=2) if ocupado==1 //en sentido amplio
fre independiente

recode p507 (1=3 "Empleador o patrono") (2=2 "Independiente") (3/7=1 "Dependiente"), gen(cat_ocup)

** La empresa donde trabaja es Persona juridica
d p510a1
fre p510a1

g persjurid=(p510a1==1) if ocupado==1 

**** lleva libros
fre p510b
gen libros=(p510b==1) if ocupado==1 
fre libros

** Formal
gen formal=(ocupinf==2)

*** casado
tab p209
g casado=p209<=2

*Número de hijos
preserve
use enaho01-2021-200, clear
gen kids614=(p208a>=6 & p208a<14)
gen kids0a5=(p208a<=5)
collapse (sum) kids*, by(conglome vivienda hogar)
save base_kids, replace
restore

*jalando bases
merge m:1 conglome vivienda hogar using base_kids
drop _merge

*** Culminación de estudios
lab list p301a
g culm_prim=(p301a>=4)
g culm_sec=(p301a>=6)
g culm_sup=(p301a>=10 | p301a==8)

*** Tamaño de empresa
fre p512a
g emp100_500=(p512a==4) if ocupado==1
g emp500_mas=(p512a==5) if ocupado==1

fre emp100_500
fre emp500_mas

g edad2=edad^2

*** Región natural

gen region=1 if dominio>=1 & dominio<=3 
replace region=1 if dominio==8
replace region=2 if dominio>=4 & dominio<=6 
replace region=3 if dominio==7 
label define region 1 "Costa" 2 "Sierra" 3 "Selva"

tab region,gen(reg)
ren reg1 costa
ren reg2 sierra
ren reg3 selva

keep horas hombre inghor culm_prim culm_sec culm_sup emp100_500 emp500_mas independiente libros culm_prim culm_sec culm_sup emp100_500 emp500_mas independiente libros edad edad2 casado jefe kids* independiente ocupsec libros lima educ estatal urbano costa sierra selva formal ingtrab_mes ingtrab_sem cat_ocup

save base_truncado, replace

******* Modelo
use base_truncado, clear

*ssc install mdesc //Visualizar la cantidad de missing
mdesc 

global xb1 inghor hombre edad edad2 culm_prim culm_sec culm_sup emp100_500 emp500_mas i.cat_ocup libros casado jefe kids* ocupsec

*** Lima metropolitana
fre lima

hist horas if lima==1, kdensity

** Regresión simple
reg horas $xb1 if lima==1

*Truncado
truncreg horas $xb1 if lima==1, ll(0)
margins, dydx(*) predict(e(0,.))

*---------------------------------------
*         Ejercico con ENAHO 2
*---------------------------------------

** La Censura se puede dar en el caso de los salarios por hora para toda la PET, se asume ingresos igual a cero para las personas que no trabajan

**Ecuación 
 *salario hora en función de años de escolaridad, edad o experiencia, casado, sexo_mujer, hijos de 0 a 5 años de edad, hijos de 6 a 11 años

use base_truncado, clear
 
*Tobit
hist inghor

gen log_inghor=log(inghor)
hist log_inghor

replace log_inghor=0 if log_inghor==.

gen mujer=(hombre==0)
fre mujer

global xb2 "educ mujer edad edad2 casado jefe kids* estatal urbano sierra selva"

sum log_inghor $xb2

*Regresion
reg log_inghor $xb2

* Tobit
tobit log_inghor $xb2, ll(0)
margins, dydx(*) predict(e(0,.))




