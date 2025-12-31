/*
clean_codes.do

This program takes in and cleans raw data from a CSV file, outputting a Stata
dataset file for further use.
*/
******************************
***** Configure settings *****
******************************
clear
set more off
capture log close
log using "clean_codes.log", replace text


**********************
***** Clean data *****
**********************
import delimited "../census_city_codes/raw_codes.csv"

* Remove all variables except city name and observations from 1940, 1950
keep v2 v10 v11

* Remove repeated headers
drop if _n == 1 | v2[_n] == "Label" | v2[_n] == ""

*Recode observations for 1940, 1950
replace v10 = "1" if v10 == "X"
replace v10 = "0" if v10 == "·"
replace v11 = "1" if v11 == "X"
replace v11 = "0" if v11 == "·"

*Destring observations (necessary due to recode technique)
destring v10 v11, replace

* Rename all variables
rename v2 msa_name
rename v10 yr1950
rename v11 yr1940

* Label variables 
label variable msa_name "Name of MSA/CC; use of 'msa' intended for application in other .do files"
label variable yr1950 "Codes exist for 1950"
label variable yr1940 "Codes exist for 1940"


****************************
***** Finalize dataset *****
****************************
save "clean_codes.dta", replace
log close
