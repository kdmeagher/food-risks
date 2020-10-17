// Public perceptions of food-related risks
// Kelsey D. Meagher
// kdmeagher@ucdavis.edu
// July 2017
// File: 01_DataCleaning.do

/*
This do file cleans data from the Eurobarometer 73.5 for a study of 
cross-national differences in public risk perceptions of chemical/technical and 
biological food risks. 

This file does the following:

1. Drops topical modules on civil justice, development, and Africa

2. Drops observations for Malta

3. Renames variables to more meaningful names

4. Creates outcome variables (concerns about biological food risks & concerns
about chemical/technical food risks)

5. Recodes predictor variables

6. Saves new file (EB73-5_01.dta).

*/

clear all
macro drop _all
set more off

global folder "/Users/kelseymeagher/Desktop/EurobarometerFoodRisks"
global data ${folder}/Data
global graphs ${folder}/Graphs

capture log close
log using ${folder}/EB_01_DataCleaning.log, replace text

use "${data}/EB73-5_Original", clear

// #1
// Drop topical modules on civil justice, development, and Africa
drop V143-V286


// #2
// Drop observations from Malta (missing key vars. at country-level)
drop if V6==25


// #3
// Rename variables to more meaningful names
clonevar id=V5
clonevar nation=V6
clonevar natweight=V8


// #4
// Create outcomes variables
// Reverse-code variables for scales
clonevar worrybse=V324
recode worrybse (1=4) (2=3) (3=2) (4=1)
label define worry 1 "Not at all worried" 2 "Not very worried" ///
				   3 "Fairly worried" 4 "Very worried"
label val worrybse worry

clonevar worrygmo=V325
recode worrygmo (1=4) (2=3) (3=2) (4=1)
label val worrygmo worry

clonevar worryadd=V326
recode worryadd (1=4) (2=3) (3=2) (4=1)
label val worryadd worry

clonevar worrybac=V328
recode worrybac (1=4) (2=3) (3=2) (4=1)
label val worrybac worry

clonevar worrypest=V329
recode worrypest (1=4) (2=3) (3=2) (4=1)
label val worrypest worry

clonevar worryres=V330
recode worryres (1=4) (2=3) (3=2) (4=1)
label val worryres worry

clonevar worrypoll=V331
recode worrypoll (1=4) (2=3) (3=2) (4=1)
label val worrypoll worry

clonevar worryplas=V332
recode worryplas (1=4) (2=3) (3=2) (4=1)
label val worryplas worry

clonevar worryvir=V336
recode worryvir (1=4) (2=3) (3=2) (4=1)
label val worryvir worry

clonevar worryclon=V337
recode worryclon (1=4) (2=3) (3=2) (4=1)
label val worryclon worry

clonevar worrynano=V340
recode worrynano (1=4) (2=3) (3=2) (4=1)
label val worrynano worry

// Create scales
// Biological risks
local bio "worrybse worrybac worryvir"
alpha `bio', item gen(bio)
label var bio "Worries about Biological Food Risks"
sum bio
// a = .7970

// Chemical/technical risks
local chemtech "worrygmo worryadd worrypest worryres worrypoll worryplas worryclon worrynano"
alpha `chemtech', item gen(chemtech)
label var chemtech "Worries about Chemical & Technical Food Risks"
sum chemtech
// a = .9080


// #5
// Recode predictors
// Demographics
clonevar age=V386 

gen female=V385
recode female 1=0 2=1
label var female "Female"
label def dummy 0 "No" 1 "Yes"
label val female dummy

clonevar educage=V383 
recode educage 97=0 // no formal education
gen inschool=1 if educage==98
recode inschool .=0
label var inschool "Still in school"
label val inschool dummy
recode educage 98=0 // still in school

clonevar diffbills=V412
label var diffbills "Has difficulty paying bills"
recode diffbills 2 3=0
label val diffbills dummy

clonevar hh15plus=V392 
clonevar hh10under=V394 
clonevar hh10_14=V396 
gen haschild=1 if hh10under>=1 & hh10under<. // has child under 10
replace haschild=1 if hh10_14>=1 & hh10_14<. // has child 10-14 years old
recode haschild .=0 						 // no missing on these vars
label var haschild "Has child under 15 years old"
label val haschild dummy

clonevar marital=V382 
recode marital (2 3 4 5 6=0)
label val marital dummy
label var marital "Married"

clonevar manag=V500
recode manag (2 3=1) (1 4 5 6 7 8=0)
label val manag dummy
label var manag "Manager or Professional"

clonevar urban=V391
recode urban (2 3=1) (1=0)
label val urban dummy
label var urban "Lives in town"


// Perceived personal control
clonevar avoidchem=V367
recode avoidchem 1=4 2=3 3=2 4=1
label define confident 1 "Not at all confident" 2 "Not very confident" ///
					   3 "Fairly confident" 4 "Very confident"
label val avoidchem confident

clonevar avoidbac=V368
recode avoidbac 1=4 2=3 3=2 4=1
label val avoidbac confident

clonevar avoidtech=V370
recode avoidtech 1=4 2=3 3=2 4=1
label val avoidtech confident

clonevar avoidbse=V371
recode avoidbse 1=4 2=3 3=2 4=1
label val avoidbse confident

local avoidbio "avoidbac avoidbse"
alpha `avoidbio', item gen(avoidbio)

local avoidchemt "avoidchem avoidtech"
alpha `avoidchemt', item gen(avoidchemt)


// Institutional trust
	// Honesty
	clonevar media=V342
	recode media 1=4 2=3 3=2 4=1
	label val media confident

	clonevar consumer=V347
	recode consumer 1=4 2=3 3=2 4=1
	label val consumer confident

	clonevar enviro=V348
	recode enviro 1=4 2=3 3=2 4=1
	label val enviro confident

	clonevar eu=V345
	recode eu 1=4 2=3 3=2 4=1
	label val eu confident

	clonevar natgov=V346
	recode natgov 1=4 2=3 3=2 4=1
	label val natgov confident

	clonevar farmer=V349
	recode farmer 1=4 2=3 3=2 4=1
	label val farmer confident

	clonevar manu=V350
	recode manu 1=4 2=3 3=2 4=1
	label val manu confident

	clonevar retailer=V351
	recode retailer 1=4 2=3 3=2 4=1
	label val retailer confident

	// General Performance
	clonevar safer = V355
	recode safer 4=1 3=2 2=3 1=4
	label define agree 1 "Totally disagree" 2 "Tend to disagree" ///
					   3 "Tend to agree" 4 "Totally agree"
	label val safer agree


// Media coverage
clonevar medcoverage = V377
recode medcoverage 1=5 2=4 4=2 5=1 
label define medcov 1 "Never" 2 "Longer than six months ago" ///
					3 "Within the past 6 months" 4 "Within the past month" ///
					5 "Within the last 7 days"
label val medcoverage medcov


save "${data}/EB73-5_01", replace

log close
exit
