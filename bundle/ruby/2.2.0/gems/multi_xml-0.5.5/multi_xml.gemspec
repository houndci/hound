# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multi_xml/version'

Gem::Specification.new do |spec|
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.author = "Erik Michaels-Ober"
  spec.cert_chain = ['certs/sferik.pem']
  spec.description = %q{Provides swappable XML backends utilizing LibXML, Nokogiri, Ox, or REXML.}
  spec.email = 'sferik@gmail.com'
  spec.files = %w(.yardopts CHANGELOG.md CONTRIBUTING.md LICENSE.md README.md Rakefile multi_xml.gemspec)
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("spec/**/*")
  spec.homepage = 'https://github.com/sferik/multi_xml'
  spec.licenses = ['MIT']
  spec.name = 'multi_xml'
  spec.require_paths = ['lib']
  spec.required_rubygems_version = '>= 1.3.5'
  spec.signing_key = File.expand_path("~/.gem/private_key.pem") if $0 =~ /gem\z/
  spec.summary = %q{A generic swappable back-end for XML parsing}
  spec.test_files = Dir.glob("spec/**/*")
  spec.version = MultiXml::VERSION
end
