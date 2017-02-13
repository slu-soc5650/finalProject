// ==========================================================================

// SOC 4650/5650 FINAL PROJECT DATA CREATION

// ==========================================================================

// define project name

local projName "csbCreate"

// ==========================================================================

// standard opening options

log close _all
graph drop _all
clear all
set more off
set linesize 80

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// construct directory structure for tabular data

capture mkdir "CodeArchive"
capture mkdir "DataClean"
capture mkdir "DataRaw"
capture mkdir "LogFile"
capture mkdir "Output"

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// create permanent text-based log file
log using "LogFile/`projName'.txt", replace text name(permLog)

// create temporary smcl log file for MarkDoc
quietly log using "LogFile/`projName'.smcl", replace smcl name(tempLog)

// ==========================================================================
// ==========================================================================
// ==========================================================================

/***
# Final Project Dataset Creation
#### SOC 4650/5650: Intro to GIS
#### Christopher Prener, PhD
#### 12 Feb 2017

### Description
This do-file creates an initial dataset from the raw Citizens' Service
bureau data for dissemination to students for the final project.

### Dependencies
This do-file was written and executed using Stata 14.2.

It also uses the latest [MarkDoc](https://github.com/haghish/markdoc/wiki)
package via GitHub as well as the latest versions of its dependencies:
***/

version 14
which markdoc
which weave
which statax

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/***
### Import/Open Data
***/

local rawData "requests.csv"
import delimited `rawData', varnames(1)

/***
The original data in `requests.csv` were downloaded from the City of St.
Louis [public datasets website](http://data.stlouis-mo.gov/downloads.cfm)
by Chris on 12 Feb 2017. They were manually exported from their original
data format - a Microsoft Access database - into `.xlsx`. These data
were then manually exported again into the `.csv` file format since Excel
files have a maximum file size of 40MB for Stata import.

### Remove 2008 and 2016 Data
The original data contain two incomplete years, 2008 and 2016. These need
to be dropped both to simplify the dataset and trim the filesize.
***/

generate reqDate = date(datetimeinit, "MD20Y")
generate reqYear = year(reqDate)
drop if reqYear == 2008 | reqYear == 2016
drop reqDate

/***
This code converts the string formatted dates - mm/dd/yy - to the Stata
date format, which eases processing. The year is then extracted and the
years 2008 and 2016 are removed. The Stata formatted date variable is
then dropped because it is no longer needed.

### Remove Variables
GitHub has a maximum file size of 100MB. The file as its stands is too
large to store there.
***/

drop probaddtype submitto datetimeclosed datecancelled callertype

/***
The address type, city agency the request was submitted to, the closure
date, the cancellation date, and the caller type are all dropped to trim
the file size down.

### Drop Observations with Requests for City Permits
There are n=18350 permit application records filed through the CSB. These
are not included since they are not reports of problems but rather
requests for assistance that are redirected to other City agencies.
***/

drop if strpos(problemcode, "PmtApp")

/***
This command uses a string function `strpos()` that allows you to identify
literal text within a variable.

### Shorten Several Addresses
There are a number of addresses that are not well formed and contain 
excess information.
***/

replace probaddress = "" if requestid == 627902

replace probaddress = "1129 St. Charles St" if requestid == 504264

replace probaddress = "4990 Childrens Pl" if requestid == 567950

replace probaddress = "1101 N 2nd St" if requestid == 517977

replace probaddress = "205 S Vandeventer Ave" if requestid == 518483

replace probaddress = "" if requestid == 639985

/***
For four of these requests, the exceess  information is replaced only 
with a street address. For two of them, the address information is 
replaced altogether.
***/


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/***
### Save and Export Clean Data
***/

compress
save "DataClean/`projName'.dta", replace
export delimited "DataClean/`projName'.csv", replace

// ==========================================================================
// ==========================================================================
// ==========================================================================

// end MarkDoc log

/*
quietly log close tempLog
*/

// convert MarkDoc log to Markdown

markdoc "LogFile/`projName'", replace export(md)
copy "LogFile/`projName'.md" "Output/`projName'.md", replace
shell rm -R "LogFile/`projName'.md"
shell rm -R "LogFile/`projName'.smcl"

// ==========================================================================

// archive code and raw data

copy "`projName'.do" "CodeArchive/`projName'.do", replace
copy "`rawData'" "DataRaw/`rawData'", replace

// ==========================================================================

// standard closing options

log close _all
graph drop _all
set more on

// ==========================================================================

exit
