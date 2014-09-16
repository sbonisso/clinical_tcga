
require 'progressbar'
require 'clinical_tcga/ClinicalMetadata'

module ClinicalTCGA
  #
  # class to retrieve desired metadata properties given a list of samples, and the features to collect
  #
  class RetrieveSamples

    def initialize(sampleLst, featureLst, are_uuids=false)
      @h = Hash.new
      @sampleLst = sampleLst
      @featureLst = featureLst
      @feature_h = Hash.new
    end
    #
    # add a txt file TCGA clinical data source
    #
    def add_tcga_source(filepath)
      m = filepath.match(/(biospecimen|clinical)\_(.*)\_(\w+)\.txt$/)
      return nil if m.nil?
      name = [m[1], m[2]].join("_")
      @h[name] = ClinicalMetadata.new(filepath)
      headerAry = @h[name].getHeader
      headerAry.each{|fstr| @feature_h.has_key?(fstr) ? @feature_h[fstr].push(name) : @feature_h[fstr] = [name] }
    end
    #
    # given a directory, add all .txt files
    #
    def add_all_sources(dirpath)
      file_list = Dir.glob("#{dirpath}*.txt")
      ProgressBar.new("load files", file_list.size) do |pbar|
        file_list.each do |f|
          self.add_tcga_source(f)
          pbar.inc
        end
      end
      # Dir.glob("#{dirpath}*.txt").each do |f|
      #   self.add_tcga_source(f)
      # end
    end
    #
    # given a feature, return the hash it's in
    #
    def feature_lookup(feature)
      raise "#{feature} does not exist" if !@feature_h.has_key?(feature) 
      return nil if @feature_h[feature].nil?
      @feature_h[feature][0] 
    end
    #
    #
    #
    def get_feature_vector()
      @sampleLst.each do |sample|
        flst = Array.new(@featureLst.size, nil)
        @featureLst.each_with_index do |f,i| 
          next if !flst[i].nil?  # skip if already filled
          hn = feature_lookup(f)
          r = @h[hn].getSampleRowAmbiguous(sample)
          #r = @h[hn].getSampleRow(sample)
          #r.nil? ? nil : r[f]
          #fL[i] = r[f]
          next if r.nil?  # skip if couldn't find sample or feature
          @featureLst.each_with_index{|local_f,j| flst[j] = r[local_f] if r.has_key?(local_f) && flst[j].nil?}
        end
        yield [sample, flst]
      end
    end
    #
    # get single feature from a row - inefficient, used mainly for testing
    #
    def get_feature(file_name, feature_name)
      row = @h[file_name].getSampleRow(@sampleLst[0])
      row[feature_name]
    end
    
    attr_accessor :h
  end

end
