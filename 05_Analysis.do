// Public perceptions of food-related risks
// Kelsey D. Meagher
// kdmeagher@ucdavis.edu
// July 2017
// File: 05_Analysis.do

/*
This do file uses data from the Eurobarometer 73.5 to investigate cross-national 
differences in consumer concerns about biological and chemical food risks.

This file does the following:

1. Examines national differences in food risk concerns

2. Examines differences in perceived control over biological & chemical food risks

3. Runs multi-level mixed effects models for two outcomes: concerns about 
biological risks and concerns about chemical/technological risks. 

4. Graphs the relationship between institutional trust and food risk concerns.

5. Tests the goodness-of-fit of the level-1 model on each nation separately.

Warning: This file can take a long time to run.

*/

clear all
macro drop _all
set more off
version 13.0

global folder "/Users/kelseymeagher/Desktop/EurobarometerFoodRisks"
global data ${folder}/Data
global graphs ${folder}/Graphs

capture log close
log using ${folder}/EB_05_Analysis.log, replace text

use "${data}/EB73-5_03", clear


// #1
// Examining national differences in food risk concern

// Test differences in outcomes at Euro level
mi svyset nation [pweight = V34]
mi estimate, post: svy: mean bio chemtech
lincom chemtech - bio

// Test differences in outcomes at nation level
mi svyset [pweight = V8]

levelsof nation, local(nation)
local lab : value label nation

foreach 1 of local nation {
	local f`1' : label `lab' `1'
}

foreach i of num 1 2 3 4 5 6 7 8 9 10 11 12 13 14 16 17 18 19 20 21 22 23 24 26 27 28 29 30 {
	display "`f`i''"
	mi estimate, post: svy: mean chemtech bio if nation == `i'
	lincom chemtech - bio
}


// #2 
// Examining differences in perceived control over food risks
mi svyset nation [pweight = V34]
mi estimate, post: svy: mean avoidchemt avoidbio
lincom avoidbio - avoidchemt


// #3
// Multi-level mixed models
// Note: This generates Table 3 in the manuscript.
local DV "chemtech bio"
local demog "i.female i.marital i.haschild educage i.inschool i.manag c.age##c.age i.diffbills i.urban"
local avoid "avoidbio avoidchemt"
local trust "eu natgov farmer manu retailer enviro consumer media safer"

mi estimate, post: mixed chemtech `demog' `avoid' `trust' unnaturalgmo HHIretail nettrade medcoveragem natmedcov || nation: avoidchemt safer, cov(uns)
estimates store chemtech
	
mi estimate, post: mixed bio `demog' `avoid' `trust' unnaturalgmo HHIretail nettrade medcoveragem natmedcov || nation: avoidbio safer, cov(uns)
estimates store bio

// Display results
estimates table bio, se p
estimates table chemtech, se p


// #4 
// Graph of institutional trust & risk concerns by country
// Note: This generates Figure 3 in the manuscript.

// Chemical risks
levelsof nation, local(nation)
local lab : value label nation

foreach 1 of local nation {
	local f`1' : label `lab' `1'
}
	
foreach i of num 1 2 3 4 5 6 7 8 9 10 11 12 13 14 16 17 18 19 20 21 22 23 24 26 27 28 29 30 {
		regress chemtech `demog' `avoid' `trust' medcoverage if nation==`i'
		margins, at(safer=(1(1)4)) post
		est store chem`i'
		marginsplot, noci yscale(range(2.25 3.25)) ylabel(2.25 2.75 3.25, angle(horizontal)) ymtick(2.5 3, grid) title("`f`i''", size(vlarge)) ytitle("") xtitle("") xlabel(1 "1" 2 "2" 3 "3" 4 "4") name("chem`i'", replace) graphregion(color(white)) scheme(sj)
}

graph combine chem1 chem2 chem3 chem4 chem5 chem6 chem7 chem8 chem9 chem10 chem11 ///
chem12 chem13 chem14 chem16 chem17 chem18 chem19 chem20 chem21 chem22 chem23 ///
chem24 chem26 chem27 chem28 chem29 chem30, rows(5) ///
graphregion(color(white))
graph export ${graphs}/chemtrust.png, replace

// Biological risks
foreach i of num 1 2 3 4 5 6 7 8 9 10 11 12 13 14 16 17 18 19 20 21 22 23 24 26 27 28 29 30 {
		regress bio `demog' `avoid' `trust' medcoverage if nation==`i'
		margins, at(safer=(1(1)4)) post
		est store bio`i'
		marginsplot, noci yscale(range(2.25 3.25)) ylabel(2.25 2.75 3.25, angle(horizontal)) ymtick(2.5 3, grid) title("`f`i''", size(vlarge)) ytitle("") xtitle("") xlabel(1 "1" 2 "2" 3 "3" 4 "4") name("bio`i'", replace) graphregion(color(white)) scheme(sj)
}

graph combine bio1 bio2 bio3 bio4 bio5 bio6 bio7 bio8 bio9 bio10 bio11 ///
bio12 bio13 bio14 bio16 bio17 bio18 bio19 bio20 bio21 bio22 bio23 ///
bio24 bio26 bio27 bio28 bio29 bio30, rows(5) ///
graphregion(color(white))
graph export ${graphs}/biotrust.png, replace

// Combined graph of chemical & bio risks
foreach i of num 1 2 3 4 5 6 7 8 9 10 11 12 13 14 16 17 18 19 20 21 22 23 24 26 27 28 29 30 {
	coefplot bio`i' (chem`i', lpattern(dash)), at xtitle("") noci connect(l) yscale(range(2.25 3.25)) ///
	ylabel(2.25 2.75 3.25, angle(horizontal)) ymtick(2.5 3, grid) msymbol(i) lwidth(medthick) ///
	title("`f`i''", size(vlarge)) name("trust`i'", replace) legend(label(1 "Biological Risks") label(2 "Chemical/Technical Risks") size(vsmall) cols(1) symxsize(8)) ///
	graphregion(color(white)) scheme(sj)
}

grc1leg trust1 trust2 trust3 trust4 trust5 trust6 trust7 trust8 trust9 trust10 ///
trust11 trust12 trust13 trust14 trust16 trust17 trust18 trust19 trust20 trust21 ///
trust22 trust23 trust24 trust26 trust27 trust28 trust29 trust30, position(5) ring(0) ///
rows(5) iscale(*1.2) ///
graphregion(color(white)) ///
note("Note: Lines represent predicted mean of risk concern at different levels of insitutional trust, adjusting for other individual predictors." ///
"Horizontal axis is institutional trust (range: 1 - 4, 1 = low trust). Vertical axis is risk concern (range: 1 - 4, 1 = low concern).", size(vsmall))
graph export ${graphs}/trust.png, replace


// #5
// Testing L1 models by country
// Note: This analysis is referenced in the conclusion of the manuscript but
// the results are not reported.
use "${data}/EB73-5_02", clear

local DV "chemtech bio"
local demog "i.female i.marital i.haschild educage i.inschool i.manag c.age##c.age i.diffbills i.urban"
local avoid "avoidbio avoidchemt"
local trust "eu natgov farmer manu retailer enviro consumer media safer"

levelsof nation, local(nation)
local lab : value label nation

foreach 1 of local nation {
	local f`1' : label `lab' `1'
}

svyset [pweight = V8]

foreach 1 of local nation {
	display "`f`1''"
	svy: regress chemtech `demog' `avoid' `trust' if nation==`1'
}



log close
exit
