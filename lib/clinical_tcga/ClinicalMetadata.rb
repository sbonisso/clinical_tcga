#!/usr/bin/env ruby


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
      #puts [sampleID, !@h.has_key?(sampleID)].join("\t")
      if !@h.has_key?(sampleID)
        # get all keys that are  superstrings of sampleID
        selK = @h.keys.select{|k| k.include?(sampleID)}
        tmpH = Hash.new
        #puts "SELK\t#{selK.to_s}"
        return nil if selK.empty?
        #puts @h[selK[0]].keys.to_s
        # puts @header.to_s
        # @h[selK[0]].keys.each do |vk| 
        @header.each do |vk|
          #selK.each{|sK| puts [":::", sK, @h[sK].to_s].join("\t")}
          vals = selK.map{|sK| @h[sK][vk]}
          #puts [vk, vals.to_s].join("\t")
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

      #truncSampleID = sampleID.split("-")[0..2].join("-")
      truncSampleID = sampleID.split("-")[0..@barcodeLen-1].join("-")
      self.getSampleRow(truncSampleID)
    end
    #
    # query based on UUID of sample, generalizing the sampleID to the patient barcode
    #
    def getSampleValueFromUUID(uuidStr, colName)
      sampleID = ConvertUUIDToBarcode.getBarcode(uuidStr)
      return nil if sampleID.nil?
      
      #truncSampleID = sampleID.split("-")[0..2].join("-")
      truncSampleID = sampleID.split("-")[0..@barcodeLen-1].join("-")
      self.getSampleValue(truncSampleID, colName)
    end

  end

end

# test out on known entity
if __FILE__ == $0 then
  
  
  #clinFile = "Clinical_READ/Biotab/nationwidechildrens.org_clinical_patient_read.txt"
  #clinFile = "Clinical_READ/Biotab/nationwidechildrens.org_clinical_follow_up_v1.0_read.txt"
  #clinFile = "Clinical_COAD/Biotab/nationwidechildrens.org_clinical_follow_up_v1.0_coad.txt"
  clinFile = "Clinical_COAD/Biotab/nationwidechildrens.org_biospecimen_slide_coad.txt"
  cm = ClinicalMetadata.new(clinFile)
  #
  puts cm.getSampleValueFromUUID("7c6a70e0-7fde-4b96-ab1c-fdca98839089", "histologic_diagnosis")
  # puts cm.getSampleValueFromUUID("7c6a70e0-7fde-4b96-ab1c-fdca98839089", "tumor_status")
  # puts cm.getSampleValueFromUUID("1dc3f8d9-c9fd-4178-a0d1-520fcf2a5ebe", "tumor_status")
  # puts cm.getSampleValueFromUUID("28904a18-b1fc-4d2f-8cd5-3f7ff759dac1", "tumor_status")
  # puts cm.getSampleValue("TCGA-AA-3521", "histologic_diagnosis")
  #puts cm.getSampleRowFromUUID("7c6a70e0-7fde-4b96-ab1c-fdca98839089").to_s
  #puts cm.getSampleRow("TCGA-D5-6539")
  puts cm.getSampleRowAmbiguous("TCGA-D5-6539")
  
end
