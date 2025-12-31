clear
set more off
capture log close 
log using wa_2.log, replace text
use ../../table4e_vars.dta, clear

*************************
***** Data Pre-Work *****
*************************
drop if msa_name == "Evansville, IN" | msa_name == "San Diego, CA" // Outliers
label variable dlcpop2 "Log Change CC Pop."
label variable dcpop2 "Change CC Pop."
label variable cc_man_50 "CC Mfg. % Emp. '50"
label variable draccld_nw_50 "Ray-NW '50"
label variable rcarea "CC Radius"
label variable dlpop "Log Change MSA Pop."
label variable dpop "Change MSA Pop."

**********************************
***** Descriptive statistics *****
**********************************
outreg2 using desc_stat.tex, noobs bdec(2) tex(frag) replace sum(log) word label

************************
***** Scatterplots *****
************************
graph matrix dlcpop2 draccld_nw_50 cc_man_50 rcarea dlpop, half
graph export scat_mat1.png, replace

***************************
***** Main Regression *****
***************************
reg dlcpop2 cc_man_50 draccld nw_50 draccld_nw_50 rcarea dlpop
outreg2 using "reg1.tex", tex(frag) bdec(3) replace word label

*******************************
***** Tests of Robustness *****
*******************************
***** Omitted Variable Bias
estat ovtest
***** Functional Forms
*** Linear
reg dcpop2 cc_man_50 draccld_nw_50 rcarea dpop
outreg2 using "ff.tex", tex(frag) bdec(3) ctitle("Linear") replace word label
*** log-Linear
gen lcc_man_50 = ln(cc_man_50)
label variable lcc_man_50 "Log CC Mfg. % Emp. '50"
gen ldraccld_nw_50 = ln(draccld_nw_50)
label variable ldraccld_nw_50 "Log Ray-NW '50"
gen lrcarea = ln(rcarea)
label variable lrcarea "Log CC Radius"
reg dlcpop2 lcc_man_50 ldraccld_nw_50 lrcarea dlpop
outreg2 using "ff.tex", tex(frag) bdec(3) ctitle("Log-Linear") append word label
*** Log-Lin
reg dlcpop2 cc_man_50 draccld_nw_50 rcarea dpop
outreg2 using "ff.tex", tex(frag) bdec(3) ctitle("Log-Lin") append word label
*** Lin-Log
reg dcpop2 lcc_man_50 ldraccld_nw_50 lrcarea dlpop
outreg2 using "ff.tex", tex(frag) bdec(3) ctitle("Lin-Log") append word label
*** Comparison of Original and Log-Linear Models
reg dlcpop2 cc_man_50 draccld_nw_50 rcarea dlpop
outreg2 using "comp_reg.tex", tex(frag) bdec(3) ctitle("Original") replace word label
reg dlcpop2 lcc_man_50 ldraccld_nw_50 lrcarea dlpop
outreg2 using "comp_reg.tex", tex(frag) bdec(3) ctitle("Log-Linear") append word label

***** Multicollinearity
reg dlcpop2 cc_man_50 draccld_nw_50 rcarea dlpop
*** Variance Inflation Factors
estat vif
*** Correlation Matrix
cor cc_man_50 draccld_nw_50 rcarea dlpop
*** Auxiliary Regressions
reg cc_man_50 draccld_nw_50 rcarea dlpop
outreg2 using "mc_ar.tex", tex(frag) bdec(1) ctitle("CC Mfg., % Emp. '50") replace word label
reg draccld_nw_50 rcarea dlpop cc_man_50
outreg2 using "mc_ar.tex", tex(frag) bdec(1) append word label
reg rcarea dlpop cc_man_50 draccld_nw_50
outreg2 using "mc_ar.tex", tex(frag) bdec(1) append word label
reg dlpop cc_man_50 draccld_nw_50 rcarea
outreg2 using "mc_ar.tex", tex(frag) bdec(1) ctitle("Log Change, MSA Pop.") append word label
***** Heteroscedasticity
reg dlcpop2 cc_man_50 draccld_nw_50 rcarea dlpop
*** Graphical
predict ehat, residual
predict yhat
label variable yhat "Fitted Values"
gen ehat2 = ehat^2
label variable ehat2 "Squared Residuals"
hist ehat2
graph export hist1.png, replace
scatter ehat2 yhat
graph export scat1.png,  replace
*** Statistical
gen ln_ehat2 = ln(ehat2)
* Breusch-Pagan
estat hettest
outreg2 using "het_tests.tex", tex(frag) bdec(2) ctitle("BP, p=0.763") replace word label
* White
ivhettest
outreg2 using "het_tests.tex", tex(frag) bdec(2) ctitle("White, p=0.468") append word label
* Park
gen ln_yhat = ln(yhat)
label variable ln_yhat "Log Fitted Values"
gen ln_y = ln(dlcpop2)
reg ln_ehat2 ln_yhat
outreg2 using "het_tests.tex", tex(frag) bdec(2) ctitle("Park, p=0.314") append word label
*Glejser
gen abs_ehat = abs(ehat)
reg abs_ehat cc_man_50 draccld_nw_50 rcarea dlpop
outreg2 using "het_tests.tex", tex(frag) bdec(2) ctitle("Glejser, p=0.639") append word label

log close
