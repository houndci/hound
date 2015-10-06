# -*- encoding: utf-8 -*-
# stub: factory_girl_rails 4.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "factory_girl_rails"
  s.version = "4.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Joe Ferris"]
  s.date = "2014-10-17"
  s.description = "factory_girl_rails provides integration between\n    factory_girl and rails 3 (currently just automatic factory definition\n    loading)"
  s.email = "jferris@thoughtbot.com"
  s.executables = ["setup"]
  s.files = ["bin/setup"]
  s.homepage = "http://github.com/thoughtbot/factory_girl_rails"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "factory_girl_rails provides integration between factory_girl and rails 3"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>, [">= 3.0.0"])
      s.add_runtime_dependency(%q<factory_girl>, ["~> 4.5.0"])
    else
      s.add_dependency(%q<railties>, [">= 3.0.0"])
      s.add_dependency(%q<factory_girl>, ["~> 4.5.0"])
    end
  else
    s.add_dependency(%q<railties>, [">= 3.0.0"])
    s.add_dependency(%q<factory_girl>, ["~> 4.5.0"])
  end
end
