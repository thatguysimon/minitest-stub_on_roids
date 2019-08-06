require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/minitest/test*.rb']
end

desc "Run tests"
task :default => :test