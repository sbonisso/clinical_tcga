Gem::Specification.new do |s|
s.name = 'clinical_tcga'
s.version = '0.0.1'
s.date = '2014-08-27'
s.summary = "TCGA clinical data parser"
s.description = "A gem to help parse clinical TCGA data"
s.authors = ["Stefano R.B."]
s.email = 'sbonisso@ucsd.edu'
s.files = Dir['lib/**/*.rb'] 
s.require_paths = ['lib', 'ext']
s.homepage = 'https://github.com/sbonisso/clinical_tcga'
s.license = 'MIT'
s.add_dependency 'progressbar'
end