
clear all  // Borrar la base de datos previa

global bases "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\bases"
global graficos "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Graficos"
global cuadros "C:\Users\Usuario\Desktop\Economía\[2] Talleres pagados\[2] Stata con Enaho\Cuadros"


cd "$bases"

***************************** // Mapas //**************************

use pobreza_multidim, clear

gen pobre=(pobreza==1 | pobreza==2)

*Primero: preparamos la base de datos de la Enaho

collapse (mean) pobre pobre_m [pw=facpob], by(dpto año)
label var pobre_m "Pobreza Multidimensional"
label var pobre "Pobreza Monetaria"
save "pobreza_mm.dta", replace

*Segundo: convertimos los "shapefile" a base de datos de Stata 
shp2dta using BAS_LIM_DEPARTAMENTO, database(data_depar) coordinates(coord_depar) genid(id_cert) gencentroids(coord) replace 

*Tercero: trabajamos la base de datos del departamento
use data_depar, clear
gen dpto=id_cert //Para crear las etiquetas del departamento

*Dpto
lab def dpto 1 "AMAZONAS" 2 "ANCASH" 3 "APURIMAC" 4 "AREQUIPA" 5 "AYACUCHO" 6 "CAJAMARCA" 7 "CALLAO" 8 "CUSCO" 9 "HUANCAVELICA" 10 "HUANUCO" 11 "ICA" 12 "JUNIN" 13 "LA LIBERTAD" 14 "LAMBAYEQUE" 15 "LIMA" 16 "LORETO" 17 "MADRE DE DIOS" 18 "MOQUEGUA" 19 "PASCO" 20 "PIURA" 21 "PUNO" 22 "SAN MARTIN" 23 "TACNA" 24 "TUMBES" 25 "UCAYALI"
lab val dpto dpto

*Cuarto: unimos ambas bases, ya que la usaremos para el gráfico del mapa
merge 1:m dpto using pobreza_mm.dta
drop _merge

*Quinto: damos formato a las variables
replace pobre = pobre*100
replace pobre_m = pobre_m*100
format %6.0g pobre
format %6.0g pobre_m

*Mapas 
spmap pobre if año==2021 using coord_depar, id (id_cert) fcolor(Blues) ///
clmethod(custom) clbreaks(5 10 20 30 40 65) oc(black) os(vvvthick_list) mop(dash) ///
title("Pobreza Monetaria, Perú 2019") ///
legend(on) clnumber(5) legend(title("Niveles de Pobreza Monetaria", size(*0.5))) ///
name(monetaria_2019, replace) ///
label(label(NOMBDEP) xcoord(x_coord) ycoord(y_coord) size(*0.7))

*Mapa pobreza monetaria (2012-2019)
spmap pobre if año==2012 using coord_depar, id (id_cert) fcolor(Blues) ///
clmethod(custom) clbreaks(5 10 20 30 40 65) oc(black) os(vvvthick_list) mop(dash) ///
title("Pobreza Monetaria, Perú 2012") ///
legend(on) clnumber(5) legend(title("Niveles de Pobreza Monetaria", size(*0.5))) ///
name(monetaria_2012, replace) ///
label(label(NOMBDEP) xcoord(x_coord) ycoord(y_coord) size(*0.7))

graph combine monetaria_2012 monetaria_2019

*Mapa pobreza multidimensional (2012-2019)
spmap pobre_m if año==2012 using coord_depar, id (id_cert) fcolor(Blues) ///
clmethod(custom) clbreaks(0 10 20 30 40 65) oc(black) os(vvvthick_list) mop(dash) ///
title("Pobreza Multidimensional, Perú 2012") ///
legend(on) clnumber(6) legend(title("Niveles de Pobreza Multidimensional", size(*0.5))) ///
name(multidimensional_2012, replace) ///
label(label(NOMBDEP) xcoord(x_coord) ycoord(y_coord) size(*0.7))

spmap pobre_m if año==2021 using coord_depar, id (id_cert) fcolor(Blues) ///
clmethod(custom) clbreaks(0 10 20 30 40 65) oc(black) os(vvvthick_list) mop(dash) ///
title("Pobreza Multidimensional, Perú 2019") ///
legend(on) clnumber(6) legend(title("Niveles de Pobreza Multidimensional", size(*0.5))) ///
name(multidimensional_2019, replace) ///
label(label(NOMBDEP) xcoord(x_coord) ycoord(y_coord) size(*0.7))

graph combine multidimensional_2012 multidimensional_2019 

graph combine monetaria_2019 multidimensional_2019


