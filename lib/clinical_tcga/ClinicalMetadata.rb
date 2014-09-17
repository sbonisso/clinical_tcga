
require 'clinical_tcga/ConvertUUIDToBarcode.rb'

class String
  def numeric?
    Float(self) != nil rescue false
  end
end

class Array
  # 
  # computes mean with minimal error/type checking (ie-must have ALL numerics)
  #
  def mean()
    n = self.size.to_f
    (0..self.size-1).inject(0) do |m,i| 
      raise TypeError, "\"#{self[i]}\" is not a number!" if !self[i].is_a?(Numeric)
      m += self[i]/n
    end
  end
end

module ClinicalTCGA
  #
  # class to represent clinical data (patient,followup,etc) from TCGA
  #
  class ClinicalMetadata

    include ConvertUUIDToBarcode

    def initialize(mdFile)
      @mdFilePath = mdFile
      lines = IO.readlines(mdFile)
      @header1 = lines[0].chomp.split("\t")
      @header2 = lines[1].chomp.split("\t")
      @header = @header1[1..@header1.size]
      @mat = lines[2..lines.size].map{|l| l.chomp.split("\t")}
      # create hash of hashes, {sampleID => {colName => val} }
      @h = @mat.inject({}) do |h,ary|
        tmpH = (1..ary.size).inject({}){|tH,i| tH.merge( @header1[i] => ary[i] )}
        h.merge( ary[0] => tmpH )
      end
      @barcodeLen = @h.keys[3].split("-").size
    end
    #
    # returns the top header of the metadata file
    #
    def getHeader() @header1 end
    #
    # returns the second header, sometimes differs in description from top header
    #
    def getSecondHeader() @header2 end
    #
    # return entire row of a sample as a hash 
    #
    def getSampleRow(sampleID) 
      @h.has_key?(sampleID) ? @h[sampleID] : nil
    end
    #
    #
    #
    def getSampleRowAmbiguous(sampleID)
      if !@h.has_key?(sampleID)
        # get all keys that are  superstrings of sampleID
        selK = @h.keys.select{|k| k.include?(sampleID)}
        tmpH = Hash.new
        return nil if selK.empty?
        @header.each do |vk|
          vals = selK.map{|sK| @h[sK][vk]}
          
          selVal = if vals[0].numeric? then
                     vals.map{|v| v.to_f}.mean 
                   else
                     vals[0]
                   end
          tmpH[vk] = selVal
        end
        tmpH
      else 
        @h[sampleID]
      end
      
    end
    #
    # return only a single value of a sample's row - inefficient if 
    # you want to extract multiple values for each sample
    #
    def getSampleValue(sampleID, colName)
      if @h.has_key?(sampleID) then
        if @h[sampleID].has_key?(colName) then
          @h[sampleID][colName]
        else
          nil
        end
      else
        nil
      end
    end
    #
    # query based on UUID of sample, generalizing the sampleID to the patient barcode
    # much slower since uses ConvertUUIDToBarcode module which uses CURL
    #
    def getSampleRowFromUUID(uuidStr)
      sampleID = ConvertUUIDToBarcode.getBarcode(uuidStr)
      return nil if sampleID.nil?
      
      truncSampleID = sampleID.split("-")[0..@barcodeLen-1].join("-")
      self.getSampleRow(truncSampleID)
    end
    #
    # query based on UUID of sample, generalizing the sampleID to the patient barcode
    #
    def getSampleValueFromUUID(uuidStr, colName)
      sampleID = ConvertUUIDToBarcode.getBarcode(uuidStr)
      return nil if sampleID.nil?
      
      truncSampleID = sampleID.split("-")[0..@barcodeLen-1].join("-")
      self.getSampleValue(truncSampleID, colName)
    end

  end

end
