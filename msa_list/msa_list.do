/*
msa_list.do

This program creates a dataset listing the names and codes for MSAs that existed
from 1950-1990 with the following measurements for said MSAs and their 
respective CCs:
1. 1950 population
2. 1990 population
3. Percentage change in population from 1950-1990
4. 1950 manufacturing share of employment


Datasets used:
1. msa-final.dta
2. temp.dta (a modified derivative of msa-final.dta)

Note: Newburgh, NY is missing data for 1980 but is included in the table 
*/

******************************
***** Configure settings *****
******************************
clear
set more off
set mem 50m
capture log close
log using "msa_list.log", replace text
use ../../data/msa-final, clear


*************************
***** Clean dataset *****
*************************
* Keep required variables -- remove all others
keep name year cpop pop msa emp empman

* Rename kept variables 
rename name msa_name
rename year year_1900s
rename cpop cc_pop
rename pop msa_pop
rename msa msa_code

* Remove intermediate decades (1950-1990)
keep if year == 50 | year == 90

* Save cleaned dataset for temporary use, troubleshooting
save "temp.dta", replace
use temp, clear


**************************************
***** Manipulate cleaned dataset *****
**************************************
* Select 1990 MSA names
gen msa_name_temp = msa_name if year_1900s[_n] == 90
replace msa_name = subinstr(msa_name_temp, " city", "", .)
drop msa_name_temp


* Create variables for CC population for 1950, 1990, and % change
gen cc_pop_50 = cc_pop if year_1900s[_n] == 50
gen cc_pop_90 = cc_pop if year_1900s[_n] == 90
gen cc_pop_delta = 100*(cc_pop - cc_pop[_n-1])/cc_pop[_n-1] if mod(_n,2) == 0
drop cc_pop

* Create separate variables for MSA population for 1950, 1990, and % change
gen msa_pop_50 = msa_pop if year_1900s[_n] == 50
gen msa_pop_90 = msa_pop if year_1900s[_n] == 90
gen msa_pop_delta = 100*(msa_pop - msa_pop[_n-1])/msa_pop[_n-1] if mod(_n,2) == 0
drop msa_pop

* Create variable for the MSA manufacturing share of employment (1950)
gen msa_man_shr_50 = 100*empman/emp if year_1900s[_n] == 50
drop emp empman year_1900s

* Partially fill, then drop missing data
replace cc_pop_50 = cc_pop_50[_n-1] if missing(cc_pop_50)
replace msa_pop_50 = msa_pop_50[_n-1] if missing(msa_pop_50)
replace msa_man_shr_50 = msa_man_shr_50[_n-1] if missing(msa_man_shr_50)
drop if missing(msa_name)


****************************
***** Finalize dataset *****
****************************
save "msa_list.dta", replace
* Comment out the below line for troubleshooting
erase "temp.dta"

* Merge msa_list with ipums_city_codes/clean_codes
use msa_list, clear
use census_city_codes/clean_codes, clear
merge m:1 msa_name using msa_list
drop if msa_code[_n] == .
drop _merge


***************************
***** Label variables *****
***************************
label variable msa_name "MSA/Center City (CC) name (1990 reference)"
* CC
label variable cc_pop_50 "CC population for 1950"
label variable cc_pop_90 "CC population for 1990"
label variable cc_pop_delta "CC population change from 1950-1990 (%)"

* MSA
label variable msa_pop_50 "MSA population for 1950"
label variable msa_pop_90 "MSA population for 1990"
label variable msa_pop_delta "MSA population change from 1950-1990 (%)"
label variable msa_man_shr_50 "MSA manufacturing share of employment (1950)"

*
drop msa_code

save "msa_list.dta", replace
log close
