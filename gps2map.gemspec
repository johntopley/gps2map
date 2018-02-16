# frozen_string_literal: true

require 'date'

require_relative 'lib/gps2map/version'

Gem::Specification.new do |s|
  s.name        = 'gps2map'
  s.version     = GPS2Map::VERSION
  s.date        = Date.today.to_s
  s.summary     = 'Creates a Google Map from an input file'
  s.description = <<~DESC
    Creates a Google Map from an input file containing GPS co-ordinates (GPX, KML or TCX format).
  DESC
  s.authors     = ['John Topley']
  s.files       = ['README.md']
  s.email       = 'john@johntopley.com'
  s.executables = 'gps2map'
  s.files      += Dir['lib/**/*.rb', 'lib/**/*.erb']
  s.homepage    = 'https://github.com/johntopley/gps2map'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.5.0'

  s.add_runtime_dependency 'nokogiri', '~> 1.8.0'
  s.add_runtime_dependency 'thor', '~> 0.20.0'
  s.add_development_dependency 'bundler', '~> 1.16'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rubocop', '~> 0.49.1'
end
