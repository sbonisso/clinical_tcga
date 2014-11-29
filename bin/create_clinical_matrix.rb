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
  opt.banner = "Usage: [OPTIONS]"
  opt.separator  ""
  opt.separator  "Options"

  opt.on("-s", "--samples FILE", "file containing sample IDs (required)") do |sampleF|
      options[:samples] = sampleF
  end

  opt.on("-f", "--features FILE", "file containing clinical features to extract (required)") do |featureF|
      options[:features] = featureF
  end

  opt.on("-d", "--database FILE", "path to database (required)") do |databasePath|
      options[:database] = databasePath
  end
  
  opt.on("-o","--output FILE","output the matrix of samples and features (required)") do |outFile|
    options[:output] = outFile
  end
  
  opt.on("-h","--help","help") do
    puts optparse
  end  
end
optparse.parse!
#
# check have minimal arguments
if !options.has_key?(:samples) || 
    !options.has_key?(:features) || 
    !options.has_key?(:database) ||
    !options.has_key?(:output) then
  puts optparse   # print help
  Process.exit(0)
end

sample_file = options[:samples]
feature_file = options[:features]
path_to_data = options[:database]
output_file = options[:output]
path_to_data += "/" if (path_to_data[-1] != "/")

sample_ids = IO.readlines(sample_file).map{|l| l.chomp}
feature_v = IO.readlines(feature_file).map{|l| l.chomp}

#
# init with samples, and desired features
rs = ClinicalTCGA::RetrieveSamples.new(sample_ids, 
                                       feature_v, 
                                       false)
#
# add all sources
#
rs.add_all_sources(path_to_data)
#
# get features for each sample, output to csv
#
CSV.open(output_file, 'w') do |csv|
  csv << ["sample", feature_v].flatten
  i = 0
  
  ProgressBar.new("matrix creation", sample_ids.size) do |pbar|
    
    rs.get_feature_vector do |sample,fV| 
      csv << [sample, fV].flatten
      i+=1
    end
    
    pbar.inc
  end
end
