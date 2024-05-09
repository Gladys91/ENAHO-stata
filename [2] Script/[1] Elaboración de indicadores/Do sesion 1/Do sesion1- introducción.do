
***** Aspectos estéticos
*Pantalla Negra
*Tamaño de letra

***** Comandos Básicos

cls        // Sirve para limpiar ventana
clear all  // Borrar la base de datos previa

cd "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\bases"  // Carpeta de trabajo

***** Trasladar la base a codigo latino (el asterisco indica que afecta a todos los archivos de la carpeta)

*unicode analyze *
*unicode encoding set ISO-8859-1 //código latino
*unicode translate *

***** Abriendo base de datos
use "enaho01-2021-200",clear  //Población

rename aÑo año 

* En este ejemplo solo vamos a quedarnos con miembros del hogar

keep if p204==1

*****
edit   // Visualizar Base y editar
browse // Visualizar Base sin modificar
br

***** Descripción general de variables
describe
d, full

***** Help
help describe
h describe

***** Contar filas

count //contar registros

***** Visualizar data con condición

br if p207==1 //Visualiza solo a los hombres

br cod* //visualiza todas la variables que comienzan con cod

br año conglome vivienda hogar codperso


*comando isid te identifica si tu llave es correcta

isid conglome vivienda hogar codperso


***** Estadisticos básicos de las variables
summarize
sum p208a
sum p208a, detail

codebook
codebook p208a

***** Crear nueva variable, label y etiqueta 
*Región natural
gen regnat=1 if dominio>=1 & dominio<=3 
replace regnat=1 if dominio==8
replace regnat=2 if dominio>=4 & dominio<=6 
replace regnat=3 if dominio==7 

label variable regnat "Región natural" //nombre de la variable

label define regnat 1 "Costa" 2 "Sierra" 3 "Selva" //definir la etiqueta

lab val regnat regnat //asignar etiqueta a la variable

***** Listar etiquetas de las variables
lab list 

lab list p207 //etiquetas de la p207

***** Tabulados básico
tab regnat //tabulado simple

tab regnat,m //tabulado con missing

fre regnat //este comadno da todo el detalle

table regnat

***** Crear variable dicotomica (0 y 1)
gen mayor_edad=(p208a>=18)

br mayor_edad

lab var mayor_edad "Mayores de edad" //Etiqueta de la variable

***** Recodificar
drop regnat //borrar variable

recode dominio (1/3=1 "Costa") (4/6=2 "Sierra") (7=3 "Selva") (8=1 "Costa"),gen(regnat)

***** Guardar base de datos
save Personas,replace

***** Borrar base de datos
erase Personas.dta

***** Seleccionar filas con condición
br if p208a>=18 //solo visualizo

keep if p208a>=18 //corta la base

***** Borrar filas con condición, 
drop if p207==2 //borrando filas de personas de sexo mujer

count //contar filas para verificar

***** Seleccionar variables de interés (se reduce la base)

keep p203 p204 p208a p207   

*Guardar base modificada
save "enaho01-2021-200_trab",replace

***** Importar datos


