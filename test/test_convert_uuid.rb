require_relative 'load_helper'
require_relative 'test_helper'

require 'tempfile'
require 'open3'
require 'clinical_tcga'

class TestConvertUUID < MiniTest::Test
  #
  # test single UUID to sample conversion
  #
  def test_uuid1()
    retval = ClinicalTCGA::ConvertUUIDToBarcode.getBarcode("7c6a70e0-7fde-4b96-ab1c-fdca98839089")
    assert_equal("TCGA-AG-A008-01A-01R-A002-07", retval)
  end
  #
  # second test, should return nil
  #
  def test_uuid2()
    retval2 = ClinicalTCGA::ConvertUUIDToBarcode.getBarcode("7c6a70e0-7fde-4b96-ab1c-fdca98839088")
    assert_nil(retval2)
  end
  #
  # test command line utility to retrieve sample ids
  #
  def test_conversion_cli()
    t = Tempfile.new("test_uuids")
    t.puts "7c6a70e0-7fde-4b96-ab1c-fdca98839089"
    t.puts "7c6a70e0-7fde-4b96-ab1c-fdca98839089"
    t.close
    outlines,stderr,pip = Open3.capture3("#{File.dirname(__FILE__)}/../bin/convert_tcga_uuid.rb -f #{t.path}")

    exp_ary = [["7c6a70e0-7fde-4b96-ab1c-fdca98839089","TCGA-AG-A008-01A-01R-A002-07"],
               ["7c6a70e0-7fde-4b96-ab1c-fdca98839089","TCGA-AG-A008-01A-01R-A002-07"]]
    outary = outlines.split("\n")
    
    (0..outary.size-1).each{|i| assert_equal(exp_ary[i].join("\t"), outary[i]) }
  end
  
end
