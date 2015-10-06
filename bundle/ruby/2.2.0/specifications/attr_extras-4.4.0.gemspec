# -*- encoding: utf-8 -*-
# stub: attr_extras 4.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "attr_extras"
  s.version = "4.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Henrik Nyh", "Joakim Kolsj\u{f6}", "Victor Arias"]
  s.date = "2015-03-08"
  s.email = ["henrik@nyh.se"]
  s.homepage = "https://github.com/barsoom/attr_extras"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Takes some boilerplate out of Ruby with methods like attr_initialize."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, [">= 5"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<minitest>, [">= 5"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<minitest>, [">= 5"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
