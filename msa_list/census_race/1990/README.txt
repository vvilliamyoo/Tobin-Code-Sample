===============================================================================
README.txt: Folder, File, and Data Processing Description
===============================================================================
-------------------------------------------------------------------------------
census_1990.url, cph-s-1-1.pdf
-------------------------------------------------------------------------------
Data is sourced from "census_1990.url" and saved as "cph-s-1-1.pdf". The PDF
can also be found on
"https://usa.ipums.org/usa/voliii/pubdocs/1990/pubvols1990.shtml" under the
section "1990 CENSUS OF POPULATION AND HOUSING (CPH PUBLICATION SERIES)",
subsection "CPH-S-1-1: Metropolitan Areas as Defined by the Office of
Management and Budget, June 30, 1993 - Section 1".

-------------------------------------------------------------------------------
data_pages_1990.pdf
-------------------------------------------------------------------------------
Using an online utility (ilovepdf.com), "cph-s-1-1.pdf" was split to only
include the relevant pages [75-124] and saved as "data_pages_1990.pdf" (tool:
Split PDF -> Split by range).

NOTE: At the time of writing, this step is necessary -- and desirable. Without
the premium version, the tool cannot perform the PDF to Excel conversion for
PDFs of more than 500 pages; "cph-s-1-1.pdf" is 714 pages. Even so, this step
is desirable because "cph-s-1-1.pdf" contains data extraneous to the project.

-------------------------------------------------------------------------------
edited_race_1990.xlsx
-------------------------------------------------------------------------------
The same online utility was used to extract data from "data_pages_1990.pdf"
(tool: PDF to Excel). These data are saved as "edited_race_1990.xlsx".

The spreadsheet contains manual edits to correct conversion errors and to 
simplify later processing. The edits are listed below in order of operation.

() Odd-numbered sheets are removed: they do not contain data.

() Extraneous variables are removed: Black - Percent; Hispanic - Percent;
Persons in households; Persons in group quarters.

() Sheets containing data on Puerto Rico are removed.

() Text wrapping errors are fixed: Some place names did not fit the cell
width of the original document and were put on new lines. When converting to
a spreadsheet, text was wrapped into a new cell.
 
() Observations are corrected for decimal separator formatting errors:
There are two types of errors in the XLSX file, both concerning the decimal
separator (it is unclear if they follow some pattern). A fix for both errors
are provided with examples where needed. The following number will be used
for demonstration: 2005073 (2,005,073). Pipes ("|") denote cells and cell
divisions.

 - One type of error uses two spaces instead of a comma or period as the
decimal separator for each number in each cell:

	|2  005  073|

A fix for this error is to simply highlight all observations (numbers) and use
the Find and Replace tool in Excel to replace all instances of two spaces with
no spaces (i.e., leave the second text field blank):

	|2005073|

 - The second error also concerns the decimal separator, however, instead of
two spaces, this error separates decimals by putting numbers in adjacent
columns (NOTE: this error does not preserve leading zeros; the true value of
"5" is 5,000 but is instead entered as 5):

	|2|5|73|

A fix for this error takes four steps.

First, convert all observations to text, forcing a three-number format
(command: =TEXT(value, "000")). This format is crucial as it introduces leading
zeros, which is necessary to preserve the full number later:

	|002|005|073|

Second, concatenate relevant observations
(command: =CONCAT(value, value, value)):

	|002005073|

Third, copy all concatenate observations and paste them as values. After
pasting, there should be a warning icon in the top left of the section of
pasted values. This "Number Stored as Text" warning is a direct result of the
first step. Click on this warning and select the "Convert to Number" option:

	|2005073|

Lastly, delete all other observations and ensure the headings are valid for
the newly-formatted observations.

() Shapes introduced by the conversion are removed (optional): shapes are at
the bottom of each sheet in the XLSX file. They can simply be clicked on and
deleted.

-------------------------------------------------------------------------------
concatenate.py, final_race_1990.csv
-------------------------------------------------------------------------------
"concatenate.py" combines the data scattered across multiple sheets within
"edited_race_1990.xlsx" into a CSV for better processing in Stata. For the
Python file to run properly, libraries must be installed using the following
command: 

	pip install pandas openpyxl

Running the Python file outputs "final_race_1990.csv".

The first row of the CSV should be renamed for compatability with Stata. The
name for the total population variable should not be "total" as it may 
conflict with a Stata function.
