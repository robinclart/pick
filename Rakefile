require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

desc "Runs tests"
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

desc "Runs RuboCop"
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options << "-a"
  task.options << "--no-color"
  task.fail_on_error = false
end

Rake::Task[:test].enhance(["rubocop"])

task default: :test
