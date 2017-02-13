Final Project Dataset Creation
==============================

#### SOC 4650/5650: Intro to GIS

#### Christopher Prener, PhD

#### 12 Feb 2017

### Description

This do-file creates an initial dataset from the raw Citizens' Service
bureau data for dissemination to students for the final project.

### Dependencies

This do-file was written and executed using Stata 14.2.

It also uses the latest
[MarkDoc](https://github.com/haghish/markdoc/wiki) package via GitHub as
well as the latest versions of its dependencies:

          . version 14

          . which markdoc
          /Users/herb/Library/Application Support/Stata/ado/plus/m/markdoc.ado

          . which weave
          /Users/herb/Library/Application Support/Stata/ado/plus/w/weave.ado

          . which statax
          /Users/herb/Library/Application Support/Stata/ado/plus/s/statax.ado

### Import/Open Data

          . local rawData "requests.csv"

          . import delimited `rawData', varnames(1)
          (16 vars, 827,745 obs)

The original data in `requests.csv` were downloaded from the City of St.
Louis [public datasets
website](http://data.stlouis-mo.gov/downloads.cfm) by Chris on 12 Feb
2017. They were manually exported from their original data format - a
Microsoft Access database - into `.xlsx`. These data were then manually
exported again into the `.csv` file format since Excel files have a
maximum file size of 40MB for Stata import.

### Remove 2008 and 2016 Data

The original data contain two incomplete years, 2008 and 2016. These
need to be dropped both to simplify the dataset and trim the filesize.

          . generate reqDate = date(datetimeinit, "MD20Y")

          . generate reqYear = year(reqDate)

          . drop if reqYear == 2008 | reqYear == 2016
          (20,288 observations deleted)

          . drop reqDate

This code converts the string formatted dates - mm/dd/yy - to the Stata
date format, which eases processing. The year is then extracted and the
years 2008 and 2016 are removed. The Stata formatted date variable is
then dropped because it is no longer needed.

### Remove Variables

GitHub has a maximum file size of 100MB. The file as its stands is too
large to store there.

          . drop probaddtype submitto datetimeclosed datecancelled callertype

The address type, city agency the request was submitted to, the closure
date, the cancellation date, and the caller type are all dropped to trim
the file size down.

### Drop Observations with Requests for City Permits

There are n=18350 permit application records filed through the CSB.
These are not included since they are not reports of problems but rather
requests for assistance that are redirected to other City agencies.

          . drop if strpos(problemcode, "PmtApp")
          (21,102 observations deleted)

This command uses a string function `strpos()` that allows you to
identify literal text within a variable.

### Shorten Several Addresses

There are a number of addresses that are not well formed and contain
excess information.

          . replace probaddress = "" if requestid == 627902
          (1 real change made)

          . replace probaddress = "1129 St. Charles St" if requestid == 504264
          (0 real changes made)

          . replace probaddress = "4990 Childrens Pl" if requestid == 567950
          (1 real change made)

          . replace probaddress = "1101 N 2nd St" if requestid == 517977
          (0 real changes made)

          . replace probaddress = "205 S Vandeventer Ave" if requestid == 518483
          (0 real changes made)

          . replace probaddress = "" if requestid == 639985
          (1 real change made)

For four of these requests, the exceess information is replaced only
with a street address. For two of them, the address information is
replaced altogether.

### Save and Export Clean Data

          . compress
            variable reqYear was float now int
            variable probaddress was str100 now str74
            (22,017,940 bytes saved)

          . save "DataClean/`projName'.dta", replace
          (note: file DataClean/csbCreate.dta not found)
          file DataClean/csbCreate.dta saved

          . export delimited "DataClean/`projName'.csv", replace
          (note: file DataClean/csbCreate.csv not found)
          file DataClean/csbCreate.csv saved
