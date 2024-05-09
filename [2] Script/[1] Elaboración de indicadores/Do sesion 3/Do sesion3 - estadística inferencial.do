
clear all  // Borrar la base de datos previa

global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"

cd "$bases"

*---------------------------------------------------------
*        Cap. 100: Población 
*-----------------------------------------------------------

use "enaho01-2016-100",clear 

*Para ver duplicados

duplicates tag conglome vivienda, gen(dup)

fre dup 


*---------------------------------------------------------
*        Cap. 300: Educación (personas de 3 años a más)
*-----------------------------------------------------------
use "enaho01a-2021-300",clear 

keep if p204==1 //miembros de hogar

drop if codinfor=="00" //missings

drop if p301a==. 

gen factor2=round(factora07)

tabstat factora07, s(sum) format (%12.0fc)

*** append
append using "enaho01a-2016-300"

tab aÑo

drop if aÑo=="2016"

*--------------------
*       Merge
*---------------------
*m:1: muchos a 1
*1:m: 1 a muchos
*m:m muchos a muchos (no se recomienda)

*Relación m:1 (Población es muchos y hogares es 1 respecto a la llave que es a nivel hogar)

*** Merge con la base 200 (población)
merge 1:1 aÑo conglome vivienda hogar codperso using enaho01-2021-200
drop if _merge==2 //me quedo con la cantidad de registros de la base madre
drop _merge

*** Merge con la base 100 (hogares)
merge m:1 aÑo conglome vivienda hogar using enaho01-2021-100
drop if _merge==2 
drop _merge

*Área geográfica
fre estrato

recode estrato (1/5=1)(6/8=2), gen(area)
lab def area 1 "Urbano" 2 "Rural"
lab val area area

fre area

*** Departamento
gen ubigeo1=substr(ubigeo,1,2) //Extracción de código de región
gen dpto=real(ubigeo1) //Conversión a dato numérico
drop ubigeo1

lab def dpto 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" 11 "Ica" 12 "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martin" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label val dpto dpto

*--------------------
*    Nivel educativo
*--------------------

fre p301a

fre p301a [iw=factora07] 

tab p301a [iw=factora07]

*--------------------
*  Años de educación
*--------------------

gen educ=0  if  p301a<=2
replace educ=p301b if  (p301a>=3  & p301a<=4) 
replace educ=p301c if  (p301a>=3  & p301a<=4) & (p301b==0 | p301b==.)
replace educ=p301b+6 if  p301a>=5  & p301a<=6
replace educ=p301b+11 if  p301a>=7  & p301a<=10
replace educ=p301b+16 if  p301a==11
replace educ=p301b if  p301a==12

fre educ

*-------------------------------------------
*     Indicador: "% de personas analfabetas"
*   (% respecto a las personas de 15 a más años)
*------------------------------------------
gen analfabeto=0 if (p208a>=15)
replace analfabeto=1 if (p208a>=15 & p302==2) 

lab def  analfabeto 0 "Alfabeto" 1 "Analfabeto" 
lab val analfabeto analfabeto

fre analfabeto

tab analfabeto [fw=factor2]
 
tab analfabeto [iw=factora07]

table p207 [pw=factora07],c(mean analfabeto) row

tabstat analfabeto [aw=factora07], by(p207)

*-----------------------------------------------------------
*  Intervalos de confianza para el estimador Media muestral
*-----------------------------------------------------------

svyset [pweight = factora07], psu(conglome) strata(estrato)

svy: prop analfabeto, percent cformat(%9.1fc)
estat cv //Lo recomendable es menor a 15%, mas pequeño mejor

*Un indicador dicotómico (0,1) lo podemos tratar como una variable cuantitativa
svy: mean analfabeto
estat cv //Lo recomendable es menor a 15%, mas pequeño mejor

*Por sexo
svy: prop analfabeto, percent cformat(%9.1fc) over(p207)
estat cv 

svy: mean analfabeto,  over(p207)
estat cv 

svy: mean analfabeto,  over(dpto)
estat cv 

svy: mean p208a,  over(p207)
estat cv 

** Tabulado con intervalos de confianza
svy: tabulate p301a, format(%11.3g) percent ci cv se

*-----------------------------------
*** Exportar tabla con matrices
*-----------------------------------
* Instalar previamente 
*ssc install dm79



svy: mean analfabeto

return list
ereturn list

matrix list e(b) //Visualizar
matrix list r(table) //Visualizar 

** Capturando datos
matrix a=r(table)
matrix list a
matrix at=a' //transpuesta
matrix list at //Visualizar la matriz

matselrc at b, row(1) col(1 2 4 5 6)
matrix list b

*** CV
estat cv
return list
matrix cv=r(cv)'/100
matrix list cv

*** Uniendo matrices
matrix unido_nac=[b,cv]
matrix list unido_nac

*----------------------
*** Exportando a excel
*----------------------
putexcel set "$cuadros/resultados", replace

putexcel A1="Porcentaje de Analfabetismo en el Perú (Pob. 15 años a más)", bold
putexcel A2="Ámbito"
putexcel B2="Porcentaje"
putexcel C2="Error Standard"
putexcel D2="p valor"
putexcel E2="Lim. Inferior"
putexcel F2="Lim. Superior"
putexcel G2="C.V."
putexcel (A2:G2), bold border (bottom) fpat(solid,"blue") font("Calibri",11,"white")

svy: mean analfabeto

** Armando matriz
matrix a=r(table)'
matselrc a b, row(1) col(1 2 4 5 6)

estat cv //Coeficiente de variación
matrix cv=r(cv)'/100
matrix unido_nac=[b,cv]

matrix rownames unido_nac=Nacional
putexcel A3=matrix(unido_nac), rownames 

*** Por area
svy: mean analfabeto, over(area)

putexcel set "$cuadros/resultados", modify

matrix a=r(table)'
matselrc a b, row(1 2) col(1 2 4 5 6)

estat cv //Coeficiente de variación
matrix cv=r(cv)'/100
matrix unido_area=[b,cv]

matrix rownames unido_area=Urbano Rural
putexcel A4=matrix(unido_area), rownames

*----------------------------
*    Pruebas de Hipotesis
*----------------------------

*---------------------------------------
** 1. Prueba t: Diferencia de medias
*----------------------------------------

tabstat analfabeto [aw=factora07], by(p207)

*Ho: No hay diferencia estadística en los promedios (dif=0)
*H1: Si hay diferencias estadistica en los promedios (dif!=0)

svy: mean analfabeto,  over(p207)
lincom analfabeto@2.p207 - analfabeto@1.p207 
** en este caso se rechaza la H0 porque el pvalor es 0.0000


*lincom [analfabeto]mujer - [analfabeto]hombre //version stata15

svy: mean analfabeto,  over(area) 
lincom analfabeto@2.area - analfabeto@1.area 

svy: mean analfabeto,  over(dpto) 
lincom analfabeto@1.dpto - analfabeto@2.dpto 

lincom analfabeto@1.dpto - analfabeto@15.dpto 

*------------------------------------------------------------------
* 2. Prueba de independencia Chi-cuadrado (variables categóricas)
*------------------------------------------------------------------

* Ho: No existe asociación entre variables (Independencia)
* H1: Sí existe asociación entre variables (Dependencia)

tab analfabeto p207
tab analfabeto p207, chi2
tab analfabeto p207, chi2 nofreq

tab analfabeto p207, chi2 V

** p<0.05 Se rechaza la Ho al 95% de confianza

*-------------------------------------
*  Vamos a trabajar solo con hogares
*---------------------------------------
duplicates drop aÑo conglome vivienda hogar, force

tabstat factor07, s(sum) format (%12.0fc)

** Declarar el factor a nivel del hogar 
svyset [pweight = factor07], psu(conglome) strata(estrato)

*-------------------------
*    Gasto en agua
*------------------------

ren p1172_01 gasto_agua

hist gasto_agua

*-------------------------
*    Gasto en luz
*------------------------

ren p1172_02 gasto_luz

hist gasto_luz

sum gasto_agua gasto_luz

*-------------------------------------------------
***** Diferencia de medias - t (variable cuantitativa)
*------------------------------------------------

svy: mean gasto_luz,  over(area) 
lincom gasto_luz@2.area - gasto_luz@1.area 

*-------------------------
*       2. Normalidad
*--------------------------

sum gasto_luz,d

sum gasto_luz if area==1, d
sum gasto_luz if area==2, d

hist gasto_luz, freq norm

hist gasto_luz if area==1, freq norm
hist gasto_luz if area==2, freq norm

* Test de normalidad:

* Ho: Nomal
* Ha: - Normal

* Shapiro - Wilk: muestras pequeñas (n<30)
* Shapiro - Francia: muestras pequeñas (n<30)
* Kolmogorov - Smirnov: muestras grandes (n>=30)
* Jackes Bera

* Kolmogorov - Smirnov: 
* -------------------

sum gasto_luz
ksmirnov gasto_luz = normal((gasto_luz-r(mean))/r(sd)) 
//ver el p valor de la primera linea

* Evaluas: pvalue vs 0.05?
*           0.0000 < 0.05

* Ho: Se tiene normalidad
* H1: No hay normalidad

* Conclusión: Rechazamos la Ho, aceptando la Ha, concluyendo
* que los datos no se distribuyen de manera Normal

* Jackes Bera
*ssc install jb
hist gasto_luz,kdensity
* ssc install jb
jb gasto_agua 

sktest gasto_luz

*------------------
* Correlaciones
*----------------
*Lineal (variables cuantitativas continuas o discretas)

correlate gasto_agua gasto_luz

