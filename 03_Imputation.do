// Public perceptions of food-related risks
// Kelsey D. Meagher
// kdmeagher@ucdavis.edu
// July 2017
// File: 03_Imputation.do

/*
This do file imputes missing data in the Eurobarometer 73.5 for a study of
cross-national differences in public concerns about different types of food risks. 

This file does the following:

1. Describes missing data

2. Multiply imputes missing values using -mi impute chained-

3. Drops imputed values for outcome variables

4. Creates passive variables

5. Saves new file (EB73-5_03.dta).

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
log using ${folder}/EB_03_Imputation.log, replace text

use "${data}/EB73-5_02", clear


// #1
// Describe missing data
local lhs "chemtech bio"
local rhs "nation female marital haschild educage inschool manag age diffbills urban"
local rhs "`rhs' avoidbio avoidchemt eu natgov farmer manu retailer enviro consumer"
local rhs "`rhs' media safer unnaturalgmo fiscdecentral HHIretail nettrade orgpercent medcoverage"

mdesc `lhs' `rhs'

// No missing on nation, female, haschild, inschool, manag, age, unnaturalgmo, 
// fiscdecentral, HHIretail, nettrade, and orgpercent.

// Highest missing on medcoverage (54% - only asked of randomly selected half of 
// sample), eu (6.9%), & safer (5.7%). 

// All others have <5% missing.


// #2
// Multiple imputation
// Set up
local miss "chemtech bio marital educage diffbills urban avoidbio avoidchemt"
local miss "`miss' eu natgov farmer manu retailer enviro consumer media safer medcoverage"
local nomiss "i.nation i.female i.haschild i.inschool i.manag age"

misstable sum `miss', gen(miss_)

mi set wide
mi register imputed chemtech bio marital educage diffbills urban avoidbio avoidchemt eu natgov farmer manu retailer enviro consumer media safer medcoverage
mi describe

// Checking imputation models for convergence
// Note: country-level vars not included because of collinearity with nation var
regress chemtech bio i.marital educage i.diffbills i.urban avoidbio avoidchemt eu natgov farmer manu retailer enviro consumer media safer medcoverage `nomiss'

regress bio chemtech i.marital educage i.diffbills i.urban avoidbio avoidchemt eu natgov farmer manu retailer enviro consumer media safer medcoverage `nomiss'

logit marital chemtech bio educage i.diffbills i.urban avoidbio avoidchemt eu natgov farmer manu retailer enviro consumer media safer medcoverage `nomiss'

regress educage chemtech bio i.marital i.diffbills i.urban avoidbio avoidchemt eu natgov farmer manu retailer enviro consumer media safer medcoverage `nomiss'

logit diffbills chemtech bio i.marital educage i.urban avoidbio avoidchemt eu natgov farmer manu retailer enviro consumer media safer medcoverage `nomiss'

logit urban chemtech bio i.marital educage i.diffbills avoidbio avoidchemt eu natgov farmer manu retailer enviro consumer media safer medcoverage `nomiss'

regress avoidbio chemtech bio i.marital educage i.diffbills i.urban avoidchemt eu natgov farmer manu retailer enviro consumer media safer medcoverage `nomiss'

regress avoidchemt chemtech bio i.marital educage i.diffbills i.urban avoidbio eu natgov farmer manu retailer enviro consumer media safer medcoverage `nomiss'

ologit eu chemtech bio i.marital educage i.diffbills i.urban avoidbio avoidchemt natgov farmer manu retailer enviro consumer media safer medcoverage `nomiss'

ologit natgov chemtech bio i.marital educage i.diffbills i.urban avoidbio avoidchemt eu farmer manu retailer enviro consumer media safer medcoverage `nomiss'

ologit farmer chemtech bio i.marital educage i.diffbills i.urban avoidbio avoidchemt eu natgov manu retailer enviro consumer media safer medcoverage `nomiss'

ologit manu chemtech bio i.marital educage i.diffbills i.urban avoidbio avoidchemt eu natgov farmer retailer enviro consumer media safer medcoverage `nomiss'

ologit retailer chemtech bio i.marital educage i.diffbills i.urban avoidbio avoidchemt eu natgov farmer manu enviro consumer media safer medcoverage `nomiss'

ologit enviro chemtech bio i.marital educage i.diffbills i.urban avoidbio avoidchemt eu natgov farmer manu retailer consumer media safer medcoverage `nomiss'

ologit consumer chemtech bio i.marital educage i.diffbills i.urban avoidbio avoidchemt eu natgov farmer manu retailer enviro media safer medcoverage `nomiss'

ologit media chemtech bio i.marital educage i.diffbills i.urban avoidbio avoidchemt eu natgov farmer manu retailer enviro consumer safer medcoverage `nomiss'

ologit safer chemtech bio i.marital educage i.diffbills i.urban avoidbio avoidchemt eu natgov farmer manu retailer enviro consumer media medcoverage `nomiss'

ologit medcoverage chemtech bio i.marital educage i.diffbills i.urban avoidbio avoidchemt eu natgov farmer manu retailer enviro consumer media safer `nomiss'

// All converged.


// Imputation
mi impute chained (logit, augment include(i.nation i.female i.haschild i.inschool i.manag age)) marital diffbills urban ///
		  (ologit, augment include(i.nation i.female i.haschild i.inschool i.manag age)) eu natgov ///
		  farmer manu retailer enviro consumer media safer medcoverage ///
		  (regress, include(i.nation i.female i.haschild i.inschool i.manag age)) chemtech bio ///
		  (pmm, include(i.nation i.female i.haschild i.inschool i.manag age)) educage avoidbio avoidchemt, ///
		  add(40) rseed(444802460)

		  
// #4
// Drop imputed values for outcome variables
drop if miss_chemtech==1 | miss_bio==1
mi update


// #5
// Create passive variables
sort nation
mi passive: by nation: egen natmedcov = mean(medcoverage)
mi passive: gen medcoveragem = medcoverage - natmedcov
mi update


save "${data}/EB73-5_03", replace


log close
exit
