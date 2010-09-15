require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "dm-events"
    gem.summary = %Q{DataMapper plugin to handle recurring events.}
    gem.description = %Q{DataMapper plugin to handle recurring events.}
    gem.email = "asher.vanbrunt@gmail.com"
    gem.homepage = "http://github.com/okbreathe/dm-events"
    gem.authors = ["Asher Van Brunt"]
    gem.add_development_dependency "shoulda", ">=2.10.3"
    gem.add_dependency('dm-core', '>= 1.0.0')
    gem.add_dependency('dm-types', '>= 1.0.0')
    gem.add_dependency('dm-is-tree', '>= 1.0.0')
    gem.add_dependency('dm-constraints', '>= 1.0.0')
    gem.add_dependency('activesupport', '>= 3.0.0')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "dm-events #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
