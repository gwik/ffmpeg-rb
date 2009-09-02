require 'rubygems'
require 'hoe'
require 'spec'
require 'spec/rake/spectask'

Hoe.plugin :git
Hoe.plugin :email

Hoe.spec 'ffmpeg' do
  developer 'Eric Hodel', 'drbrain@segment7.net'
  developer 'Antonin Amand', 'antonin.amand@gmail.com'
end

namespace :spec do
  desc "Print Specdoc for all specs"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_opts = ["--format", "specdoc", "--dry-run"]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.libs << 'lib' << 'spec'
  end

  desc "run specs, specify TEST_FILE environment variable"
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_files = FileList["spec/**/*_spec.rb"]
    t.libs << 'lib' << 'spec'
  end
end
