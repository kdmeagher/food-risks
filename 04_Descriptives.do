// Public perceptions of food-related risks
// Kelsey D. Meagher
// kdmeagher@ucdavis.edu
// July 2017
// File: 04_Descriptives.do

/*
This do file uses the Eurobarometer 73.5 to investigate cross-national differences
in consumer risk perceptions about different types of food risks. 

This file does the following:

1. Graph mean concerns about bio & chem food risks by nation

2. Graph difference in mean concerns over food risks by nation

3. Generate descriptive tables of variables


Note: All descriptive stats in the paper are derived from the original 
(non-imputed) data and make use of the recommended survey weights.
Descriptive stats of Europe as a whole use V34.
Descriptive stats of separate national or subnational regions use V8.

*/

clear all
macro drop _all
set more off

global folder "/Users/kelseymeagher/Desktop/EurobarometerFoodRisks"
global data ${folder}/Data
global graphs ${folder}/Graphs

capture log close
log using ${folder}/EB_04_Descriptives.log, replace text

use "${data}/EB73-5_03", clear


// #1
// Graph mean concerns about food-related risks by nation
// Note: This generates Figure 1 in the manuscript.
	// black & white version
	graph dot (mean) bio (mean) chemtech [pweight = V8], over(nation, sort(bio) label(labsize(small))) ///
	exclude0 marker(1, msymbol(circle) mcolor(black)) marker(2, msymbol(triangle) mcolor(black)) xsize(6) ysize(4) ///
	legend(label(1 "Biological Risks") label(2 "Chemical/Technical Risks")) ///
	graphregion(color(white)) ///
	note("Source: 2010 Data from Eurobarometer 73.5" "Responses range from 1 = 'Not at all worried' to 4 = 'Very worried'", size(vsmall) span) ///
	legend(region(lwidth(none)))
	graph export ${graphs}/meanoutcomepdf.png, replace

	// color version
	graph dot (mean) bio (mean) chemtech [pweight = V8], over(nation, sort(bio) label(labsize(small))) ///
	exclude0 marker(1, msymbol(circle) mcolor(sea)) marker(2, msymbol(triangle) mcolor(turquoise)) xsize(6) ysize(4) ///
	legend(label(1 "Biological Risks") label(2 "Chemical/Technical Risks")) ///
	graphregion(color(white)) ///
	note("Source: 2010 Data from Eurobarometer 73.5" "Responses range from 1 = 'Not at all worried' to 4 = 'Very worried'", size(vsmall) span) ///
	title("Mean Concerns about Food-Related Risks", span color(black)) ///
	legend(region(lwidth(none)))
	graph export ${graphs}/meanoutcomeweb.png, replace
	

// #2
// Graph difference in mean concerns over bio & chem risks by nation
// Note: This generates Figure 2 in the manuscript.
	// black & white version
	gen diff = chemtech - bio
	graph hbar (mean) diff [pweight = V8], over(nation, sort(diff) label(labsize(small))) ///
	ytitle((Chemical/Technical Concerns) - (Biological Concerns)) ///
	graphregion(color(white))  ///
	scheme(sj)  bar (1, color(black)) ///
	note("Source: 2010 Data from Eurobarometer 73.5" "Responses for each variable range from 1 = 'Not at all worried' to 4 = 'Very worried'", size(vsmall) span)
	graph export ${graphs}/meandiff.png, replace

	// color version
	graph hbar (mean) diff [pweight = V8], over(nation, sort(diff) label(labsize(small))) ///
	ytitle((Chemical/Technical Concerns) - (Biological Concerns)) ///
	graphregion(color(white))  ///
	scheme(sj)  bar (1, color(sea)) ///
	note("Source: 2010 Data from Eurobarometer 73.5" "Responses for each variable range from 1 = 'Not at all worried' to 4 = 'Very worried'", size(vsmall) span)
	graph export ${graphs}/meandiffpdf.png, replace


// #3
// Descriptive tables
// Variables & value labels
local myvars "chemtech bio female marital haschild educage inschool manag age"
local myvars "`myvars' diffbills urban avoidbio avoidchemt unnaturalgmo eu natgov"
local myvars "`myvars' farmer manu retailer enviro consumer media safer" 
local myvars "`myvars' HHIretail nettrade medcoverage natmedcov"

foreach varname of varlist `myvars' {
	local varlabel : variable label `varname'
	display "`varname'" _col(12) "`varlabel'"
}
 
// Summary stats for all variables in sample
// Variable name, N, Missing, Mean, SD, Min, Max
// Note: This generates the data in Tables 1 & 2 in the manuscript.
foreach varname of varlist `myvars' {
	quietly sum `varname'
	local mean = string(r(mean), "%8.3f")
	local sd = string(r(sd), "%8.3f")
	local min = string(r(min), "%8.3f")
	local max = string(r(max), "%8.3f")
	display "`varname'" _col(20) r(N) _col(30) =_N-r(N) _col(40) `mean' _col(50) `sd' _col(60) `min' _col(70) `max'
}


// Correlations between country-level variables
// Note: This generates the data in Table 2 in the manuscript.
pwcorr chemtech bio unnaturalgmo HHIretail nettrade natmedcov, sig

	
log close
exit

