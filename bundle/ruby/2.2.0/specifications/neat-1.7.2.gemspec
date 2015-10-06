# -*- encoding: utf-8 -*-
# stub: neat 1.7.2 ruby lib

Gem::Specification.new do |s|
  s.name = "neat"
  s.version = "1.7.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Joel Oliveira", "Kyle Fiedler", "Reda Lemeden"]
  s.date = "2015-03-13"
  s.description = "Neat is a fluid grid framework built with Bourbon with the aim of being easy\nenough to use out of the box and flexible enough to customize down the road.\n"
  s.email = "design+bourbon@thoughtbot.com"
  s.executables = ["neat"]
  s.files = ["bin/neat"]
  s.homepage = "http://neat.bourbon.io"
  s.licenses = ["MIT"]
  s.rubyforge_project = "neat"
  s.rubygems_version = "2.4.8"
  s.summary = "A lightweight, semantic grid framework built with Bourbon"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sass>, [">= 3.3"])
      s.add_runtime_dependency(%q<bourbon>, [">= 4.0"])
      s.add_development_dependency(%q<aruba>, ["~> 0.5.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<css_parser>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<rb-fsevent>, ["~> 0.9.1"])
      s.add_development_dependency(%q<scss-lint>, ["~> 0.29.0"])
    else
      s.add_dependency(%q<sass>, [">= 3.3"])
      s.add_dependency(%q<bourbon>, [">= 4.0"])
      s.add_dependency(%q<aruba>, ["~> 0.5.0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<css_parser>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rb-fsevent>, ["~> 0.9.1"])
      s.add_dependency(%q<scss-lint>, ["~> 0.29.0"])
    end
  else
    s.add_dependency(%q<sass>, [">= 3.3"])
    s.add_dependency(%q<bourbon>, [">= 4.0"])
    s.add_dependency(%q<aruba>, ["~> 0.5.0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<css_parser>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rb-fsevent>, ["~> 0.9.1"])
    s.add_dependency(%q<scss-lint>, ["~> 0.29.0"])
  end
end
