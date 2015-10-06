# -*- encoding: utf-8 -*-
# stub: html2haml 2.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "html2haml"
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Norman Clarke", "Stefan Natchev"]
  s.date = "2015-01-19"
  s.description = "Converts HTML into Haml"
  s.email = ["norman@njclarke.com", "stefan.natchev@gmail.com"]
  s.executables = ["html2haml"]
  s.files = ["bin/html2haml"]
  s.homepage = "http://haml.info"
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.rubygems_version = "2.4.8"
  s.summary = "Converts HTML into Haml"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.6.0"])
      s.add_runtime_dependency(%q<erubis>, ["~> 2.7.0"])
      s.add_runtime_dependency(%q<ruby_parser>, ["~> 3.5"])
      s.add_runtime_dependency(%q<haml>, ["~> 4.0.0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.7.1"])
      s.add_development_dependency(%q<minitest>, ["~> 4.4.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, ["~> 1.6.0"])
      s.add_dependency(%q<erubis>, ["~> 2.7.0"])
      s.add_dependency(%q<ruby_parser>, ["~> 3.5"])
      s.add_dependency(%q<haml>, ["~> 4.0.0"])
      s.add_dependency(%q<simplecov>, ["~> 0.7.1"])
      s.add_dependency(%q<minitest>, ["~> 4.4.0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, ["~> 1.6.0"])
    s.add_dependency(%q<erubis>, ["~> 2.7.0"])
    s.add_dependency(%q<ruby_parser>, ["~> 3.5"])
    s.add_dependency(%q<haml>, ["~> 4.0.0"])
    s.add_dependency(%q<simplecov>, ["~> 0.7.1"])
    s.add_dependency(%q<minitest>, ["~> 4.4.0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
