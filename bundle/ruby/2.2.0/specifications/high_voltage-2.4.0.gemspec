# -*- encoding: utf-8 -*-
# stub: high_voltage 2.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "high_voltage"
  s.version = "2.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Matt Jankowski", "Dan Croak", "Nick Quaranto", "Chad Pytel", "Joe Ferris", "J. Edward Dewyea", "Tammer Saleh", "Mike Burns", "Tristan Dunn"]
  s.date = "2015-07-17"
  s.description = "Fire in the disco. Fire in the ... taco bell."
  s.email = ["support@thoughtbot.com"]
  s.homepage = "http://github.com/thoughtbot/high_voltage"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Simple static page rendering controller"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<activesupport>, [">= 3.1.0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 3.2.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.1.0"])
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<rspec-rails>, ["~> 3.2.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.1.0"])
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<rspec-rails>, ["~> 3.2.0"])
  end
end
