# -*- encoding: utf-8 -*-
# stub: shoulda-matchers 3.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "shoulda-matchers"
  s.version = "3.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Tammer Saleh", "Joe Ferris", "Ryan McGeary", "Dan Croak", "Matt Jankowski", "Stafford Brunk", "Elliot Winkler"]
  s.date = "2015-10-01"
  s.description = "Making tests easy on the fingers and eyes"
  s.email = "support@thoughtbot.com"
  s.homepage = "http://thoughtbot.com/community/"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.rubygems_version = "2.4.8"
  s.summary = "Making tests easy on the fingers and eyes"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 4.0.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 4.0.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 4.0.0"])
  end
end
