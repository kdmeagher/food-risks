// Public perceptions of food-related risks
// Kelsey D. Meagher
// kdmeagher@ucdavis.edu
// June 2017
// File: EB73-1_01_DataCleaning.do

/*
This do file uses data from the Eurobarometer 73.1 to generate a national
measure of mean perceptions of genetically modified food as unnatural. This 
measure is saved in the nation.dta file.
*/

clear all
macro drop _all
set more off

global folder "/Users/kelseymeagher/Desktop/EurobarometerFoodRisks"
global data ${folder}/Data
global graphs ${folder}/Graphs

capture log close
log using "${folder}/EB73-1_01_DataCleaning.log", replace text

use "${data}/EB73-1_Original", clear

// #1
// Rename variables to more meaningful names
clonevar id=V5
clonevar nation=V6
clonevar natweight=V8


// #2
// Aggregate perceptions of GMOs as "unnatural"
clonevar unnatural_gmo=V152
recode unnatural_gmo 1=4 2=3 3=2 4=1
label define agree4 1 "Totally disagree" 2 "Tend to disagree" ///
					3 "Tend to agree" 4 "Totally agree"
label val unnatural_gmo agree4

bysort nation: egen natunnaturalgmo = mean(unnatural_gmo)

table nation [pweight=natweight], contents(mean natunnaturalgmo)


log close
exit
