/*
table4e.do

This program extends the analysis done for Table 4 in ld.do. It includes
additional OLS and IV analysis columns. The new functional form of the new OLS
regression (OLS3e) includes the independent variables of OLS3 and adds the
following:
 
 - 1950 manufacturing shares of employment for CCs
 - 1950 non-White shares of population for CCs
 - Interaction between 1950 non-White shares and the change in number of rays

Some variables generated herein are also generated in "table4e_vars.dta". They
are commented out but left in as a precaution. These variables will be tagged
with "red-gen" (redundant generation). 

Below is the quoted description of the originial file:

	"ld.do

	This program runs a variety of specifications for the 
	highways and suburbanization paper.  All are long differences
	50-90.

	For the battery of specifications, the samples used are

	1. Every MSA
	2. Only MSAs that existed in 1950
	3. Only MSAs of at least 100,000 w/ CC at least 50,000 in 1950
	4. 3. + CC at least 20 miles from a coast or border

	All of this is run using 

	A. OLS
	B. OLS with state fe
	C. IV
	D. IV with state fe

	The results are saved in the text files
	outputX
	where X is A-D, the estimation strategy."

*/



clear
set more off
set matsize 800


set mem 60m

capture log close
log using table4e.log, replace text


***************************************************
******** Build Basic Variables ********************

clear
*use ../../data/msa-final.dta
use ../table4e/variables/table4e_vars.dta

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

*******************************************************
**** Summary Statistics For Primary Sample (3) ********
************ Appendix Table 1 *************************

sum xpop2 xpop lcpop2 lcpop lpop raccld racc rays_planc mray rcarea rarea linch ginih lincome if year==50 & pop50>.1 & cpop50>.05
sum xpop2 xpop lcpop2 lcpop lpop raccld racc rays_planc mray rcarea rarea linch ginih lincome if year==90 & pop50>.1 & cpop50>.05
sum dxpop2 dxpop dlcpop2 dlcpop dlpop draccld dracc rays_planc dmray drcarea rarea Dlincomeh Dginih dlincome if year==50 & pop50>.1 & cpop50>.05

** Drop all of the missing values from the differences
keep if year==50

******************************************************



********************  A ******************************

*** Sample 3

reg dlcpop2 draccld if pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputA.tex, se replace 
reg dlcpop2 draccld rcarea if pop50>.1 & cpop50>.05, cluster(stfip) 
outreg2 using outputA.tex, tex(frag) se append
reg dlcpop2 draccld rcarea Dlincomeh if pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputA.tex, tex(frag) se append
reg dlcpop2 draccld rcarea Dlincomeh dlpop if pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputA.tex, tex(frag) se append
reg dlcpop2 draccld rcarea Dlincomeh Dginih dlpop if pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputA.tex, tex(frag) se append
reg dlcpop2 draccld rcarea Dlincomeh dlpop lpop50 if pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputA.tex, tex(frag) se append

*** Sample 4

reg dlcpop2 draccld if dis_borcoa>20 & pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputA.tex, tex(frag) se append
reg dlcpop2 draccld rcarea if dis_borcoa>20 & pop50>.1 & cpop50>.05, cluster(stfip) 
outreg2 using outputA.tex, tex(frag) se append
reg dlcpop2 draccld rcarea Dlincomeh if dis_borcoa>20 & pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputA.tex, tex(frag) se append
reg dlcpop2 draccld rcarea Dlincomeh dlpop if dis_borcoa>20 & pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputA.tex, tex(frag) se append
reg dlcpop2 draccld rcarea Dlincomeh Dginih dlpop if dis_borcoa>20 & pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputA.tex, tex(frag) se append
reg dlcpop2 draccld rcarea Dlincomeh dlpop lpop50 if dis_borcoa>20 & pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputA.tex, tex(frag) se append


********************  C ******************************
** (Keep samples 1 and 2 for reference in the text)

*** Sample 1

ivreg dlcpop2 (draccld=rays_planc), cluster(stfip)
ivreg dlcpop2 (draccld=rays_planc) rcarea, cluster(stfip) 
ivreg dlcpop2 (draccld=rays_planc) rcarea Dlincomeh, cluster(stfip)
ivreg dlcpop2 (draccld=rays_planc) dlpop rcarea Dlincomeh, cluster(stfip)
ivreg dlcpop2 (draccld=rays_planc) dlpop rcarea Dlincomeh Dginih, cluster(stfip)
ivreg dlcpop2 (draccld=rays_planc) dlpop rcarea Dlincomeh lpop50, cluster(stfip)

*** Sample 2 

ivreg dlcpop2 (draccld=rays_planc) if msa50==1, cluster(stfip)
ivreg dlcpop2 (draccld=rays_planc) rcarea if msa50==1, cluster(stfip) 
ivreg dlcpop2 (draccld=rays_planc) rcarea Dlincomeh if msa50==1, cluster(stfip)
ivreg dlcpop2 (draccld=rays_planc) dlpop rcarea Dlincomeh if msa50==1, cluster(stfip)
ivreg dlcpop2 (draccld=rays_planc) dlpop rcarea Dlincomeh Dginih if msa50==1, cluster(stfip)
ivreg dlcpop2 (draccld=rays_planc) dlpop rcarea Dlincomeh lpop50 if msa50==1, cluster(stfip)

*** Sample 3

ivreg dlcpop2 (draccld=rays_planc) if pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputC.tex, se replace 
ivreg dlcpop2 (draccld=rays_planc) rcarea if pop50>.1 & cpop50>.05, cluster(stfip) 
outreg2 using outputC.tex, tex(frag) se append
ivreg dlcpop2 (draccld=rays_planc) rcarea Dlincomeh if pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputC.tex, tex(frag) se append
ivreg dlcpop2 (draccld=rays_planc) dlpop rcarea Dlincomeh if pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputC.tex, tex(frag) se append
ivreg dlcpop2 (draccld=rays_planc) dlpop rcarea Dlincomeh Dginih if pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputC.tex, tex(frag) se append
ivreg dlcpop2 (draccld=rays_planc) dlpop rcarea Dlincomeh lpop50 if pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputC.tex, tex(frag) se append

*** Sample 4 

ivreg dlcpop2 (draccld=rays_planc) if dis_borcoa>20 & pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputC.tex, tex(frag) se append
ivreg dlcpop2 (draccld=rays_planc) rcarea if dis_borcoa>20 & pop50>.1 & cpop50>.05, cluster(stfip) 
outreg2 using outputC.tex, tex(frag) se append
ivreg dlcpop2 (draccld=rays_planc) rcarea Dlincomeh if dis_borcoa>20 & pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputC.tex, tex(frag) se append
ivreg dlcpop2 (draccld=rays_planc) dlpop rcarea Dlincomeh if dis_borcoa>20 & pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputC.tex, tex(frag) se append
ivreg dlcpop2 (draccld=rays_planc) dlpop rcarea Dlincomeh Dginih if dis_borcoa>20 & pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputC.tex, tex(frag) se append
ivreg dlcpop2 (draccld=rays_planc) dlpop rcarea Dlincomeh lpop50 if dis_borcoa>20 & pop50>.1 & cpop50>.05, cluster(stfip)
outreg2 using outputC.tex, tex(frag) se append

*** Buera Regressions
reg dlcpop2 draccld nw_50 draccld_nw_50, cluster(stfip)
outreg2 using outputBuera.tex, tex(frag) se replace
ivreg dlcpop2 (draccld draccld_nw_50=rays_planc rays_planc_nw_50), cluster(stfip)
outreg2 using outputBuera.tex, tex(frag) se append
ivreg dlcpop2 nw_50 (draccld draccld_nw_50=rays_planc rays_planc_nw_50), cluster(stfip)

log close





