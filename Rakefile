require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "ruby-shapefile"
  gem.homepage = "http://github.com/toastbrot/ruby-shapefile"
  gem.license = "MIT"
  gem.summary = %Q{shapefile (.shp) parser written in pure ruby}
  gem.description = %Q{Pure ruby parser for .shp shapefiles and .dbf attribute files.\nSupported shapes: NullShape, Point, MultiPoint, PolyLine and Polygon.}
  gem.email = "marc@dietrichstein.net"
  gem.authors = ["Marc Dietrichstein"]
  
  #gem.add_runtime_dependency 'dbf', '> 1.5.0'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ruby-shapefile #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
