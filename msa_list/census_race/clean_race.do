/*

clean_race.do

Cleans race data from 1950 and 1990 for MSAs and CCs. Data are then merged and
further cleaned to combine both years into the same dataset. 

Note: While a dash "-" represents zero or a percent that rounds to less than
0.1%, they are intentionally replaced with 0 to allow for computation.

*/

**************************
***** Initialization *****
**************************
clear
set  more off
capture log close
log using "clean_race.log", replace text


****************
***** 1950 *****
****************
import delimited "1950/edited_race_1950.csv", varnames(1)

* Clean MSA names
replace msa_name = subinstr(msa_name, " (remainder)", "", .)
replace msa_name = "Nashville, TN" if msa_name == "Nashville-Davidson, TN"
drop if missing(msa_total)


* Generate variables for nonwhite population percents
gen pct_msa_nw_1950 = msa_nonwhite/msa_total*100
gen pct_cc_nw_1950 = cc_nonwhite/cc_total*100
keep msa_name pct_msa_nw_1950 pct_cc_nw_1950


* Label variables
label variable msa_name "MSA/CC name"
label variable pct_msa_nw_1950 "1950 Non-White population of MSA (%)"
label variable pct_cc_nw_1950 "1950 Non-White population of CC (%)"

* Finalize dataset
sort msa_name
save "1950/clean_race_1950.dta", replace


****************
***** 1990 *****
****************
clear
import delimited "../census_race/1990/final_race_1990.csv"

* Manage variable names
drop if _n == 1
keep v1-v3
rename v1 msa_name
rename v2 total_pop
rename v3 white

* Remove MSA names containing "Con."
drop if regexm(msa_name, "Con.$")

* Format MSA names in preparation for dataset merge
replace msa_name = trim(regexr(msa_name, "-+$", "")) // Remove trailing hyphens
replace msa_name = "Inside Central City" if msa_name == "Inside central city" 
replace msa_name = "Outside Central City" if msa_name == "Outside central city"
replace msa_name = subinstr(msa_name, " (pt.)", "", .)
replace msa_name = subinstr(msa_name, " city", "", .)
replace msa_name = subinstr(msa_name, " town", "", .)

* Replace dashes with 0
foreach var of varlist _all {
    replace `var' = "0" if `var' == "-"
}

* Format relevant numerical variables correctly
destring total_pop white, force replace

* Generate Non-White variable
gen nonwhite = total_pop-white

* Create MSA groups (used for troubleshooting)
gen group_id = substr(trim(msa_name), -3, 3) == "MSA"
replace group_id = sum(group_id)

* Flag MSAs (makes code more readable)
gen flag_msa = regexm(msa_name, "MSA")

* Label variables
label variable msa_name "MSA/CC name"
label variable total_pop "Total population of MSA/CC"
label variable white "Population of Whites of MSA/CC"
label variable nonwhite "Population of Non-Whites of MSA/CC"
label variable group_id "Groups MSAs (for troubleshooting)"
label variable flag_msa "Flags names that are MSAs (for code readability)"
save "1990/clean_race_1990.dta", replace


**************************
***** Merged Dataset *****
**************************
use "1990/clean_race_1990.dta", clear

* Merge
merge m:1 msa_name using "1950/clean_race_1950.dta"

* Sort for troubleshooting
gsort group_id -flag_msa

* Generate final variables
gen pct_msa_nw_1990 = nonwhite/total_pop*100 if flag_msa == 1
gen pct_cc_nw_1990 = nonwhite/total_pop*100 if _merge == 3
drop if missing(pct_msa_nw_1990) & missing(pct_cc_nw_1990) // Remove places without MSA-CC pair

* Manage gaps in data caused by formatting
gen next_msa_name_temp = msa_name[_n+1]
drop if regexm(msa_name, "MSA$") & regexm(next_msa_name_temp, "MSA$")
replace pct_msa_nw_1990 = pct_msa_nw_1990[_n-1] if missing(pct_msa_nw_1990)
drop if missing(pct_msa_nw_1950)

* Label variables
label variable pct_msa_nw_1990 "1990 Non-White population of MSA (%)"
label variable pct_cc_nw_1990 "1990 Non-White population of CC (%)"

* Finalize
keep msa_name pct_msa_nw_1950 pct_cc_nw_1950 pct_msa_nw_1990 pct_cc_nw_1990
compress msa_name // Format msa_name column width to the longest MSA name
sort msa_name
quietly by msa_name: gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup
save "clean_race.dta", replace
log close
