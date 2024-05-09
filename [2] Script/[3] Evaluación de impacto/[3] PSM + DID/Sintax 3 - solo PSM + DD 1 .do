
clear all  // Borrar la base de datos previa

global bases "C:\Trabajos\Bases ENAHO\"
global graficos "C:\Trabajos\Bases ENAHO\Graficos"
global cuadros "C:\Trabajos\Bases ENAHO\Cuadros"
global sesion "C:\Trabajos\Empresa2\ValoraConsult\1. Programas\1. Especialización en Econometría con ENAHO\3. Evaluación de impacto\3. Sesion 3 - PSM + DID\"

cd "$bases"

*-------------------------------------------------------------
*        IMPACTO DE JUNTOS EN VALOR DE PRODUCCIÓN (RURAL)
*        IMPACTO DE JUNTOS EN LAS HORAS TRABAJADAS (RURAL)
*-------------------------------------------------------------
clear all

*p556 //Programa JUNTOS

*** Haciendo pool de cortes trasnversales

use base_enaho_hogares_2005,clear
append using base_enaho_hogares_2006

append using base_enaho_hogares_2009
append using base_enaho_hogares_2010

destring aÑo, gen(año)

** Tiempo
gen t=0 if año==2005 | año==2006
replace t=1 if año==2009 | año==2010

fre t

*** Programa
gen D=(juntos==1)

tab D t, m

tab pobre D //hay filtración y no pobres cerca a la linea de pobreza

*** niños menores de 14 años
gen menores_14=(kids614==1 | kids0a5==1)

*** Embarazo hogar
fre embarazo_hogar

*** Distritos juntos
preserve
keep if juntos==1
collapse (sum) juntos, by(ubigeo)
drop if juntos==1 //Excluir distritos donde solo hay un caso, es probabale que recién esté entrando el programa
save distritos_juntos_2010,replace
restore

merge m:1 ubigeo using distritos_juntos_2010
gen distrito_juntos_2010=(_merge==3)
drop if _merge==2
drop _merge

*** Distritos Juntos (total hasta el 2014/2015)
merge m:1 ubigeo using distritos_juntos
gen distrito_juntos_2014=(_merge==3)
drop if _merge==2
drop _merge

gen distritos_elegibles=(distrito_juntos_2014==1 & distrito_juntos_2010==0)

*----------------------------------------------------
*** Escogiendo un grupo de "No tratados" elegibles
*----------------------------------------------------

keep if area==2 //solo rural

gen notratado=1 if (embarazo_hogar==1 | menores_14==1) & pobre==1 & distritos_elegibles==1 & juntos==0

keep if D==1 | notratado==1

tab D t,m

*----------------------------------------
*  Variables para hacer el emparejamiento
*-----------------------------------------

**** Pobreza distrital
merge m:1 ubigeo using pobreza_total_unicos
drop if _merge==2
drop _merge

ren pob pob_dist 

*** Valores reales (produccion agricola, gasto e ingresos)
tabstat horas if t==0, s(n mean min p25 p50 p75 max sd) by(D)

tabstat horas if t==1, s(n mean min p25 p50 p75 max sd) by(D)

tabstat produccion_agri_real if t==0, by(D)

tabstat produccion_agri_real if t==1, by(D)

***
save base_trabajada_psm, replace
sum

*-------------------------------------------------
*** Propensity Score Matching en la línea de salida
*--------------------------------------------------
use base_trabajada_psm,clear

*Línea de salida
keep if t==1

tab D

***
tabstat produccion_agri_real, by(D) s(n mean min p25 p50 p75 p95 max sd)

*--------------------------
*** Variables para emparejar (determina participacion en el programa y están relacionados con el resultado) pero no han sido influenciadas por el programa
*---------------------------

global X pobreza_index mieperho hombre edad educ agua elect sierra selva kids0a5

probit D $X
dprobit D $X
predict pscore 
lstat

* Gráfico
twoway kdensity pscore if D==0 || kdensity pscore if D==1,  legend(order(1 "No tratados" 2 "Tratados"))

tabstat produccion_agri_real, by(D)

*** Impacto sobre producción agricola, 
*gastos e ingresos

**** Estimador
set seed 50
drawnorm orden
sort orden

*------------------
***   1 vecino
*-----------------

psmatch2 D $X, outcome(produccion_agri_real gasto_real horas asist_esc) n(1) com   //Hay que ver la base de precios, estoy usando base 2012, Cesar tomó base 2001

** Evaluar balanceo
pstest $X
psgraph

** Antes del matching
twoway kdensity _pscore if D==0, legend(label(1 "No Tratados")) || kdensity _pscore if D==1, name(sinm, replace) legend(label(2 "Tratados"))

** Con el matching
twoway (kdensity _pscore if D==0 [fw=_weight], legend(label(1 "Controles")))(kdensity _pscore if D==1 [fw=_weight], legend(label(2 "Tratados"))), name(conm, replace)

graph combine sinm conm

*Bootstrap
bootstrap r(att) : psmatch2 D $X, out(produccion_agri_real) com

** Con regresión
psmatch2 D $X, outcome(produccion_agri_real gasto_real horas asist_esc) n(1) com  

reg produccion_agri_real D [pw=_weight],robust

estima store psm_1vec
outreg2 psm_1vec using "$cuadros/PSM.xls", replace 

scalar b_v1_des=_b[D]

****
// |t|>1.64 entonces coeficiente significativo al 10%
// |t|>1.96 entonces coeficiente significativo al 5%
// |t|>2.33 entonces coeficiente significativo al 1%

*-------------
*** 5 vecinos
*------------

psmatch2 D $X, outcome(produccion_agri_real gasto_real horas) n(5) com //Hay que ver la base de precios, estoy usando base 2012, Cesar tomó base 2001

pstest $X
psgraph

** Con el matching
twoway (kdensity _pscore if D==0 [aw=_weight], legend(label(1 "Controles")))(kdensity _pscore if D==1 [aw=_weight], legend(label(2 "Tratados"))), name(conm, replace)

*-----------------
*** radius Caliper
*-----------------

psmatch2 D $X, outcome(produccion_agri_real gasto_real horas asist_esc)) radius caliper(0.005) com

pstest $X
psgraph

** Con el matching
twoway (kdensity _pscore if D==0 [aw=_weight], legend(label(1 "Controles")))(kdensity _pscore if D==1 [aw=_weight], legend(label(2 "Tratados"))), name(conm, replace)

*-----------
*** Kernel
*------------

psmatch2 D $X, outcome(produccion_agri_real gasto_real horas asist_esc) com kernel 

pstest $X
psgraph

** Con el matching
twoway (kdensity _pscore if D==0 [aw=_weight], legend(label(1 "Controles")))(kdensity _pscore if D==1 [aw=_weight], legend(label(2 "Tratados"))), name(conm, replace)

*** Con regresión
reg produccion_agri_real D [pw=_weight],robust

estima store psm_kernel
outreg2 psm_kernel using "$cuadros/PSM.xls", append 

scalar b_ker_des=_b[D]

*---------------------------------------------------
*                Linea de Base
*---------------------------------------------------

use base_trabajada_psm,clear

keep if t==0

*** Variables para emparejar (determina participacion en el programa y están relacionados con el resultado) pero no han sido influenciadas por el programa

global X pobreza_dist mieperho hombre edad educ agua elect sierra selva kids0a5

*** Impacto sobre producción agricola, 
*gastos e ingresos

**** Estimador
set seed 50
drawnorm orden
sort orden

*------------
*** 1 vecino
*------------

psmatch2 D $X, outcome(produccion_agri_real gasto_real horas) n(1) com   //Hay que ver la base de precios, estoy usando base 2012, Cesar tomó base 2001

** Evaluar balanceo
pstest $X

*** Con regresión
reg produccion_agri_real D [pw=_weight],robust

scalar b_v1_antes=_b[D]

*-----------
*** Kernel
*------------

psmatch2 D $X, outcome(produccion_agri_real gasto_real horas) com kernel 
pstest $X

** Con el matching
twoway (kdensity _pscore if D==0 [aw=_weight], legend(label(1 "Controles")))(kdensity _pscore if D==1 [aw=_weight], legend(label(2 "Tratados"))), name(conm, replace)

*** Con regresión
reg produccion_agri_real D [pw=_weight],robust

scalar b_ker_antes=_b[D]

*------------------------------------------------
*      Solo Doble Diferencias sin emparejar
*------------------------------------------------

use base_trabajada_psm,clear

gen Dxt=D*t

reg produccion_agri_real D t Dxt $X ,robust

estima store DID
outreg2 DID using "$cuadros/PSM.xls", append 

reg gasto_real D t Dxt $X ,robust

reg horas D t Dxt $X ,robust

*----------------------------------------------
*            Doble Diferencia + PSM
*---------------------------------------------

scalar DID_n1= b_v1_des - b_v1_antes
display DID_n1

scalar DID_ker= b_ker_des - b_ker_antes
display DID_ker

*----------------------
**    Con regresión
*--------------------
use base_trabajada_psm,clear

global X pobreza_index mieperho hombre edad educ agua elect sierra selva kids0a5

** Vecino más cercano
psmatch2 D $X if t==1, outcome(produccion_agri_real gasto_real horas) n(1) com 

gen peso=_weight

psmatch2 D $X if t==0, outcome(produccion_agri_real gasto_real horas) n(1) com 

replace peso=_weight if t==0

** Regresión
gen Dxt=D*t

reg produccion_agri_real D t Dxt [pw=peso],robust

estima store DID_PSM_v1
outreg2 DID_PSM_v1 using "$cuadros/PSM.xls", append 

reg gasto_real D t Dxt [pw=peso],robust

reg horas D t Dxt [pw=peso],robust

*** Kernel
psmatch2 D $X if t==1, outcome(produccion_agri_real gasto_real horas) kernel com 

drop peso
gen peso=_weight

psmatch2 D $X if t==0, outcome(produccion_agri_real gasto_real horas) kernel com 

replace peso=_weight if t==0

reg produccion_agri_real D t Dxt [pw=peso],robust

estima store DID_PSM_ker
outreg2 DID_PSM_ker using "$cuadros/PSM.xls", append 

reg gasto_real D t Dxt [pw=peso],robust

reg horas D t Dxt [pw=peso],robust

reg asist_esc D t Dxt [pw=peso],robust

