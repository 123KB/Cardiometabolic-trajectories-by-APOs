
***********************************************************************************
***********************************************************************************

* CPRD GOLD data cleaning
* Including converting text files to Stata data
* Text files found in: \\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data
* Save Stata datasets to: \\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data

***********************************************************************************
***********************************************************************************
* Practices 

import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\20_145_gold_part1_Extract_Practice_001.txt", clear
save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\Practice\practice1.dta", replace

import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\20_145_gold_part2_Extract_Practice_001.txt", clear
save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\Practice\practice2.dta", replace

import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\20_145_gold_part3_Extract_Practice_001.txt", clear
save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\Practice\practice3.dta", replace

use "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\Practice\practice1.dta", clear
append using "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\Practice\practice2.dta"
append using "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\Practice\practice3.dta"

sort pracid
duplicates drop 

	foreach date in lcd uts {
		capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
	}

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\practices_all.dta", replace

use "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\practices_all.dta", clear


***********************************************************************************
* Patients
/*
patid	Encrypted unique identifier given to a patient in CPRD GOLD
vmid	Old vm id when the practice was using VAMP system
gender	Patient’s gender
yob		Patient’s year of birth
mob		Patient’s month of birth (for those aged under 16). 0 indicates no month set
marital	Patient’s current marital status
famnum	Family ID number
chsreg	Value to indicate whether the patient is registered with Child Health Surveillance
chsdate	Date of registration with Child Health Surveillance
prescr	Type of prescribing exemption the patient has currently
capsup	Level of capitation supplement the patient has currently (e.g. low, medium, high)
frd		Date the patient first registered with the practice. If patient only has ‘temporary’ records, the date is the first encounter with the practice; if patient has
crd		Date the patient’s current period of registration with the practice began (date of the first ‘permanent’ record after the latest transferred out period). If there are no ‘transferred out periods’, the date is equal to ‘frd’
regstat	Status of registration detailing gaps and temporary patients
reggap	Number of days missing in the patients registration details
internal	Number of internal transfer out periods, in the patient’s registration details
tod		Date the patient transferred out of the practice, if relevant. Empty for patients who have not transferred out
toreason	Reason the patient transferred out of the practice. Includes 'Death' as an option
deathdate	Date of death of patient – derived using a CPRD algorithm
accept	Flag to indicate whether the patient has met certain quality standards: 1 = acceptable, 0 = unacceptable

*/


import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\20_145_gold_part1_Extract_Patient_001.txt", clear
save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\Patient\patient1.dta", replace

import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\20_145_gold_part2_Extract_Patient_001.txt", clear
save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\Patient\patient2.dta", replace

import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\20_145_gold_part3_Extract_Patient_001.txt", clear
save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\Patient\patient3.dta", replace

use "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\Patient\patient1.dta", clear
append using "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\Patient\patient2.dta"
append using "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\Patient\patient3.dta"

duplicates drop

	foreach date in chsdate deathdate frd crd tod {
		capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
	}

keep if accept==1

keep patid gender yob mob frd crd prescr deathdate accept

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\accept_pats.dta", replace


***********************************************************************************
* Convert linked data to Stata datasets

* Linkage eligibility file for Set 18 of the linkages 
import delim "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\Linked_Data\linkage_eligibility.txt", varn(1) clear 
	foreach date in linkdate {
		capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
	}
	
save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\linkage_eligibility.dta", replace


***********************************************************************************
***********************************************************************************

* Convert clinical files to Stata datasets

*	patid	 -	Encrypted unique identifier given to a patient in CPRD GOLD
*	eventdate	 -	Date associated with the event, as entered by the GP
*	sysdate	 -	Date the event was entered into Vision
*	constype	 -	Consultation type code for the category of event recorded within the GP system (e.g. diagnosis or symptom)
*	consid	 -	Consultation identifier that allows information about the consultation to be retrieved, when used in combination with pracid
*	medcode	 -	CPRD unique code for the medical term selected by the GP
*	staffid	 -	Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown
*	episode	 -	Episode type for a specific clinical event
*	enttype	 -	Entity identifier that represents the structured data area in Vision where the data was entered
*	adid	 -	Additional details identifier that allows additional information to be retrieved for this event, when used in combination with pracid. A value of 0 signifies that there is no additional information associated with the event.

* Part 1 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part1_Extract_Clinical*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear
		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Clinical"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	
	
* Part 2 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part2_Extract_Clinical*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear
		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Clinical"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	
	
* Part 3 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part3_Extract_Clinical*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear
		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Clinical"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	

* Append together
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Clinical"
local fnames: dir "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Clinical" files "*"
foreach file of local fnames {
        append using "`file'"
        }

		
keep patid eventdate constype consid medcode adid

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\clinical_all.dta", replace


***********************************************************************************
***********************************************************************************

* Convert therapy files to Stata datasets

*	patid	 -	Encrypted unique identifier given to a patient in CPRD GOLD
*	eventdate	 -	Date associated with the event, as entered by the GP
*	sysdate	 -	Date the event was entered into Vision
*	consid	 -	Consultation identifier that allows information about the consultation to be retrieved, when used in combination with pracid
*	prodcode	 -	CPRD unique product code for the treatment selected by the GP
*	staffid	 -	Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown
*	dosageid	 -	Identifier that allows dosage information on the event to be retrieved. Use the Common Dosages Lookup to obtain the anonymised dosage text, and extracted numerical information such as daily dose.
*	bnfcode	 -	Code representing the chapter & section from the British National Formulary for the product selected by GP
*	qty	 -	Total quantity entered by the GP for the prescribed product
*	numdays	 -	Number of treatment days prescribed for a specific therapy event
*	numpacks	 -	Number of individual product packs prescribed for a specific therapy event
*	packtype	 -	Pack size or type of the prescribed product
*	issueseq	 -	Number to indicate whether the event is associated with a repeat schedule. Value of 0 implies the event is not part of a repeat prescription. A value  1 denotes the issue number for the prescription within a repeat schedule

* Part 1 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part1_Extract_Therapy*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear
		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Therapy"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	
	
* Part 2 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part1_Extract_Therapy*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear
		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Therapy"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	
	
* Part 3 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part1_Extract_Therapy*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear
		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Therapy"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	

* Append together
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Therapy"
local fnames: dir "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Therapy" files "*"
foreach file of local fnames {
        append using "`file'"
        }

keep patid eventdate consid prodcode bnfcode
		
		
save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\therapy_all.dta", replace



***********************************************************************************
***********************************************************************************

* Convert test files to Stata datasets

*	patid	 -	Encrypted unique identifier given to a patient in CPRD GOLD
*	eventdate	 -	Date associated with the event, as entered by the GP
*	sysdate	 -	Date the event was entered into Vision
*	constype	 -	Code for the consultation category of event recorded within the GP system (e.g. examination)
*	consid	 -	Identifier that allows information about the consultation to be retrieved, when used in combination with pracid
*	medcode	 -	CPRD unique code for the medical term selected by the GP
*	staffid	 -	Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown
*	enttype	 -	Entity identifier that represents the structured data area in Vision where the data was entered

* Depending on the Test Entity Type, tests have 4, 7, or 8 data fields:
* 4 fields:	Qualifier, Normal range from, Normal range to, Normal range basis
* 7 fields: Operator, Value, Unit of measure, Unit of measure, Qualifier, Normal range from, Normal range to, Normal range basis, (or peak flow device for entity type 311)
* 8 fields: Operator, Value, Unit of measure, Qualifier, Normal range from, Normal range to, Normal range basis, Expected delivery date (entity type 284) / Weeks (entity type 154)




* Part 1 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part1_Extract_Test*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) stringcols(13) clear 
		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
					
		foreach x of varlist data1 data2 data3 data4 data5 data6 data7 data8 {
			rename `x' test_`x'

		}
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Test"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}



* Part 2 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part2_Extract_Test*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) stringcols(13) clear
		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}

		foreach x of varlist data1 data2 data3 data4 data5 data6 data7 data8 {
			rename `x' test_`x'
			
		}
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Test"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	
	
* Part 3 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part3_Extract_Test*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) stringcols(13) clear
		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}

		foreach x of varlist data1 data2 data3 data4 data5 data6 data7 data8 {
			rename `x' test_`x'
		
		}
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Test"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	

* Append together
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Test"
local fnames: dir "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Test" files "*"
foreach file of local fnames {
        append using "`file'"
        }

keep patid eventdate constype consid medcode test*
		
save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\test_all.dta", replace



***********************************************************************************
***********************************************************************************

* Convert consultation files to Stata datasets

* patid                   
* eventdate  Date associated with the event, as entered by the GP   
* sysdate    Date the event was entered into Vision
* constype   Type of consultation (e.g. Surgery Consultation, Night Visit, Emergency etc.)
* consid     The consultation identifier linking events at the same consultation, when used in combination with pracid
* staffid    The identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown
* duration   The length of time (minutes) between the opening, and closing of the consultation record

	
* Part 1 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part1_Extract_Consultation*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear
		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Consultation"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	

* Part 2 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part2_Extract_Consultation*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear
		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Consultation"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
			
	
* Part 3 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part3_Extract_Consultation*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear
		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Consultation"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	
	
* Append together
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Consultation"
local fnames: dir "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Consultation" files "*"
foreach file of local fnames {
        append using "`file'"
        }

keep patid eventdate constype consid staffid
		
save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\consultation_all.dta", replace


***********************************************************************************
***********************************************************************************

* Convert Additional Clinical Details files to Stata datasets

* patid	Patient Identifier	Encrypted unique identifier given to a patient in CPRD GOLD	
* enttype	Entity Type	Identifier that represents the structured data area in Vision where the data was entered	
* adid	Additional Details Identifier	Identifier that allows information about the original clinical event to be retrieved, when used in combination with pracid	Link Clinical table
* data1 etc	Depends on Entity Type		


	
* Part 1 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part1_Extract_Additional*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear

		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Additional"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	
* Part 2 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part2_Extract_Additional*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear

		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Additional"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	
* Part 3 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part3_Extract_Additional*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear

		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Additional"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}



* Add dates to additional detail files

local clinicalfiles : dir "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Clinical" files "20_145_gold_part*.dta"
local addfiles : dir "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Additional" files "20_145_gold_part*.dta"

mkdir "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/tmp"

qui foreach clinical in `clinicalfiles' {
	use patid adid eventdate sysdate using "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Clinical/`clinical'" , clear
	drop if adid==0
	save "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/tmp/tmp_`clinical'", replace
}

local clinicalfiles : dir "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Clinical" files "20_145_gold_part*.dta"
local addfiles : dir "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Additional" files "20_145_gold_part*.dta"
	
foreach add in `addfiles' {
	local clinicalfiles : dir "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Clinical" files "20_145_gold_part*.dta"
	use "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Additional/`add'" ,clear
	save "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Additional/dated_`add'", replace
	qui foreach clinical in `clinicalfiles' {
		use "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Additional/dated_`add'", clear
		merge 1:1 patid adid using "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/tmp/tmp_`clinical'", update keep(1 3 4)
		drop _merge
		save "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Additional/dated_`add'", replace
	}
}

	
* Append together
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Additional"
local fnames: dir "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Additional" files "dated_*"
foreach file of local fnames {
        append using "`file'"
        }


drop sysdate 
		
save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\additional_all.dta", replace


***********************************************************************************
***********************************************************************************

* Convert Immunisation files to Stata datasets

* patid
* eventdate
* sysdate
* constype   Consultation Type   Code for the category of event recorded within the GP system (e.g. intervention)
* consid     Identifier that allows information about the consultation to be retrieved, when used in combination with pracid
* medcode    CPRD unique code for the medical term selected by the GP   Lookup Medical Dictionary
* staffid    Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown
* immstype   Individual components of an immunisation, e.g. Mumps, Rubella, Measles   Lookup IMT
* stage      Stage of the immunisation given, e.g. 1, 2, B2   Lookup IST
* status     Status of the immunisation e.g. Advised, Given, Refusal   Lookup IMM
* compound   Immunisation compound administered – may be a single or multi-component preparation, e.g. MMR   Lookup IMC
* source     Location where the immunisation was administered, e.g. In this practice  Lookup INP
* reason     Reason for administering the immunisation, e.g. Routine measure   Lookup RIN
* method     Route of administration for the immunisation, e.g. Oral, Intramuscular   Linkage lookup IME
* batch      Immunisation batch number


* Part 1 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part1_Extract_Immunisation*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear

		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Immunisation"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	
* Part 2 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part2_Extract_Immunisation*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear

		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Immunisation"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}	
	
* Part 3 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part3_Extract_Immunisation*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear

		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Immunisation"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}	
	

* Append together
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Immunisation"
local fnames: dir "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Immunisation" files "*"
foreach file of local fnames {
        append using "`file'"
        }

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\immunisation_all.dta", replace



***********************************************************************************
***********************************************************************************

* Convert Referral files to Stata datasets	
	
* patid
* eventdate
* sysdate
* constype   Code for the category of event recorded within the GP system (e.g. management or administration)
* consid     Identifier that allows information about the consultation to be retrieved, when used in combination with pracid
* medcode    CPRD unique code for the medical term selected by the GP
* staffid    Identifier of the practice staff member entering the data. A value of 0 indicates that the staffid is unknown
* source     Classification of the source of the referral e.g. GP, Self
* nhsspec    Referral speciality according to the National Health Service (NHS) classification
* fhsaspec   Referral speciality according to the Family Health Services Authority (FHSA) classification
* inpatient  Classification of the type of referral, e.g. Day case, In patient
* attendance Category describing whether the referral event is the first visit, a follow-up etc.
* urgency    Classification of the urgency of the referral e.g. Routine, Urgent

		
* Part 1 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part1_Extract_Referral*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear

		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Referral"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	
	
* Part 2 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part2_Extract_Referral*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear

		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Referral"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}	
	
* Part 3 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part3_Extract_Referral*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear

		foreach date in chsdate frd crd tod deathdate lcd uts eventdate sysdate linkdate start end discharged dod perend perstart subdate apptdate dnadate reqdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		
		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Referral"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	
* Append together
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Referral"
local fnames: dir "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Referral" files "*"
foreach file of local fnames {
        append using "`file'"
        }

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\referral_all.dta", replace


***********************************************************************************
***********************************************************************************

* Convert Staff files to Stata datasets	
	
* staffid Encrypted unique identifier given to the practice staff member entering the data
* gender
* role    Role of the member of staff who created the event
	
* Part 1 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part1_Extract_Staff*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear

		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Staff"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	
* Part 2 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part2_Extract_Staff*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear

		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Staff"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	
* Part 3 files
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"

	local myfilelist : dir . files "20_145_gold_part3_Extract_Staff*.txt"
	foreach file of local myfilelist {
	cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data"		
		import delim `file', varn(1) clear

		compress
		cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Staff"
		local file = subinstr("`file'",".txt",".dta",.)
		save "`file'", replace
	}
	
* Append together
cd "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Staff"
local fnames: dir "//ads.bris.ac.uk/filestore/HealthSci SafeHaven/CPRD Projects UOB/Projects/20_145/Data Analysis/Kate/Stata data/Staff" files "*"
foreach file of local fnames {
        append using "`file'"
        }
		
duplicates drop

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\staff_all.dta", replace


***********************************************************************************
***********************************************************************************

* CONVERT TEXT FILES TO STATA DATA
* LINKED DATA

***********************************************************************************
***********************************************************************************	


***********************************************************************************
***********************************************************************************

* Pregnancy register


* Note the following indicates whether we have the variables in documentation:

/*
Yes: patid		Encrypted unique patient identifier
Yes: pregid		Unique identifier of the pregnancy episode
No:  mblbabies	Number of babies the pregnancy is linked to in the MBL
No:  babypatid1	Encrypted unique patient identifier (linked baby)
Yes: babymob	Baby’s month of birth as recorded in the baby’s medical record
Yes: babyyob	Baby’s year of birth as recorded in the baby’s medical record
Yes: totalpregs	Total number of identified pregnancy episodes (per woman)
Yes: pregnumber	Pregnancy episode number (per woman)
Yes: pregstart	Estimated start date of pregnancy
No:  firstantenatal	Date of earliest antenatal record within the pregnancy
No:  startsource	Data source used to estimate pregnancy start date: 1 = Imputed2, 2 = EDD, 3 = LMP, 4 = Gestational age at birth, 5 = Gestational age from antenatal record, 6 = EDC
No:  startadj	Flag to indicate whether the pregnancy start date has been adjusted: 0 = Not adjusted, 1 = Due to antenatal records in the preceding 4 weeks, 2 = Due to specific conflicts between the estimated pregnancy duration and records indicating gestational age at birth (live births and stillbirths only), 3 = Both
No:  Secondtrim3	Estimated start date of second trimester
No:  Thirdtrim3	Estimated start date of third trimester
Yes: pregend	Estimated end date of pregnancy. NB: For pregnancies with unknown outcome, the date of the latest antenatal record in the pregnancy episode is provided.
No:  endsource	ata source used to estimate pregnancy end date: 1 = Delivery record, 2 = Postnatal record in the mother’s medical record, 3 = Discharge date relating to a delivery, 4 = Baby’s (month and) year of birth as recorded in the baby’s medical record, 5 = Postnatal record in the baby’s medical record, 6 = First consultation in the baby’s medical record. Only completed for live births and stillbirths.
No:  endadj		Flag to indicate whether the pregnancy end date has been adjusted: 0 = Not adjusted, 1 = Due to specific conflicts between the estimated pregnancy duration and records indicating gestational age, 2 = Due to prior adjustments to the start date, 3 = Both. Missing for deliveries based on late pregnancy records4.
No:  gestdays	Estimated duration of pregnancy episode in days (calculated as pregend minus pregstart)
No:  matage		Mother’s age at end of pregnancy (years)
Yes: outcome	Outcome of pregnancy: 1 = Live birth, 2 = Stillbirth, 3 = 1 and 2, 4 = Miscarriage, 5 = TOP, 6 = 4 or 5, 7 = Ectopic, 8 = Molar, 9 = Blighted ovum, 10 = Unspecified loss, 11 = Delivery based on a third trimester pregnancy record, 12 = Delivery based on a late pregnancy record4, 13 = Outcome unknown
Yes: preterm_ev	Flag to indicate evidence of a premature delivery: 1=preterm, 0=no evidence of preterm, 9=not applicable (outcome not a delivery)
Yes: postterm_ev	Flag to indicate evidence of a post-term delivery: 1=post-term, 0=no evidence of post-term, 9=not applicable (outcome not a delivery)
Yes: multiple_ev	Flag to indicate evidence of a multiple pregnancy: 1=multiple, 0=no evidence of multiple. Missing for pregnancy losses.
No:  conflict	Flag to indicate whether the pregnancy episode overlaps with another episode (within a woman): 1=overlapping, 0= non-overlapping
*/

import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\Linked_Data\Preg_Reg_202004.txt"
		foreach date in pregstart pregend {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\pregnancy_register.dta", replace



***********************************************************************************
***********************************************************************************

* Mother and baby linkage


import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\Linked_Data\20_145_MBL.txt", encoding(ISO-8859-9) 
drop _merge

		foreach date in deldate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
sort mumpatid deldate

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\mbl.dta", replace


***********************************************************************************
***********************************************************************************
* Mother and baby link - convert to wide format
use "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\mbl.dta", clear

order mumpatid deldate
sort mumpatid deldate
drop pracid mumbirthyear babybirthyear 

by mumpatid deldate: gen n1= _n

reshape wide babypatid gender, i(mumpatid deldate) j(n1)

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\mbl_wide.dta", replace


***********************************************************************************
***********************************************************************************

* HES maternity

* Birthweight

clear
import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\Linked_Data\Data Minimisation\hes_maternity_20_145_part2_DM.txt"

		foreach date in epistart epiend anasdate {
			capture confirm variable `date'
			if !_rc {
				gen `date'1 = date(`date',"DMY")
				format %td `date'1
				drop `date'
				rename `date'1 `date'
			}
		}
		
	
keep if birweit < .
drop if birweit == 9999

* Quickly get birthweight of first baby
keep if matordr == 1
keep patid gestat epistart epiend birweit sexbaby
gen year = year( epiend)
duplicates re patid year

sort patid year
by patid: gen n1= _n
keep if n1==1
drop n1

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\hes_bw.dta", replace



***********************************************************************************
***********************************************************************************

* Indices of multiple deprivation (IMD) 

clear
import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\Linked_Data\patient_townsend2001_20_145_part2.txt"

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\patient_townsend.dta", replace


clear
import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\Linked_Data\practice_imd_20_145_part2.txt"

drop ni2017_imd_5 s2016_imd_5 w2014_imd_5

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\practice_imd.dta", replace



***********************************************************************************
***********************************************************************************

* Ethnicity

clear
import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\Linked_Data\Data Minimisation\hes_patient_20_145_part2_DM.txt"

keep patid gen_ethnicity

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\ethnicity.dta", replace



***********************************************************************************
***********************************************************************************

* HES maternity

clear
import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\Linked_Data\Data Minimisation\hes_maternity_20_145_part2_DM.txt"

* Generate numeric versions of date variables
gen epistart_num = date(epistart, "DMY")
gen epiend_num = date(epiend, "DMY")
gen anasdate_num = date(anasdate, "DMY")
format %td epistart_num epiend_num anasdate_num

* format variables 
encode numbaby, gen(numbaby_num)
recode numbaby_num (7=-3) (8=-2) (9=-1) 
label define lb_numbaby /* 
*/ 1  "One" /*  
*/ 2  "Two"  /*
*/ 3  "Three"  /*
*/ 4  "Four"  /*
*/ 5  "Five"  /*
*/ 6  "Six or more" /* 
*/ -3  "" /* Not in data dictionary
*/ -2  "Not known (submitted value)" /*  
*/ -1  "Not known (derived in HES where the field is null)" 
label values numbaby_num lb_numbaby

label define lb_neocare /*
*/ 0 "Normal care" 		/* care given by the mother or mother substitute, with medical and neonatal nursing advice if needed  
*/ 1 "Special care" 	/* care given in a special nursery, transitional care ward or postnatal ward, which provides care and treatment exceeding normal routine care. Some aspects of special care can be undertaken by a mother supervised by qualified nursing staff. Special nursing care includes support for and education of the infant's parents  
*/ 2  "Level 2 intensive care" /* (high dependency intensive care): care given in an intensive or special care nursery, which provides continuous skilled supervision by qualified and specially trained nursing staff who may care for more babies than in level 1 intensive care. Care includes support for the infant's parents  
*/ 3  "Level 1 intensive care" /* (maximal intensive care): care given in an intensive or special care nursery, which provides continuous skilled supervision by qualified and specially trained nursing and medical staff. Care includes support for the infant's parents  
/* 4 "" */ Not in data dictionary
*/ 8  "Not applicable" 	/* the episode of care does not involve a neonate at any time  
*/ 9  "Not known" 		// the episode of care involves a neonate and is finished but no data has been entered this constitutes a validation error. Alternatively the episode involves a neonate but is unfinished, therefore no data need be present
label values neocare lb_neocare

encode birordr, gen(birordr_num)
recode birordr_num (8=-3) (9=-2) (10=-1) 
label define lb_birordr /* 
*/ -1 "Not known (derived in HES where the field is null)" /* 
*/ -2 "Not known (submitted value)" /*
*/ -3 "Not applicable"
label values birordr_num lb_birordr

label define lb_birstat /*
*/ 1 "Live" /*  
*/ 2 "Still birth: ante-partum" /*  
*/ 3 "Still birth: intra-partum"  /* 
*/ 4 "Still birth: indeterminate"  /*
*/ 9 "Not known" 
label values birstat lb_birstat

label define lb_biresus /* 
*/ 1 "Positive pressure nil, drugs nil" /*  
*/ 2 "Positive pressure nil, drugs administered" /* 
*/ 3 "Positive pressure by mask, drugs nil" /*  
*/ 4 "Positive pressure by mask, drugs administered" /*  
*/ 5 "Positive pressure by endotracheal tube, drugs nil" /*  
*/ 6 "Positive pressure by endotracheal tube, drugs administered" /*  
*/ 8 "Not applicable (e.g. stillborn, where no method of resuscitation was attempted)" /*
*/ 9 "Not known"
label values biresus lb_biresus

recode birweit (9999=-1) (0/9=10) (7001/9998=7000) // data dictionary specifies values betwee 10g and 6999g - HF to check whether this recoding is sensible - could also recode 0 to a not known value
label define lb_birweit /*
*/ 7000 "7000g or more" /* 601 between 7000 and 9998 
*/ 10 "10 g or less" /* 4378 with value 0; 97 between 1-9 ,
*/ -1 "Not known" // 784,420 have a value of 9999 indicating birthweight not known
label values birweit lb_birweit

encode delmeth, gen(delmeth_num)
recode delmeth_num (11=-1) (1=0) (2=1) (3=2) (4=3) (5=4) (6=5) (7=6) (8=7) (9=8) (10=9)
label define lb_delmeth /*
*/ 0 "Spontaneous vertex" /* (normal vaginal delivery, occipitoanterior)  
*/ 1 "Spontaneous other cephalic" /* (cephalic vaginal delivery with abnormal presentation of head at delivery, without instruments, with or without manipulation)  
*/ 2 "Low forceps, not breech" /* including forceps delivery not otherwise specified (forceps, low application, without manipulation)  
*/ 3 "Other forceps, not breech" /* including high forceps and mid forceps (forceps with manipulation)  
*/ 4 "Ventouse, vacuum extraction" /* 
*/ 5 "Breech, including partial breech extraction" /* (spontaneous delivery assisted or unspecified)  
*/ 6 "Breech" /*
*/ 7 "Elective caesarean section" /*
*/ 8 "Emergency caesarean section" /*
*/ 9 "Other" /*
*/ -1 "Not known"
label values delmeth_num lb_delmeth

label define lb_delonset /*
*/ 1 "Spontaneous" /* the onset of regular contractions whether or not preceded by spontaneous rupture of the membranes  
*/ 2 "Any caesarean section" /* carried out immediately following the onset of labour, when the decision was made before labour  
*/ 3 "Surgical induction by amniotomy" /*  
*/ 4 "Medical induction" /*, including the administration of agents either orally, intravenously or intravaginally with the intention of initiating labour  
*/ 5 "Combination of surgical induction and medical induction" /*  
*/ 8 "Not applicable" /*
*/ 9 "Not known: validation error" 
label values delonset lb_delonset

recode gestat (99=-1) (1/9=-2)  
label define lb_gestat /*
*/ -1 "Not known: a validation error" /* 934,498
*/ -2 "Gestational age less than 10 weeks" // 471 with gestational age below 10 weeks
label values gestat lb_gestat

recode numpreg (99=-1)
label define lb_numpreg -1 "Not known"
label values numpreg lb_numpreg

*hes maternity var cleaning
*Delonset: Method to iduce labour
lab var delonset  "Method used to induce (initiate) labour, rather than to accelerate it" 
lab define delonset 1 "Spontaneous" ///
2 "Any CS carried out immed following onset of labour, when decision made before labour" ///
3 "Surgical induction by amniotomy" ///
4 "Medical induction (orally/intravenously/intravaginally)" ///
5 "Combination of surgical and medical induction" ///
8 "Not applicable (from 1996-97 onwards)" ///
9 "Not known: validation error"
lab val delonset delonset

*Label variables
label variable patid "patient id"
label variable spno "Number uniquely identifying a hospitalisation"
label variable epikey "Episode key uniquely identifying an episode of care"
label variable epistart "Date of start of episode"
label variable epistart_num "Start date of episode of care (numeric)"
label variable epiend "Date of end of episode"
label variable epiend_num "Date of end of episode (numeric)"
label variable eorder "Order of episode within spell"
label variable epidur "Duration of episode in days"
label variable numbaby "Number of babies delivered at the end of a single pregnancy"
label variable numbaby_num "Number of babies delivered at the end of a single pregnancy (numeric)"
label variable numtailb "Number of baby tails"
label variable matordr "Order of birth"
label variable neocare "Neonatal level of care"
label variable anasdate "First antenatal assessment date"
label variable anasdate_num "First antenatal assessment date (numeric)"
label variable birordr "The position in the sequence of births"
label variable birordr_num "The position in the sequence of births (numeric)"
label variable birstat "Indicates whether the baby was born alive or dead (still birth)"
label variable biresus "Identifies resuscitation method used to get the baby breathing"
label variable sexbaby "Sex of baby"
label variable birweit "Weight of the baby in grams immediately after birth"
label variable delmeth "Method used to deliver a baby that is a registrable birth"
label variable delmeth_num "Method used to deliver a baby that is a registrable birth (numeric)"
label variable delonset "Method used to induce (initiate) labour, rather than to accelerate it"
label variable gestat "Length of gestation - number of completed weeks of gestation"
label variable numpreg "Number of previous pregnancies that resulted in a registered birth (live or still born)"
label variable antedur "Antenatal days of stay"
label variable postdur "Postnatal days of stay"

order patid* spno* epikey* epistart* epiend* eorder* epidur* numbaby* numtailb* matordr* neocare* anasdate* birordr* birstat* biresus* sexbaby* birweit* delmeth* delonset* gestat* numpreg* antedur* postdur*

compress

* Male
gen sexbaby_num=1 if sexbaby=="1"
* Female
replace sexbaby_num=2 if sexbaby=="2"

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\hes_maternity.dta", replace

***********************************************************************************
***********************************************************************************

* HES procedures

clear
import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\Linked_Data\Data Minimisation\hes_procedures_epi_20_145_part2_DM.txt"

* Generate numeric versions of date variables
gen epistart_num = date(epistart, "DMY")
gen admidate_num = date(admidate, "DMY")
gen evdate_num = date(evdate, "DMY")
format %td epistart_num admidate_num evdate_num

*Label variables
label variable patid "patient id"
label variable spno "Number uniquely identifying a hospitalisation"
label variable epikey "Episode key uniquely identifying an episode of care"
label variable admidate "Date of admission"
label variable admidate_num "Date of admission (numeric)"
label variable epistart "Date of start of episode"
label variable epistart_num "Start date of episode of care (numeric)"
label variable opcs "An OPCS 4 procedure code"
label variable evdate "Date of operation / procedure"
label variable evdate_num "Date of operation / procedure (numeric)"
label variable p_order "Ordering of OPCS code in episode, within range 1-24"

compress

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\hes_procedures.dta", replace



***********************************************************************************
***********************************************************************************

* HES diagnosis (episodes)

clear
import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\Linked_Data\Data Minimisation\hes_diagnosis_epi_20_145_part2_DM.txt"


* Generate numeric versions of date variables
gen epistart_num = date(epistart, "DMY")
format %td epistart_num

*Label variables
label variable patid "patient id"
label variable spno "Number uniquely identifying a hospitalisation"
label variable epikey "Episode key uniquely identifying an episode of care"
label variable epistart "Start date of episode of care"
label variable epistart_num "Start date of episode of care (numeric)"
label variable icd "An ICD10 diagnosis code in XXX or XXX.X format"
label variable icdx "5th/6th characters of the ICD code (if available)"
label variable d_order "Ordering of diagnosis code in episode"

compress

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\hes_diagnosis.dta", replace



***********************************************************************************
***********************************************************************************

* HES outpatient clinical 

clear
import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\Linked_Data\Data Minimisation\hesop_clinical_20_145_part2_DM.txt"

* Label variables
label variable patid "Patient id"
label variable attendkey "Record identifier (unique in combination with patid)"
label variable diag_01 "Primary diagnosis"
label variable diag_02 "Secondary diagnosis"
label variable diag_03 "Secondary diagnosis"
label variable diag_04 "Secondary diagnosis"
label variable diag_05 "Secondary diagnosis"
label variable diag_06 "Secondary diagnosis"
label variable diag_07 "Secondary diagnosis"
label variable diag_08 "Secondary diagnosis"
label variable diag_09 "Secondary diagnosis"
label variable diag_10 "Secondary diagnosis"
label variable diag_11 "Secondary diagnosis"
label variable diag_12 "Secondary diagnosis"
label variable opertn_01 "Main (i.e. most resource intensive) operation"
label variable opertn_02 "Secondary operation/procedure"
label variable opertn_03 "Secondary operation/procedure"
label variable opertn_04 "Secondary operation/procedure"
label variable opertn_05 "Secondary operation/procedure"
label variable opertn_06 "Secondary operation/procedure"
label variable opertn_07 "Secondary operation/procedure"
label variable opertn_08 "Secondary operation/procedure"
label variable opertn_09 "Secondary operation/procedure"
label variable opertn_10 "Secondary operation/procedure"
label variable opertn_11 "Secondary operation/procedure"
label variable opertn_12 "Secondary operation/procedure"
label variable opertn_13 "Secondary operation/procedure"
label variable opertn_14 "Secondary operation/procedure"
label variable opertn_15 "Secondary operation/procedure"
label variable opertn_16 "Secondary operation/procedure"
label variable opertn_17 "Secondary operation/procedure"
label variable opertn_18 "Secondary operation/procedure"
label variable opertn_19 "Secondary operation/procedure"
label variable opertn_20 "Secondary operation/procedure"
label variable opertn_21 "Secondary operation/procedure"
label variable opertn_22 "Secondary operation/procedure"
label variable opertn_23 "Secondary operation/procedure"
label variable opertn_24 "Secondary operation/procedure"
label variable operstat "Operation status code" 
label variable tretspef "Treatment speciality" 
label variable mainspef "Main speciality"


* format variables
replace tretspef = "999" if tretspef==""
replace tretspef = "1000" if tretspef=="&"
destring tretspef, replace
label define lb_tretspef /*
*/ 100   "General Surgery Service" /*
*/ 101   "Urology Service" /*
*/ 102   "Transplant Surgery Service (From 1 April 2004)" /*
*/ 103   "Breast Surgery Service (From 1 April 2004)" /*
*/ 104   "Colorectal Surgery Service (From 1 April 2004)" /*
*/ 105   "Hepatobiliary and Pancreatic Surgery Service (From 1 April 2004)"  /*
*/ 106   "Upper Gastrointestinal Surgery Service (From 1 April 2004)"  /*
*/ 107   "Vascular Surgery Service (From 1 April 2004)" /*
*/ 108   "Spinal Surgery Service (From April 2013)" /*
*/ 109   "Bariatric Surgery Service (From 1 April 2021)" /*
*/ 110   "Trauma and Orthopaedic Service" /*
*/ 111   "Orthopaedic Service (From 1 April 2021)" /*
*/ 113   "Endocrine Surgery Service (From 1 April 2021)" /*
*/ 115   "Trauma Surgery Service (From 1 April 2021)" /*
*/ 120   "Ear Nose and Throat Service" /*
*/ 130   "Ophthalmology Service" /*
*/ 140   "Oral Surgery Service" /*
*/ 141   "Restorative Dentistry Service" /*
*/ 142   "Paediatric Dentistry Service (From 1999-2000)" /*
*/ 143   "Orthodontic Service" /*
*/ 144   "Maxillofacial Surgery Service (From 1 April 2004)" /*
*/ 145   "Oral and Maxillofacial Surgery Service (From 1 April 2021)" /*
*/ 150   "Neurosurgical Service" /*
*/ 160   "Plastic Surgery Service" /*
*/ 161   "Burns Care Service (From 1 April 2004)" /* 
*/ 170   "Cardiothoracic Surgery Service" /*
*/ 171   "Paediatric Surgery Service" /*
*/ 172   "Cardiac Surgery Service (From 1 April 2004)" /*
*/ 173   "Thoracic Surgery Service (From 1 April 2004)" /*
*/ 174   "Cardiothoracic Transplantation Service (From 1 April 2004)" /* 
*/ 180   "Emergency Medicine Service" /*
*/ 190   "Anaesthetic Service" /*
*/ 191   "Pain Management Service (From 1998-99)" /*
*/ 192   "Intensive Care Medicine Service (From 1 April 2004)" /*
*/ 200   "Aviation and Space Medicine Service (From 1 April 2021)" /*
*/ 211   "Paediatric Urology Service (From 2006-07)" /*
*/ 212   "Paediatric Transplantation Surgery Service (From 2006-07)" /*
*/ 213   "Paediatric Gastrointestinal Surgery Service (From 2006-07)" /*
*/ 214   "Paediatric Trauma and Orthopaedic Service (From 2006-07)" /*
*/ 215   "Paediatric Ear Nose and Throat Service (From 2006-07)" /*
*/ 216   "Paediatric Ophthalmology Service (From 2006-07)" /*
*/ 217   "Paediatric Oral and Maxillofacial Surgery Service (From 2006-07)" /*
*/ 218   "Paediatric Neurosurgery Service (From 2006-07)" /*
*/ 219   "Paediatric Plastic Surgery Service (From 2006-07)" /*
*/ 220   "Paediatric Burns Care Service (From 2006-07)" /*
*/ 221   "Paediatric Cardiac Surgery Service (From 2006-07)" /*
*/ 222   "Paediatric Thoracic Surgery Service (From 2006-07)" /*
*/ 223   "Paediatric Epilepsy Service (From April 2013)" /*
*/ 230   "Paediatric Clinical Pharmacology Service (From 1 April 2021)" /*
*/ 240   "Paediatric Palliative Medicine Service (From 1 April 2021)" /*
*/ 241   "Paediatric Pain Management Service (From 2006-07)" /*
*/ 242   "Paediatric Intensive Care Service (From 2006-07)" /*
*/ 250   "Paediatric Hepatology Service (From 1 April 2021)" /*
*/ 251   "Paediatric Gastroenterology Service (From 2006-07)" /* 
*/ 252   "Paediatric Endocrinology Service (From 2006-07)" /*
*/ 253   "Paediatric Clinical Haematology Service (From 2006-07)" /*
*/ 254   "Paediatric Audio Vestibular Medicine Service (From 2006-07)" /*
*/ 255   "Paediatric Clinical Immunology and Allergy Service (From 2006-07)" /*
*/ 256   "Paediatric Infectious Diseases Service (From 2006-07)" /*
*/ 257   "Paediatric Dermatology Service (From 2006-07)" /*
*/ 258   "Paediatric Respiratory Medicine Service (From 2006-07)" /*
*/ 259   "Paediatric Nephrology Service (From 2006-07)" /*
*/ 260   "Paediatric Medical Oncology Service (From 2006-07)" /*
*/ 261   "Paediatric Inherited Metabolic Medicine Service (From 2006-07)" /*
*/ 262   "Paediatric Rheumatology Service (From 2006-07)" /*
*/ 263   "Paediatric Diabetes Service (From 1 April 2004)" /*
*/ 264   "Paediatric Cystic Fibrosis Service (From 1 April 2004)" /*
*/ 270   "Paediatric Emergency Medicine Service (From 1 April 2021)" /*
*/ 280   "Paediatric Interventional Radiology Service (From 2006-07)" /*
*/ 290   "Community Paediatric Service (From 2006-07)" /*
*/ 291   "Paediatric Neurodisability Service (From 2006-07)" /*
*/ 300   "General Internal Medicine Service" /*
*/ 301   "Gastroenterology Service" /*
*/ 302   "Endocrinology Service" /*
*/ 303   "Clinical Haematology Service" /*
*/ 304   "Clinical Physiology Service (From 2008-09)" /*
*/ 305   "Clinical Pharmacology Service" /*
*/ 306   "Hepatology Service (From 1 April 2004)" /*
*/ 307   "Diabetes Service (From 1 April 2004)" /*
*/ 308   "Blood and Marrow Transplantation Service (From 1 April 2004)" /*
*/ 309   "Haemophilia Service (From 1 April 2004)" /*
*/ 310   "Audio Vestibular Medicine Service" /*
*/ 311   "Clinical Genetics Service" /*
*/ 313   "Clinical Immunology and Allergy Service (From 1991-92)" /*
*/ 314   "Rehabilitation Medicine Service (From 1991-92)" /*
*/ 315   "Palliative Medicine Service" /*
*/ 316   "Clinical Immunology Service (From 1 April 2004)" /*
*/ 317   "Allergy Service (From 1 April 2004)" /*
*/ 318   "Intermediate Care Service (From 1 April 2004)" /*
*/ 319   "Respite Care Service (From 1 April 2004)" /*
*/ 320   "Cardiology Service" /*
*/ 321   "Paediatric Cardiology Service (From 1 April 2004)" /*
*/ 322   "Clinical Microbiology Service (From 1 April 2004)" /*
*/ 323   "Spinal Injuries Service (From 2006-07)" /*
*/ 324   "Anticoagulant Service (From 1 April 2004)" /*
*/ 325   "Sport and Exercise Medicine Service (From 1 April 2004)" /*
*/ 326   "Acute Internal Medicine Service (From 1 April 2021)" /*
*/ 327   "Cardiac Rehabilitation Service (From 1 April 2004)" /*
*/ 328   "Stroke Medicine Service (From 1 April 2004)" /*
*/ 329   "Transient Ischaemic Attack Service (From 1 April 2004)" /*
*/ 330   "Dermatology Service" /*
*/ 331   "Congenital Heart Disease Service (From April 2013)" /*
*/ 333   "Rare Disease Service (From 1 April 2021)" /*
*/ 335   "Inherited Metabolic Medicine Service (From 1 April 2021)" /*
*/ 340   "Respiratory Medicine Service" /*
*/ 341   "Respiratory Physiology Service (From 1 April 2004)" /*
*/ 342   "Pulmonary Rehabilitation Service (From 1 April 2004)" /*
*/ 343   "Adult Cystic Fibrosis Service (From 1 April 2004)" /*
*/ 344   "Complex Specialised Rehabilitation Service (From April 2013)" /*
*/ 345   "Specialist Rehabilitation Service (From April 2013)" /*
*/ 346   "Local Specialist Rehabilitation Service (From April 2013)" /*
*/ 347   "Sleep Medicine Service (From 1 April 2021)" /*
*/ 348   "Post-COVID-19 Syndrome Service (From 1 April 2021)" /*
*/ 350   "Infectious Diseases Service" /*
*/ 352   "Tropical Medicine Service (From 1 April 2004)" /*
*/ 360   "Genitourinary Medicine Service" /*
*/ 361   "Renal Medicine Service" /*
*/ 370   "Medical Oncology Service" /*
*/ 371   "Nuclear Medicine Service (From 2008-09)" /*
*/ 400   "Neurology Service" /*
*/ 401   "Clinical Neurophysiology Service (From 2008-09)" /*
*/ 410   "Rheumatology Service" /*
*/ 420   "Paediatric Service" /*
*/ 421   "Paediatric Neurology Service" /*
*/ 422   "Neonatal Critical Care Service (From 1 April 2004)" /*
*/ 424   "Well Baby Service (From 1 April 2004)" /*
*/ 430   "Elderly Medicine Service" /*
*/ 431   "Orthogeriatric Medicine Service (From 1 April 2021)" /*
*/ 450   "Dental Medicine Service (From 1990-91)" /*
*/ 451   "Special Care Dentistry Service (From 1 April 2021)" /*
*/ 460   "Medical Ophthalmology Service (From 1993-94)" /*
*/ 461   "Ophthalmic and Vision Science Service (From 1 April 2021)" /*
*/ 501   "Obstetrics Service" /*
*/ 502   "Gynaecology Service" /*
*/ 503   "Gynaecological Oncology Service (From 1 April 2004)" /*
*/ 504   "Community Sexual and Reproductive Health Service (From 1 April 2021)" /*
*/ 505   "Fetal Medicine Service (From 1 April 2021)" /*
*/ 560   "Midwifery Service (From October 1995)" /*
*/ 650   "Physiotherapy Service (From 2006-07)" /*
*/ 651   "Occupational Therapy Service (From 2006-07)" /*
*/ 652   "Speech and Language Therapy Service (From 2006-07)" /*
*/ 653   "Podiatry Service (From 2006-07)" /*
*/ 654   "Dietetics Service (From 2006-07)" /*
*/ 655   "Orthoptics Service (From 2006-07)" /*
*/ 656   "Clinical Psychology Service (From 2006-07)" /*
*/ 657   "Prosthetics Service (From 1 April 2004)" /*
*/ 658   "Orthotics Service (From 1 April 2004)" /*
*/ 659   "Dramatherapy Service (From 1 April 2004)" /*
*/ 660   "Art Therapy Service (From 1 April 2004)" /*
*/ 661   "Music Therapy Service (From 1 April 2004)" /*
*/ 662   "Optometry Service (From 1 April 2004)" /*
*/ 663   "Podiatric Surgery Service (From April 2013)" /*
*/ 670   "Urological Physiology Service (From 1 April 2021)" /*
*/ 673   "Vascular Physiology Service (From 1 April 2021)" /*
*/ 675   "Cardiac Physiology Service (From 1 April 2021)" /*
*/ 677   "Gastrointestinal Physiology Service (From 1 April 2021)" /*
*/ 700   "Learning Disability Service" /*
*/ 710   "Adult Mental Health Service" /*
*/ 711   "Child and Adolescent Psychiatry Service" /*
*/ 712   "Forensic Psychiatry Service" /*
*/ 713   "Medical Psychotherapy Service" /*
*/ 715   "Old Age Psychiatry Service (From 1990-91)" /*
*/ 720   "Eating Disorders Service (From 2006-07)" /*
*/ 721   "Addiction Service (From 2006-07)" /*
*/ 722   "Liaison Psychiatry Service (From 2006-07)" /*
*/ 723   "Psychiatric Intensive Care Service (From 2006-07)" /*
*/ 724   "Perinatal Mental Health Service (From 2006-07)" /*
*/ 725   "Mental Health Recovery and Rehabilitation Service (From April 2013)" /*
*/ 726   "Mental Health Dual Diagnosis Service (From April 2013)" /*
*/ 727   "Dementia Assessment Service (From April 2013)" /*
*/ 730   "Neuropsychiatry Service (From 1 April 2021)" /*
*/ 800   "Clinical Oncology Service" /*
*/ 811   "Interventional Radiology Service (From 1 April 2004)" /*
*/ 812   "Diagnostic Imaging Service (From 2008-09)" /*
*/ 822   "Chemical Pathology Service" /*
*/ 834   "Medical Virology Service (From 1 April 2004)" /*
*/ 840   "Audiology Service (From 2008-09)" /*
*/ 920   "Diabetic Education Service (From April 2013)" /*
*/ 999   "Other Maternity Event" /*
*/ 1000  "Not known"
label values tretspef lb_tretspef

replace mainspef = "999" if mainspef==""
replace mainspef = "1000" if mainspef=="&"
destring mainspef, replace
label define lb_mainspef /*
*/ 100  "General Surgery" /*
*/ 101  "Urology" /*
*/ 107  "Vascular Surgery (Introduced 1 April 2021)" /*
*/ 110  "Trauma and Orthopaedics" /*
*/ 120  "Ear Nose and Throat" /*
*/ 130  "Ophthalmology" /*
*/ 140  "Oral Surgery" /*
*/ 141  "Restorative Dentistry" /* 
*/ 142  "Paediatric Dentistry" /*
*/ 143  "Orthodontics" /*
*/ 145  "Oral and Maxillofacial Surgery" /*
*/ 146  "Endodontics" /*
*/ 147  "Periodontics" /*
*/ 148  "Prosthodontics" /*
*/ 149  "Surgical Dentistry" /*
*/ 150  "Neurosurgery" /*
*/ 160  "Plastic Surgery" /*
*/ 170  "Cardiothoracic Surgery" /*
*/ 171  "Paediatric Surgery" /*
*/ 191  "Pain Management (Retired 1 April 2004)" /*
*/ 180  "Emergency Medicine" /*
*/ 190  "Anaesthetics" /*
*/ 192  "Intensive Care Medicine" /*
*/ 200  "Aviation and Space Medicine (Introduced 1 April 2021)" /*
*/ 300  "General Internal Medicine" /*
*/ 301  "Gastroenterology" /*
*/ 302  "Endocrinology and Diabetes" /*
*/ 303  "Clinical Haematology" /*
*/ 304  "Clinical Physiology" /*
*/ 305  "Clinical Pharmacology" /*
*/ 310  "Audio Vestibular Medicine" /*
*/ 311  "Clinical Genetics" /*
*/ 312  "Clinical Cytogenetics and Molecular Genetics (Retired 1 April 2010). National Code 312 is retained for consultants qualified in this Main Specialty prior to 1 April 2010" /*
*/ 313  "Clinical Immunology" /*
*/ 314  "Rehabilitation Medicine" /*
*/ 315  "Palliative Medicine" /*
*/ 317  "Allergy (Introduced 1 April 2021)" /*
*/ 320  "Cardiology" /*
*/ 321  "Paediatric Cardiology" /*
*/ 325  "Sport and Exercise Medicine" /*
*/ 326  "Acute Internal Medicine" /*
*/ 330  "Dermatology" /*
*/ 340  "Respiratory Medicine" /*
*/ 350  "Infectious Diseases" /*
*/ 352  "Tropical Medicine" /*
*/ 360  "Genitourinary Medicine" /*
*/ 361  "Renal Medicine" /*
*/ 370  "Medical Oncology" /*
*/ 371  "Nuclear Medicine" /*
*/ 400  "Neurology" /*
*/ 401  "Clinical Neurophysiology" /*
*/ 410  "Rheumatology" /*
*/ 420  "Paediatrics" /*
*/ 421  "Paediatric Neurology" /*
*/ 430  "Geriatric Medicine" /*
*/ 450  "Dental Medicine" /*
*/ 451  "Special Care Dentistry" /*
*/ 501  "Obstetrics" /*
*/ 502  "Gynaecology" /*
*/ 504  "Community Sexual and Reproductive Health" /*
*/ 510  "Antenatal Clinic (Retired 1 April 2004)" /*
*/ 520  "Postnatal Clinic (Retired 1 April 2004)" /*
*/ 560  "Midwifery" /*
*/ 600  "General Medical Practice" /*
*/ 601  "General Dental Practice" /*
*/ 610  "Maternity Function (Retired 1 April 2004)" /*
*/ 620  "Other than Maternity (Retired 1 April 2004)" /*
*/ 700  "Learning Disability" /*
*/ 710  "Adult Mental Illness" /*
*/ 711  "Child and Adolescent Psychiatry" /*
*/ 712  "Forensic Psychiatry" /*
*/ 713  "Medical Psychotherapy" /*
*/ 715  "Old Age Psychiatry" /*
*/ 800  "Clinical Oncology" /*
*/ 810  "Radiology" /*
*/ 820  "General Pathology" /*
*/ 821  "Blood Transfusion" /*
*/ 822  "Chemical Pathology" /*
*/ 823  "Haematology" /*
*/ 824  "Histopathology" /*
*/ 830  "Immunopathology" /*
*/ 831  "Medical Microbiology and Virology" /*
*/ 832  "Neuropathology (Retired 1 April 2004)" /*
*/ 833  "Medical Microbiology" /*
*/ 834  "Medical Virology" /*
*/ 900  "Community Medicine" /*
*/ 901  "Occupational Medicine" /*
*/ 902  "Community Health Services Dental" /*
*/ 903  "Public Health Medicine" /*
*/ 904  "Public Health Dental" /*
*/ 950  "Nursing" /*
*/ 960  "Allied Health Professional" /*
*/ 990  "Joint Consultant Clinics (Retired 1 April 2004)" /*
*/ 199  "Non-UK Provider - Specialty Function Not Known, Treatment Mainly Surgical" /*
*/ 460  "Medical Ophthalmology" /*
*/ 499  "Non-UK Provider - Specialty Function Not Known, Treatment Mainly Medical" /*
*/ 999  "Other Maternity Event" /*
*/ 1000 "Not Known" 
label values mainspef lb_mainspef 

compress

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\hesop_clinical.dta", replace


***********************************************************************************
***********************************************************************************

* HES outpatient appointment 

clear
import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\Linked_Data\Data Minimisation\hesop_appointment_20_145_part2_DM.txt"


* Generate numeric versions of date variables
gen apptdate_num = date(apptdate, "DMY")
format %td apptdate_num 

* Label variables
label variable patid "Patient id"
label variable attendkey "Record identifier (unique in combination with patid)"
label variable ethnos "Ethnic category as recorded at appointment"
label variable apptdate "Appointment date"
label variable apptdate_num "Appointment date (numeric)"
*label variable attended "Attended or did not attend"
/*
* format variable 
label define lb_attended /*
*/ 2 "Appointment cancelled by, or on behalf of, the patient" /*
*/ 3 "Did not attend - no advance warning given"  /*
*/ 4 "Appointment cancelled or postponed by the Health Care Provider" /* 
*/ 5 "Seen, having attended on time or, if late, before the relevant care professional was ready to see the patient"  /*
*/ 6 "Arrived late, after the relevant care professional was ready to see the patient, but was seen" /*
*/ 7 "Did not attend - patient arrived late and could not be seen" /*
*/ 9 "Not known"
label values attended lb_attended
*/

compress

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\hesop_appointment.dta", replace



***********************************************************************************
***********************************************************************************

* HES episodes

clear
import delimited "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data\Linked_Data\Data Minimisation\hes_episodes_20_145_part2_DM.txt", clear

	
* Generate numeric versions of date variables
gen epistart_num = date(epistart, "DMY")
gen epiend_num = date(epiend, "DMY")
gen discharged_num = date(discharged, "DMY")
gen admidate_num = date(admidate, "DMY")
format %td epistart_num epiend_num discharged_num admidate_num
drop epistart epiend discharged admidate

save "\\ads.bris.ac.uk\filestore\HealthSci SafeHaven\CPRD Projects UOB\Projects\20_145\Data Analysis\Kate\Stata data\hes_episodes.dta", replace











