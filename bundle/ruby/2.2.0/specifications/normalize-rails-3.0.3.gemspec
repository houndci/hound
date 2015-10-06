# -*- encoding: utf-8 -*-
# stub: normalize-rails 3.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "normalize-rails"
  s.version = "3.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Nicolas Gallagher", "Jonathan Neal", "Mark McConachie"]
  s.date = "2015-05-01"
  s.description = "Normalize.css is an alternative to CSS resets"
  s.email = ["mark@markmcconachie.com"]
  s.homepage = "https://github.com/markmcconachie/normalize-rails"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Normalize.css is a customisable CSS file that makes browsers render all elements more consistently and in line with modern standards. We researched the differences between default browser styles in order to precisely target only the styles that need normalizing."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
