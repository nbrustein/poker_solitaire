#!/usr/bin/env rake
 
require 'rake/testtask'
 
Dir.glob(File.expand_path("../lib/tasks/**/*.rake", __FILE__)).each { |f| load(f) } 
 
Rake::TestTask.new do |t|
  t.libs << 'lib/poker_solitaire'
  t.test_files = FileList['test/poker_solitaire/**/*_test.rb']
  t.verbose = true
end
 
task :default => :test