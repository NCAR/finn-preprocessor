## Use without notebook

For automated execution of code, `*.py` codes are available which does something similar to `work_generic/main_generic.ipynb` 

* work_raster.py<br />
Grab global raster for MODIS LCT and VCF and import into database

* work_nrt.py<br />
Process AF into burened area and land characterized text file, to be processed further by emission model.

* work_clean.py<br />
Clean insermediates files from system, intermediate tables from database.

* work_common.py<br />
Above two code shares some common metadata/functinalities, and they are put into here

`work_nrt/` directory has sample bash script to use these files
