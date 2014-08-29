require_relative 'load_helper'
require_relative 'test_helper'

require 'clinical_tcga/ClinicalMetadata'

class TestClinicalMetadata < MiniTest::Test  
  #
  # test for TCGA_TEST_DATA env variable
  #
  def test_env_variable()
    assert(!ENV['TCGA_CLINICAL_TEST_DATA'].nil?, 
           "env variable TCGA_CLINICAL_TEST_DATA is not present, all subsequent tests will fail")
  end
  #
  # test arbitrary row that is ambiguous
  #
  def test_sample_row_ambiguous_example()    
    clinFile = "#{ENV['TCGA_CLINICAL_TEST_DATA']}/Biotab/nationwidechildrens.org_clinical_follow_up_v1.0_coad.txt"
    assert(File.exists?(clinFile), "test data file not found")
    
    cm = ClinicalTCGA::ClinicalMetadata.new(clinFile)
    row = cm.getSampleRowAmbiguous("TCGA-D5-6539")
    
    assert_equal(row["bcr_followup_barcode"], "TCGA-D5-6539-F28922")
    assert_equal(row["last_contact_days_to"].to_i, 380)
  end
  #
  # test an arbitrary row
  #
  def test_row()
    clinFile = "#{ENV['TCGA_CLINICAL_TEST_DATA']}/Biotab/nationwidechildrens.org_biospecimen_slide_coad.txt"
    assert(File.exists?(clinFile), "test data file not found")
    
    cm = ClinicalTCGA::ClinicalMetadata.new(clinFile)
    row = cm.getSampleRow("TCGA-4N-A93T-01A")
    
    assert_equal(row["percent_tumor_nuclei"].to_i, 75)
    assert_equal(row["percent_neutrophil_infiltration"].to_i, 4)
  end
  #
  # test retrieving a sample by UUID
  #
  def test_uuid_row()
    uuid_str = "9258D514-40C1-480A-8FA8-D4E8B3819BDE"
    clinFile = "#{ENV['TCGA_CLINICAL_TEST_DATA']}/Biotab/nationwidechildrens.org_biospecimen_slide_coad.txt"
    assert(File.exists?(clinFile), "test data file not found")
    
    cm = ClinicalTCGA::ClinicalMetadata.new(clinFile)
    row = cm.getSampleRowFromUUID(uuid_str)
    
    assert_equal(row["percent_tumor_nuclei"].to_i, 75)
    assert_equal(row["percent_neutrophil_infiltration"].to_i, 4)
  end
  #
  # test getting the header of a metadata file
  #
  def test_header()
    clinFile = "#{ENV['TCGA_CLINICAL_TEST_DATA']}/Biotab/nationwidechildrens.org_biospecimen_slide_coad.txt"
    assert(File.exists?(clinFile), "test data file not found")

    cm = ClinicalTCGA::ClinicalMetadata.new(clinFile)
    exp_header_lst = ["bcr_sample_barcode", "bcr_slide_barcode", "bcr_slide_uuid", "is_derived_from_ffpe", "percent_lymphocyte_infiltration", "percent_monocyte_infiltration", "percent_necrosis", "percent_neutrophil_infiltration", "percent_normal_cells", "percent_stromal_cells", "percent_tumor_cells", "percent_tumor_nuclei", "section_location"]
    assert_equal(cm.getHeader, exp_header_lst, "header differs from expected")
  end
  
end
