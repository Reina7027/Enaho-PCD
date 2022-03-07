/*
    Description:
    ENAHO PEA ocupada con discapacidad - Cajamarca
    Author: YolaM
    Version: 1.0
*/

*BASES ENAHO MÓDULO 500
*------------------------
clear all
*set more off

gl up F:\Enaho\Bases
gl rutasave F:\Enaho\data1

forvalues x=2018/2020{
use "$up\Enaho-`x'-500_variables_MTPE.dta", clear

keep conglome vivienda hogar codperso estrato fac500a7 r3 rdpto rarea p207 r1r r2r_a r11r p511a r8 r19
gen str4 año = "`x'"
sort conglome vivienda hogar codperso

display "==`x'=="
qui saveold "$rutasave\base_aux`x'.dta"
}



*BASES ENAHO MÓDULO 400 DISCAPACIDAD
*------------------------------------
clear all
*set more off

gl up F:\Enaho\Bases_400
gl rutasave F:\Enaho\data1

forvalues x=2018/2020{
use "$up\enaho01a-`x'-400.dta", clear

keep conglome vivienda hogar codperso p401h1 p401h2 p401h3 p401h4 p401h5 p401h6 
sort conglome vivienda hogar codperso

display "==`x'=="
qui saveold "$rutasave\base_aux`x'.dta"
}


*MERGE
*-----------------------
clear all
cd F:\Enaho\data1
forvalues x=2018/2020{
use base_aux`x'.dta, clear
merge 1:1 conglome vivienda hogar codperso using base_aux`x'_400.dta

display "==`x'=="
save base_aux`x'.dta, replace
}


*TABULADOS
*------------
clear all
*set more off

gl up F:\Enaho\data1
*gl rutasave F:\Enaho\data

forvalues x=2018/2020{
use "$up\base_aux`x'.dta", clear

drop if _merge==2

gen discapacidad=1 if p401h1==1 |  p401h2==1 |  p401h3==1 |  p401h4==1 |  p401h5==1 |  p401h6==1
replace discapacidad=2 if p401h1==2 &  p401h2==2 &  p401h3==2 &  p401h4==2 &  p401h5==2 &  p401h6==2  
replace discapacidad=9 if discapacidad==.

label var discapacidad "Discapacidad"
label define discapacidad 1 "Con discapacidad" 2 "Sin discapacidad" 9 "No determinado"
label values discapacidad discapacidad

recode r1r (1=1 "0 a 13 años") (2=2 "14 años") (3=3 "15 a 29 años") (4=4 "30 a 44 años") (5/6=5 "45 a 64 años") (7=6 "65 a más años"),gen(r1r2)
recode r19 (1=1 "1 trabajador")(2=2 "2 a 10 trabajadores")(3/4=3 "11 a 100 trabajadores")(5/6=4 "101 a mas trabajadores")(7=5 "No especificado"), gen(r_r19)
replace p511a=9 if p511a==.
label define p511a 9 "No determinado", add

svyset conglome [pweight=fac500a7], strata(estrato) vce(linearized) singleunit(missing)

display "==`x'=="

svy linearized,subpop(if rdpto==6 & discapacidad==1) : tabulate r3, col percent cv format(%17.5f) stubwidth(30)
svy linearized,subpop(if r3==1 & rdpto==6 & discapacidad==1) : tabulate r11r, col percent cv format(%17.5f) stubwidth(30)
svy linearized,subpop(if r3==1 & rdpto==6 & discapacidad==1) : tabulate p511a, col percent cv format(%17.5f) stubwidth(30)
svy linearized,subpop(if r3==1 & rdpto==6 & discapacidad==1) : tabulate r8, col percent cv format(%17.5f) stubwidth(30)
svy linearized,subpop(if r3==1 & rdpto==6 & discapacidad==1) : tabulate r_r19, col percent cv format(%17.5f) stubwidth(30)
svy linearized,subpop(if r3==1 & rdpto==6 & discapacidad==1) : tabulate r2r_a, col percent cv format(%17.5f) stubwidth(30)
svy linearized,subpop(if r3==1 & rdpto==6 & discapacidad==1) : tabulate r1r2, col percent cv format(%17.5f) stubwidth(30)

svy linearized,subpop(if r3==1 & rdpto==6 & discapacidad==1) : tabulate p207 rarea, col percent cv format(%17.5f) stubwidth(30)

}






















