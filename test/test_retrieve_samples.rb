require_relative 'load_helper'
require_relative 'test_helper'

require 'clinical_tcga'

class TestRetrieveSamples < MiniTest::Test  
  #
  # test adding a single source
  #
  def test_add_sample()
    rs = ClinicalTCGA::RetrieveSamples.new(["TCGA-A6-2671"], ["death_days_to"], false)
    followup = "#{ENV['TCGA_CLINICAL_TEST_DATA']}/Biotab/nationwidechildrens.org_clinical_follow_up_v1.0_coad.txt"
    rs.add_tcga_source(followup)    
   
    assert_equal(rs.h.keys.size, 1)
  end
  #
  # test adding all sources from a dir
  #
  def test_add_dir()
    dirpath = "#{ENV['TCGA_CLINICAL_TEST_DATA']}/Biotab/"
    rs = ClinicalTCGA::RetrieveSamples.new(["TCGA-A6-2671"], ["death_days_to"], false)
    rs.add_all_sources(dirpath)

    assert_equal(rs.h.keys.size, 18)
    assert(rs.h.has_key?("biospecimen_sample"))
  end
  #
  # test retrieving data
  # 
  def test_get_feature1()
    rs = ClinicalTCGA::RetrieveSamples.new(["TCGA-A6-2671"], ["death_days_to"], false)
    followup = "#{ENV['TCGA_CLINICAL_TEST_DATA']}/Biotab/nationwidechildrens.org_clinical_follow_up_v1.0_coad.txt"
    rs.add_tcga_source(followup)    

    assert_equal( rs.get_feature("clinical_follow_up_v1.0", "death_days_to"), "1331", "unexpected result for death_days_to")
  end  
  #
  # test recreating a small matrix of [samples x features]
  #
  def test_get_feature_vect()
    rs = ClinicalTCGA::RetrieveSamples.new(["TCGA-A6-2671","TCGA-A6-2672"], 
                                           ["vital_status", "death_days_to","percent_tumor_nuclei"], 
                                           false)
    followup = "#{ENV['TCGA_CLINICAL_TEST_DATA']}/Biotab/nationwidechildrens.org_clinical_follow_up_v1.0_coad.txt"
    tumor_sample = "#{ENV['TCGA_CLINICAL_TEST_DATA']}/Biotab/nationwidechildrens.org_biospecimen_slide_coad.txt"
    rs.add_tcga_source(followup)
    rs.add_tcga_source(tumor_sample)
    
    h = Hash.new
    rs.get_feature_vector do |sample,fV|
      h[sample] = fV
    end

    assert_equal(h["TCGA-A6-2671"], ["Dead", "1331", 35.0], "returned unexpected result for TCGA-A6-2671")
    assert_equal(h["TCGA-A6-2672"], ["Alive", "[Not Available]", 40.0], "returned unexpected result for TCGA-A6-2672")
  end  
  #
  # create a larger feature set to test
  #
  def test_get_larger_feature_vect()
    feature_v = ["percent_normal_cells", 
                 "percent_stromal_cells", 
                 "percent_tumor_cells",
                 "percent_lymphocyte_infiltration",
                 "vital_status",
                 "death_days_to",
                 "last_contact_days_to", 
                 "tumor_status",
                 "ajcc_tumor_pathologic_pt",
                 "ajcc_nodes_pathologic_pn", 
                 "ajcc_metastasis_pathologic_pm", 
                 "ajcc_pathologic_tumor_stage"
                ]
    
    rs = ClinicalTCGA::RetrieveSamples.new(["TCGA-QG-A5YW", "TCGA-A6-2676"],
                                           feature_v,
                                           false)
    rs.add_all_sources("#{ENV['TCGA_CLINICAL_TEST_DATA']}/Biotab/")
    
    h = Hash.new
    rs.get_feature_vector{|sample,fV| h[sample] = fV}
    
    assert_equal(h["TCGA-QG-A5YW"][0], 10.0, "not expected value at index 0")
    assert_equal(h["TCGA-A6-2676"][0], 2.5, "not expected value at index 0")
    assert_equal(h["TCGA-QG-A5YW"][-2],nil, "not expected value at index -2")
    assert_equal(h["TCGA-A6-2676"][-2],"M0", "not expected value at index -2")
  end
  
end
