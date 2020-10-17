// Public perceptions of food-related risks
// Kelsey D. Meagher
// kdmeagher@ucdavis.edu
// July 2017
// File: 02_Merge.do

/*
This do file merges nation-level data (nation.dta) with microdata from the 
Eurobarometer 73.5 for a study of cross-national differences in public concerns 
about different types of food risks.
*/

clear all
macro drop _all
set more off

global folder "/Users/kelseymeagher/Desktop/EurobarometerFoodRisks"
global data ${folder}/Data
global graphs ${folder}/Graphs

capture log close
log using ${folder}/EB_02_Merge.log, replace text


// Merge with microdata
use "${data}/EB73-5_01", clear
merge m:1 nation using ${data}/nation.dta

// All merged.
drop _merge

save "${data}/EB73-5_02", replace

log close
exit
