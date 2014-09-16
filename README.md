clinical_tcga
=============

Library for parsing clinical metadata files from TCGA

###### Setup
Due to the nature of TCGA data, test data is not included. The enviroment variable TCGA_CLINICAL_TEST_DATA can be set to point to the test data should the user be able to download it.

All of the metadata for COAD can be downloaded, and the environment variable points to the top-level directory. A subdirectory called "Biotab" is expected to contain the txt files.


###### Dependencies
* curb
* progressbar
* minitest
* minitest-reporters
