/*
table4e_vars.do

This program creates a unified dataset for the variables used in the table 4e
regressions. The program pulls data from the following datasets:

 - clean_industry_shares_1950.dta
 - clean_race.dta
 - msa-final.dta
 
 
From these datasets and calculation, the following variables are created:

 - cc_man_50: CC 1950 manufacturing industry shares
 - cc_nw_50: CC 1950 non-White population shares
 - draccld_nw_50: the interaction between change in the number of rays and the
	CC 1950 non-White population shares
 - ray_planc_nw_50: the interaction between the 1947 plan rays running through
	CCs and the CC 1950 non-White population shares
 
*/

clear
set more off
capture log close
log using table4e_vars.log, replace text

*************************
***** msa-final.dta *****
*************************
use ../../../data/msa-final.dta
rename name msa_name
rename year year_1900s
* Select 1990 MSA names
gen msa_name_temp = msa_name if year_1900s[_n] == 90
replace msa_name = subinstr(msa_name_temp, " city", "", .)
* Calculate variables
replace pop=pop/1000000
replace cpop=cpop/1000000
replace cpop2=cpop2/1000000
gen lcpop2 = log(cpop2)
gen lpop = log(pop)
by msa: gen dlcpop2 = lcpop2[_n+1]-lcpop2
by msa: gen dlpop = lpop[_n+1]-lpop
by msa: gen draccld = raccld[_n+1]-raccld
by msa: gen Dlincomeh = linch[_n+1]-linch
by msa: gen Dginih = ginih[_n+1]-ginih
gen rcarea = sqrt(carea/_pi)
by msa: gen dcpop2 = cpop2[_n+1]-cpop2
by msa: gen dpop = pop[_n+1]-pop
*
drop if year_1900s != 50 & year_1900s != 90
replace msa_name = msa_name[_n+1] if missing(msa_name)
drop if year_1900s == 90 | missing(dlcpop2)
* keep msa_name dlcpop2 draccld rcarea dlpop dcpop2 dpop
save "temp.dta", replace

**************************
***** ind_shr_50.dta *****
**************************
use ../../msa_list/industry_shares/clean_ind_shr_50.dta, clear
merge m:1 msa_name using "temp.dta"
rename cc_man_shr_50 cc_man_50
drop if _merge != 3
drop _merge
save "temp.dta", replace

**************************
***** clean_race.dta *****
**************************
use ../../msa_list/census_race/clean_race.dta, clear
merge m:1 msa_name using "temp.dta"
rename pct_cc_nw_1950 nw_50
drop if _merge != 3
gen draccld_nw_50 = draccld * nw_50 // OLS and instrumental variable
gen rays_planc_nw_50 = rays_planc * nw_50 // Instrumental variable
* keep msa_name dlcpop2 draccld_nw_50 draccld nw_50 cc_man_50 rcarea dlpop dcpop2 dpop

******************
***** Labels *****
******************
label variable dlcpop2 "Log CC Pop., 1950"
label variable cc_man_50 "CC Mfg. % Emp., 1950"
label variable rcarea "CC Radius"
label variable dlpop "Log Change MSA Pop."
label variable draccld_nw_50 "Ray*Non-White, 1950"
label variable draccld "Change in # of Rays"
label variable nw_50 "Non-White Pop. %, 1950"

********************
***** Finalize *****
********************
drop msa_name_temp
drop _merge
save "table4e_vars.dta", replace
erase "temp.dta"
log close
