# -*- encoding: utf-8 -*-
# stub: angularjs-rails 1.4.7 ruby lib

Gem::Specification.new do |s|
  s.name = "angularjs-rails"
  s.version = "1.4.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Hirav Gandhi"]
  s.date = "2015-10-01"
  s.description = "Injects Angular.js into your asset pipeline as well as other Angular modules."
  s.email = "hgandhi@alumni.stanford.edu"
  s.homepage = "https://github.com/hiravgandhi/angularjs-rails/"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Angular.js on Rails"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<versionomy>, [">= 0"])
      s.add_development_dependency(%q<nokogiri>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<versionomy>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<versionomy>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
  end
end
