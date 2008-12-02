require 'spec/rake/spectask'

desc 'run all specs (default)'
task :default => :spec

desc 'report all specs'
Spec::Rake::SpecTask.new(:report) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['-f', 's', '-c']
end

desc'run all specs'
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['-c']
end
