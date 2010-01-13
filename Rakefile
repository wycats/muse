$:.unshift File.join(File.dirname(__FILE__), 'lib')
require "./vendor/gems/environment"
require "muse"

spec = Gem::Specification.new do |s|
  s.name    = "muse"
  s.version = Muse::VERSION
  s.authors = ["Yehuda Katz"]
  s.email   = ["wycats@gmail.com"]
  s.homepage = "http://github.com/wycats/muse"
  s.description = s.summary = "A package for producing printed books from formatted plain text"

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["LICENSE"]

  s.required_rubygems_version = ">= 1.3.5"

  s.require_path = 'lib'
  s.files = %w(LICENSE) + Dir.glob("lib/**/*")
end

file 'muse.specification' do
  File.open('./muse.specification', "w") do |file|
    file.puts spec.to_ruby
  end
end

task :package => 'muse.specification' do
  system "gem build muse.specification"
end

begin
  require 'spec/rake/spectask'
rescue LoadError
  task(:spec) { $stderr.puts '`gem install rspec` to run specs' }
else
  desc "Run specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = %w(-cfs --require ./spec/spec_helper)
    t.warning = true
  end
end

task :default => :spec