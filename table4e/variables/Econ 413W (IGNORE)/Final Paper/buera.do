/*
table4e.do

This program isolates the Buera regressions found in table4e.do.
Changes made from that program are either for compatibility or visual changes
to the output file.

*/



clear
set more off
set matsize 800


set mem 60m

capture log close
log using buera.log, replace text


***************************************************
******** Build Basic Variables ********************

clear
*use ../../data/msa-final.dta
use ../../table4e_vars.dta, clear

gen xpop2 = cpop2/pop
gen xpop = cpop/pop
* gen lcpop2 = log(cpop2) // red-gen
gen lcpop = log(cpop)
* gen lpop = log(pop) // red-gen
* gen rcarea = sqrt(carea/_pi) // red-gen
gen rarea = sqrt(area/_pi)
gen mray = max(ray,racc)
gen inter = linch*raccld



**keep only end years and drop msas
*that enter sample after 1950
* keep if year==50 | year==90

sort msa year
by msa: gen dxpop2 = xpop2[_n+1]-xpop2
by msa: gen dlxpop2 = log(xpop2[_n+1])-log(xpop2)
by msa: gen dxpop = xpop[_n+1]-xpop
* by msa: gen dlcpop2 = lcpop2[_n+1]-lcpop2 // red-gen
by msa: gen dlcpop = lcpop[_n+1]-lcpop
* by msa: gen dlpop = lpop[_n+1]-lpop // red-gen
* by msa: gen draccld = raccld[_n+1]-raccld // red-gen
by msa: gen dracclds = raccld[_n+1]^2-raccld^2
by msa: gen dracc = racc[_n+1]-racc
* by msa: gen Dlincomeh = linch[_n+1]-linch // red-gen
* by msa: gen Dginih = ginih[_n+1]-ginih // red-gen
by msa: gen Dsdlinch = sdlinch[_n+1]-sdlinch
by msa: gen dlincome = lincome[_n+1]-lincome
by msa: gen dmray = mray[_n+1]-mray
by msa: gen trarea = carea[_n+1]/carea 
by msa: gen drcarea = rcarea[_n+1]-rcarea 
by msa: gen dinter = inter[_n+1]-inter
gen planint = rays_planc*Dlincomeh

****** Create census divisions
gen cdiv = -9
replace cdiv = 6 if stfip==1
replace cdiv = 9 if stfip==2
replace cdiv = 8 if stfip==4
replace cdiv = 7 if stfip==5
replace cdiv = 9 if stfip==6
replace cdiv = 8 if stfip==8
replace cdiv = 1 if stfip==9
replace cdiv = 5 if stfip==10
replace cdiv = 5 if stfip==11
replace cdiv = 5 if stfip==12
replace cdiv = 5 if stfip==13
replace cdiv = 9 if stfip==15
replace cdiv = 8 if stfip==16
replace cdiv = 3 if stfip==17
replace cdiv = 3 if stfip==18
replace cdiv = 4 if stfip==19
replace cdiv = 4 if stfip==20
replace cdiv = 6 if stfip==21
replace cdiv = 7 if stfip==22
replace cdiv = 1 if stfip==23
replace cdiv = 5 if stfip==24
replace cdiv = 1 if stfip==25
replace cdiv = 3 if stfip==26
replace cdiv = 4 if stfip==27
replace cdiv = 6 if stfip==28
replace cdiv = 4 if stfip==29
replace cdiv = 8 if stfip==30
replace cdiv = 4 if stfip==31
replace cdiv = 8 if stfip==32
replace cdiv = 1 if stfip==33
replace cdiv = 2 if stfip==34
replace cdiv = 8 if stfip==35
replace cdiv = 2 if stfip==36
replace cdiv = 5 if stfip==37
replace cdiv = 4 if stfip==38
replace cdiv = 3 if stfip==39
replace cdiv = 7 if stfip==40
replace cdiv = 9 if stfip==41
replace cdiv = 2 if stfip==42
replace cdiv = 1 if stfip==44
replace cdiv = 5 if stfip==45
replace cdiv = 4 if stfip==46
replace cdiv = 6 if stfip==47
replace cdiv = 7 if stfip==48
replace cdiv = 8 if stfip==49
replace cdiv = 1 if stfip==50
replace cdiv = 5 if stfip==51
replace cdiv = 9 if stfip==53
replace cdiv = 5 if stfip==54
replace cdiv = 3 if stfip==55
replace cdiv = 8 if stfip==56

** Since 50 is the only year in the dataset, these commands work
gen POP50 = pop if year_1900s==50
egen pop50 = max(POP50), by(msa)
gen POP90 = pop if year_1900s==90
egen pop90 = max(POP90), by(msa)
gen CPOP50 = cpop if year_1900s==50
egen cpop50 = max(CPOP50), by(msa)
gen lpop50 = log(pop50)


******************
***** Labels *****
******************
label variable dlcpop2 "Log Change CC Pop."
label variable cc_man_50 "CC Mfg. % Emp., 1950"
label variable rcarea "CC Radius"
label variable dlpop "Log Change MSA Pop."
label variable draccld_nw_50 "Ray*Non-White, 1950"
label variable draccld "Change in # of Rays"
label variable nw_50 "Non-White Pop. %, 1950"

*******************************************************
**** Summary Statistics For Primary Sample (3) ********
************ Appendix Table 1 *************************

sum xpop2 xpop lcpop2 lcpop lpop raccld racc rays_planc mray rcarea rarea linch ginih lincome if year==50 & pop50>.1 & cpop50>.05
sum xpop2 xpop lcpop2 lcpop lpop raccld racc rays_planc mray rcarea rarea linch ginih lincome if year==90 & pop50>.1 & cpop50>.05
sum dxpop2 dxpop dlcpop2 dlcpop dlpop draccld dracc rays_planc dmray drcarea rarea Dlincomeh Dginih dlincome if year==50 & pop50>.1 & cpop50>.05

** Drop all of the missing values from the differences
keep if year==50

******************************************************

*** Buera Regressions
reg dlcpop2 draccld nw_50 draccld_nw_50, cluster(stfip)
outreg2 using outputBuera.tex, tex(frag) bdec(3) ctitle("OLS") se replace word label
ivreg 2sls dlcpop2 (draccld draccld_nw_50=rays_planc rays_planc_nw_50), first cluster(stfip)
outreg2 using outputBuera.tex, tex(frag) bdec(3) ctitle("IV") se append word label

*** Full summary statistics for BS variables
sum 
*** Add the interacted variables separately

*** Run full model with all observations

*** Restrict all variables to selcted observations

*** Run Buera specifications

log close





