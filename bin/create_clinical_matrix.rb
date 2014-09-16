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

if ARGV.size != 4 then
  puts "USAGE #{__FILE__} sample_list.txt feature_list.txt path/to/clinical/data/ output_file.csv"
  Process.exit(0)
end

sample_file, feature_file, path_to_data, output_file = ARGV

sample_ids = IO.readlines(sample_file).map{|l| l.chomp}
feature_v = IO.readlines(feature_file).map{|l| l.chomp}

puts sample_ids.to_s
puts feature_v.to_s
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
