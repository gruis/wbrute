require File.expand_path("../lib/wbrute/version", __FILE__)
require "rubygems"
::Gem::Specification.new do |s|
  s.name                      = "wbrute"
  s.version                   = Wbrute::VERSION
  s.platform                  = ::Gem::Platform::RUBY
  s.authors                   = ['Caleb Crane']
  s.email                     = ['wbrute@simulacre.org']
  s.homepage                  = 'http://github.com/simulacre/wbrute'
  s.summary                   = 'Brute Force HTTP[s] Server Directories'
  s.description               = ''
  s.required_rubygems_version = ">= 1.3.6"
  s.files                     = Dir["lib/**/*.rb", "bin/*", "*.md"]
  s.require_paths             = ['lib']
  s.executables               = Dir["bin/*"].map{|f| f.split("/")[-1] }
  s.license                   = 'MIT'

  s.add_dependency 'http'
end
