require_relative 'load_helper'
require_relative 'test_helper'

require 'clinical_tcga'

class TestConvertUUID < MiniTest::Test
  #
  # test single UUID to sample conversion
  #
  def test_uuid1()
    retval = ConvertUUIDToBarcode.getBarcode("7c6a70e0-7fde-4b96-ab1c-fdca98839089")
    assert_equal(retval, "TCGA-AG-A008-01A-01R-A002-07")
  end
  #
  # second test, should return nil
  #
  def test_uuid2()
    retval2 = ConvertUUIDToBarcode.getBarcode("7c6a70e0-7fde-4b96-ab1c-fdca98839088")
    assert_nil(retval2)
  end

  
end
