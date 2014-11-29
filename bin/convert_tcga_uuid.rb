#!/usr/bin/env ruby

#
# given a list of samples, features, and database, create matrix of:
#   [sample, clinical_features]
#
# ex: ./create_clinical_matrix.rb sample_list.txt feature_list.txt path/to/clinical/data/ output_file.csv
#
require 'clinical_tcga'
require 'csv'
require 'progressbar'
require 'optparse'

options = {}
optparse = OptionParser.new do |opt|
  opt.banner = "Usage: [UUID] [OPTIONS]"
  opt.separator  ""
  opt.separator  "Options"

  opt.on("-f", "--file_uuids FILE", "file containing multiple UUIDs to convert") do |fileF|
      options[:file] = fileF
  end

  opt.on("-o","--output FILE","output the UUID,sample ID to specified file") do |outFile|
    options[:output] = outFile
  end
  
  opt.on("-h","--help","help") do
    puts optparse
  end  
end
optparse.parse!
#
# basic checking
#
if options.size == 0 && ARGV.size == 0 then
  puts "must provide UUID as argument or a file with -f flag"
  puts optparse
  Process.exit(0)
end
#
# if given a file with multiple inputs
#
if options.has_key?(:file) then
  lst = []
  IO.foreach(options[:file]) do |line|
    next if line.match(/^(\s*)\#/) # skip if comment line with '#'
    uuid = line.chomp
    barcode_id = ClinicalTCGA::ConvertUUIDToBarcode.getBarcode(uuid)
    lst.push([uuid,barcode_id])
  end
  #
  # if specified file to output, write to that, otherwise STDOUT
  if options.has_key?(:output) then
    File.open(options[:output],"w") do |f| 
      lst.each{|ary| f.puts ary.join("\t")}
    end
  else
    lst.each{|ary| puts ary.join("\t")}
  end
else # if one option
  barcode_id = ClinicalTCGA::ConvertUUIDToBarcode.getBarcode(ARGV[0])
  puts barcode_id
end
