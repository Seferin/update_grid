update_grid

Functions in R and Python to ensure that the latest release of GRID is available
locally in a specified folder. GRID in this context refers to the Global
Research Identifier Database from Digital Science. The homepage of GRID can be
found here:

  https://grid.ac/

  
The update_grid functions:

  (1) Accepts a path_data parameter for a local folder location in the form 
  "./data/". The folder will be created if it does not exist.
  (2) Check the figshare API for details of the latest GRID release.
  (3) Check whether the target folder for a log file indicating the latest
  release.
  (4.a) If it does, the function confirms that the latest release is already
  available and exits without further action.
  (4.b) Otherwise, the latest release is downloaded and unzipped in the target
  folder; a log file record is created and the downloaded zip file is removed.


R library dependencies:
  base, curl, jsonlite

Tested:
  R version 4.0.3 (2020-10-10)
  Platform: x86_64-w64-mingw32/x64 (64-bit)
  Running under: Windows 10 x64 (build 14393)
  curl_4.3
  jsonlite_1.7.2 


Python package dependencies:
  requests, json, pandas, zipfile, os

Tested:
  Python 3.8.5
  requests 2.24.0
  pandas 1.1.3
  json 2.0.9
