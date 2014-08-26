#!/usr/bin/env ruby

#
# module to convert a given UUID to a Barcode
# as shown at: https://wiki.nci.nih.gov/display/TCGA/TCGA+Barcode+to+UUID+Web+Service+User%27s+Guide
#

require 'json'
require 'net/http'
require 'curb'

module ConvertUUIDToBarcode

  def ConvertUUIDToBarcode.getBarcode(uuidStr)
    url = 'https://tcga-data.nci.nih.gov/uuid/uuidws/mapping/json/uuid/'+"#{uuidStr}"
    http = Curl.get(url)
    my_hash = JSON.parse(http.body_str)
    my_hash.has_key?('barcode') ? my_hash['barcode'] : nil
  end
  
end


if __FILE__ == $0 then
  
  puts ConvertUUIDToBarcode.getBarcode(ARGV[0])
  
end
