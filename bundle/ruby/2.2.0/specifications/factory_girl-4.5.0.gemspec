# -*- encoding: utf-8 -*-
# stub: factory_girl 4.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "factory_girl"
  s.version = "4.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Josh Clayton", "Joe Ferris"]
  s.date = "2014-10-17"
  s.description = "factory_girl provides a framework and DSL for defining and\n                      using factories - less error-prone, more explicit, and\n                      all-around easier to work with than fixtures."
  s.email = ["jclayton@thoughtbot.com", "jferris@thoughtbot.com"]
  s.homepage = "https://github.com/thoughtbot/factory_girl"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.rubygems_version = "2.4.8"
  s.summary = "factory_girl provides a framework and DSL for defining and using model instance factories."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.12.0"])
      s.add_development_dependency(%q<cucumber>, ["~> 1.3.15"])
      s.add_development_dependency(%q<timecop>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<aruba>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0.12.8"])
      s.add_development_dependency(%q<bourne>, [">= 0"])
      s.add_development_dependency(%q<appraisal>, ["~> 1.0.0"])
      s.add_development_dependency(%q<activerecord>, [">= 3.0.0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.0.0"])
      s.add_dependency(%q<rspec>, ["~> 2.12.0"])
      s.add_dependency(%q<cucumber>, ["~> 1.3.15"])
      s.add_dependency(%q<timecop>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<aruba>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0.12.8"])
      s.add_dependency(%q<bourne>, [">= 0"])
      s.add_dependency(%q<appraisal>, ["~> 1.0.0"])
      s.add_dependency(%q<activerecord>, [">= 3.0.0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.0.0"])
    s.add_dependency(%q<rspec>, ["~> 2.12.0"])
    s.add_dependency(%q<cucumber>, ["~> 1.3.15"])
    s.add_dependency(%q<timecop>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<aruba>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0.12.8"])
    s.add_dependency(%q<bourne>, [">= 0"])
    s.add_dependency(%q<appraisal>, ["~> 1.0.0"])
    s.add_dependency(%q<activerecord>, [">= 3.0.0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end
