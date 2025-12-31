===============================================================================
README.txt: Folder, File, and Data Processing Description
===============================================================================
This directory is in service of Table 4e, which extends the analysis of Table 4
from Nathaniel Baum-Snow's "Did Highways Cause Suburbanization?". At the time
of writing, Table 4e includes two new regressions, ordinary least squares (OLS)
and instrumental variables (IV). The following are general descriptions of
the contents.
-------------------------------------------------------------------------------
table4e_vars.do, table4e_vars.dta, table4e_vars.log
-------------------------------------------------------------------------------
At the heart of Table 4e is the central do file, table4e_vars.do. It
calculates and consolidates the variables used in the new regressions into a
new dataset, table4e_vars.dta. This is used in table4e.do, which runs the
original regressions from Table 4, in addition to the new regressions. Included
is the log file for the operation.
-------------------------------------------------------------------------------
Econ 413W (IGNORE)
-------------------------------------------------------------------------------
This folder and its contents are not needed for the analysis as described above
but are related to a separate project. While the folder should be have already
been removed, if it is still present, it can be safely removed.