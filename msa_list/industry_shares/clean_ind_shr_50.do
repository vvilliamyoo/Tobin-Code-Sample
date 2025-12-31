clear
set more off
capture log close
log using "clean_ind_shr_50.log", replace text
import delimited "edited_industry_shares_1950.csv", varnames(1)

gen cc_man_shr_50 = cc_man/cc_emp*100
keep msa_name cc_man_shr_50
drop if missing(cc_man_shr_50)
sort msa_name

label variable msa_name "MSA/Center City (CC) name (1990 reference)"
label variable cc_man_shr_50 "CC manufacturing share of employment (1950)"

save "clean_ind_shr_50.dta", replace
log close