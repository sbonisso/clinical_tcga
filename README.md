clinical_tcga
=============

Library for parsing metadata files from TCGA.

###### Examples

Two files are required as input: a file containing *n* sample IDs, another containing the *m* clinical features to extract; and the database (local) to use. An output file is also required to be defined. The database should be the tab-delimited files.

```
create_clinical_matrix.rb -s samples.txt -f features.txt -d /path/to/db/Biotab/ -o outfile.csv
```

the file outfile_mat.txt will contain an *n* x *m* matrix of each feature within each sample for simpler parsing and analysis. If 

Also included is a conversion tool for UUIDs to barcode IDs. A single UUID can be converted as such:

```
convert_tcga_uuid.rb sample_uuid
```

or multiple UUIDs can be converted at once when given as a file:

```
convert_tcga_uuid.rb -f file.txt
```

please note, any ID conversion requires internet access as a curl request to the TCGA servers is used to obtain the converted ID.

###### Setup
Due to the nature of TCGA data, test data is not included. The environment variable TCGA_CLINICAL_TEST_DATA can be set to point to the test data (COAD) should the user download it.

All of the metadata for COAD can be downloaded, and the environment variable points to the top-level directory. A subdirectory called "Biotab" is expected to contain the txt files.


###### Dependencies
* curb
* progressbar
* minitest
* minitest-reporters
